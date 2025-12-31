import { Controller, Post, Get, Body, UseGuards, Request, HttpCode, HttpStatus, Query } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth, ApiBody, ApiResponse, ApiQuery } from '@nestjs/swagger';
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

  @Get('my-content-views')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ 
    summary: 'Get my content views (places visited)',
    description: 'Retrieves all listings and events viewed by the authenticated user. Returns paginated results with listing/event details. Useful for showing "Places Visited" in the user profile. Results are ordered by most recent view first.'
  })
  @ApiQuery({ name: 'page', required: false, type: Number, example: 1, description: 'Page number (default: 1)' })
  @ApiQuery({ name: 'limit', required: false, type: Number, example: 20, description: 'Items per page (default: 20)' })
  @ApiQuery({ name: 'contentType', required: false, enum: ['listing', 'event'], description: 'Filter by content type (default: all)' })
  @ApiResponse({ 
    status: 200, 
    description: 'Content views retrieved successfully',
    schema: {
      type: 'object',
      properties: {
        data: {
          type: 'array',
          items: {
            type: 'object',
            properties: {
              id: { type: 'string', example: '123e4567-e89b-12d3-a456-426614174000' },
              contentType: { type: 'string', enum: ['listing', 'event'], example: 'listing' },
              contentId: { type: 'string', example: '123e4567-e89b-12d3-a456-426614174000' },
              viewedAt: { type: 'string', format: 'date-time', example: '2024-12-30T16:00:00Z' },
              content: {
                type: 'object',
                description: 'Full listing or event details',
                properties: {
                  id: { type: 'string' },
                  name: { type: 'string', example: 'Grand Hotel Kigali' },
                  images: { type: 'array', items: { type: 'object' } },
                  location: { type: 'object' },
                  rating: { type: 'number', example: 4.5 },
                  reviewCount: { type: 'number', example: 120 }
                }
              }
            }
          }
        },
        meta: {
          type: 'object',
          properties: {
            total: { type: 'number', example: 45 },
            page: { type: 'number', example: 1 },
            limit: { type: 'number', example: 20 },
            totalPages: { type: 'number', example: 3 }
          }
        }
      }
    }
  })
  @ApiResponse({ status: 401, description: 'Unauthorized - Invalid or missing token' })
  async getMyContentViews(
    @Request() req,
    @Query('page') page?: string,
    @Query('limit') limit?: string,
    @Query('contentType') contentType?: 'listing' | 'event',
  ) {
    return this.analyticsService.getMyContentViews(
      req.user.id,
      {
        page: page ? parseInt(page, 10) : 1,
        limit: limit ? parseInt(limit, 10) : 20,
        contentType,
      },
    );
  }
}

