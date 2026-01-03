import { Controller, Delete, Get, Param, Query, UseGuards } from '@nestjs/common';
import { ApiBearerAuth, ApiOperation, ApiTags, ApiResponse, ApiParam } from '@nestjs/swagger';
import { Roles } from '../../../common/decorators/roles.decorator';
import { RolesGuard } from '../../../common/guards/roles.guard';
import { JwtAuthGuard } from '../../auth/guards/jwt-auth.guard';
import { AdminReviewsService } from './admin-reviews.service';
import { AdminListReviewsDto } from './dto/list-reviews.dto';

@ApiTags('Admin - Reviews')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard, RolesGuard)
@Roles('admin', 'super_admin')
@Controller('admin/reviews')
export class AdminReviewsController {
  constructor(private readonly adminReviewsService: AdminReviewsService) {}

  @Get()
  @ApiOperation({ 
    summary: 'List all reviews (including unapproved) with filters and pagination',
    description: 'Retrieve all reviews in the system including unapproved ones. Admin only. Supports filtering by status (pending, approved, rejected), listing, user, rating, and date range. Useful for review moderation and management.'
  })
  @ApiResponse({ 
    status: 200, 
    description: 'Reviews retrieved successfully',
    schema: {
      type: 'object',
      properties: {
        data: { type: 'array', items: { type: 'object' } },
        total: { type: 'number', example: 150 },
        page: { type: 'number', example: 1 },
        limit: { type: 'number', example: 20 }
      }
    }
  })
  @ApiResponse({ status: 401, description: 'Unauthorized - Invalid or missing token' })
  @ApiResponse({ status: 403, description: 'Forbidden - Admin access required' })
  async listReviews(@Query() query: AdminListReviewsDto) {
    return this.adminReviewsService.listReviews(query);
  }

  @Delete(':id')
  @ApiOperation({ 
    summary: 'Delete review (admin only)',
    description: 'Permanently delete a review from the system. Admin only. This action cannot be undone. Use with caution.'
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
  @ApiResponse({ status: 403, description: 'Forbidden - Admin access required' })
  @ApiResponse({ status: 404, description: 'Review not found' })
  async deleteReview(@Param('id') id: string) {
    return this.adminReviewsService.deleteReview(id);
  }
}

