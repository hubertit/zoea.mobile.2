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
  @ApiOperation({ 
    summary: 'Get all listings with filters and sorting',
    description: 'Retrieve paginated listings with optional filters and sorting. Supports filtering by type, location, category, price range, rating, and more. Sorting options include popular (default), rating, name, price, and creation date.'
  })
  @ApiQuery({ name: 'page', required: false, type: Number, example: 1, description: 'Page number (default: 1)' })
  @ApiQuery({ name: 'limit', required: false, type: Number, example: 20, description: 'Items per page (default: 20)' })
  @ApiQuery({ name: 'type', required: false, enum: ['hotel', 'restaurant', 'attraction', 'activity', 'rental', 'nightlife', 'spa'], description: 'Filter by listing type' })
  @ApiQuery({ name: 'status', required: false, enum: ['draft', 'pending_review', 'active', 'inactive'], description: 'Filter by listing status' })
  @ApiQuery({ name: 'cityId', required: false, type: String, description: 'Filter by city UUID' })
  @ApiQuery({ name: 'countryId', required: false, type: String, description: 'Filter by country UUID' })
  @ApiQuery({ name: 'categoryId', required: false, type: String, description: 'Filter by category UUID' })
  @ApiQuery({ name: 'search', required: false, type: String, description: 'Search in name and description' })
  @ApiQuery({ name: 'minPrice', required: false, type: Number, description: 'Minimum price filter' })
  @ApiQuery({ name: 'maxPrice', required: false, type: Number, description: 'Maximum price filter' })
  @ApiQuery({ name: 'rating', required: false, type: Number, description: 'Minimum rating filter (e.g., 4.0 for 4+ stars)' })
  @ApiQuery({ name: 'isFeatured', required: false, type: Boolean, description: 'Filter for featured listings only' })
  @ApiQuery({ 
    name: 'sortBy', 
    required: false, 
    enum: ['popular', 'rating_desc', 'rating_asc', 'name_asc', 'name_desc', 'price_asc', 'price_desc', 'createdAt_desc', 'createdAt_asc'],
    description: 'Sort order: popular (default - featured first, then rating, then date), rating_desc/asc, name_asc/desc, price_asc/desc, createdAt_desc/asc',
    example: 'rating_desc'
  })
  async findAll(@Query() query: ListingQueryDto) {
    return this.listingsService.findAll({
      ...query,
      page: query.page ? +query.page : 1,
      limit: query.limit ? +query.limit : 20,
    });
  }

  @Get('featured')
  @ApiOperation({ 
    summary: 'Get featured listings',
    description: 'Retrieve featured listings sorted by rating. Featured listings are prioritized and displayed first.'
  })
  @ApiQuery({ name: 'limit', required: false, type: Number, example: 10, description: 'Maximum number of listings to return (default: 10)' })
  async getFeatured(@Query('limit') limit?: string) {
    return this.listingsService.getFeatured(limit ? +limit : 10);
  }

  @Get('nearby')
  @ApiOperation({ 
    summary: 'Get nearby listings based on coordinates',
    description: 'Find listings within a specified radius from given coordinates. Results are sorted by distance (nearest first). Uses PostGIS for geospatial queries.'
  })
  @ApiQuery({ name: 'latitude', required: true, type: Number, example: -1.9403, description: 'Latitude coordinate' })
  @ApiQuery({ name: 'longitude', required: true, type: Number, example: 29.8739, description: 'Longitude coordinate' })
  @ApiQuery({ name: 'radius', required: false, type: Number, example: 10, description: 'Search radius in kilometers (default: 10)' })
  @ApiQuery({ name: 'limit', required: false, type: Number, example: 20, description: 'Maximum number of listings to return (default: 20)' })
  async getNearby(
    @Query('latitude') latitude: string,
    @Query('longitude') longitude: string,
    @Query('radius') radius?: string,
    @Query('limit') limit?: string,
  ) {
    return this.listingsService.getNearby(+latitude, +longitude, radius ? +radius : 10, limit ? +limit : 20);
  }

  @Get('random')
  @ApiOperation({ 
    summary: 'Get random listings',
    description: 'Retrieve random active listings. Useful for "Near Me" section when geolocation is not available. Only returns active listings.'
  })
  @ApiQuery({ name: 'limit', required: false, type: Number, example: 10, description: 'Maximum number of listings to return (default: 10)' })
  async getRandom(@Query('limit') limit?: string) {
    return this.listingsService.getRandom(limit ? +limit : 10);
  }

  @Get('type/:type')
  @ApiOperation({ 
    summary: 'Get listings by type',
    description: 'Retrieve listings filtered by type. Only returns active listings. Supports pagination and city filtering.'
  })
  @ApiParam({ name: 'type', enum: ['hotel', 'restaurant', 'attraction', 'activity', 'rental', 'nightlife', 'spa'], description: 'Listing type to filter by' })
  @ApiQuery({ name: 'page', required: false, type: Number, description: 'Page number (default: 1)' })
  @ApiQuery({ name: 'limit', required: false, type: Number, description: 'Items per page (default: 20)' })
  @ApiQuery({ name: 'cityId', required: false, type: String, description: 'Filter by city UUID' })
  async findByType(@Param('type') type: string, @Query() query: any) {
    return this.listingsService.findByType(type, {
      page: query.page ? +query.page : 1,
      limit: query.limit ? +query.limit : 20,
      cityId: query.cityId,
    });
  }

  @Get('slug/:slug')
  @ApiOperation({ 
    summary: 'Get listing by slug',
    description: 'Retrieve a single listing by its unique slug identifier. Returns full listing details including images, amenities, and related data.'
  })
  @ApiParam({ name: 'slug', example: 'grand-hotel-kigali', description: 'Unique slug identifier for the listing' })
  async findBySlug(@Param('slug') slug: string) {
    return this.listingsService.findBySlug(slug);
  }

  @Get('merchant/:merchantId')
  @ApiOperation({ 
    summary: 'Get all listings for a merchant/business',
    description: 'Retrieve all listings owned by a specific merchant. Supports filtering by status and pagination.'
  })
  @ApiParam({ name: 'merchantId', description: 'Merchant profile UUID' })
  @ApiQuery({ name: 'page', required: false, type: Number, description: 'Page number (default: 1)' })
  @ApiQuery({ name: 'limit', required: false, type: Number, description: 'Items per page (default: 20)' })
  @ApiQuery({ name: 'status', required: false, enum: ['draft', 'pending_review', 'active', 'inactive'], description: 'Filter by listing status' })
  async getMerchantListings(@Param('merchantId') merchantId: string, @Query() query: any) {
    return this.listingsService.findAll({
      merchantId,
      page: query.page ? +query.page : 1,
      limit: query.limit ? +query.limit : 20,
      status: query.status,
    });
  }

  @Get(':id')
  @ApiOperation({ 
    summary: 'Get listing by ID',
    description: 'Retrieve a single listing by its UUID. Includes full details, images, amenities, room types (for hotels), tables (for restaurants), and recent reviews. Automatically increments view count.'
  })
  @ApiParam({ name: 'id', description: 'Listing UUID' })
  async findOne(@Param('id') id: string) {
    return this.listingsService.findOne(id);
  }

  @Get(':id/rooms')
  @ApiOperation({ 
    summary: 'Get room types for a hotel listing',
    description: 'Retrieve all active room types for a hotel listing. Includes availability information for the next 30 days. Sorted by base price (lowest first).'
  })
  @ApiParam({ name: 'id', description: 'Listing UUID (must be a hotel type)' })
  async getRoomTypes(@Param('id') id: string) {
    return this.listingsService.getRoomTypes(id);
  }

  @Get(':id/tables')
  @ApiOperation({ 
    summary: 'Get tables for a restaurant listing',
    description: 'Retrieve all active tables for a restaurant listing. Sorted by table number.'
  })
  @ApiParam({ name: 'id', description: 'Listing UUID (must be a restaurant type)' })
  async getTables(@Param('id') id: string) {
    return this.listingsService.getTables(id);
  }

  @Get(':id/availability')
  @ApiOperation({ 
    summary: 'Check room availability for dates',
    description: 'Check which room types are available for a given date range and guest count. Returns only room types with sufficient capacity and availability for all nights in the date range.'
  })
  @ApiParam({ name: 'id', description: 'Listing UUID (must be a hotel type)' })
  @ApiQuery({ name: 'checkIn', required: true, type: String, example: '2025-12-01', description: 'Check-in date in YYYY-MM-DD format' })
  @ApiQuery({ name: 'checkOut', required: true, type: String, example: '2025-12-05', description: 'Check-out date in YYYY-MM-DD format' })
  @ApiQuery({ name: 'guests', required: false, type: Number, example: 2, description: 'Number of guests (default: 2)' })
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
  @ApiOperation({ 
    summary: 'Create a new listing',
    description: 'Create a new listing for a merchant. The listing will be created in draft status and must be submitted for review before becoming active. Requires merchant authentication.'
  })
  async create(@Body() data: CreateListingDto) {
    return this.listingsService.create(data.merchantId, data);
  }

  @Put(':id')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ 
    summary: 'Update a listing',
    description: 'Update an existing listing. Only the listing owner (merchant) can update their listings. Requires merchant authentication.'
  })
  @ApiParam({ name: 'id', description: 'Listing UUID' })
  async update(@Param('id') id: string, @Body() data: UpdateListingDto) {
    return this.listingsService.update(id, data.merchantId, data);
  }

  @Post(':id/submit')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ 
    summary: 'Submit listing for review',
    description: 'Submit a draft listing for admin review. The listing status will change from draft to pending_review. Only draft listings can be submitted.'
  })
  @ApiParam({ name: 'id', description: 'Listing UUID' })
  async submitForReview(@Param('id') id: string, @Body() data: SubmitListingDto) {
    return this.listingsService.submitForReview(id, data.merchantId);
  }

  @Delete(':id')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ 
    summary: 'Delete a listing (soft delete)',
    description: 'Soft delete a listing by setting deletedAt timestamp. The listing will no longer appear in public listings but data is preserved. Requires merchant authentication (or admin).'
  })
  @ApiParam({ name: 'id', description: 'Listing UUID' })
  async delete(@Param('id') id: string, @Body('merchantId') merchantId?: string) {
    return this.listingsService.delete(id, merchantId);
  }

  // ============ IMAGES ============
  @Post(':id/images')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ 
    summary: 'Add image to listing',
    description: 'Add an image to a listing. The image must be uploaded first via the media endpoint to get a mediaId. If isPrimary is true, this image becomes the primary image and all others are set to non-primary. Requires merchant authentication.'
  })
  @ApiParam({ name: 'id', description: 'Listing UUID' })
  async addImage(@Param('id') id: string, @Body() data: AddListingImageDto) {
    return this.listingsService.addImage(id, data.merchantId, data);
  }

  @Delete(':id/images/:imageId')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ 
    summary: 'Remove image from listing',
    description: 'Remove an image from a listing. Permanently deletes the image association. Requires merchant authentication.'
  })
  @ApiParam({ name: 'id', description: 'Listing UUID' })
  @ApiParam({ name: 'imageId', description: 'Listing image UUID' })
  async removeImage(@Param('id') id: string, @Param('imageId') imageId: string, @Body('merchantId') merchantId: string) {
    return this.listingsService.removeImage(id, imageId, merchantId);
  }

  @Put(':id/images/reorder')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ 
    summary: 'Reorder listing images',
    description: 'Change the display order of listing images by providing an array of image IDs in the desired order. The first image in the array becomes the primary image. Requires merchant authentication.'
  })
  @ApiParam({ name: 'id', description: 'Listing UUID' })
  async reorderImages(@Param('id') id: string, @Body() data: ReorderImagesDto) {
    return this.listingsService.reorderImages(id, data.merchantId, data.imageIds);
  }

  // ============ AMENITIES ============
  @Put(':id/amenities')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ 
    summary: 'Set listing amenities',
    description: 'Replace all amenities for a listing with the provided list. Existing amenities are removed and replaced with the new set. Provide an array of amenity UUIDs. Requires merchant authentication.'
  })
  @ApiParam({ name: 'id', description: 'Listing UUID' })
  async setAmenities(@Param('id') id: string, @Body() data: SetAmenitiesDto) {
    return this.listingsService.setAmenities(id, data.merchantId, data.amenityIds);
  }

  // ============ ROOM TYPES ============
  @Post(':id/rooms')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ 
    summary: 'Create room type for hotel',
    description: 'Create a new room type for a hotel listing. Only available for listings with type "hotel". Includes room details like capacity, bed type, amenities, and pricing. Requires merchant authentication.'
  })
  @ApiParam({ name: 'id', description: 'Listing UUID (must be a hotel type)' })
  async createRoomType(@Param('id') id: string, @Body() data: CreateRoomTypeDto) {
    return this.listingsService.createRoomType(id, data.merchantId, data);
  }

  @Put('rooms/:roomTypeId')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ 
    summary: 'Update room type',
    description: 'Update an existing room type. Can modify pricing, capacity, amenities, and other room details. Requires merchant authentication.'
  })
  @ApiParam({ name: 'roomTypeId', description: 'Room type UUID' })
  async updateRoomType(@Param('roomTypeId') roomTypeId: string, @Body() data: UpdateRoomTypeDto) {
    return this.listingsService.updateRoomType(roomTypeId, data.merchantId, data);
  }

  @Delete('rooms/:roomTypeId')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ 
    summary: 'Delete room type (soft delete)',
    description: 'Soft delete a room type by setting isActive to false. The room type will no longer appear in availability checks but data is preserved. Requires merchant authentication.'
  })
  @ApiParam({ name: 'roomTypeId', description: 'Room type UUID' })
  async deleteRoomType(@Param('roomTypeId') roomTypeId: string, @Body('merchantId') merchantId: string) {
    return this.listingsService.deleteRoomType(roomTypeId, merchantId);
  }

  // ============ TABLES ============
  @Post(':id/tables')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ 
    summary: 'Create table for restaurant',
    description: 'Create a new table for a restaurant listing. Only available for listings with type "restaurant". Includes table number, capacity, and location (window, patio, etc.). Requires merchant authentication.'
  })
  @ApiParam({ name: 'id', description: 'Listing UUID (must be a restaurant type)' })
  async createTable(@Param('id') id: string, @Body() data: CreateTableDto) {
    return this.listingsService.createTable(id, data.merchantId, data);
  }

  @Put('tables/:tableId')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ 
    summary: 'Update table',
    description: 'Update an existing restaurant table. Can modify capacity, location, status, and other table details. Requires merchant authentication.'
  })
  @ApiParam({ name: 'tableId', description: 'Table UUID' })
  async updateTable(@Param('tableId') tableId: string, @Body() data: UpdateTableDto) {
    return this.listingsService.updateTable(tableId, data.merchantId, data);
  }

  @Delete('tables/:tableId')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ 
    summary: 'Delete table (soft delete)',
    description: 'Soft delete a restaurant table by setting isActive to false. The table will no longer appear in booking options but data is preserved. Requires merchant authentication.'
  })
  @ApiParam({ name: 'tableId', description: 'Table UUID' })
  async deleteTable(@Param('tableId') tableId: string, @Body('merchantId') merchantId: string) {
    return this.listingsService.deleteTable(tableId, merchantId);
  }
}
