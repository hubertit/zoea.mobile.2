import { Controller, Get, Post, Param, Query, Body, UseGuards, Request } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth, ApiQuery, ApiParam, ApiResponse, ApiBody } from '@nestjs/swagger';
import { EventsService } from './events.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { CreateEventCommentDto } from './dto/event.dto';

@ApiTags('Events')
@Controller('events')
export class EventsController {
  constructor(private eventsService: EventsService) {}

  @Get()
  @ApiOperation({ 
    summary: 'Get all events (explore-events compatible)',
    description: 'Retrieves paginated events with optional filters. Compatible with SINC API format. Events are fetched from the SINC API and cached locally. Supports filtering by location, category, date range, and search query.'
  })
  @ApiQuery({ name: 'page', required: false, type: Number, example: 1, description: 'Page number (default: 1)' })
  @ApiQuery({ name: 'limit', required: false, type: Number, example: 25, description: 'Items per page (default: 25)' })
  @ApiQuery({ name: 'status', required: false, enum: ['draft', 'published', 'cancelled'], description: 'Filter by event status (default: published)', example: 'published' })
  @ApiQuery({ name: 'cityId', required: false, type: String, description: 'Filter by city UUID', example: '123e4567-e89b-12d3-a456-426614174000' })
  @ApiQuery({ name: 'countryId', required: false, type: String, description: 'Filter by country UUID', example: '123e4567-e89b-12d3-a456-426614174000' })
  @ApiQuery({ name: 'category', required: false, type: String, description: 'Event context/category ID', example: '123e4567-e89b-12d3-a456-426614174000' })
  @ApiQuery({ name: 'startDate', required: false, type: String, description: 'Filter events starting from this date', example: '2024-12-31T00:00:00Z' })
  @ApiQuery({ name: 'endDate', required: false, type: String, description: 'Filter events ending before this date', example: '2025-01-31T23:59:59Z' })
  @ApiQuery({ name: 'search', required: false, type: String, description: 'Search in event name and description', example: 'music festival' })
  @ApiQuery({ name: 'sort', required: false, enum: ['date_asc', 'date_desc', 'name_asc', 'name_desc'], description: 'Sort order', example: 'date_asc' })
  @ApiResponse({ 
    status: 200, 
    description: 'Events retrieved successfully',
    schema: {
      type: 'object',
      properties: {
        data: { type: 'array', items: { type: 'object' }, description: 'List of events' },
        total: { type: 'number', example: 100 },
        page: { type: 'number', example: 1 },
        limit: { type: 'number', example: 25 }
      }
    }
  })
  async findAll(
    @Query('page') page?: string,
    @Query('limit') limit?: string,
    @Query('status') status?: string,
    @Query('cityId') cityId?: string,
    @Query('countryId') countryId?: string,
    @Query('category') category?: string,
    @Query('startDate') startDate?: string,
    @Query('endDate') endDate?: string,
    @Query('search') search?: string,
  ) {
    return this.eventsService.findAll({
      page: page ? +page : 1,
      limit: limit ? +limit : 25,
      status: status || 'published',
      cityId,
      countryId,
      contextId: category,
      startDate: startDate ? new Date(startDate) : undefined,
      endDate: endDate ? new Date(endDate) : undefined,
      search,
    });
  }

