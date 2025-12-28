import { Controller, Get, Post, Put, Delete, Param, Body, Query, UseGuards, Request } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth, ApiQuery, ApiParam } from '@nestjs/swagger';
import { MerchantsService } from './merchants.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import {
  CreateBusinessDto,
  UpdateBusinessDto,
  CreateMerchantListingDto,
  UpdateMerchantListingDto,
  CreateMerchantRoomTypeDto,
  CreateMerchantTableDto,
  UpdateBookingStatusDto,
  AddListingImageDto,
  UpdateMerchantRoomTypeDto,
  UpdateMerchantTableDto,
  ReviewResponseDto,
} from './dto/merchant.dto';

@ApiTags('Merchants')
@Controller('merchants')
@UseGuards(JwtAuthGuard)
@ApiBearerAuth()
export class MerchantsController {
  constructor(private merchantsService: MerchantsService) {}

  // ============ BUSINESS PROFILE ============
  @Get('businesses')
  @ApiOperation({ summary: 'Get all my businesses' })
  async getMyBusinesses(@Request() req) {
    return this.merchantsService.getMyBusinesses(req.user.id);
  }

  @Get('businesses/:businessId')
  @ApiOperation({ summary: 'Get business details' })
  @ApiParam({ name: 'businessId', description: 'Business UUID' })
  async getBusiness(@Request() req, @Param('businessId') businessId: string) {
    return this.merchantsService.getBusiness(req.user.id, businessId);
  }

  @Post('businesses')
  @ApiOperation({ summary: 'Create a new business' })
  async createBusiness(@Request() req, @Body() data: CreateBusinessDto) {
    return this.merchantsService.createBusiness(req.user.id, data);
  }

  @Put('businesses/:businessId')
  @ApiOperation({ summary: 'Update business details' })
  @ApiParam({ name: 'businessId', description: 'Business UUID' })
  async updateBusiness(@Request() req, @Param('businessId') businessId: string, @Body() data: UpdateBusinessDto) {
    return this.merchantsService.updateBusiness(req.user.id, businessId, data);
  }

  @Delete('businesses/:businessId')
  @ApiOperation({ summary: 'Delete a business' })
  @ApiParam({ name: 'businessId', description: 'Business UUID' })
  async deleteBusiness(@Request() req, @Param('businessId') businessId: string) {
    return this.merchantsService.deleteBusiness(req.user.id, businessId);
  }

  // ============ LISTINGS ============
  @Get('businesses/:businessId/listings')
  @ApiOperation({ summary: 'Get all listings for a business' })
  @ApiParam({ name: 'businessId', description: 'Business UUID' })
  @ApiQuery({ name: 'page', required: false, type: Number })
  @ApiQuery({ name: 'limit', required: false, type: Number })
  @ApiQuery({ name: 'status', required: false, enum: ['draft', 'pending_review', 'active', 'inactive', 'rejected'] })
  async getListings(
    @Request() req,
    @Param('businessId') businessId: string,
    @Query('page') page?: string,
    @Query('limit') limit?: string,
    @Query('status') status?: string,
  ) {
    return this.merchantsService.getListings(req.user.id, businessId, {
      page: page ? +page : 1,
      limit: limit ? +limit : 20,
      status,
    });
  }

  @Get('businesses/:businessId/listings/:listingId')
  @ApiOperation({ summary: 'Get listing details' })
  @ApiParam({ name: 'businessId', description: 'Business UUID' })
  @ApiParam({ name: 'listingId', description: 'Listing UUID' })
  async getListing(
    @Request() req,
    @Param('businessId') businessId: string,
    @Param('listingId') listingId: string,
  ) {
    return this.merchantsService.getListing(req.user.id, businessId, listingId);
  }

