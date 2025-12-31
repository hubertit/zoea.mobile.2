import { Controller, Get, Post, Put, Delete, Param, Body, Query, UseGuards, Request } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth, ApiQuery, ApiParam, ApiResponse, ApiBody } from '@nestjs/swagger';
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
  @ApiOperation({ 
    summary: 'Get all my businesses',
    description: 'Retrieves all business profiles owned by the authenticated merchant user. A merchant can own multiple businesses. Returns business details including verification status, listings count, and statistics.'
  })
  @ApiResponse({ 
    status: 200, 
    description: 'Businesses retrieved successfully',
    schema: {
      type: 'array',
      items: {
        type: 'object',
        properties: {
          id: { type: 'string' },
          name: { type: 'string', example: 'Grand Hotel Kigali' },
          registrationStatus: { type: 'string', enum: ['pending', 'verified', 'rejected'], example: 'verified' },
          listingsCount: { type: 'number', example: 5 },
          createdAt: { type: 'string' }
        }
      }
    }
  })
  @ApiResponse({ status: 401, description: 'Unauthorized - Invalid or missing token' })
  async getMyBusinesses(@Request() req) {
    return this.merchantsService.getMyBusinesses(req.user.id);
  }

  @Get('businesses/:businessId')
  @ApiOperation({ 
    summary: 'Get business details',
    description: 'Retrieves detailed information about a specific business including profile, verification status, settings, listings summary, and statistics. Only the business owner can access this endpoint.'
  })
  @ApiParam({ name: 'businessId', type: String, description: 'Business UUID', example: '123e4567-e89b-12d3-a456-426614174000' })
  @ApiResponse({ 
    status: 200, 
    description: 'Business details retrieved successfully',
    schema: { type: 'object' }
  })
  @ApiResponse({ status: 401, description: 'Unauthorized - Invalid or missing token' })
  @ApiResponse({ status: 403, description: 'Forbidden - Not authorized to access this business' })
  @ApiResponse({ status: 404, description: 'Business not found' })
  async getBusiness(@Request() req, @Param('businessId') businessId: string) {
    return this.merchantsService.getBusiness(req.user.id, businessId);
  }

  @Post('businesses')
  @ApiOperation({ 
    summary: 'Create a new business',
    description: 'Creates a new business profile for the authenticated merchant. The business will be in "pending" status until verified by an admin. Merchants can create multiple businesses (e.g., multiple hotel locations).'
  })
  @ApiBody({ type: CreateBusinessDto })
  @ApiResponse({ 
    status: 201, 
    description: 'Business created successfully',
    schema: {
      type: 'object',
      properties: {
        id: { type: 'string' },
        name: { type: 'string', example: 'Grand Hotel Kigali' },
        registrationStatus: { type: 'string', enum: ['pending', 'verified', 'rejected'], example: 'pending' },
        createdAt: { type: 'string' }
      }
    }
  })
  @ApiResponse({ status: 400, description: 'Bad request - Invalid input data' })
  @ApiResponse({ status: 401, description: 'Unauthorized - Invalid or missing token' })
  async createBusiness(@Request() req, @Body() data: CreateBusinessDto) {
    return this.merchantsService.createBusiness(req.user.id, data);
  }

  @Put('businesses/:businessId')
  @ApiOperation({ 
    summary: 'Update business details',
    description: 'Updates business profile information including name, description, contact details, and settings. Only the business owner can update their business. Some changes may require re-verification.'
  })
  @ApiParam({ name: 'businessId', type: String, description: 'Business UUID', example: '123e4567-e89b-12d3-a456-426614174000' })
  @ApiBody({ type: UpdateBusinessDto })
  @ApiResponse({ 
    status: 200, 
    description: 'Business updated successfully',
    schema: { type: 'object' }
  })
  @ApiResponse({ status: 400, description: 'Bad request - Invalid input data' })
  @ApiResponse({ status: 401, description: 'Unauthorized - Invalid or missing token' })
  @ApiResponse({ status: 403, description: 'Forbidden - Not authorized to update this business' })
  @ApiResponse({ status: 404, description: 'Business not found' })
  async updateBusiness(@Request() req, @Param('businessId') businessId: string, @Body() data: UpdateBusinessDto) {
    return this.merchantsService.updateBusiness(req.user.id, businessId, data);
  }

  @Delete('businesses/:businessId')
  @ApiOperation({ 
    summary: 'Delete a business',
    description: 'Soft deletes a business profile. The business and all its listings will be hidden from public view. Only the business owner can delete their business. This action can be reversed by an admin.'
  })
  @ApiParam({ name: 'businessId', type: String, description: 'Business UUID', example: '123e4567-e89b-12d3-a456-426614174000' })
  @ApiResponse({ 
    status: 200, 
    description: 'Business deleted successfully',
    schema: {
      type: 'object',
      properties: {
        success: { type: 'boolean', example: true },
        message: { type: 'string', example: 'Business deleted successfully' }
      }
    }
  })
  @ApiResponse({ status: 401, description: 'Unauthorized - Invalid or missing token' })
  @ApiResponse({ status: 403, description: 'Forbidden - Not authorized to delete this business' })
  @ApiResponse({ status: 404, description: 'Business not found' })
  async deleteBusiness(@Request() req, @Param('businessId') businessId: string) {
    return this.merchantsService.deleteBusiness(req.user.id, businessId);
  }

  // ============ LISTINGS ============
  @Get('businesses/:businessId/listings')
  @ApiOperation({ 
    summary: 'Get all listings for a business',
    description: 'Retrieves paginated list of listings owned by a specific business. Supports filtering by listing status. Useful for managing business listings and viewing their approval status.'
  })
  @ApiParam({ name: 'businessId', type: String, description: 'Business UUID', example: '123e4567-e89b-12d3-a456-426614174000' })
  @ApiQuery({ name: 'page', required: false, type: Number, example: 1, description: 'Page number (default: 1)' })
  @ApiQuery({ name: 'limit', required: false, type: Number, example: 20, description: 'Items per page (default: 20)' })
  @ApiQuery({ name: 'status', required: false, enum: ['draft', 'pending_review', 'active', 'inactive', 'rejected'], description: 'Filter by listing status', example: 'active' })
  @ApiResponse({ 
    status: 200, 
    description: 'Listings retrieved successfully',
    schema: {
      type: 'object',
      properties: {
        data: { type: 'array', items: { type: 'object' } },
        total: { type: 'number', example: 10 },
        page: { type: 'number', example: 1 },
        limit: { type: 'number', example: 20 }
      }
    }
  })
  @ApiResponse({ status: 401, description: 'Unauthorized - Invalid or missing token' })
  @ApiResponse({ status: 403, description: 'Forbidden - Not authorized to access this business' })
  @ApiResponse({ status: 404, description: 'Business not found' })
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
  @ApiOperation({ 
    summary: 'Submit listing for review',
    description: 'Submits a draft listing for admin review. The listing status will change from "draft" to "pending_review". Once approved by an admin, the listing will become "active" and visible to users. Rejected listings can be resubmitted after making corrections.'
  })
  @ApiParam({ name: 'businessId', type: String, description: 'Business UUID', example: '123e4567-e89b-12d3-a456-426614174000' })
  @ApiParam({ name: 'listingId', type: String, description: 'Listing UUID', example: '123e4567-e89b-12d3-a456-426614174000' })
  @ApiResponse({ 
    status: 200, 
    description: 'Listing submitted for review successfully',
    schema: {
      type: 'object',
      properties: {
        success: { type: 'boolean', example: true },
        message: { type: 'string', example: 'Listing submitted for review' },
        listing: { type: 'object', properties: { status: { type: 'string', example: 'pending_review' } } }
      }
    }
  })
  @ApiResponse({ status: 400, description: 'Bad request - Listing is not in draft status or missing required fields' })
  @ApiResponse({ status: 401, description: 'Unauthorized - Invalid or missing token' })
  @ApiResponse({ status: 403, description: 'Forbidden - Not authorized to submit this listing' })
  @ApiResponse({ status: 404, description: 'Business or listing not found' })
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
  @ApiOperation({ 
    summary: 'Get all bookings for a business',
    description: 'Retrieves paginated list of bookings for all listings owned by a business. Supports filtering by status, listing, and date range. Essential for managing reservations and tracking business bookings.'
  })
  @ApiParam({ name: 'businessId', type: String, description: 'Business UUID', example: '123e4567-e89b-12d3-a456-426614174000' })
  @ApiQuery({ name: 'page', required: false, type: Number, example: 1, description: 'Page number (default: 1)' })
  @ApiQuery({ name: 'limit', required: false, type: Number, example: 20, description: 'Items per page (default: 20)' })
  @ApiQuery({ name: 'status', required: false, enum: ['pending', 'confirmed', 'cancelled', 'completed', 'no_show'], description: 'Filter by booking status', example: 'confirmed' })
  @ApiQuery({ name: 'listingId', required: false, type: String, description: 'Filter by specific listing UUID', example: '123e4567-e89b-12d3-a456-426614174000' })
  @ApiQuery({ name: 'startDate', required: false, type: String, description: 'Filter bookings from this date (YYYY-MM-DD)', example: '2024-12-01' })
  @ApiQuery({ name: 'endDate', required: false, type: String, description: 'Filter bookings until this date (YYYY-MM-DD)', example: '2024-12-31' })
  @ApiResponse({ 
    status: 200, 
    description: 'Bookings retrieved successfully',
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
  @ApiResponse({ status: 401, description: 'Unauthorized - Invalid or missing token' })
  @ApiResponse({ status: 403, description: 'Forbidden - Not authorized to access this business' })
  @ApiResponse({ status: 404, description: 'Business not found' })
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
  @ApiOperation({ 
    summary: 'Update booking status (confirm, cancel, complete, no-show)',
    description: 'Updates the status of a booking. Merchants can confirm pending bookings, mark bookings as completed or no-show, and cancel bookings. Status changes may trigger notifications to customers.'
  })
  @ApiParam({ name: 'businessId', type: String, description: 'Business UUID', example: '123e4567-e89b-12d3-a456-426614174000' })
  @ApiParam({ name: 'bookingId', type: String, description: 'Booking UUID', example: '123e4567-e89b-12d3-a456-426614174000' })
  @ApiBody({ type: UpdateBookingStatusDto })
  @ApiResponse({ 
    status: 200, 
    description: 'Booking status updated successfully',
    schema: {
      type: 'object',
      properties: {
        success: { type: 'boolean', example: true },
        message: { type: 'string', example: 'Booking status updated successfully' },
        booking: { type: 'object', properties: { status: { type: 'string', example: 'confirmed' } } }
      }
    }
  })
  @ApiResponse({ status: 400, description: 'Bad request - Invalid status transition or missing status' })
  @ApiResponse({ status: 401, description: 'Unauthorized - Invalid or missing token' })
  @ApiResponse({ status: 403, description: 'Forbidden - Not authorized to update this booking' })
  @ApiResponse({ status: 404, description: 'Business or booking not found' })
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
  @ApiOperation({ 
    summary: 'Get business dashboard overview',
    description: 'Retrieves comprehensive dashboard data for a business including key metrics, recent bookings, revenue summary, listing statistics, and review summaries. Essential for merchant dashboard screens.'
  })
  @ApiParam({ name: 'businessId', type: String, description: 'Business UUID', example: '123e4567-e89b-12d3-a456-426614174000' })
  @ApiResponse({ 
    status: 200, 
    description: 'Dashboard data retrieved successfully',
    schema: {
      type: 'object',
      properties: {
        totalBookings: { type: 'number', example: 150 },
        totalRevenue: { type: 'number', example: 45000.00 },
        activeListings: { type: 'number', example: 5 },
        averageRating: { type: 'number', example: 4.5 },
        recentBookings: { type: 'array', items: { type: 'object' } },
        revenueByPeriod: { type: 'object' }
      }
    }
  })
  @ApiResponse({ status: 401, description: 'Unauthorized - Invalid or missing token' })
  @ApiResponse({ status: 403, description: 'Forbidden - Not authorized to access this business' })
  @ApiResponse({ status: 404, description: 'Business not found' })
  async getDashboard(@Request() req, @Param('businessId') businessId: string) {
    return this.merchantsService.getDashboard(req.user.id, businessId);
  }

  @Get('businesses/:businessId/analytics/revenue')
  @ApiOperation({ 
    summary: 'Get revenue analytics',
    description: 'Retrieves detailed revenue analytics for a business. Supports date range filtering and grouping by day, week, month, or year. Useful for revenue reports and financial analysis.'
  })
  @ApiParam({ name: 'businessId', type: String, description: 'Business UUID', example: '123e4567-e89b-12d3-a456-426614174000' })
  @ApiQuery({ name: 'startDate', required: false, type: String, description: 'Start date for analytics (YYYY-MM-DD)', example: '2024-12-01' })
  @ApiQuery({ name: 'endDate', required: false, type: String, description: 'End date for analytics (YYYY-MM-DD)', example: '2024-12-31' })
  @ApiQuery({ name: 'groupBy', required: false, enum: ['day', 'week', 'month', 'year'], description: 'Group revenue data by time period', example: 'month' })
  @ApiResponse({ 
    status: 200, 
    description: 'Revenue analytics retrieved successfully',
    schema: {
      type: 'object',
      properties: {
        totalRevenue: { type: 'number', example: 45000.00 },
        periodData: { 
          type: 'array',
          items: {
            type: 'object',
            properties: {
              period: { type: 'string', example: '2024-12' },
              revenue: { type: 'number', example: 15000.00 },
              bookingCount: { type: 'number', example: 50 }
            }
          }
        }
      }
    }
  })
  @ApiResponse({ status: 401, description: 'Unauthorized - Invalid or missing token' })
  @ApiResponse({ status: 403, description: 'Forbidden - Not authorized to access this business' })
  @ApiResponse({ status: 404, description: 'Business not found' })
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

