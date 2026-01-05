import { Controller, Get, Post, Put, Delete, Param, Query, Body, UseGuards } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiQuery, ApiParam, ApiResponse, ApiBody, ApiBearerAuth } from '@nestjs/swagger';
import { CategoriesService } from './categories.service';
import { CreateCategoryDto } from './dto/create-category.dto';
import { UpdateCategoryDto } from './dto/update-category.dto';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { RolesGuard } from '../../common/guards/roles.guard';
import { Roles } from '../../common/decorators/roles.decorator';

@ApiTags('Categories')
@Controller('categories')
export class CategoriesController {
  constructor(private categoriesService: CategoriesService) {}

  @Get()
  @ApiOperation({ 
    summary: 'Get all categories',
    description: 'Retrieves all active categories. Supports hierarchical categories via parentId. Returns top-level categories by default, or subcategories if parentId is provided. Use flat=true to get all categories in a flat list.'
  })
  @ApiQuery({ name: 'parentId', required: false, type: String, description: 'Filter by parent category ID to get subcategories', example: '123e4567-e89b-12d3-a456-426614174000' })
  @ApiQuery({ name: 'flat', required: false, type: Boolean, description: 'Return all categories in a flat list (ignores parentId filter)', example: true })
  @ApiResponse({ 
    status: 200, 
    description: 'Categories retrieved successfully',
    schema: {
      type: 'array',
      items: {
        type: 'object',
        properties: {
          id: { type: 'string' },
          name: { type: 'string', example: 'Attractions' },
          slug: { type: 'string', example: 'attractions' },
          parentId: { type: 'string', nullable: true },
          icon: { type: 'string', example: 'icon-url' },
          imageId: { type: 'string', nullable: true },
          description: { type: 'string', nullable: true },
          sortOrder: { type: 'number', example: 1 },
          isActive: { type: 'boolean', example: true }
        }
      }
    }
  })
  async findAll(@Query('parentId') parentId?: string, @Query('flat') flat?: string) {
    return this.categoriesService.findAll(parentId, flat === 'true');
  }

  @Get('amenities')
  @ApiOperation({ 
    summary: 'Get all amenities',
    description: 'Retrieves all available amenities. Can be filtered by category to get category-specific amenities. Useful for listing creation and filtering.'
  })
  @ApiQuery({ name: 'category', required: false, type: String, description: 'Filter amenities by category ID', example: '123e4567-e89b-12d3-a456-426614174000' })
  @ApiResponse({ 
    status: 200, 
    description: 'Amenities retrieved successfully',
    schema: {
      type: 'array',
      items: {
        type: 'object',
        properties: {
          id: { type: 'string' },
          name: { type: 'string', example: 'Wi-Fi' },
          icon: { type: 'string', example: 'wifi-icon' },
          category: { type: 'string', nullable: true }
        }
      }
    }
  })
  async getAmenities(@Query('category') category?: string) {
    return this.categoriesService.getAmenities(category);
  }

  @Get('tags')
  @ApiOperation({ 
    summary: 'Get all tags',
    description: 'Retrieves all available tags. Can be filtered by category. Tags are used for content organization and search enhancement.'
  })
  @ApiQuery({ name: 'category', required: false, type: String, description: 'Filter tags by category ID', example: '123e4567-e89b-12d3-a456-426614174000' })
  @ApiResponse({ 
    status: 200, 
    description: 'Tags retrieved successfully',
    schema: {
      type: 'array',
      items: {
        type: 'object',
        properties: {
          id: { type: 'string' },
          name: { type: 'string', example: 'luxury' },
          category: { type: 'string', nullable: true }
        }
      }
    }
  })
  async getTags(@Query('category') category?: string) {
    return this.categoriesService.getTags(category);
  }

  @Get('listings')
  @ApiOperation({ 
    summary: 'Get listing categories',
    description: 'Retrieves categories specifically for listings. Alias for GET /categories. Returns all active categories that can be used for listings.'
  })
  @ApiResponse({ 
    status: 200, 
    description: 'Listing categories retrieved successfully',
    schema: {
      type: 'array',
      items: { type: 'object' }
    }
  })
  async getListingCategories() {
    return this.categoriesService.findAll();
  }

