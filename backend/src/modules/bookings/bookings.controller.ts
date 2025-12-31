import { Controller, Get, Post, Put, Param, Query, Body, UseGuards, Request } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth, ApiQuery, ApiParam, ApiResponse, ApiBody } from '@nestjs/swagger';
import { BookingsService } from './bookings.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { CreateBookingDto, UpdateBookingDto, CancelBookingDto, ConfirmPaymentDto, BookingQueryDto } from './dto/booking.dto';

@ApiTags('Bookings')
@Controller('bookings')
@UseGuards(JwtAuthGuard)
@ApiBearerAuth()
export class BookingsController {
  constructor(private bookingsService: BookingsService) {}

  @Get()
  @ApiOperation({ 
    summary: 'Get my bookings',
    description: 'Retrieves paginated list of bookings for the authenticated user. Supports filtering by status and type. Useful for displaying booking history and managing reservations.'
  })
  @ApiQuery({ name: 'page', required: false, type: Number, example: 1, description: 'Page number (default: 1)' })
  @ApiQuery({ name: 'limit', required: false, type: Number, example: 20, description: 'Items per page (default: 20)' })
  @ApiQuery({ name: 'status', required: false, enum: ['pending', 'confirmed', 'completed', 'cancelled'], description: 'Filter by booking status', example: 'confirmed' })
  @ApiQuery({ name: 'type', required: false, enum: ['hotel', 'restaurant', 'event', 'tour'], description: 'Filter by booking type', example: 'hotel' })
  @ApiResponse({ 
    status: 200, 
    description: 'Bookings retrieved successfully',
    schema: {
      type: 'object',
      properties: {
        data: { type: 'array', items: { type: 'object' } },
        total: { type: 'number', example: 25 },
        page: { type: 'number', example: 1 },
        limit: { type: 'number', example: 20 }
      }
    }
  })
  @ApiResponse({ status: 401, description: 'Unauthorized - Invalid or missing token' })
  async findAll(@Request() req, @Query() query: BookingQueryDto) {
    return this.bookingsService.findAll(req.user.id, {
      page: query.page ? +query.page : 1,
      limit: query.limit ? +query.limit : 20,
      status: query.status,
      type: query.type,
    });
  }

  @Get('upcoming')
  @ApiOperation({ 
    summary: 'Get upcoming bookings',
    description: 'Retrieves upcoming bookings for the authenticated user. Returns bookings with start dates in the future, sorted by date (earliest first). Useful for displaying "Upcoming" section.'
  })
  @ApiQuery({ name: 'limit', required: false, type: Number, example: 5, description: 'Maximum number of bookings to return (default: 5)' })
  @ApiResponse({ 
    status: 200, 
    description: 'Upcoming bookings retrieved successfully',
    schema: {
      type: 'array',
      items: { type: 'object' }
    }
  })
  @ApiResponse({ status: 401, description: 'Unauthorized - Invalid or missing token' })
  async getUpcoming(@Request() req, @Query('limit') limit?: string) {
    return this.bookingsService.getUpcoming(req.user.id, limit ? +limit : 5);
  }

  @Get(':id')
  @ApiOperation({ 
    summary: 'Get booking details',
    description: 'Retrieves detailed information about a specific booking including dates, guests, pricing, payment status, and cancellation policy.'
  })
  @ApiParam({ name: 'id', type: String, description: 'Booking UUID', example: '123e4567-e89b-12d3-a456-426614174000' })
  @ApiResponse({ 
    status: 200, 
    description: 'Booking retrieved successfully',
    schema: { type: 'object' }
  })
  @ApiResponse({ status: 401, description: 'Unauthorized - Invalid or missing token' })
  @ApiResponse({ status: 403, description: 'Forbidden - Not authorized to view this booking' })
  @ApiResponse({ status: 404, description: 'Booking not found' })
  async findOne(@Param('id') id: string, @Request() req) {
    return this.bookingsService.findOne(id, req.user.id);
  }

