import { Controller, Get, Post, Put, Param, Query, Body, UseGuards, Request } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth, ApiQuery, ApiParam } from '@nestjs/swagger';
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
  @ApiOperation({ summary: 'Get my bookings' })
  @ApiQuery({ name: 'page', required: false, type: Number, example: 1 })
  @ApiQuery({ name: 'limit', required: false, type: Number, example: 20 })
  @ApiQuery({ name: 'status', required: false, enum: ['pending', 'confirmed', 'completed', 'cancelled'] })
  @ApiQuery({ name: 'type', required: false, enum: ['hotel', 'restaurant', 'event', 'tour'] })
  async findAll(@Request() req, @Query() query: BookingQueryDto) {
    return this.bookingsService.findAll(req.user.id, {
      page: query.page ? +query.page : 1,
      limit: query.limit ? +query.limit : 20,
      status: query.status,
      type: query.type,
    });
  }

  @Get('upcoming')
  @ApiOperation({ summary: 'Get upcoming bookings' })
  @ApiQuery({ name: 'limit', required: false, type: Number, example: 5 })
  async getUpcoming(@Request() req, @Query('limit') limit?: string) {
    return this.bookingsService.getUpcoming(req.user.id, limit ? +limit : 5);
  }

  @Get(':id')
  @ApiOperation({ summary: 'Get booking details' })
  @ApiParam({ name: 'id', description: 'Booking UUID' })
  async findOne(@Param('id') id: string, @Request() req) {
    return this.bookingsService.findOne(id, req.user.id);
  }

  @Post()
  @ApiOperation({ summary: 'Create a booking' })
  async create(@Request() req, @Body() data: CreateBookingDto) {
    return this.bookingsService.create(req.user.id, data);
  }

  @Put(':id')
  @ApiOperation({ summary: 'Update a booking' })
  @ApiParam({ name: 'id', description: 'Booking UUID' })
  async update(@Param('id') id: string, @Request() req, @Body() data: UpdateBookingDto) {
    return this.bookingsService.update(id, req.user.id, data);
  }

  @Post(':id/cancel')
  @ApiOperation({ summary: 'Cancel a booking' })
  @ApiParam({ name: 'id', description: 'Booking UUID' })
  async cancel(@Param('id') id: string, @Request() req, @Body() data: CancelBookingDto) {
    return this.bookingsService.cancel(id, req.user.id, data.reason);
  }

  @Post(':id/confirm-payment')
  @ApiOperation({ summary: 'Confirm payment for a booking' })
  @ApiParam({ name: 'id', description: 'Booking UUID' })
  async confirmPayment(@Param('id') id: string, @Body() data: ConfirmPaymentDto) {
    return this.bookingsService.confirmPayment(id, data.paymentMethod, data.paymentReference);
  }
}