  @Get('event-contexts')
  @ApiOperation({ 
    summary: 'Get event contexts/types',
    description: 'Retrieves categories used for event classification (event contexts). Supports hierarchical structure via parentId. Used for filtering and organizing events.'
  })
  @ApiQuery({ name: 'parentId', required: false, type: String, description: 'Filter by parent context ID to get sub-contexts', example: '123e4567-e89b-12d3-a456-426614174000' })
  @ApiResponse({ 
    status: 200, 
    description: 'Event contexts retrieved successfully',
    schema: {
      type: 'array',
      items: { type: 'object' }
    }
  })
  async getEventContexts(@Query('parentId') parentId?: string) {
    return this.categoriesService.getEventContexts(parentId);
  }

  @Get('slug/:slug')
  @ApiOperation({ 
    summary: 'Get category by slug',
    description: 'Retrieves a single category by its URL-friendly slug. Useful for SEO-friendly URLs and category detail pages.'
  })
  @ApiParam({ name: 'slug', type: String, description: 'Category slug', example: 'attractions' })
  @ApiResponse({ 
    status: 200, 
    description: 'Category retrieved successfully',
    schema: { type: 'object' }
  })
  @ApiResponse({ status: 404, description: 'Category not found' })
  async findBySlug(@Param('slug') slug: string) {
    return this.categoriesService.findBySlug(slug);
  }

  @Put(':id')
  @ApiBearerAuth()
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles('admin', 'super_admin')
  @ApiOperation({ 
    summary: 'Update a category',
    description: 'Updates an existing category. Supports updating name, description, icon, image, parent relationship, and sort order. Requires admin privileges.'
  })
  @ApiParam({ name: 'id', type: String, description: 'Category UUID', example: '123e4567-e89b-12d3-a456-426614174000' })
  @ApiBody({ type: UpdateCategoryDto })
  @ApiResponse({ 
    status: 200, 
    description: 'Category updated successfully',
    schema: { type: 'object' }
  })
  @ApiResponse({ status: 400, description: 'Bad request - Invalid input data' })
  @ApiResponse({ status: 404, description: 'Category not found' })
  async update(@Param('id') id: string, @Body() updateCategoryDto: UpdateCategoryDto) {
    return this.categoriesService.update(id, updateCategoryDto);
  }

  @Delete(':id')
  @ApiBearerAuth()
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles('admin', 'super_admin')
  @ApiOperation({ 
    summary: 'Delete a category',
    description: 'Deletes a category. Prevents deletion if category has associated listings or tours. Requires admin privileges.'
  })
  @ApiParam({ name: 'id', type: String, description: 'Category UUID', example: '123e4567-e89b-12d3-a456-426614174000' })
  @ApiResponse({ 
    status: 200, 
    description: 'Category deleted successfully'
  })
  @ApiResponse({ status: 400, description: 'Bad request - Category has associated listings or tours' })
  @ApiResponse({ status: 404, description: 'Category not found' })
  async delete(@Param('id') id: string) {
    return this.categoriesService.delete(id);
  }

  @Get(':id')
  @ApiOperation({ 
    summary: 'Get category by ID',
    description: 'Retrieves detailed information about a specific category including its subcategories, associated listings count, and metadata.'
  })
  @ApiParam({ name: 'id', type: String, description: 'Category UUID', example: '123e4567-e89b-12d3-a456-426614174000' })
  @ApiResponse({ 
    status: 200, 
    description: 'Category retrieved successfully',
    schema: { type: 'object' }
  })
  @ApiResponse({ status: 404, description: 'Category not found' })
  async findOne(@Param('id') id: string) {
    return this.categoriesService.findOne(id);
  }

  @Post()
  @ApiBearerAuth()
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles('admin', 'super_admin')
  @ApiOperation({ 
    summary: 'Create a new category',
    description: 'Creates a new category. Can be a top-level category or a subcategory (via parentId). Requires admin privileges.'
  })
  @ApiBody({ type: CreateCategoryDto })
  @ApiResponse({ 
    status: 201, 
    description: 'Category created successfully',
    schema: {
      type: 'object',
      properties: {
        id: { type: 'string' },
        name: { type: 'string', example: 'New Category' },
        slug: { type: 'string', example: 'new-category' },
        parentId: { type: 'string', nullable: true },
        isActive: { type: 'boolean', example: true }
      }
    }
  })
  @ApiResponse({ status: 400, description: 'Bad request - Invalid input data or duplicate slug' })
  @ApiResponse({ status: 409, description: 'Conflict - Category with this slug already exists' })
  async create(@Body() createCategoryDto: CreateCategoryDto) {
    return this.categoriesService.create(createCategoryDto);
  }
}

