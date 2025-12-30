import { Controller, Get, Post, Put, Param, Query, Body } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiQuery, ApiParam } from '@nestjs/swagger';
import { CategoriesService } from './categories.service';
import { CreateCategoryDto } from './dto/create-category.dto';
import { UpdateCategoryDto } from './dto/update-category.dto';

@ApiTags('Categories')
@Controller('categories')
export class CategoriesController {
  constructor(private categoriesService: CategoriesService) {}

  @Get()
  @ApiOperation({ summary: 'Get all categories' })
  @ApiQuery({ name: 'parentId', required: false })
  async findAll(@Query('parentId') parentId?: string) {
    return this.categoriesService.findAll(parentId);
  }

  @Get('amenities')
  @ApiOperation({ summary: 'Get all amenities' })
  @ApiQuery({ name: 'category', required: false })
  async getAmenities(@Query('category') category?: string) {
    return this.categoriesService.getAmenities(category);
  }

  @Get('tags')
  @ApiOperation({ summary: 'Get all tags' })
  @ApiQuery({ name: 'category', required: false })
  async getTags(@Query('category') category?: string) {
    return this.categoriesService.getTags(category);
  }

  @Get('listings')
  @ApiOperation({ summary: 'Get listing categories' })
  async getListingCategories() {
    return this.categoriesService.findAll();
  }

  @Get('event-contexts')
  @ApiOperation({ summary: 'Get event contexts/types' })
  @ApiQuery({ name: 'parentId', required: false })
  async getEventContexts(@Query('parentId') parentId?: string) {
    return this.categoriesService.getEventContexts(parentId);
  }

  @Get('slug/:slug')
  @ApiOperation({ summary: 'Get category by slug' })
  async findBySlug(@Param('slug') slug: string) {
    return this.categoriesService.findBySlug(slug);
  }

  @Put(':id')
  @ApiOperation({ summary: 'Update a category' })
  @ApiParam({ name: 'id', description: 'Category ID' })
  async update(@Param('id') id: string, @Body() updateCategoryDto: UpdateCategoryDto) {
    return this.categoriesService.update(id, updateCategoryDto);
  }

  @Get(':id')
  @ApiOperation({ summary: 'Get category by ID' })
  async findOne(@Param('id') id: string) {
    return this.categoriesService.findOne(id);
  }

  @Post()
  @ApiOperation({ summary: 'Create a new category' })
  async create(@Body() createCategoryDto: CreateCategoryDto) {
    return this.categoriesService.create(createCategoryDto);
  }
}

