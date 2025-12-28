import { Controller, Get, Post, Put, Delete, Param, Body, Query, UseGuards, Request } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth, ApiQuery, ApiParam } from '@nestjs/swagger';
import { ListingsService } from './listings.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import {
  CreateListingDto,
  UpdateListingDto,
  AddListingImageDto,
  SetAmenitiesDto,
  CreateRoomTypeDto,
  CreateTableDto,
  ListingQueryDto,
  SubmitListingDto,
  ReorderImagesDto,
  UpdateRoomTypeDto,
  UpdateTableDto,
} from './dto/listing.dto';

@ApiTags('Listings')
@Controller('listings')
export class ListingsController {
  constructor(private listingsService: ListingsService) {}

  @Get()
  @ApiOperation({ summary: 'Get all listings with filters' })
  @ApiQuery({ name: 'page', required: false, type: Number, example: 1 })
  @ApiQuery({ name: 'limit', required: false, type: Number, example: 20 })
  @ApiQuery({ name: 'type', required: false, enum: ['hotel', 'restaurant', 'attraction', 'activity', 'rental', 'nightlife', 'spa'] })
  @ApiQuery({ name: 'status', required: false, enum: ['draft', 'pending_review', 'active', 'inactive'] })
  @ApiQuery({ name: 'cityId', required: false, type: String })
  @ApiQuery({ name: 'countryId', required: false, type: String })
  @ApiQuery({ name: 'categoryId', required: false, type: String })
  @ApiQuery({ name: 'search', required: false, type: String })
  @ApiQuery({ name: 'minPrice', required: false, type: Number })
  @ApiQuery({ name: 'maxPrice', required: false, type: Number })
  @ApiQuery({ name: 'rating', required: false, type: Number })
  @ApiQuery({ name: 'isFeatured', required: false, type: Boolean })
  async findAll(@Query() query: ListingQueryDto) {
    return this.listingsService.findAll({
      ...query,
      page: query.page ? +query.page : 1,
      limit: query.limit ? +query.limit : 20,
    });
  }

  @Get('featured')
  @ApiOperation({ summary: 'Get featured listings' })
  @ApiQuery({ name: 'limit', required: false, type: Number, example: 10 })
  async getFeatured(@Query('limit') limit?: string) {
    return this.listingsService.getFeatured(limit ? +limit : 10);
  }

  @Get('nearby')
  @ApiOperation({ summary: 'Get nearby listings based on coordinates' })
  @ApiQuery({ name: 'latitude', required: true, type: Number, example: -1.9403 })
  @ApiQuery({ name: 'longitude', required: true, type: Number, example: 29.8739 })
  @ApiQuery({ name: 'radius', required: false, type: Number, example: 10, description: 'Radius in km' })
  @ApiQuery({ name: 'limit', required: false, type: Number, example: 20 })
  async getNearby(
    @Query('latitude') latitude: string,
    @Query('longitude') longitude: string,
    @Query('radius') radius?: string,
    @Query('limit') limit?: string,
  ) {
    return this.listingsService.getNearby(+latitude, +longitude, radius ? +radius : 10, limit ? +limit : 20);
  }

  @Get('type/:type')
  @ApiOperation({ summary: 'Get listings by type' })
  @ApiParam({ name: 'type', enum: ['hotel', 'restaurant', 'attraction', 'activity', 'rental', 'nightlife', 'spa'] })
  @ApiQuery({ name: 'page', required: false, type: Number })
  @ApiQuery({ name: 'limit', required: false, type: Number })
  @ApiQuery({ name: 'cityId', required: false, type: String })
  async findByType(@Param('type') type: string, @Query() query: any) {
    return this.listingsService.findByType(type, {
      page: query.page ? +query.page : 1,
      limit: query.limit ? +query.limit : 20,
      cityId: query.cityId,
    });
  }

  @Get('slug/:slug')
  @ApiOperation({ summary: 'Get listing by slug' })
  @ApiParam({ name: 'slug', example: 'grand-hotel-kigali' })
  async findBySlug(@Param('slug') slug: string) {
    return this.listingsService.findBySlug(slug);
  }

  @Get('merchant/:merchantId')
  @ApiOperation({ summary: 'Get all listings for a merchant/business' })
  @ApiParam({ name: 'merchantId', description: 'Merchant profile ID' })
  @ApiQuery({ name: 'page', required: false, type: Number })
  @ApiQuery({ name: 'limit', required: false, type: Number })
  @ApiQuery({ name: 'status', required: false, enum: ['draft', 'pending_review', 'active', 'inactive'] })
  async getMerchantListings(@Param('merchantId') merchantId: string, @Query() query: any) {
    return this.listingsService.findAll({
      merchantId,
      page: query.page ? +query.page : 1,
      limit: query.limit ? +query.limit : 20,
      status: query.status,
    });
  }

  @Get(':id')
  @ApiOperation({ summary: 'Get listing by ID' })
  @ApiParam({ name: 'id', description: 'Listing UUID' })
  async findOne(@Param('id') id: string) {
    return this.listingsService.findOne(id);
  }

  @Get(':id/rooms')
  @ApiOperation({ summary: 'Get room types for a hotel listing' })
  @ApiParam({ name: 'id', description: 'Listing UUID' })
  async getRoomTypes(@Param('id') id: string) {
    return this.listingsService.getRoomTypes(id);
  }