  @Get('explore-events')
  @ApiOperation({ 
    summary: 'Get events for explore (SINC API compatible)',
    description: 'SINC API compatible endpoint for retrieving events. Returns only published events starting from today. Used by the mobile app explore screen.'
  })
  @ApiQuery({ name: 'page', required: false, type: Number, example: 1, description: 'Page number (default: 1)' })
  @ApiQuery({ name: 'limit', required: false, type: Number, example: 25, description: 'Items per page (default: 25)' })
  @ApiQuery({ name: 'category', required: false, type: String, description: 'Event context/category ID' })
  @ApiQuery({ name: 'location', required: false, type: String, description: 'Location filter' })
  @ApiQuery({ name: 'startDate', required: false, type: String, description: 'Filter events starting from this date (default: today)' })
  @ApiQuery({ name: 'endDate', required: false, type: String, description: 'Filter events ending before this date' })
  @ApiQuery({ name: 'search', required: false, type: String, description: 'Search query' })
  @ApiQuery({ name: 'sort', required: false, enum: ['date_asc', 'date_desc', 'name_asc', 'name_desc'], description: 'Sort order' })
  @ApiResponse({ 
    status: 200, 
    description: 'Events retrieved successfully (SINC format)',
    schema: {
      type: 'object',
      properties: {
        events: { type: 'array', items: { type: 'object' } },
        pagination: { type: 'object' }
      }
    }
  })
  async exploreEvents(
    @Query('page') page?: string,
    @Query('limit') limit?: string,
    @Query('category') category?: string,
    @Query('location') location?: string,
    @Query('startDate') startDate?: string,
    @Query('endDate') endDate?: string,
    @Query('search') search?: string,
    @Query('sort') sort?: string,
  ) {
    return this.eventsService.findAll({
      page: page ? +page : 1,
      limit: limit ? +limit : 25,
      status: 'published',
      contextId: category,
      startDate: startDate ? new Date(startDate) : new Date(),
      endDate: endDate ? new Date(endDate) : undefined,
      search,
    });
  }

  @Get('upcoming')
  @ApiOperation({ 
    summary: 'Get upcoming events',
    description: 'Retrieves events that are scheduled to occur in the future, sorted by start date (earliest first). Useful for displaying "Upcoming Events" sections.'
  })
  @ApiQuery({ name: 'limit', required: false, type: Number, example: 10, description: 'Maximum number of events to return (default: 10)' })
  @ApiQuery({ name: 'cityId', required: false, type: String, description: 'Filter by city UUID', example: '123e4567-e89b-12d3-a456-426614174000' })
  @ApiResponse({ 
    status: 200, 
    description: 'Upcoming events retrieved successfully',
    schema: {
      type: 'array',
      items: { type: 'object' }
    }
  })
  async getUpcoming(@Query('limit') limit?: string, @Query('cityId') cityId?: string) {
    return this.eventsService.getUpcoming(limit ? +limit : 10, cityId);
  }

  @Get('this-week')
  @ApiOperation({ 
    summary: 'Get events happening this week',
    description: 'Retrieves events scheduled for the current week (Monday to Sunday). Useful for displaying "This Week" sections on the explore screen.'
  })
  @ApiQuery({ name: 'limit', required: false, type: Number, example: 25, description: 'Maximum number of events to return (default: 25)' })
  @ApiQuery({ name: 'cityId', required: false, type: String, description: 'Filter by city UUID', example: '123e4567-e89b-12d3-a456-426614174000' })
  @ApiResponse({ 
    status: 200, 
    description: 'This week\'s events retrieved successfully',
    schema: {
      type: 'array',
      items: { type: 'object' }
    }
  })
  async getThisWeek(@Query('limit') limit?: string, @Query('cityId') cityId?: string) {
    return this.eventsService.getThisWeek(limit ? +limit : 25, cityId);
  }

  @Get('slug/:slug')
  @ApiOperation({ 
    summary: 'Get event by slug',
    description: 'Retrieves a single event by its URL-friendly slug. Useful for SEO-friendly URLs.'
  })
  @ApiParam({ name: 'slug', type: String, description: 'Event slug', example: 'rwanda-culture-festival-2024' })
  @ApiResponse({ 
    status: 200, 
    description: 'Event retrieved successfully',
    schema: { type: 'object' }
  })
  @ApiResponse({ status: 404, description: 'Event not found' })
  async findBySlug(@Param('slug') slug: string) {
    return this.eventsService.findBySlug(slug);
  }

