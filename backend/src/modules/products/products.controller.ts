import { Controller, Get, Post, Put, Delete, Param, Body, Query, UseGuards, Request, HttpCode, HttpStatus } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth, ApiQuery, ApiParam, ApiResponse, ApiBody } from '@nestjs/swagger';
import { ProductsService } from './products.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import {
  CreateProductDto,
  UpdateProductDto,
  ProductQueryDto,
  CreateProductVariantDto,
  UpdateProductVariantDto,
  ProductStatus,
} from './dto/product.dto';

@ApiTags('Products')
@Controller('products')
export class ProductsController {
  constructor(private productsService: ProductsService) {}

  @Get()
  @ApiOperation({ 
    summary: 'Get all products with filters and sorting',
    description: 'Retrieve paginated products with optional filters and sorting. Supports filtering by listing, status, category, price range, and more. Useful for product browsing, search, and catalog display.'
  })
  @ApiQuery({ name: 'page', required: false, type: Number, example: 1, description: 'Page number (default: 1)' })
  @ApiQuery({ name: 'limit', required: false, type: Number, example: 20, description: 'Items per page (default: 20)' })
  @ApiQuery({ name: 'listingId', required: false, type: String, description: 'Filter by listing UUID' })
  @ApiQuery({ name: 'status', required: false, enum: ProductStatus, description: 'Filter by product status', example: 'active' })
  @ApiQuery({ name: 'search', required: false, type: String, description: 'Search in name and description', example: 'leather bag' })
  @ApiQuery({ name: 'category', required: false, type: String, description: 'Filter by category', example: 'apparel' })
  @ApiQuery({ name: 'minPrice', required: false, type: Number, description: 'Minimum price filter', example: 10000 })
  @ApiQuery({ name: 'maxPrice', required: false, type: Number, description: 'Maximum price filter', example: 100000 })
  @ApiQuery({ name: 'isFeatured', required: false, type: Boolean, description: 'Filter for featured products only', example: true })
  @ApiQuery({ 
    name: 'sortBy', 
    required: false, 
    enum: ['popular', 'name_asc', 'name_desc', 'price_asc', 'price_desc', 'createdAt_desc', 'createdAt_asc'],
    description: 'Sort order',
    example: 'popular'
  })
  @ApiResponse({ 
    status: 200, 
    description: 'Products retrieved successfully',
    schema: {
      type: 'object',
      properties: {
        data: { type: 'array', items: { type: 'object' } },
        meta: {
          type: 'object',
          properties: {
            total: { type: 'number', example: 50 },
            page: { type: 'number', example: 1 },
            limit: { type: 'number', example: 20 },
            totalPages: { type: 'number', example: 3 }
          }
        }
      }
    }
  })
  async findAll(@Query() query: ProductQueryDto) {
    return this.productsService.findAll({
      ...query,
      page: query.page || 1,
      limit: query.limit || 20,
    });
  }

  @Get('listing/:listingId')
  @ApiOperation({ 
    summary: 'Get products by listing',
    description: 'Retrieve all products for a specific listing with optional filters and sorting.'
  })
  @ApiParam({ name: 'listingId', description: 'Listing UUID' })
  @ApiQuery({ name: 'page', required: false, type: Number })
  @ApiQuery({ name: 'limit', required: false, type: Number })
  @ApiQuery({ name: 'status', required: false, enum: ProductStatus })
  @ApiQuery({ name: 'search', required: false, type: String })
  @ApiQuery({ name: 'category', required: false, type: String })
  async findByListing(
    @Param('listingId') listingId: string,
    @Query() query: ProductQueryDto,
  ) {
    return this.productsService.findByListing(listingId, query);
  }

  @Get(':id')
  @ApiOperation({ 
    summary: 'Get product by ID',
    description: 'Retrieve a single product with all details including variants, inventory information, pricing, and related listing data. Useful for product detail pages.'
  })
  @ApiParam({ name: 'id', type: String, description: 'Product UUID', example: '123e4567-e89b-12d3-a456-426614174000' })
  @ApiResponse({ 
    status: 200, 
    description: 'Product retrieved successfully',
    schema: { type: 'object' }
  })
  @ApiResponse({ status: 404, description: 'Product not found' })
  async findOne(@Param('id') id: string) {
    return this.productsService.findOne(id);
  }

