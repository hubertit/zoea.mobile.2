import { Controller, Get, Post, Put, Delete, Param, Query, Body, UseGuards, Request, ForbiddenException } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth, ApiQuery, ApiParam, ApiResponse, ApiBody } from '@nestjs/swagger';
import { ToursService } from './tours.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { CreateTourDto, UpdateTourDto } from './dto/tour.dto';
import { CreateTourScheduleDto, UpdateTourScheduleDto } from './dto/tour-schedule.dto';
import { Prisma } from '@prisma/client';

@ApiTags('Tours')
@Controller('tours')
export class ToursController {
  constructor(private toursService: ToursService) {}

  @Get()
  @ApiOperation({ 
    summary: 'Get all tours with filters',
    description: 'Retrieves paginated tours with comprehensive filtering options. Supports filtering by location, category, type, difficulty, price range, and search query. Results are sorted by popularity by default.'
  })
  @ApiQuery({ name: 'page', required: false, type: Number, example: 1, description: 'Page number (default: 1)' })
  @ApiQuery({ name: 'limit', required: false, type: Number, example: 20, description: 'Items per page (default: 20)' })
  @ApiQuery({ name: 'status', required: false, enum: ['draft', 'active', 'inactive', 'cancelled'], description: 'Filter by tour status (default: active)', example: 'active' })
  @ApiQuery({ name: 'cityId', required: false, type: String, description: 'Filter by city UUID', example: '123e4567-e89b-12d3-a456-426614174000' })
  @ApiQuery({ name: 'countryId', required: false, type: String, description: 'Filter by country UUID', example: '123e4567-e89b-12d3-a456-426614174000' })
  @ApiQuery({ name: 'categoryId', required: false, type: String, description: 'Filter by category UUID', example: '123e4567-e89b-12d3-a456-426614174000' })
  @ApiQuery({ name: 'type', required: false, type: String, description: 'Filter by tour type (e.g., hiking, cultural, wildlife)', example: 'hiking' })
  @ApiQuery({ name: 'difficulty', required: false, enum: ['easy', 'moderate', 'challenging'], description: 'Filter by difficulty level', example: 'moderate' })
  @ApiQuery({ name: 'minPrice', required: false, type: Number, description: 'Minimum price filter', example: 50 })
  @ApiQuery({ name: 'maxPrice', required: false, type: Number, description: 'Maximum price filter', example: 500 })
  @ApiQuery({ name: 'search', required: false, type: String, description: 'Search in tour name and description', example: 'gorilla trekking' })
  @ApiResponse({ 
    status: 200, 
    description: 'Tours retrieved successfully',
    schema: {
      type: 'object',
      properties: {
        data: { type: 'array', items: { type: 'object' } },
        total: { type: 'number', example: 100 },
        page: { type: 'number', example: 1 },
        limit: { type: 'number', example: 20 }
      }
    }
  })
  async findAll(
    @Query('page') page?: string,
    @Query('limit') limit?: string,
    @Query('status') status?: string,
    @Query('cityId') cityId?: string,
    @Query('countryId') countryId?: string,
    @Query('categoryId') categoryId?: string,
    @Query('type') type?: string,
    @Query('difficulty') difficulty?: string,
    @Query('minPrice') minPrice?: string,
    @Query('maxPrice') maxPrice?: string,
    @Query('search') search?: string,
  ) {
    return this.toursService.findAll({
      page: page ? +page : 1,
      limit: limit ? +limit : 20,
      status: status || 'active',
      cityId,
      countryId,
      categoryId,
      type,
      difficulty,
      minPrice: minPrice ? +minPrice : undefined,
      maxPrice: maxPrice ? +maxPrice : undefined,
      search,
    });
  }

  @Get('featured')
  @ApiOperation({ 
    summary: 'Get featured tours',
    description: 'Retrieves tours marked as featured. Featured tours are prioritized and displayed prominently. Useful for homepage or explore sections.'
  })
  @ApiQuery({ name: 'limit', required: false, type: Number, example: 10, description: 'Maximum number of tours to return (default: 10)' })
  @ApiResponse({ 
    status: 200, 
    description: 'Featured tours retrieved successfully',
    schema: {
      type: 'array',
      items: { type: 'object' }
    }
  })
  async getFeatured(@Query('limit') limit?: string) {
    return this.toursService.getFeatured(limit ? +limit : 10);
  }