  @Post()
  @ApiOperation({ 
    summary: 'Create a booking',
    description: 'Creates a new booking for a listing (hotel, restaurant) or event. Requires valid dates, guest counts, and payment information. Booking will be in "pending" status until payment is confirmed.'
  })
  @ApiBody({ type: CreateBookingDto })
  @ApiResponse({ 
    status: 201, 
    description: 'Booking created successfully',
    schema: {
      type: 'object',
      properties: {
        id: { type: 'string' },
        status: { type: 'string', enum: ['pending', 'confirmed', 'completed', 'cancelled'], example: 'pending' },
        totalAmount: { type: 'number', example: 150.00 },
        currency: { type: 'string', example: 'USD' },
        checkInDate: { type: 'string' },
        checkOutDate: { type: 'string', nullable: true }
      }
    }
  })
  @ApiResponse({ status: 400, description: 'Bad request - Invalid dates, unavailable slots, or invalid input data' })
  @ApiResponse({ status: 401, description: 'Unauthorized - Invalid or missing token' })
  @ApiResponse({ status: 404, description: 'Listing or event not found' })
  @ApiResponse({ status: 409, description: 'Conflict - No available slots for the requested dates' })
  async create(@Request() req, @Body() data: CreateBookingDto) {
    return this.bookingsService.create(req.user.id, data);
  }

  @Put(':id')
  @ApiOperation({ 
    summary: 'Update a booking',
    description: 'Updates booking details such as guest counts, special requests, or contact information. Only pending or confirmed bookings can be updated. Some changes may require re-confirmation.'
  })
  @ApiParam({ name: 'id', type: String, description: 'Booking UUID', example: '123e4567-e89b-12d3-a456-426614174000' })
  @ApiBody({ type: UpdateBookingDto })
  @ApiResponse({ 
    status: 200, 
    description: 'Booking updated successfully',
    schema: { type: 'object' }
  })
  @ApiResponse({ status: 400, description: 'Bad request - Invalid input data or booking cannot be updated' })
  @ApiResponse({ status: 401, description: 'Unauthorized - Invalid or missing token' })
  @ApiResponse({ status: 403, description: 'Forbidden - Not authorized to update this booking' })
  @ApiResponse({ status: 404, description: 'Booking not found' })
  async update(@Param('id') id: string, @Request() req, @Body() data: UpdateBookingDto) {
    return this.bookingsService.update(id, req.user.id, data);
  }

  @Post(':id/cancel')
  @ApiOperation({ 
    summary: 'Cancel a booking',
    description: 'Cancels a booking. Cancellation policies apply and refunds are processed according to the listing/event cancellation policy. Cancellation reason is required.'
  })
  @ApiParam({ name: 'id', type: String, description: 'Booking UUID', example: '123e4567-e89b-12d3-a456-426614174000' })
  @ApiBody({ type: CancelBookingDto })
  @ApiResponse({ 
    status: 200, 
    description: 'Booking cancelled successfully',
    schema: {
      type: 'object',
      properties: {
        success: { type: 'boolean', example: true },
        message: { type: 'string', example: 'Booking cancelled successfully' },
        refundAmount: { type: 'number', example: 120.00, description: 'Refund amount (if applicable)' }
      }
    }
  })
  @ApiResponse({ status: 400, description: 'Bad request - Booking cannot be cancelled or missing cancellation reason' })
  @ApiResponse({ status: 401, description: 'Unauthorized - Invalid or missing token' })
  @ApiResponse({ status: 403, description: 'Forbidden - Not authorized to cancel this booking' })
  @ApiResponse({ status: 404, description: 'Booking not found' })
  async cancel(@Param('id') id: string, @Request() req, @Body() data: CancelBookingDto) {
    return this.bookingsService.cancel(id, req.user.id, data.reason);
  }

  @Post(':id/confirm-payment')
  @ApiOperation({ 
    summary: 'Confirm payment for a booking',
    description: 'Confirms payment for a booking. Updates booking status from "pending" to "confirmed". Requires payment method and payment reference (transaction ID).'
  })
  @ApiParam({ name: 'id', type: String, description: 'Booking UUID', example: '123e4567-e89b-12d3-a456-426614174000' })
  @ApiBody({ type: ConfirmPaymentDto })
  @ApiResponse({ 
    status: 200, 
    description: 'Payment confirmed successfully',
    schema: {
      type: 'object',
      properties: {
        success: { type: 'boolean', example: true },
        message: { type: 'string', example: 'Payment confirmed successfully' },
        booking: { type: 'object', description: 'Updated booking with confirmed status' }
      }
    }
  })
  @ApiResponse({ status: 400, description: 'Bad request - Invalid payment information or booking already confirmed' })
  @ApiResponse({ status: 401, description: 'Unauthorized - Invalid or missing token' })
  @ApiResponse({ status: 404, description: 'Booking not found' })
  async confirmPayment(@Param('id') id: string, @Body() data: ConfirmPaymentDto) {
    return this.bookingsService.confirmPayment(id, data.paymentMethod, data.paymentReference);
  }
}
