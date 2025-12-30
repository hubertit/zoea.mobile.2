import { Controller, Post, Body, UseGuards, Request, HttpCode, HttpStatus } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth, ApiBody, ApiResponse } from '@nestjs/swagger';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { AnalyticsService } from './analytics.service';
import { BatchAnalyticsEventsDto, RecordContentViewDto } from './dto/analytics.dto';

@ApiTags('Analytics')
@Controller('analytics')
export class AnalyticsController {
  constructor(private analyticsService: AnalyticsService) {}

  @Post('events')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ 
    summary: 'Receive batched analytics events from mobile app',
    description: 'Processes multiple analytics events in a single request. Tracks views, searches, and interactions. Events are stored in content_views and search_analytics tables. View counts on listings/events are automatically incremented. User demographics (age range, gender, interests) are automatically included from the user profile.'
  })
  @ApiBody({ type: BatchAnalyticsEventsDto })
  @ApiResponse({ 
    status: 200, 
    description: 'Events processed successfully',
    schema: {
      type: 'object',
      properties: {
        processed: { type: 'number', example: 5, description: 'Number of events successfully processed' },
        errors: { type: 'number', example: 0, description: 'Number of events that failed to process' },
        details: { 
          type: 'array', 
          items: { 
            type: 'object',
            properties: {
              type: { type: 'string', example: 'listing_view' },
              error: { type: 'string', example: 'listingId is required' }
            }
          },
          description: 'Details of any errors (only present if errors > 0)'
        }
      }
    }
  })
  @ApiResponse({ status: 400, description: 'Bad request - Invalid event data' })
  @ApiResponse({ status: 401, description: 'Unauthorized - Invalid or missing token' })
  async receiveBatchEvents(@Request() req, @Body() dto: BatchAnalyticsEventsDto) {
    return this.analyticsService.processBatchEvents(req.user.id, dto, req);
  }

  @Post('content-view')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @HttpCode(HttpStatus.CREATED)
  @ApiOperation({ 
    summary: 'Record a content view',
    description: 'Records a view of a listing or event with detailed tracking information. Automatically includes user demographics (age range, gender, interests) from the user profile. Also increments the viewCount on the listing/event. Use this endpoint for server-side tracking or when you need to record additional metadata like scroll depth or interaction data.'
  })
  @ApiBody({ type: RecordContentViewDto })
  @ApiResponse({ 
    status: 201, 
    description: 'Content view recorded successfully',
    schema: {
      type: 'object',
      properties: {
        message: { type: 'string', example: 'Content view recorded successfully' }
      }
    }
  })
  @ApiResponse({ status: 400, description: 'Bad request - Invalid content type or ID' })
  @ApiResponse({ status: 401, description: 'Unauthorized - Invalid or missing token' })
  @ApiResponse({ status: 404, description: 'Content not found' })
  async recordContentView(@Request() req, @Body() dto: RecordContentViewDto) {
    await this.analyticsService.recordContentView(req.user.id, dto, req);
    return { message: 'Content view recorded successfully' };
  }
}

