import { Injectable, Logger } from '@nestjs/common';
import OpenAI from 'openai';
import { IntegrationsService } from '../integrations/integrations.service';
import { ContentSearchService, SearchResult } from './content-search.service';

interface OpenAIConfig {
  apiKey: string;
  model?: string;
  maxTokens?: number;
  temperature?: number;
}

interface ChatMessage {
  role: 'user' | 'assistant' | 'system';
  content: string;
}

interface ChatResponse {
  text: string;
  cards: SearchResult[];
  suggestions: string[];
}

@Injectable()
export class OpenAIService {
  private readonly logger = new Logger(OpenAIService.name);
  private openai: OpenAI | null = null;

  constructor(
    private integrationsService: IntegrationsService,
    private contentSearchService: ContentSearchService,
  ) {
    this.initializeOpenAI();
  }

  private async initializeOpenAI() {
    try {
      const config = await this.integrationsService.getConfig<OpenAIConfig>('openai');
      if (config?.apiKey) {
        this.openai = new OpenAI({ apiKey: config.apiKey });
        this.logger.log('OpenAI initialized successfully');
      } else {
        this.logger.warn('OpenAI not configured - assistant will not work');
      }
    } catch (error) {
      this.logger.error('Failed to initialize OpenAI', error);
    }
  }

  /**
   * Main chat method - handles user message and returns assistant response
   */
  async chat(
    userMessage: string,
    conversationHistory: ChatMessage[] = [],
    location?: { lat: number; lng: number },
    countryCode?: string,
  ): Promise<ChatResponse> {
    if (!this.openai) {
      await this.initializeOpenAI();
      if (!this.openai) {
        throw new Error('OpenAI not configured');
      }
    }

    const config = await this.integrationsService.getConfig<OpenAIConfig>('openai');

    // Build messages with system prompt
    const messages: ChatMessage[] = [
      {
        role: 'system',
        content: this.getSystemPrompt(countryCode),
      },
      ...conversationHistory,
      {
        role: 'user',
        content: userMessage,
      },
    ];

    try {
      // Call OpenAI with function calling
      const response = await this.openai.chat.completions.create({
        model: config?.model || 'gpt-4-turbo-preview',
        messages: messages as any,
        functions: this.getFunctions(),
        function_call: 'auto',
        temperature: config?.temperature || 0.7,
        max_tokens: config?.maxTokens || 1000,
      });

      const choice = response.choices[0];
      let cards: SearchResult[] = [];
      let assistantText = '';

      // Check if function was called
      if (choice.message.function_call) {
        const functionName = choice.message.function_call.name;
        const functionArgs = JSON.parse(choice.message.function_call.arguments);

        // Execute the function
        if (functionName === 'searchContent') {
          cards = await this.contentSearchService.searchContent({
            query: functionArgs.query,
            types: functionArgs.types,
            limit: functionArgs.limit || 5,
            lat: location?.lat,
            lng: location?.lng,
          });

          // Call OpenAI again to generate natural response with results
          const followUpMessages = [
            ...messages,
            choice.message as any,
            {
              role: 'function' as const,
              name: functionName,
              content: JSON.stringify({ results: cards }),
            },
          ];

          const followUpResponse = await this.openai.chat.completions.create({
            model: config?.model || 'gpt-4-turbo-preview',
            messages: followUpMessages as any,
            temperature: 0.7,
            max_tokens: 500,
          });

          assistantText = this.cleanResponseText(followUpResponse.choices[0].message.content || '');
        } else if (functionName === 'getCategories') {
          const categories = await this.contentSearchService.getCategories();
          
          const followUpMessages = [
            ...messages,
            choice.message as any,
            {
              role: 'function' as const,
              name: functionName,
              content: JSON.stringify({ categories }),
            },
          ];

          const followUpResponse = await this.openai.chat.completions.create({
            model: config?.model || 'gpt-4-turbo-preview',
            messages: followUpMessages as any,
            temperature: 0.7,
            max_tokens: 500,
          });

          assistantText = this.cleanResponseText(followUpResponse.choices[0].message.content || '');
        }
      } else {
        // No function call - just return the text response
        assistantText = this.cleanResponseText(choice.message.content || '');
      }

      // Generate suggestions
      const suggestions = this.generateSuggestions(userMessage, cards);

      return {
        text: assistantText,
        cards,
        suggestions,
      };
    } catch (error) {
      this.logger.error('OpenAI chat error', error);
      throw error;
    }
  }

