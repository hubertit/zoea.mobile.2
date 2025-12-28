import { Controller, Get, Post, Put, Delete, Param, Query, Body, UseGuards } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth, ApiQuery } from '@nestjs/swagger';
import { ToursService } from './tours.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { CreateTourDto, UpdateTourDto } from './dto/tour.dto';

@ApiTags('Tours')
@Controller('tours')
export class ToursController {
  constructor(private toursService: ToursService) {}

  @Get()
  @ApiOperation({ summary: 'Get all tours with filters' })
  @ApiQuery({ name: 'page', required: false })
  @ApiQuery({ name: 'limit', required: false })
  @ApiQuery({ name: 'status', required: false })
  @ApiQuery({ name: 'cityId', required: false })
  @ApiQuery({ name: 'countryId', required: false })
  @ApiQuery({ name: 'categoryId', required: false })
  @ApiQuery({ name: 'type', required: false })
  @ApiQuery({ name: 'difficulty', required: false, enum: ['easy', 'moderate', 'challenging'] })
  @ApiQuery({ name: 'minPrice', required: false })
  @ApiQuery({ name: 'maxPrice', required: false })
  @ApiQuery({ name: 'search', required: false })
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
  @ApiOperation({ summary: 'Get featured tours' })
  async getFeatured(@Query('limit') limit?: string) {
    return this.toursService.getFeatured(limit ? +limit : 10);
  }

  @Get('slug/:slug')
  @ApiOperation({ summary: 'Get tour by slug' })
  async findBySlug(@Param('slug') slug: string) {
    return this.toursService.findBySlug(slug);
  }

  @Get(':id')
  @ApiOperation({ summary: 'Get tour by ID' })
  async findOne(@Param('id') id: string) {
    return this.toursService.findOne(id);
  }

  @Get(':id/schedules')
  @ApiOperation({ summary: 'Get available schedules for a tour' })
  @ApiQuery({ name: 'startDate', required: false })
  @ApiQuery({ name: 'endDate', required: false })
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
  @ApiOperation({ summary: 'Create a new tour' })
  async create(@Body() data: CreateTourDto) {
    return this.toursService.create(data);
  }

  @Put(':id')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Update a tour' })
  async update(@Param('id') id: string, @Body() data: UpdateTourDto) {
    return this.toursService.update(id, data);
  }

  @Delete(':id')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Delete a tour' })
  async delete(@Param('id') id: string) {
    return this.toursService.delete(id);
  }
}

