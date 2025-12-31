import { Controller, Delete, Get, Param, Query, UseGuards } from '@nestjs/common';
import { ApiBearerAuth, ApiOperation, ApiTags } from '@nestjs/swagger';
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
  @ApiOperation({ summary: 'List all reviews (including unapproved) with filters and pagination' })
  async listReviews(@Query() query: AdminListReviewsDto) {
    return this.adminReviewsService.listReviews(query);
  }

  @Delete(':id')
  @ApiOperation({ summary: 'Delete review (admin only)' })
  async deleteReview(@Param('id') id: string) {
    return this.adminReviewsService.deleteReview(id);
  }
}