  @Post('businesses/:businessId/listings')
  @ApiOperation({ summary: 'Create a new listing' })
  @ApiParam({ name: 'businessId', description: 'Business UUID' })
  async createListing(
    @Request() req,
    @Param('businessId') businessId: string,
    @Body() data: CreateMerchantListingDto,
  ) {
    return this.merchantsService.createListing(req.user.id, businessId, data);
  }

  @Put('businesses/:businessId/listings/:listingId')
  @ApiOperation({ summary: 'Update a listing' })
  @ApiParam({ name: 'businessId', description: 'Business UUID' })
  @ApiParam({ name: 'listingId', description: 'Listing UUID' })
  async updateListing(
    @Request() req,
    @Param('businessId') businessId: string,
    @Param('listingId') listingId: string,
    @Body() data: UpdateMerchantListingDto,
  ) {
    return this.merchantsService.updateListing(req.user.id, businessId, listingId, data);
  }

  @Delete('businesses/:businessId/listings/:listingId')
  @ApiOperation({ summary: 'Delete a listing' })
  @ApiParam({ name: 'businessId', description: 'Business UUID' })
  @ApiParam({ name: 'listingId', description: 'Listing UUID' })
  async deleteListing(
    @Request() req,
    @Param('businessId') businessId: string,
    @Param('listingId') listingId: string,
  ) {
    return this.merchantsService.deleteListing(req.user.id, businessId, listingId);
  }

  @Post('businesses/:businessId/listings/:listingId/submit')
  @ApiOperation({ summary: 'Submit listing for review' })
  @ApiParam({ name: 'businessId', description: 'Business UUID' })
  @ApiParam({ name: 'listingId', description: 'Listing UUID' })
  async submitListing(
    @Request() req,
    @Param('businessId') businessId: string,
    @Param('listingId') listingId: string,
  ) {
    return this.merchantsService.submitListing(req.user.id, businessId, listingId);
  }

  // ============ LISTING IMAGES ============
  @Post('businesses/:businessId/listings/:listingId/images')
  @ApiOperation({ summary: 'Add image to listing' })
  @ApiParam({ name: 'businessId', description: 'Business UUID' })
  @ApiParam({ name: 'listingId', description: 'Listing UUID' })
  async addListingImage(
    @Request() req,
    @Param('businessId') businessId: string,
    @Param('listingId') listingId: string,
    @Body() data: AddListingImageDto,
  ) {
    return this.merchantsService.addListingImage(req.user.id, businessId, listingId, data);
  }

  @Delete('businesses/:businessId/listings/:listingId/images/:imageId')
  @ApiOperation({ summary: 'Remove image from listing' })
  @ApiParam({ name: 'businessId', description: 'Business UUID' })
  @ApiParam({ name: 'listingId', description: 'Listing UUID' })
  @ApiParam({ name: 'imageId', description: 'Image UUID' })
  async removeListingImage(
    @Request() req,
    @Param('businessId') businessId: string,
    @Param('listingId') listingId: string,
    @Param('imageId') imageId: string,
  ) {
    return this.merchantsService.removeListingImage(req.user.id, businessId, listingId, imageId);
  }

  // ============ ROOM TYPES (Hotels) ============
  @Get('businesses/:businessId/listings/:listingId/rooms')
  @ApiOperation({ summary: 'Get room types for a hotel listing' })
  @ApiParam({ name: 'businessId', description: 'Business UUID' })
  @ApiParam({ name: 'listingId', description: 'Hotel listing UUID' })
  async getRoomTypes(
    @Request() req,
    @Param('businessId') businessId: string,
    @Param('listingId') listingId: string,
  ) {
    return this.merchantsService.getRoomTypes(req.user.id, businessId, listingId);
  }

  @Post('businesses/:businessId/listings/:listingId/rooms')
  @ApiOperation({ summary: 'Create room type for a hotel listing' })
  @ApiParam({ name: 'businessId', description: 'Business UUID' })
  @ApiParam({ name: 'listingId', description: 'Hotel listing UUID' })
  async createRoomType(
    @Request() req,
    @Param('businessId') businessId: string,
    @Param('listingId') listingId: string,
    @Body() data: CreateMerchantRoomTypeDto,
  ) {
    return this.merchantsService.createRoomType(req.user.id, businessId, listingId, data);
  }

