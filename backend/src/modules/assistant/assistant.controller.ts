import { 
  Controller, 
  Get, 
  Post, 
  Delete, 
  Body, 
  Param, 
  UseGuards,
  Request,
  HttpCode,
  HttpStatus
} from '@nestjs/common';
import { 
  ApiTags, 
  ApiOperation, 
  ApiBearerAuth, 
  ApiResponse,
  ApiParam
} from '@nestjs/swagger';
import { AssistantService } from './assistant.service';
import { ChatDto } from './dto/chat.dto';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';

@ApiTags('Assistant (Ask Zoea)')
@Controller('assistant')
@UseGuards(JwtAuthGuard)
@ApiBearerAuth()
export class AssistantController {
  constructor(private assistantService: AssistantService) {}

  @Post('chat')
  @ApiOperation({ 
    summary: 'Send a chat message to AI assistant',
    description: 'Send a message to the Zoea AI assistant and receive an intelligent response. The assistant can help with travel recommendations, booking inquiries, local information, and more. Responses may include clickable cards for quick actions like viewing listings, booking tours, or exploring events. Requires authentication.'
  })
  @ApiResponse({ 
    status: 200, 
    description: 'Chat response received successfully',
    schema: {
      type: 'object',
      properties: {
        message: { type: 'string', example: 'I can help you find great hotels in Kigali...' },
        cards: {
          type: 'array',
          items: {
            type: 'object',
            properties: {
              type: { type: 'string', enum: ['listing', 'event', 'tour'], example: 'listing' },
              id: { type: 'string', example: '123e4567-e89b-12d3-a456-426614174000' },
              title: { type: 'string', example: 'Four Points by Sheraton Kigali' },
              image: { type: 'string', example: 'https://example.com/image.jpg' }
            }
          }
        },
        conversationId: { type: 'string', example: '123e4567-e89b-12d3-a456-426614174000' }
      }
    }
  })
  @ApiResponse({ status: 401, description: 'Unauthorized - Invalid or missing token' })
  @ApiResponse({ status: 400, description: 'Bad request - Invalid message format' })
  async chat(@Request() req, @Body() chatDto: ChatDto) {
    return this.assistantService.chat(req.user.id, chatDto);
  }

  @Get('conversations')
  @ApiOperation({ 
    summary: 'Get user conversations',
    description: 'Retrieve all conversation history for the authenticated user. Returns conversations from the last 90 days, sorted by most recent first. Each conversation includes metadata like creation date and message count.'
  })
  @ApiResponse({ 
    status: 200, 
    description: 'Conversations retrieved successfully',
    schema: {
      type: 'array',
      items: {
        type: 'object',
        properties: {
          id: { type: 'string', example: '123e4567-e89b-12d3-a456-426614174000' },
          createdAt: { type: 'string', format: 'date-time' },
          updatedAt: { type: 'string', format: 'date-time' },
          messageCount: { type: 'number', example: 5 }
        }
      }
    }
  })
  @ApiResponse({ status: 401, description: 'Unauthorized - Invalid or missing token' })
  async getConversations(@Request() req) {
    return this.assistantService.getConversations(req.user.id);
  }

  @Get('conversations/:id/messages')
  @ApiOperation({ 
    summary: 'Get conversation messages',
    description: 'Retrieve all messages for a specific conversation. Returns both user messages and assistant responses in chronological order. Useful for displaying conversation history or resuming a previous chat.'
  })
  @ApiParam({ name: 'id', type: String, description: 'Conversation UUID', example: '123e4567-e89b-12d3-a456-426614174000' })
  @ApiResponse({ 
    status: 200, 
    description: 'Messages retrieved successfully',
    schema: {
      type: 'array',
      items: {
        type: 'object',
        properties: {
          id: { type: 'string' },
          role: { type: 'string', enum: ['user', 'assistant'], example: 'user' },
          content: { type: 'string', example: 'What are the best hotels in Kigali?' },
          createdAt: { type: 'string', format: 'date-time' }
        }
      }
    }
  })
  @ApiResponse({ status: 401, description: 'Unauthorized - Invalid or missing token' })
  @ApiResponse({ status: 403, description: 'Forbidden - Not authorized to view this conversation' })
  @ApiResponse({ status: 404, description: 'Conversation not found' })
  async getMessages(@Request() req, @Param('id') conversationId: string) {
    return this.assistantService.getMessages(conversationId, req.user.id);
  }

  @Delete('conversations/:id')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ 
    summary: 'Delete a conversation',
    description: 'Permanently delete a conversation and all its messages. This action cannot be undone. Only the conversation owner can delete their own conversations.'
  })
  @ApiParam({ name: 'id', type: String, description: 'Conversation UUID', example: '123e4567-e89b-12d3-a456-426614174000' })
  @ApiResponse({ 
    status: 200, 
    description: 'Conversation deleted successfully',
    schema: {
      type: 'object',
      properties: {
        success: { type: 'boolean', example: true },
        message: { type: 'string', example: 'Conversation deleted successfully' }
      }
    }
  })
  @ApiResponse({ status: 401, description: 'Unauthorized - Invalid or missing token' })
  @ApiResponse({ status: 403, description: 'Forbidden - Not authorized to delete this conversation' })
  @ApiResponse({ status: 404, description: 'Conversation not found' })
  async deleteConversation(@Request() req, @Param('id') conversationId: string) {
    return this.assistantService.deleteConversation(conversationId, req.user.id);
  }
}