  @Get('slug/:slug')
  @ApiOperation({ 
    summary: 'Get tour by slug',
    description: 'Retrieves a single tour by its URL-friendly slug. Useful for SEO-friendly URLs.'
  })
  @ApiParam({ name: 'slug', type: String, description: 'Tour slug', example: 'gorilla-trekking-rwanda' })
  @ApiResponse({ 
    status: 200, 
    description: 'Tour retrieved successfully',
    schema: { type: 'object' }
  })
  @ApiResponse({ status: 404, description: 'Tour not found' })
  async findBySlug(@Param('slug') slug: string) {
    return this.toursService.findBySlug(slug);
  }

  @Get(':id')
  @ApiOperation({ 
    summary: 'Get tour by ID',
    description: 'Retrieves detailed information about a specific tour including description, itinerary, pricing, schedules, and booking information.'
  })
  @ApiParam({ name: 'id', type: String, description: 'Tour UUID', example: '123e4567-e89b-12d3-a456-426614174000' })
  @ApiResponse({ 
    status: 200, 
    description: 'Tour retrieved successfully',
    schema: { type: 'object' }
  })
  @ApiResponse({ status: 404, description: 'Tour not found' })
  async findOne(@Param('id') id: string) {
    return this.toursService.findOne(id);
  }

  @Get(':id/schedules')
  @ApiOperation({ 
    summary: 'Get schedules for a tour',
    description: 'Retrieves tour schedules within a date range. Useful for displaying booking options and checking availability. Returns schedules with available slots and pricing.'
  })
  @ApiParam({ name: 'id', type: String, description: 'Tour UUID', example: '123e4567-e89b-12d3-a456-426614174000' })
  @ApiQuery({ name: 'startDate', required: false, type: String, description: 'Filter schedules starting from this date', example: '2024-12-31T00:00:00Z' })
  @ApiQuery({ name: 'endDate', required: false, type: String, description: 'Filter schedules ending before this date', example: '2025-01-31T23:59:59Z' })
  @ApiQuery({ name: 'includeUnavailable', required: false, type: Boolean, description: 'Include unavailable schedules (for management)', example: false })
  @ApiResponse({ 
    status: 200, 
    description: 'Tour schedules retrieved successfully',
    schema: {
      type: 'array',
      items: {
        type: 'object',
        properties: {
          id: { type: 'string' },
          tourId: { type: 'string' },
          date: { type: 'string' },
          startTime: { type: 'string' },
          availableSpots: { type: 'number', example: 10 },
          bookedSpots: { type: 'number', example: 5 },
          priceOverride: { type: 'number', example: 1500 },
          isAvailable: { type: 'boolean', example: true }
        }
      }
    }
  })
  @ApiResponse({ status: 404, description: 'Tour not found' })
  async getSchedules(
    @Param('id') id: string,
    @Query('startDate') startDate?: string,
    @Query('endDate') endDate?: string,
    @Query('includeUnavailable') includeUnavailable?: string,
  ) {
    return this.toursService.getSchedules(
      id,
      startDate ? new Date(startDate) : undefined,
      endDate ? new Date(endDate) : undefined,
      includeUnavailable === 'true',
    );
  }