  @Put('businesses/:businessId/rooms/:roomTypeId')
  @ApiOperation({ summary: 'Update room type' })
  @ApiParam({ name: 'businessId', description: 'Business UUID' })
  @ApiParam({ name: 'roomTypeId', description: 'Room type UUID' })
  async updateRoomType(
    @Request() req,
    @Param('businessId') businessId: string,
    @Param('roomTypeId') roomTypeId: string,
    @Body() data: UpdateMerchantRoomTypeDto,
  ) {
    return this.merchantsService.updateRoomType(req.user.id, businessId, roomTypeId, data);
  }

  @Delete('businesses/:businessId/rooms/:roomTypeId')
  @ApiOperation({ summary: 'Delete room type' })
  @ApiParam({ name: 'businessId', description: 'Business UUID' })
  @ApiParam({ name: 'roomTypeId', description: 'Room type UUID' })
  async deleteRoomType(
    @Request() req,
    @Param('businessId') businessId: string,
    @Param('roomTypeId') roomTypeId: string,
  ) {
    return this.merchantsService.deleteRoomType(req.user.id, businessId, roomTypeId);
  }

  // ============ TABLES (Restaurants) ============
  @Get('businesses/:businessId/listings/:listingId/tables')
  @ApiOperation({ summary: 'Get tables for a restaurant listing' })
  @ApiParam({ name: 'businessId', description: 'Business UUID' })
  @ApiParam({ name: 'listingId', description: 'Restaurant listing UUID' })
  async getTables(
    @Request() req,
    @Param('businessId') businessId: string,
    @Param('listingId') listingId: string,
  ) {
    return this.merchantsService.getTables(req.user.id, businessId, listingId);
  }

  @Post('businesses/:businessId/listings/:listingId/tables')
  @ApiOperation({ summary: 'Create table for a restaurant listing' })
  @ApiParam({ name: 'businessId', description: 'Business UUID' })
  @ApiParam({ name: 'listingId', description: 'Restaurant listing UUID' })
  async createTable(
    @Request() req,
    @Param('businessId') businessId: string,
    @Param('listingId') listingId: string,
    @Body() data: CreateMerchantTableDto,
  ) {
    return this.merchantsService.createTable(req.user.id, businessId, listingId, data);
  }

  @Put('businesses/:businessId/tables/:tableId')
  @ApiOperation({ summary: 'Update table' })
  @ApiParam({ name: 'businessId', description: 'Business UUID' })
  @ApiParam({ name: 'tableId', description: 'Table UUID' })
  async updateTable(
    @Request() req,
    @Param('businessId') businessId: string,
    @Param('tableId') tableId: string,
    @Body() data: UpdateMerchantTableDto,
  ) {
    return this.merchantsService.updateTable(req.user.id, businessId, tableId, data);
  }

  @Delete('businesses/:businessId/tables/:tableId')
  @ApiOperation({ summary: 'Delete table' })
  @ApiParam({ name: 'businessId', description: 'Business UUID' })
  @ApiParam({ name: 'tableId', description: 'Table UUID' })
  async deleteTable(
    @Request() req,
    @Param('businessId') businessId: string,
    @Param('tableId') tableId: string,
  ) {
    return this.merchantsService.deleteTable(req.user.id, businessId, tableId);
  }

