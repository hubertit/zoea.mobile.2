import { Controller, Get, Post, Put, Delete, Param, Body, Query, UseGuards, Request, HttpCode, HttpStatus } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth, ApiQuery, ApiParam, ApiResponse, ApiBody } from '@nestjs/swagger';
import { ServicesService } from './services.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import {
  CreateServiceDto,
  UpdateServiceDto,
  ServiceQueryDto,
  CreateServiceBookingDto,
  UpdateServiceBookingDto,
  ServiceStatus,
} from './dto/service.dto';

@ApiTags('Services')
@Controller('services')
export class ServicesController {
  constructor(private servicesService: ServicesService) {}

  @Get()
  @ApiOperation({ 
    summary: 'Get all services with filters and sorting',
    description: 'Retrieve paginated services with optional filters and sorting.'
  })
  @ApiQuery({ name: 'page', required: false, type: Number, example: 1 })
  @ApiQuery({ name: 'limit', required: false, type: Number, example: 20 })
  @ApiQuery({ name: 'listingId', required: false, type: String })
  @ApiQuery({ name: 'status', required: false, enum: ServiceStatus })
  @ApiQuery({ name: 'search', required: false, type: String })
  @ApiQuery({ name: 'category', required: false, type: String })
  @ApiQuery({ name: 'minPrice', required: false, type: Number })
  @ApiQuery({ name: 'maxPrice', required: false, type: Number })
  @ApiQuery({ name: 'isFeatured', required: false, type: Boolean })
  @ApiQuery({ name: 'sortBy', required: false, enum: ['popular', 'name_asc', 'name_desc', 'price_asc', 'price_desc', 'createdAt_desc', 'createdAt_asc'] })
  async findAll(@Query() query: ServiceQueryDto) {
    return this.servicesService.findAll({
      ...query,
      page: query.page || 1,
      limit: query.limit || 20,
    });
  }

  @Get('listing/:listingId')
  @ApiOperation({ summary: 'Get services by listing' })
  @ApiParam({ name: 'listingId', description: 'Listing UUID' })
  async findByListing(
    @Param('listingId') listingId: string,
    @Query() query: ServiceQueryDto,
  ) {
    return this.servicesService.findByListing(listingId, query);
  }

  @Get(':id')
  @ApiOperation({ summary: 'Get service by ID' })
  @ApiParam({ name: 'id', description: 'Service UUID' })
  @ApiResponse({ status: 200, description: 'Service found' })
  @ApiResponse({ status: 404, description: 'Service not found' })
  async findOne(@Param('id') id: string) {
    return this.servicesService.findOne(id);
  }

  @Post()
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Create a new service' })
  @ApiResponse({ status: 201, description: 'Service created successfully' })
  @ApiResponse({ status: 403, description: 'Forbidden - not the owner' })
  async create(@Request() req, @Body() createServiceDto: CreateServiceDto) {
    return this.servicesService.create(req.user.userId, createServiceDto);
  }

  @Put(':id')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Update a service' })
  @ApiParam({ name: 'id', description: 'Service UUID' })
  @ApiResponse({ status: 200, description: 'Service updated successfully' })
  @ApiResponse({ status: 403, description: 'Forbidden - not the owner' })
  async update(
    @Param('id') id: string,
    @Request() req,
    @Body() updateServiceDto: UpdateServiceDto,
  ) {
    return this.servicesService.update(id, req.user.userId, updateServiceDto);
  }

  @Delete(':id')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Delete a service' })
  @ApiParam({ name: 'id', description: 'Service UUID' })
  @ApiResponse({ status: 200, description: 'Service deleted successfully' })
  async remove(@Param('id') id: string, @Request() req) {
    return this.servicesService.remove(id, req.user.userId);
  }

  // Service Bookings
  @Post(':serviceId/bookings')
  @ApiOperation({ 
    summary: 'Book a service',
    description: 'Create a service booking. Works for both authenticated and guest users. Validates availability, concurrent booking limits, and advance booking days. Automatically creates service booking record.'
  })
  @ApiParam({ name: 'serviceId', type: String, description: 'Service UUID', example: '123e4567-e89b-12d3-a456-426614174000' })
  @ApiBody({ type: CreateServiceBookingDto })
  @ApiResponse({ 
    status: 201, 
    description: 'Service booking created successfully',
    schema: {
      type: 'object',
      properties: {
        id: { type: 'string' },
        bookingDate: { type: 'string', format: 'date' },
        bookingTime: { type: 'string', example: '14:00' },
        status: { type: 'string', enum: ['pending', 'confirmed', 'completed', 'cancelled', 'no_show'], example: 'pending' }
      }
    }
  })
  @ApiResponse({ status: 400, description: 'Bad request - Time slot full, service unavailable, invalid dates, or exceeds advance booking days' })
  @ApiResponse({ status: 404, description: 'Service not found' })
  async createBooking(
    @Param('serviceId') serviceId: string,
    @Request() req,
    @Body() createBookingDto: CreateServiceBookingDto,
  ) {
    const userId = req.user?.userId || null;
    return this.servicesService.createBooking(serviceId, userId, createBookingDto);
  }

  @Get(':serviceId/bookings')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ 
    summary: 'Get all bookings for a service (merchant only)',
    description: 'Retrieve all bookings for a specific service. Only accessible by the merchant who owns the listing. Returns bookings sorted by date and time (earliest first).'
  })
  @ApiParam({ name: 'serviceId', type: String, description: 'Service UUID', example: '123e4567-e89b-12d3-a456-426614174000' })
  @ApiResponse({ 
    status: 200, 
    description: 'Bookings retrieved successfully',
    schema: {
      type: 'array',
      items: { type: 'object' }
    }
  })
  @ApiResponse({ status: 401, description: 'Unauthorized - Invalid or missing token' })
  @ApiResponse({ status: 403, description: 'Forbidden - Not the owner of the listing' })
  @ApiResponse({ status: 404, description: 'Service not found' })
  async getBookings(@Param('serviceId') serviceId: string, @Request() req) {
    return this.servicesService.getBookings(serviceId, req.user.userId);
  }

  @Put('bookings/:bookingId')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ 
    summary: 'Update a service booking',
    description: 'Update a service booking status or special requests. Can be updated by either the customer (booking owner) or the merchant (listing owner).'
  })
  @ApiParam({ name: 'bookingId', type: String, description: 'Booking UUID', example: '123e4567-e89b-12d3-a456-426614174000' })
  @ApiBody({ type: UpdateServiceBookingDto })
  @ApiResponse({ 
    status: 200, 
    description: 'Booking updated successfully',
    schema: { type: 'object' }
  })
  @ApiResponse({ status: 401, description: 'Unauthorized - Invalid or missing token' })
  @ApiResponse({ status: 403, description: 'Forbidden - Not authorized to update this booking' })
  @ApiResponse({ status: 404, description: 'Booking not found' })
  async updateBooking(
    @Param('bookingId') bookingId: string,
    @Request() req,
    @Body() updateBookingDto: UpdateServiceBookingDto,
  ) {
    return this.servicesService.updateBooking(bookingId, req.user.userId, updateBookingDto);
  }
}