  @Get(':id/tables')
  @ApiOperation({ summary: 'Get tables for a restaurant listing' })
  @ApiParam({ name: 'id', description: 'Listing UUID' })
  async getTables(@Param('id') id: string) {
    return this.listingsService.getTables(id);
  }

  @Get(':id/availability')
  @ApiOperation({ summary: 'Check room availability for dates' })
  @ApiParam({ name: 'id', description: 'Listing UUID' })
  @ApiQuery({ name: 'checkIn', required: true, type: String, example: '2025-12-01' })
  @ApiQuery({ name: 'checkOut', required: true, type: String, example: '2025-12-05' })
  @ApiQuery({ name: 'guests', required: false, type: Number, example: 2 })
  async checkAvailability(
    @Param('id') id: string,
    @Query('checkIn') checkIn: string,
    @Query('checkOut') checkOut: string,
    @Query('guests') guests?: string,
  ) {
    return this.listingsService.checkAvailability(id, new Date(checkIn), new Date(checkOut), guests ? +guests : 2);
  }

  @Post()
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Create a new listing' })
  async create(@Body() data: CreateListingDto) {
    return this.listingsService.create(data.merchantId, data);
  }

  @Put(':id')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Update a listing' })
  @ApiParam({ name: 'id', description: 'Listing UUID' })
  async update(@Param('id') id: string, @Body() data: UpdateListingDto) {
    return this.listingsService.update(id, data.merchantId, data);
  }

  @Post(':id/submit')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Submit listing for review' })
  @ApiParam({ name: 'id', description: 'Listing UUID' })
  async submitForReview(@Param('id') id: string, @Body() data: SubmitListingDto) {
    return this.listingsService.submitForReview(id, data.merchantId);
  }

  @Delete(':id')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Delete a listing (soft delete)' })
  @ApiParam({ name: 'id', description: 'Listing UUID' })
  async delete(@Param('id') id: string, @Body('merchantId') merchantId?: string) {
    return this.listingsService.delete(id, merchantId);
  }

  // ============ IMAGES ============
  @Post(':id/images')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Add image to listing' })
  @ApiParam({ name: 'id', description: 'Listing UUID' })
  async addImage(@Param('id') id: string, @Body() data: AddListingImageDto) {
    return this.listingsService.addImage(id, data.merchantId, data);
  }

  @Delete(':id/images/:imageId')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Remove image from listing' })
  @ApiParam({ name: 'id', description: 'Listing UUID' })
  @ApiParam({ name: 'imageId', description: 'Image UUID' })
  async removeImage(@Param('id') id: string, @Param('imageId') imageId: string, @Body('merchantId') merchantId: string) {
    return this.listingsService.removeImage(id, imageId, merchantId);
  }

  @Put(':id/images/reorder')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Reorder listing images' })
  @ApiParam({ name: 'id', description: 'Listing UUID' })
  async reorderImages(@Param('id') id: string, @Body() data: ReorderImagesDto) {
    return this.listingsService.reorderImages(id, data.merchantId, data.imageIds);
  }

  // ============ AMENITIES ============
  @Put(':id/amenities')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Set listing amenities' })
  @ApiParam({ name: 'id', description: 'Listing UUID' })
  async setAmenities(@Param('id') id: string, @Body() data: SetAmenitiesDto) {
    return this.listingsService.setAmenities(id, data.merchantId, data.amenityIds);
  }

  // ============ ROOM TYPES ============
  @Post(':id/rooms')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Create room type for hotel' })
  @ApiParam({ name: 'id', description: 'Listing UUID' })
  async createRoomType(@Param('id') id: string, @Body() data: CreateRoomTypeDto) {
    return this.listingsService.createRoomType(id, data.merchantId, data);
  }

  @Put('rooms/:roomTypeId')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Update room type' })
  @ApiParam({ name: 'roomTypeId', description: 'Room type UUID' })
  async updateRoomType(@Param('roomTypeId') roomTypeId: string, @Body() data: UpdateRoomTypeDto) {
    return this.listingsService.updateRoomType(roomTypeId, data.merchantId, data);
  }

  @Delete('rooms/:roomTypeId')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Delete room type (soft delete)' })
  @ApiParam({ name: 'roomTypeId', description: 'Room type UUID' })
  async deleteRoomType(@Param('roomTypeId') roomTypeId: string, @Body('merchantId') merchantId: string) {
    return this.listingsService.deleteRoomType(roomTypeId, merchantId);
  }

  // ============ TABLES ============
  @Post(':id/tables')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Create table for restaurant' })
  @ApiParam({ name: 'id', description: 'Listing UUID' })
  async createTable(@Param('id') id: string, @Body() data: CreateTableDto) {
    return this.listingsService.createTable(id, data.merchantId, data);
  }

  @Put('tables/:tableId')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Update table' })
  @ApiParam({ name: 'tableId', description: 'Table UUID' })
  async updateTable(@Param('tableId') tableId: string, @Body() data: UpdateTableDto) {
    return this.listingsService.updateTable(tableId, data.merchantId, data);
  }

  @Delete('tables/:tableId')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Delete table (soft delete)' })
  @ApiParam({ name: 'tableId', description: 'Table UUID' })
  async deleteTable(@Param('tableId') tableId: string, @Body('merchantId') merchantId: string) {
    return this.listingsService.deleteTable(tableId, merchantId);
  }
}
