import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';
import { OpenAIService } from './openai.service';
import { ChatDto } from './dto/chat.dto';

@Injectable()
export class AssistantService {
  constructor(
    private prisma: PrismaService,
    private openaiService: OpenAIService,
  ) {}

  /**
   * Create a new conversation
   */
  async createConversation(userId: string, firstMessage?: string) {
    const title = firstMessage 
      ? this.generateTitle(firstMessage)
      : 'New Conversation';

    return this.prisma.assistantConversation.create({
      data: {
        userId,
        title,
      },
    });
  }

  /**
   * Get user's conversations (last 90 days)
   */
  async getConversations(userId: string) {
    const ninetyDaysAgo = new Date();
    ninetyDaysAgo.setDate(ninetyDaysAgo.getDate() - 90);

    return this.prisma.assistantConversation.findMany({
      where: {
        userId,
        createdAt: { gte: ninetyDaysAgo },
      },
      orderBy: { lastMessageAt: 'desc' },
      select: {
        id: true,
        title: true,
        createdAt: true,
        lastMessageAt: true,
      },
    });
  }

  /**
   * Get conversation messages
   */
  async getMessages(conversationId: string, userId: string) {
    // Verify ownership
    const conversation = await this.prisma.assistantConversation.findFirst({
      where: { id: conversationId, userId },
    });

    if (!conversation) {
      throw new NotFoundException('Conversation not found');
    }

    return this.prisma.assistantMessage.findMany({
      where: { conversationId },
      include: {
        cards: true,
      },
      orderBy: { createdAt: 'asc' },
    });
  }

  /**
   * Send a chat message and get response
   */
  async chat(userId: string, chatDto: ChatDto) {
    const { conversationId, message, location } = chatDto;

    // Get or create conversation
    let conversation;
    if (conversationId) {
      conversation = await this.prisma.assistantConversation.findFirst({
        where: { id: conversationId, userId },
      });
      if (!conversation) {
        throw new NotFoundException('Conversation not found');
      }
    } else {
      conversation = await this.createConversation(userId, message);
    }

    // Get conversation history
    const history = await this.prisma.assistantMessage.findMany({
      where: { conversationId: conversation.id },
      orderBy: { createdAt: 'asc' },
      take: 10, // Last 10 messages for context
    });

    const conversationHistory = history.map(msg => ({
      role: msg.role as 'user' | 'assistant',
      content: msg.text,
    }));

    // Save user message
    await this.prisma.assistantMessage.create({
      data: {
        conversationId: conversation.id,
        role: 'user',
        text: message,
      },
    });

    // Get AI response
    const response = await this.openaiService.chat(
      message,
      conversationHistory,
      location,
    );

    // Save assistant message
    const assistantMessage = await this.prisma.assistantMessage.create({
      data: {
        conversationId: conversation.id,
        role: 'assistant',
        text: response.text,
      },
    });

    // Save cards
    if (response.cards.length > 0) {
      await this.prisma.assistantMessageCard.createMany({
        data: response.cards.map(card => ({
          messageId: assistantMessage.id,
          type: card.type,
          entityId: card.id,
          title: card.title,
          subtitle: card.subtitle || '',
          imageUrl: card.imageUrl,
          route: card.route,
          params: card.params,
        })),
      });
    }

    // Update conversation timestamp
    await this.prisma.assistantConversation.update({
      where: { id: conversation.id },
      data: { lastMessageAt: new Date() },
    });

    // Return response with cards
    const cards = await this.prisma.assistantMessageCard.findMany({
      where: { messageId: assistantMessage.id },
    });

    return {
      conversationId: conversation.id,
      assistantMessage: {
        id: assistantMessage.id,
        text: assistantMessage.text,
        createdAt: assistantMessage.createdAt,
      },
      cards: cards.map(card => ({
        type: card.type,
        id: card.entityId,
        title: card.title,
        subtitle: card.subtitle,
        imageUrl: card.imageUrl,
        route: card.route,
        params: card.params,
      })),
      suggestions: response.suggestions,
      title: conversationHistory.length === 0 ? conversation.title : undefined,
    };
  }

  /**
   * Delete a conversation
   */
  async deleteConversation(conversationId: string, userId: string) {
    const conversation = await this.prisma.assistantConversation.findFirst({
      where: { id: conversationId, userId },
    });

    if (!conversation) {
      throw new NotFoundException('Conversation not found');
    }

    await this.prisma.assistantConversation.delete({
      where: { id: conversationId },
    });

    return { success: true, message: 'Conversation deleted' };
  }

  /**
   * Generate conversation title from first message
   */
  private generateTitle(message: string): string {
    // Simple title generation - take first 50 chars
    const title = message.substring(0, 50);
    return title.length < message.length ? `${title}...` : title;
  }

  /**
   * Clean up old conversations (90+ days) - called by cron
   */
  async cleanupOldConversations() {
    const ninetyDaysAgo = new Date();
    ninetyDaysAgo.setDate(ninetyDaysAgo.getDate() - 90);

    const result = await this.prisma.assistantConversation.deleteMany({
      where: {
        createdAt: { lt: ninetyDaysAgo },
      },
    });

    return { deleted: result.count };
  }
}