  @Post(':id/schedules')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ 
    summary: 'Create a tour schedule',
    description: 'Creates a new schedule for a tour. Requires authentication and ownership of the tour.'
  })
  @ApiParam({ name: 'id', type: String, description: 'Tour UUID' })
  @ApiBody({ type: CreateTourScheduleDto })
  @ApiResponse({ status: 201, description: 'Schedule created successfully' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  @ApiResponse({ status: 403, description: 'Forbidden - Not authorized to create schedules for this tour' })
  @ApiResponse({ status: 404, description: 'Tour not found' })
  async createSchedule(
    @Param('id') tourId: string,
    @Request() req,
    @Body() data: CreateTourScheduleDto,
  ) {
    return this.toursService.createSchedule(req.user.userId, tourId, data);
  }

  @Put('schedules/:scheduleId')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ 
    summary: 'Update a tour schedule',
    description: 'Updates an existing tour schedule. Requires authentication and ownership of the tour.'
  })
  @ApiParam({ name: 'scheduleId', type: String, description: 'Schedule UUID' })
  @ApiBody({ type: UpdateTourScheduleDto })
  @ApiResponse({ status: 200, description: 'Schedule updated successfully' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  @ApiResponse({ status: 403, description: 'Forbidden - Not authorized to update this schedule' })
  @ApiResponse({ status: 404, description: 'Schedule not found' })
  async updateSchedule(
    @Param('scheduleId') scheduleId: string,
    @Request() req,
    @Body() data: UpdateTourScheduleDto,
  ) {
    return this.toursService.updateSchedule(req.user.userId, scheduleId, data);
  }

  @Delete('schedules/:scheduleId')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ 
    summary: 'Delete a tour schedule',
    description: 'Deletes a tour schedule. Requires authentication and ownership of the tour. Cannot delete schedules with existing bookings.'
  })
  @ApiParam({ name: 'scheduleId', type: String, description: 'Schedule UUID' })
  @ApiResponse({ status: 200, description: 'Schedule deleted successfully' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  @ApiResponse({ status: 403, description: 'Forbidden - Not authorized to delete this schedule' })
  @ApiResponse({ status: 404, description: 'Schedule not found' })
  async deleteSchedule(
    @Param('scheduleId') scheduleId: string,
    @Request() req,
  ) {
    return this.toursService.deleteSchedule(req.user.userId, scheduleId);
  }

  @Post()
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ 
    summary: 'Create a new tour',
    description: 'Creates a new tour. Requires authentication. The tour will be created in draft status and must be submitted for review before becoming active.'
  })
  @ApiBody({ type: CreateTourDto })
  @ApiResponse({ 
    status: 201, 
    description: 'Tour created successfully',
    schema: {
      type: 'object',
      properties: {
        id: { type: 'string' },
        name: { type: 'string', example: 'Gorilla Trekking Adventure' },
        status: { type: 'string', enum: ['draft', 'active', 'inactive'], example: 'draft' }
      }
    }
  })
  @ApiResponse({ status: 400, description: 'Bad request - Invalid input data' })
  @ApiResponse({ status: 401, description: 'Unauthorized - Invalid or missing token' })
  async create(@Request() req, @Body() data: CreateTourDto) {
    return this.toursService.create(req.user.userId, {
      operator: { connect: { id: data.operatorId } },
      name: data.name,
      slug: data.slug,
      description: data.description,
      shortDescription: data.shortDescription,
      type: data.type,
      category: data.categoryId ? { connect: { id: data.categoryId } } : undefined,
      country: data.countryId ? { connect: { id: data.countryId } } : undefined,
      city: data.cityId ? { connect: { id: data.cityId } } : undefined,
      startLocationName: data.startLocationName,
      endLocationName: data.endLocationName,
      durationDays: data.durationDays,
      durationHours: data.durationHours,
      pricePerPerson: data.pricePerPerson,
      currency: data.currency || 'USD',
      groupDiscountPercentage: data.groupDiscountPercentage,
      minGroupSize: data.minGroupSize,
      maxGroupSize: data.maxGroupSize,
      includes: data.includes || [],
      excludes: data.excludes || [],
      requirements: data.requirements || [],
      difficultyLevel: data.difficultyLevel,
      languages: data.languages || ['en'],
      itinerary: data.itinerary,
      status: 'draft',
    });
  }

  @Put(':id')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ 
    summary: 'Update a tour',
    description: 'Updates an existing tour. Only the tour owner or admin can update a tour. All fields are optional.'
  })
  @ApiParam({ name: 'id', type: String, description: 'Tour UUID', example: '123e4567-e89b-12d3-a456-426614174000' })
  @ApiBody({ type: UpdateTourDto })
  @ApiResponse({ 
    status: 200, 
    description: 'Tour updated successfully',
    schema: { type: 'object' }
  })
  @ApiResponse({ status: 400, description: 'Bad request - Invalid input data' })
  @ApiResponse({ status: 401, description: 'Unauthorized - Invalid or missing token' })
  @ApiResponse({ status: 403, description: 'Forbidden - Not authorized to update this tour' })
  @ApiResponse({ status: 404, description: 'Tour not found' })
  async update(@Param('id') id: string, @Request() req, @Body() data: UpdateTourDto) {
    const updateData: Prisma.TourUpdateInput = {};
    if (data.name !== undefined) updateData.name = data.name;
    if (data.slug !== undefined) updateData.slug = data.slug;
    if (data.description !== undefined) updateData.description = data.description;
    if (data.shortDescription !== undefined) updateData.shortDescription = data.shortDescription;
    if (data.type !== undefined) updateData.type = data.type;
    if (data.categoryId !== undefined) updateData.category = data.categoryId ? { connect: { id: data.categoryId } } : { disconnect: true };
    if (data.durationDays !== undefined) updateData.durationDays = data.durationDays;
    if (data.durationHours !== undefined) updateData.durationHours = data.durationHours;
    if (data.pricePerPerson !== undefined) updateData.pricePerPerson = data.pricePerPerson;
    if (data.currency !== undefined) updateData.currency = data.currency;
    if (data.groupDiscountPercentage !== undefined) updateData.groupDiscountPercentage = data.groupDiscountPercentage;
    if (data.maxGroupSize !== undefined) updateData.maxGroupSize = data.maxGroupSize;
    if (data.minGroupSize !== undefined) updateData.minGroupSize = data.minGroupSize;
    if (data.difficultyLevel !== undefined) updateData.difficultyLevel = data.difficultyLevel;
    if (data.languages !== undefined) updateData.languages = data.languages;
    if (data.includes !== undefined) updateData.includes = data.includes;
    if (data.excludes !== undefined) updateData.excludes = data.excludes;
    if (data.requirements !== undefined) updateData.requirements = data.requirements;
    if (data.itinerary !== undefined) updateData.itinerary = data.itinerary;
    return this.toursService.update(id, req.user.userId, updateData);
  }

  @Delete(':id')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ 
    summary: 'Delete a tour',
    description: 'Soft deletes a tour. Only the tour owner or admin can delete a tour. The tour will be marked as inactive and hidden from public listings.'
  })
  @ApiParam({ name: 'id', type: String, description: 'Tour UUID', example: '123e4567-e89b-12d3-a456-426614174000' })
  @ApiResponse({ 
    status: 200, 
    description: 'Tour deleted successfully',
    schema: {
      type: 'object',
      properties: {
        success: { type: 'boolean', example: true },
        message: { type: 'string', example: 'Tour deleted successfully' }
      }
    }
  })
  @ApiResponse({ status: 401, description: 'Unauthorized - Invalid or missing token' })
  @ApiResponse({ status: 403, description: 'Forbidden - Not authorized to delete this tour' })
  @ApiResponse({ status: 404, description: 'Tour not found' })
  async delete(@Param('id') id: string, @Request() req) {
    return this.toursService.delete(id, req.user.userId);
  }

  @Get('operator/:operatorId')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ 
    summary: 'Get tours for an operator',
    description: 'Retrieves all tours for a specific tour operator. Requires authentication and ownership of the operator profile.'
  })
  @ApiParam({ name: 'operatorId', type: String, description: 'Tour operator profile UUID', example: '123e4567-e89b-12d3-a456-426614174000' })
  @ApiQuery({ name: 'page', required: false, type: Number, example: 1 })
  @ApiQuery({ name: 'limit', required: false, type: Number, example: 20 })
  @ApiQuery({ name: 'status', required: false, type: String, description: 'Filter by status', example: 'active' })
  @ApiResponse({ 
    status: 200, 
    description: 'Tours retrieved successfully',
    schema: { type: 'object' }
  })
  @ApiResponse({ status: 401, description: 'Unauthorized - Invalid or missing token' })
  @ApiResponse({ status: 403, description: 'Forbidden - Not authorized to access this operator' })
  async getOperatorTours(
    @Param('operatorId') operatorId: string,
    @Query('page') page?: string,
    @Query('limit') limit?: string,
    @Query('status') status?: string,
    @Request() req,
  ) {
    // Verify operator ownership
    const hasAccess = await this.toursService.verifyOperatorAccess(operatorId, req.user.userId);
    if (!hasAccess) {
      throw new ForbiddenException('You do not have permission to access this operator');
    }

    return this.toursService.findByOperator(operatorId, {
      page: page ? +page : 1,
      limit: limit ? +limit : 20,
      status,
    });
  }
}

