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
    summary: 'Send a chat message',
    description: 'Send a message to the AI assistant and get a response with optional clickable cards'
  })
  @ApiResponse({ 
    status: 200, 
    description: 'Chat response with assistant message and cards'
  })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  async chat(@Request() req, @Body() chatDto: ChatDto) {
    return this.assistantService.chat(req.user.id, chatDto);
  }

  @Get('conversations')
  @ApiOperation({ 
    summary: 'Get user conversations',
    description: 'Retrieve all conversations for the authenticated user (last 90 days)'
  })
  @ApiResponse({ 
    status: 200, 
    description: 'Conversations retrieved successfully'
  })
  async getConversations(@Request() req) {
    return this.assistantService.getConversations(req.user.id);
  }

  @Get('conversations/:id/messages')
  @ApiOperation({ 
    summary: 'Get conversation messages',
    description: 'Retrieve all messages for a specific conversation'
  })
  @ApiParam({ name: 'id', description: 'Conversation UUID' })
  @ApiResponse({ 
    status: 200, 
    description: 'Messages retrieved successfully'
  })
  @ApiResponse({ status: 404, description: 'Conversation not found' })
  async getMessages(@Request() req, @Param('id') conversationId: string) {
    return this.assistantService.getMessages(conversationId, req.user.id);
  }

  @Delete('conversations/:id')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ 
    summary: 'Delete a conversation',
    description: 'Delete a conversation and all its messages'
  })
  @ApiParam({ name: 'id', description: 'Conversation UUID' })
  @ApiResponse({ 
    status: 200, 
    description: 'Conversation deleted successfully'
  })
  @ApiResponse({ status: 404, description: 'Conversation not found' })
  async deleteConversation(@Request() req, @Param('id') conversationId: string) {
    return this.assistantService.deleteConversation(conversationId, req.user.id);
  }
}