  // ============ BOOKINGS ============
  @Get('businesses/:businessId/bookings')
  @ApiOperation({ summary: 'Get all bookings for a business' })
  @ApiParam({ name: 'businessId', description: 'Business UUID' })
  @ApiQuery({ name: 'page', required: false, type: Number })
  @ApiQuery({ name: 'limit', required: false, type: Number })
  @ApiQuery({ name: 'status', required: false, enum: ['pending', 'confirmed', 'cancelled', 'completed', 'no_show'] })
  @ApiQuery({ name: 'listingId', required: false, type: String })
  @ApiQuery({ name: 'startDate', required: false, type: String, description: 'Filter from date (YYYY-MM-DD)' })
  @ApiQuery({ name: 'endDate', required: false, type: String, description: 'Filter to date (YYYY-MM-DD)' })
  async getBookings(
    @Request() req,
    @Param('businessId') businessId: string,
    @Query('page') page?: string,
    @Query('limit') limit?: string,
    @Query('status') status?: string,
    @Query('listingId') listingId?: string,
    @Query('startDate') startDate?: string,
    @Query('endDate') endDate?: string,
  ) {
    return this.merchantsService.getBookings(req.user.id, businessId, {
      page: page ? +page : 1,
      limit: limit ? +limit : 20,
      status,
      listingId,
      startDate,
      endDate,
    });
  }

  @Get('businesses/:businessId/bookings/:bookingId')
  @ApiOperation({ summary: 'Get booking details' })
  @ApiParam({ name: 'businessId', description: 'Business UUID' })
  @ApiParam({ name: 'bookingId', description: 'Booking UUID' })
  async getBooking(
    @Request() req,
    @Param('businessId') businessId: string,
    @Param('bookingId') bookingId: string,
  ) {
    return this.merchantsService.getBooking(req.user.id, businessId, bookingId);
  }

  @Put('businesses/:businessId/bookings/:bookingId/status')
  @ApiOperation({ summary: 'Update booking status (confirm, cancel, complete, no-show)' })
  @ApiParam({ name: 'businessId', description: 'Business UUID' })
  @ApiParam({ name: 'bookingId', description: 'Booking UUID' })
  async updateBookingStatus(
    @Request() req,
    @Param('businessId') businessId: string,
    @Param('bookingId') bookingId: string,
    @Body() data: UpdateBookingStatusDto,
  ) {
    return this.merchantsService.updateBookingStatus(req.user.id, businessId, bookingId, data);
  }

  // ============ REVIEWS ============
  @Get('businesses/:businessId/reviews')
  @ApiOperation({ summary: 'Get all reviews for business listings' })
  @ApiParam({ name: 'businessId', description: 'Business UUID' })
  @ApiQuery({ name: 'page', required: false, type: Number })
  @ApiQuery({ name: 'limit', required: false, type: Number })
  @ApiQuery({ name: 'listingId', required: false, type: String })
  @ApiQuery({ name: 'rating', required: false, type: Number, description: 'Filter by rating (1-5)' })
  async getReviews(
    @Request() req,
    @Param('businessId') businessId: string,
    @Query('page') page?: string,
    @Query('limit') limit?: string,
    @Query('listingId') listingId?: string,
    @Query('rating') rating?: string,
  ) {
    return this.merchantsService.getReviews(req.user.id, businessId, {
      page: page ? +page : 1,
      limit: limit ? +limit : 20,
      listingId,
      rating: rating ? +rating : undefined,
    });
  }

  @Post('businesses/:businessId/reviews/:reviewId/respond')
  @ApiOperation({ summary: 'Respond to a review' })
  @ApiParam({ name: 'businessId', description: 'Business UUID' })
  @ApiParam({ name: 'reviewId', description: 'Review UUID' })
  async respondToReview(
    @Request() req,
    @Param('businessId') businessId: string,
    @Param('reviewId') reviewId: string,
    @Body() data: ReviewResponseDto,
  ) {
    return this.merchantsService.respondToReview(req.user.id, businessId, reviewId, data.response);
  }

  // ============ ANALYTICS ============
  @Get('businesses/:businessId/dashboard')
  @ApiOperation({ summary: 'Get business dashboard overview' })
  @ApiParam({ name: 'businessId', description: 'Business UUID' })
  async getDashboard(@Request() req, @Param('businessId') businessId: string) {
    return this.merchantsService.getDashboard(req.user.id, businessId);
  }

