import { Controller, Get, Post, Put, Delete, Param, Query, Body, UseGuards, Request } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth, ApiQuery, ApiParam, ApiResponse, ApiBody } from '@nestjs/swagger';
import { ReviewsService } from './reviews.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { CreateReviewDto, UpdateReviewDto, MarkHelpfulDto, ReviewQueryDto } from './dto/review.dto';

@ApiTags('Reviews')
@Controller('reviews')
export class ReviewsController {
  constructor(private reviewsService: ReviewsService) {}

  @Get()
  @ApiOperation({ 
    summary: 'Get reviews with filters',
    description: 'Retrieves paginated reviews with comprehensive filtering options. Supports filtering by listing, event, tour, user, and moderation status. Only approved reviews are returned by default.'
  })
  @ApiQuery({ name: 'page', required: false, type: Number, example: 1, description: 'Page number (default: 1)' })
  @ApiQuery({ name: 'limit', required: false, type: Number, example: 20, description: 'Items per page (default: 20)' })
  @ApiQuery({ name: 'listingId', required: false, type: String, description: 'Filter reviews for a specific listing', example: '123e4567-e89b-12d3-a456-426614174000' })
  @ApiQuery({ name: 'eventId', required: false, type: String, description: 'Filter reviews for a specific event', example: '123e4567-e89b-12d3-a456-426614174000' })
  @ApiQuery({ name: 'tourId', required: false, type: String, description: 'Filter reviews for a specific tour', example: '123e4567-e89b-12d3-a456-426614174000' })
  @ApiQuery({ name: 'userId', required: false, type: String, description: 'Filter reviews by a specific user', example: '123e4567-e89b-12d3-a456-426614174000' })
  @ApiQuery({ name: 'status', required: false, enum: ['pending', 'approved', 'rejected'], description: 'Filter by moderation status (default: approved)', example: 'approved' })
  @ApiResponse({ 
    status: 200, 
    description: 'Reviews retrieved successfully',
    schema: {
      type: 'object',
      properties: {
        data: { type: 'array', items: { type: 'object' } },
        total: { type: 'number', example: 100 },
        page: { type: 'number', example: 1 },
        limit: { type: 'number', example: 20 }
      }
    }
  })
  async findAll(@Query() query: ReviewQueryDto) {
    return this.reviewsService.findAll({
      page: query.page ? +query.page : 1,
      limit: query.limit ? +query.limit : 20,
      listingId: query.listingId,
      eventId: query.eventId,
      tourId: query.tourId,
      userId: query.userId,
      status: query.status || 'approved',
    });
  }

