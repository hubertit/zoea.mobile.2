import { Controller, Get, Post, Put, Delete, Param, Query, Body, UseGuards } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth, ApiQuery, ApiParam, ApiResponse, ApiBody } from '@nestjs/swagger';
import { ToursService } from './tours.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { CreateTourDto, UpdateTourDto } from './dto/tour.dto';

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
    summary: 'Get available schedules for a tour',
    description: 'Retrieves available tour schedules within a date range. Useful for displaying booking options and checking availability. Returns schedules with available slots and pricing.'
  })
  @ApiParam({ name: 'id', type: String, description: 'Tour UUID', example: '123e4567-e89b-12d3-a456-426614174000' })
  @ApiQuery({ name: 'startDate', required: false, type: String, description: 'Filter schedules starting from this date', example: '2024-12-31T00:00:00Z' })
  @ApiQuery({ name: 'endDate', required: false, type: String, description: 'Filter schedules ending before this date', example: '2025-01-31T23:59:59Z' })
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
          startDate: { type: 'string' },
          endDate: { type: 'string' },
          availableSlots: { type: 'number', example: 10 },
          price: { type: 'number', example: 1500 }
        }
      }
    }
  })
  @ApiResponse({ status: 404, description: 'Tour not found' })
  async getSchedules(
    @Param('id') id: string,
    @Query('startDate') startDate?: string,
    @Query('endDate') endDate?: string,
  ) {
    return this.toursService.getSchedules(
      id,
      startDate ? new Date(startDate) : undefined,
      endDate ? new Date(endDate) : undefined,
    );
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
  async create(@Body() data: CreateTourDto) {
    return this.toursService.create(data);
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
  async update(@Param('id') id: string, @Body() data: UpdateTourDto) {
    return this.toursService.update(id, data);
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
  async delete(@Param('id') id: string) {
    return this.toursService.delete(id);
  }
}