  /**
   * Get country name from ISO code
   */
  private getCountryName(code?: string): string {
    if (!code) return 'Rwanda';
    
    const countryMap: Record<string, string> = {
      'RW': 'Rwanda',
      'KE': 'Kenya',
      'UG': 'Uganda',
      'TZ': 'Tanzania',
    };
    
    return countryMap[code.toUpperCase()] || 'Rwanda';
  }

  /**
   * Clean response text by removing image markdown syntax
   * Images are shown as cards, not in the text
   */
  private cleanResponseText(text: string): string {
    // Remove image markdown: ![alt](url)
    let cleaned = text.replace(/!\[([^\]]*)\]\([^\)]+\)/g, '');
    
    // Remove multiple consecutive newlines
    cleaned = cleaned.replace(/\n{3,}/g, '\n\n');
    
    // Trim whitespace
    cleaned = cleaned.trim();
    
    return cleaned;
  }

  private getSystemPrompt(countryCode?: string): string {
    const countryName = this.getCountryName(countryCode);
    return `You are Zoea, a friendly and knowledgeable AI assistant for Zoea Africa - a travel and discovery app for ${countryName}.

Your role:
- Help users discover places, tours, products, and services in Rwanda
- Be friendly, warm, and conversational (like a local friend)
- Keep responses SHORT and natural (2-3 sentences max)
- Ask ONE follow-up question at a time to refine searches
- Never mention events (they are excluded from our system)
- Use the searchContent function when users ask about places, tours, restaurants, hotels, products, or services
- Provide helpful Rwanda travel information when no internal matches exist

Formatting rules:
- You can use **bold** for emphasis on important words
- Use numbered lists (1. 2. 3.) when listing items
- NEVER include images or image links in your response (images are shown automatically as cards)
- NEVER use markdown image syntax like ![text](url)
- Keep formatting simple and clean

Tone:
- Friendly and warm, but not overly casual
- Professional but approachable
- Short responses that feel human
- One question at a time

Example responses:
User: "Find 5 restaurants in Kigali"
You: "Here are some great places for lunch in Kigali:

1. **Neza Haven Kigali** - Not just an accommodation but also known for its delightful dining options.

2. **Taste Food Restaurant** - A go-to for delicious meals in a cozy setting.

Would you like more options or details on these?"

User: "What's the weather like in Rwanda?"
You: "Rwanda has a pleasant climate year-round, with temperatures around 20-25°C. The dry seasons (June-September and December-February) are ideal for visiting. Planning a trip?"

Remember: Be helpful, be brief, be human. Never include image URLs in your text.`;
  }

  private getFunctions() {
    return [
      {
        name: 'searchContent',
        description: 'Search for places, tours, products, or services in Rwanda. Use this when users ask about restaurants, hotels, attractions, tours, shopping, or services.',
        parameters: {
          type: 'object',
          properties: {
            query: {
              type: 'string',
              description: 'The search query (e.g., "restaurants", "hotels in Kigali", "tours")',
            },
            types: {
              type: 'array',
              items: {
                type: 'string',
                enum: ['listing', 'tour', 'product', 'service'],
              },
              description: 'Types of content to search. listing=places/restaurants/hotels, tour=tours/experiences, product=products to buy, service=services',
            },
            limit: {
              type: 'number',
              description: 'Number of results to return (default: 5, max: 10)',
            },
          },
          required: ['query'],
        },
      },
      {
        name: 'getCategories',
        description: 'Get all available categories of places and services. Use this to understand what types of content exist in the app.',
        parameters: {
          type: 'object',
          properties: {},
        },
      },
    ];
  }

  private generateSuggestions(userMessage: string, cards: SearchResult[]): string[] {
    const suggestions: string[] = [];

    if (cards.length > 0) {
      // Suggestions based on results
      suggestions.push('Show me more options');
      suggestions.push('Filter by price');
      suggestions.push('What\'s nearby?');
    } else {
      // Suggestions when no results
      suggestions.push('Show me popular places');
      suggestions.push('What can I do in Kigali?');
      suggestions.push('Find tours');
    }

    return suggestions.slice(0, 3);
  }
}