  @Get('my')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ 
    summary: 'Get my reviews',
    description: 'Retrieves all reviews created by the authenticated user. Useful for displaying user\'s review history and allowing users to manage their reviews.'
  })
  @ApiQuery({ name: 'page', required: false, type: Number, example: 1, description: 'Page number (default: 1)' })
  @ApiQuery({ name: 'limit', required: false, type: Number, example: 20, description: 'Items per page (default: 20)' })
  @ApiResponse({ 
    status: 200, 
    description: 'User reviews retrieved successfully',
    schema: {
      type: 'object',
      properties: {
        data: { type: 'array', items: { type: 'object' } },
        total: { type: 'number', example: 5 },
        page: { type: 'number', example: 1 },
        limit: { type: 'number', example: 20 }
      }
    }
  })
  @ApiResponse({ status: 401, description: 'Unauthorized - Invalid or missing token' })
  async getMyReviews(@Request() req, @Query('page') page?: string, @Query('limit') limit?: string) {
    return this.reviewsService.findAll({
      page: page ? +page : 1,
      limit: limit ? +limit : 20,
      userId: req.user.id,
    });
  }

  @Get(':id')
  @ApiOperation({ 
    summary: 'Get review by ID',
    description: 'Retrieves detailed information about a specific review including rating, comment, helpful count, and user information.'
  })
  @ApiParam({ name: 'id', type: String, description: 'Review UUID', example: '123e4567-e89b-12d3-a456-426614174000' })
  @ApiResponse({ 
    status: 200, 
    description: 'Review retrieved successfully',
    schema: { type: 'object' }
  })
  @ApiResponse({ status: 404, description: 'Review not found' })
  async findOne(@Param('id') id: string) {
    return this.reviewsService.findOne(id);
  }

  @Post()
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ 
    summary: 'Create a review',
    description: 'Creates a new review for a listing, event, or tour. Reviews are subject to moderation and will be in "pending" status until approved by an admin. Users can only review items they have booked or attended.'
  })
  @ApiBody({ type: CreateReviewDto })
  @ApiResponse({ 
    status: 201, 
    description: 'Review created successfully',
    schema: {
      type: 'object',
      properties: {
        id: { type: 'string' },
        rating: { type: 'number', example: 5, minimum: 1, maximum: 5 },
        comment: { type: 'string', example: 'Great experience!' },
        status: { type: 'string', enum: ['pending', 'approved', 'rejected'], example: 'pending' },
        listingId: { type: 'string', nullable: true },
        eventId: { type: 'string', nullable: true },
        tourId: { type: 'string', nullable: true }
      }
    }
  })
  @ApiResponse({ status: 400, description: 'Bad request - Invalid rating or missing required fields' })
  @ApiResponse({ status: 401, description: 'Unauthorized - Invalid or missing token' })
  @ApiResponse({ status: 409, description: 'Conflict - User has already reviewed this item' })
  async create(@Request() req, @Body() data: CreateReviewDto) {
    return this.reviewsService.create(req.user.id, data);
  }

  @Put(':id')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ 
    summary: 'Update a review',
    description: 'Updates an existing review. Only the review owner can update their review. Reviews that are already approved may require re-moderation after update.'
  })
  @ApiParam({ name: 'id', type: String, description: 'Review UUID', example: '123e4567-e89b-12d3-a456-426614174000' })
  @ApiBody({ type: UpdateReviewDto })
  @ApiResponse({ 
    status: 200, 
    description: 'Review updated successfully',
    schema: { type: 'object' }
  })
  @ApiResponse({ status: 400, description: 'Bad request - Invalid input data' })
  @ApiResponse({ status: 401, description: 'Unauthorized - Invalid or missing token' })
  @ApiResponse({ status: 403, description: 'Forbidden - Not authorized to update this review' })
  @ApiResponse({ status: 404, description: 'Review not found' })
  async update(@Param('id') id: string, @Request() req, @Body() data: UpdateReviewDto) {
    return this.reviewsService.update(id, req.user.id, data);
  }

  @Delete(':id')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ 
    summary: 'Delete a review',
    description: 'Deletes a review. Only the review owner can delete their review. This action cannot be undone.'
  })
  @ApiParam({ name: 'id', type: String, description: 'Review UUID', example: '123e4567-e89b-12d3-a456-426614174000' })
  @ApiResponse({ 
    status: 200, 
    description: 'Review deleted successfully',
    schema: {
      type: 'object',
      properties: {
        success: { type: 'boolean', example: true },
        message: { type: 'string', example: 'Review deleted successfully' }
      }
    }
  })
  @ApiResponse({ status: 401, description: 'Unauthorized - Invalid or missing token' })
  @ApiResponse({ status: 403, description: 'Forbidden - Not authorized to delete this review' })
  @ApiResponse({ status: 404, description: 'Review not found' })
  async delete(@Param('id') id: string, @Request() req) {
    return this.reviewsService.delete(id, req.user.id);
  }

  @Post(':id/helpful')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ 
    summary: 'Mark review as helpful/not helpful',
    description: 'Toggles the helpful status of a review for the authenticated user. Helps other users identify useful reviews. Users cannot mark their own reviews as helpful.'
  })
  @ApiParam({ name: 'id', type: String, description: 'Review UUID', example: '123e4567-e89b-12d3-a456-426614174000' })
  @ApiBody({ type: MarkHelpfulDto })
  @ApiResponse({ 
    status: 200, 
    description: 'Helpful status updated successfully',
    schema: {
      type: 'object',
      properties: {
        isHelpful: { type: 'boolean', example: true, description: 'Current helpful status after toggle' },
        helpfulCount: { type: 'number', example: 15, description: 'Total number of users who marked this review as helpful' }
      }
    }
  })
  @ApiResponse({ status: 400, description: 'Bad request - Cannot mark own review as helpful' })
  @ApiResponse({ status: 401, description: 'Unauthorized - Invalid or missing token' })
  @ApiResponse({ status: 404, description: 'Review not found' })
  async markHelpful(@Param('id') id: string, @Request() req, @Body() data: MarkHelpfulDto) {
    return this.reviewsService.markHelpful(id, req.user.id, data.isHelpful);
  }
}