  @Get(':id')
  @ApiOperation({ 
    summary: 'Get event by ID',
    description: 'Retrieves detailed information about a specific event including description, images, location, dates, and ticket information.'
  })
  @ApiParam({ name: 'id', type: String, description: 'Event UUID', example: '123e4567-e89b-12d3-a456-426614174000' })
  @ApiResponse({ 
    status: 200, 
    description: 'Event retrieved successfully',
    schema: { type: 'object' }
  })
  @ApiResponse({ status: 404, description: 'Event not found' })
  async findOne(@Param('id') id: string) {
    return this.eventsService.findOne(id);
  }

  @Post(':id/like')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ 
    summary: 'Like/unlike an event',
    description: 'Toggles the like status of an event for the authenticated user. If the event is already liked, it will be unliked, and vice versa.'
  })
  @ApiParam({ name: 'id', type: String, description: 'Event UUID', example: '123e4567-e89b-12d3-a456-426614174000' })
  @ApiResponse({ 
    status: 200, 
    description: 'Like status toggled successfully',
    schema: {
      type: 'object',
      properties: {
        liked: { type: 'boolean', example: true, description: 'Current like status after toggle' },
        likeCount: { type: 'number', example: 42, description: 'Total number of likes' }
      }
    }
  })
  @ApiResponse({ status: 401, description: 'Unauthorized - Invalid or missing token' })
  @ApiResponse({ status: 404, description: 'Event not found' })
  async likeEvent(@Param('id') id: string, @Request() req) {
    return this.eventsService.likeEvent(id, req.user.id);
  }

  @Get(':id/comments')
  @ApiOperation({ 
    summary: 'Get event comments',
    description: 'Retrieves paginated comments for an event. Comments are sorted by creation date (newest first). Supports nested replies via parentId.'
  })
  @ApiParam({ name: 'id', type: String, description: 'Event UUID', example: '123e4567-e89b-12d3-a456-426614174000' })
  @ApiQuery({ name: 'page', required: false, type: Number, example: 1, description: 'Page number (default: 1)' })
  @ApiQuery({ name: 'limit', required: false, type: Number, example: 20, description: 'Items per page (default: 20)' })
  @ApiResponse({ 
    status: 200, 
    description: 'Comments retrieved successfully',
    schema: {
      type: 'object',
      properties: {
        data: { type: 'array', items: { type: 'object' } },
        total: { type: 'number', example: 50 },
        page: { type: 'number', example: 1 },
        limit: { type: 'number', example: 20 }
      }
    }
  })
  @ApiResponse({ status: 404, description: 'Event not found' })
  async getComments(
    @Param('id') id: string,
    @Query('page') page?: string,
    @Query('limit') limit?: string,
  ) {
    return this.eventsService.getComments(id, page ? +page : 1, limit ? +limit : 20);
  }

  @Post(':id/comments')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ 
    summary: 'Add a comment to an event',
    description: 'Creates a new comment on an event. Can be a top-level comment or a reply to another comment (via parentId). Comments are subject to moderation.'
  })
  @ApiParam({ name: 'id', type: String, description: 'Event UUID', example: '123e4567-e89b-12d3-a456-426614174000' })
  @ApiBody({ type: CreateEventCommentDto })
  @ApiResponse({ 
    status: 201, 
    description: 'Comment created successfully',
    schema: {
      type: 'object',
      properties: {
        id: { type: 'string' },
        content: { type: 'string', example: 'Great event!' },
        userId: { type: 'string' },
        eventId: { type: 'string' },
        parentId: { type: 'string', nullable: true },
        createdAt: { type: 'string' }
      }
    }
  })
  @ApiResponse({ status: 400, description: 'Bad request - Invalid comment content' })
  @ApiResponse({ status: 401, description: 'Unauthorized - Invalid or missing token' })
  @ApiResponse({ status: 404, description: 'Event not found' })
  async addComment(
    @Param('id') id: string,
    @Request() req,
    @Body() data: CreateEventCommentDto,
  ) {
    return this.eventsService.addComment(id, req.user.id, data.content, data.parentId);
  }
}