  @Get('businesses/:businessId/analytics/revenue')
  @ApiOperation({ summary: 'Get revenue analytics' })
  @ApiParam({ name: 'businessId', description: 'Business UUID' })
  @ApiQuery({ name: 'startDate', required: false, type: String, description: 'Start date (YYYY-MM-DD)' })
  @ApiQuery({ name: 'endDate', required: false, type: String, description: 'End date (YYYY-MM-DD)' })
  @ApiQuery({ name: 'groupBy', required: false, enum: ['day', 'week', 'month', 'year'] })
  async getRevenueAnalytics(
    @Request() req,
    @Param('businessId') businessId: string,
    @Query('startDate') startDate?: string,
    @Query('endDate') endDate?: string,
    @Query('groupBy') groupBy?: string,
  ) {
    return this.merchantsService.getRevenueAnalytics(req.user.id, businessId, { startDate, endDate, groupBy });
  }

  @Get('businesses/:businessId/analytics/bookings')
  @ApiOperation({ summary: 'Get booking analytics' })
  @ApiParam({ name: 'businessId', description: 'Business UUID' })
  @ApiQuery({ name: 'startDate', required: false, type: String })
  @ApiQuery({ name: 'endDate', required: false, type: String })
  async getBookingAnalytics(
    @Request() req,
    @Param('businessId') businessId: string,
    @Query('startDate') startDate?: string,
    @Query('endDate') endDate?: string,
  ) {
    return this.merchantsService.getBookingAnalytics(req.user.id, businessId, { startDate, endDate });
  }

  // ============ PROMOTIONS ============
  @Get('businesses/:businessId/promotions')
  @ApiOperation({ summary: 'Get promotions this business is participating in' })
  @ApiParam({ name: 'businessId', description: 'Business UUID' })
  @ApiQuery({ name: 'page', required: false, type: Number })
  @ApiQuery({ name: 'limit', required: false, type: Number })
  @ApiQuery({ name: 'active', required: false, type: Boolean })
  async getPromotions(
    @Request() req,
    @Param('businessId') businessId: string,
    @Query('page') page?: string,
    @Query('limit') limit?: string,
    @Query('active') active?: string,
  ) {
    return this.merchantsService.getPromotions(req.user.id, businessId, {
      page: page ? +page : 1,
      limit: limit ? +limit : 20,
      active: active === 'true' ? true : active === 'false' ? false : undefined,
    });
  }

  @Get('businesses/:businessId/promotions/available')
  @ApiOperation({ summary: 'Get available promotions to join' })
  @ApiParam({ name: 'businessId', description: 'Business UUID' })
  async getAvailablePromotions(
    @Request() req,
    @Param('businessId') businessId: string,
  ) {
    return this.merchantsService.getAvailablePromotions(req.user.id, businessId);
  }

  @Post('businesses/:businessId/promotions/:promotionId/join')
  @ApiOperation({ summary: 'Join a promotion' })
  @ApiParam({ name: 'businessId', description: 'Business UUID' })
  @ApiParam({ name: 'promotionId', description: 'Promotion UUID' })
  async joinPromotion(
    @Request() req,
    @Param('businessId') businessId: string,
    @Param('promotionId') promotionId: string,
  ) {
    return this.merchantsService.joinPromotion(req.user.id, businessId, promotionId);
  }

  @Delete('businesses/:businessId/promotions/:promotionId/leave')
  @ApiOperation({ summary: 'Leave a promotion' })
  @ApiParam({ name: 'businessId', description: 'Business UUID' })
  @ApiParam({ name: 'promotionId', description: 'Promotion UUID' })
  async leavePromotion(
    @Request() req,
    @Param('businessId') businessId: string,
    @Param('promotionId') promotionId: string,
  ) {
    return this.merchantsService.leavePromotion(req.user.id, businessId, promotionId);
  }
}