  @Post()
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ 
    summary: 'Create a new product',
    description: 'Create a new product for a listing. Requires authentication and ownership of the listing. Product will be created in draft status by default. Supports inventory tracking, variants, and pricing.'
  })
  @ApiBody({ type: CreateProductDto })
  @ApiResponse({ 
    status: 201, 
    description: 'Product created successfully',
    schema: {
      type: 'object',
      properties: {
        id: { type: 'string' },
        name: { type: 'string', example: 'Handmade Leather Bag' },
        slug: { type: 'string', example: 'handmade-leather-bag' },
        status: { type: 'string', enum: ['draft', 'active', 'inactive', 'out_of_stock'], example: 'draft' },
        basePrice: { type: 'number', example: 50000 }
      }
    }
  })
  @ApiResponse({ status: 400, description: 'Bad request - Duplicate slug or SKU, invalid data' })
  @ApiResponse({ status: 401, description: 'Unauthorized - Invalid or missing token' })
  @ApiResponse({ status: 403, description: 'Forbidden - Not the owner of the listing' })
  @ApiResponse({ status: 404, description: 'Listing not found' })
  async create(@Request() req, @Body() createProductDto: CreateProductDto) {
    return this.productsService.create(req.user.userId, createProductDto);
  }

  @Put(':id')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ 
    summary: 'Update a product',
    description: 'Update an existing product. Requires authentication and ownership of the listing. All fields are optional - only provided fields will be updated.'
  })
  @ApiParam({ name: 'id', type: String, description: 'Product UUID', example: '123e4567-e89b-12d3-a456-426614174000' })
  @ApiBody({ type: UpdateProductDto })
  @ApiResponse({ 
    status: 200, 
    description: 'Product updated successfully',
    schema: { type: 'object' }
  })
  @ApiResponse({ status: 400, description: 'Bad request - Duplicate slug or SKU, invalid data' })
  @ApiResponse({ status: 401, description: 'Unauthorized - Invalid or missing token' })
  @ApiResponse({ status: 403, description: 'Forbidden - Not the owner of the listing' })
  @ApiResponse({ status: 404, description: 'Product not found' })
  async update(
    @Param('id') id: string,
    @Request() req,
    @Body() updateProductDto: UpdateProductDto,
  ) {
    return this.productsService.update(id, req.user.userId, updateProductDto);
  }

  @Delete(':id')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ 
    summary: 'Delete a product',
    description: 'Soft delete a product. The product is marked as deleted but not removed from the database. Requires authentication and ownership of the listing.'
  })
  @ApiParam({ name: 'id', type: String, description: 'Product UUID', example: '123e4567-e89b-12d3-a456-426614174000' })
  @ApiResponse({ 
    status: 200, 
    description: 'Product deleted successfully',
    schema: {
      type: 'object',
      properties: {
        message: { type: 'string', example: 'Product deleted successfully' }
      }
    }
  })
  @ApiResponse({ status: 401, description: 'Unauthorized - Invalid or missing token' })
  @ApiResponse({ status: 403, description: 'Forbidden - Not the owner of the listing' })
  @ApiResponse({ status: 404, description: 'Product not found' })
  async remove(@Param('id') id: string, @Request() req) {
    return this.productsService.remove(id, req.user.userId);
  }

  // Product Variants endpoints
  @Post(':productId/variants')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ 
    summary: 'Create a product variant',
    description: 'Create a new variant for a product (e.g., size, color). Variants allow products to have different options with separate pricing and inventory. Requires authentication and ownership.'
  })
  @ApiParam({ name: 'productId', type: String, description: 'Product UUID', example: '123e4567-e89b-12d3-a456-426614174000' })
  @ApiBody({ type: CreateProductVariantDto })
  @ApiResponse({ 
    status: 201, 
    description: 'Variant created successfully',
    schema: { type: 'object' }
  })
  @ApiResponse({ status: 400, description: 'Bad request - Duplicate SKU, invalid data' })
  @ApiResponse({ status: 401, description: 'Unauthorized - Invalid or missing token' })
  @ApiResponse({ status: 403, description: 'Forbidden - Not the owner' })
  @ApiResponse({ status: 404, description: 'Product not found' })
  async createVariant(
    @Param('productId') productId: string,
    @Request() req,
    @Body() createVariantDto: CreateProductVariantDto,
  ) {
    return this.productsService.createVariant(productId, req.user.userId, createVariantDto);
  }

  @Put('variants/:variantId')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ 
    summary: 'Update a product variant',
    description: 'Update an existing product variant. All fields are optional - only provided fields will be updated. Requires authentication and ownership.'
  })
  @ApiParam({ name: 'variantId', type: String, description: 'Variant UUID', example: '123e4567-e89b-12d3-a456-426614174000' })
  @ApiBody({ type: UpdateProductVariantDto })
  @ApiResponse({ 
    status: 200, 
    description: 'Variant updated successfully',
    schema: { type: 'object' }
  })
  @ApiResponse({ status: 400, description: 'Bad request - Duplicate SKU, invalid data' })
  @ApiResponse({ status: 401, description: 'Unauthorized - Invalid or missing token' })
  @ApiResponse({ status: 403, description: 'Forbidden - Not the owner' })
  @ApiResponse({ status: 404, description: 'Variant not found' })
  async updateVariant(
    @Param('variantId') variantId: string,
    @Request() req,
    @Body() updateVariantDto: UpdateProductVariantDto,
  ) {
    return this.productsService.updateVariant(variantId, req.user.userId, updateVariantDto);
  }

  @Delete('variants/:variantId')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ 
    summary: 'Delete a product variant',
    description: 'Permanently delete a product variant. This action cannot be undone. Requires authentication and ownership.'
  })
  @ApiParam({ name: 'variantId', type: String, description: 'Variant UUID', example: '123e4567-e89b-12d3-a456-426614174000' })
  @ApiResponse({ 
    status: 200, 
    description: 'Variant deleted successfully',
    schema: {
      type: 'object',
      properties: {
        message: { type: 'string', example: 'Variant deleted successfully' }
      }
    }
  })
  @ApiResponse({ status: 401, description: 'Unauthorized - Invalid or missing token' })
  @ApiResponse({ status: 403, description: 'Forbidden - Not the owner' })
  @ApiResponse({ status: 404, description: 'Variant not found' })
  async removeVariant(@Param('variantId') variantId: string, @Request() req) {
    return this.productsService.removeVariant(variantId, req.user.userId);
  }
}

