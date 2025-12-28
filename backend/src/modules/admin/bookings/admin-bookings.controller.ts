import { Body, Controller, Get, Param, Patch, Post, Put, Query, Request, UseGuards } from '@nestjs/common';
import { ApiBearerAuth, ApiOperation, ApiTags } from '@nestjs/swagger';
import { Roles } from '../../../common/decorators/roles.decorator';
import { RolesGuard } from '../../../common/guards/roles.guard';
import { JwtAuthGuard } from '../../auth/guards/jwt-auth.guard';
import { AdminBookingsService } from './admin-bookings.service';
import { AdminListBookingsDto } from './dto/list-bookings.dto';
import { AdminUpdateBookingStatusDto } from './dto/update-booking-status.dto';
import { AdminCreateBookingDto, AdminUpdateBookingDetailsDto } from './dto/create-admin-booking.dto';

@ApiTags('Admin - Bookings')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard, RolesGuard)
@Roles('admin', 'super_admin')
@Controller('admin/bookings')
export class AdminBookingsController {
  constructor(private readonly adminBookingsService: AdminBookingsService) {}

  @Get()
  @ApiOperation({ summary: 'List bookings with filters' })
  async list(@Query() query: AdminListBookingsDto) {
    return this.adminBookingsService.listBookings(query);
  }

  @Get(':id')
  @ApiOperation({ summary: 'Get booking detail' })
  async get(@Param('id') id: string) {
    return this.adminBookingsService.getBooking(id);
  }

  @Post()
  @ApiOperation({ summary: 'Create booking on behalf of user' })
  async create(@Body() dto: AdminCreateBookingDto) {
    return this.adminBookingsService.createBooking(dto);
  }

  @Put(':id')
  @ApiOperation({ summary: 'Update booking details (notes, guest counts)' })
  async updateDetails(@Param('id') id: string, @Body() dto: AdminUpdateBookingDetailsDto) {
    return this.adminBookingsService.updateBookingDetails(id, dto);
  }

  @Patch(':id/status')
  @ApiOperation({ summary: 'Update booking status/payment state' })
  async updateStatus(@Param('id') id: string, @Request() req, @Body() dto: AdminUpdateBookingStatusDto) {
    return this.adminBookingsService.updateBookingStatus(id, req.user.id, dto);
  }
}


