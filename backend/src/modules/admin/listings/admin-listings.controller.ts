import { Body, Controller, Delete, Get, Param, Patch, Post, Put, Query, UseGuards } from '@nestjs/common';
import { ApiBearerAuth, ApiOperation, ApiTags } from '@nestjs/swagger';
import { Roles } from '../../../common/decorators/roles.decorator';
import { RolesGuard } from '../../../common/guards/roles.guard';
import { JwtAuthGuard } from '../../auth/guards/jwt-auth.guard';
import { AdminListingsService } from './admin-listings.service';
import { AdminListListingsDto } from './dto/list-listings.dto';
import { AdminUpdateListingStatusDto } from './dto/update-listing-status.dto';
import { AdminCreateListingDto, AdminUpdateListingDto } from './dto/create-listing.dto';

@ApiTags('Admin - Listings')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard, RolesGuard)
@Roles('admin', 'super_admin')
@Controller('admin/listings')
export class AdminListingsController {
  constructor(private readonly adminListingsService: AdminListingsService) {}

  @Get()
  @ApiOperation({ summary: 'List listings with filters/pagination' })
  async list(@Query() query: AdminListListingsDto) {
    return this.adminListingsService.listListings(query);
  }

  @Get(':id')
  @ApiOperation({ summary: 'Get listing detail' })
  async getById(@Param('id') id: string) {
    return this.adminListingsService.getListingById(id);
  }

  @Post()
  @ApiOperation({ summary: 'Create listing on behalf of merchant' })
  async create(@Body() dto: AdminCreateListingDto) {
    return this.adminListingsService.createListing(dto);
  }

  @Put(':id')
  @ApiOperation({ summary: 'Update listing content' })
  async update(@Param('id') id: string, @Body() dto: AdminUpdateListingDto) {
    return this.adminListingsService.updateListing(id, dto);
  }

  @Patch(':id/status')
  @ApiOperation({ summary: 'Update listing moderation/feature state' })
  async updateStatus(@Param('id') id: string, @Body() dto: AdminUpdateListingStatusDto) {
    return this.adminListingsService.updateListingStatus(id, dto);
  }

  @Delete(':id')
  @ApiOperation({ summary: 'Soft delete listing' })
  async delete(@Param('id') id: string) {
    return this.adminListingsService.deleteListing(id);
  }

  @Patch(':id/restore')
  @ApiOperation({ summary: 'Restore soft deleted listing' })
  async restore(@Param('id') id: string) {
    return this.adminListingsService.restoreListing(id);
  }
}


