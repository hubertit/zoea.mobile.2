import { Controller, Get, Post, Put, Delete, Param, Body, Query, UseGuards, Request, HttpCode, HttpStatus } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth, ApiQuery, ApiParam, ApiResponse } from '@nestjs/swagger';
import { MenusService } from './menus.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import {
  CreateMenuDto,
  UpdateMenuDto,
  MenuQueryDto,
  CreateMenuCategoryDto,
  UpdateMenuCategoryDto,
  CreateMenuItemDto,
  UpdateMenuItemDto,
} from './dto/menu.dto';

@ApiTags('Menus')
@Controller('menus')
export class MenusController {
  constructor(private menusService: MenusService) {}

  @Get()
  @ApiOperation({ 
    summary: 'Get all menus',
    description: 'Retrieve menus with optional filters. Returns menus with their items grouped by category.'
  })
  @ApiQuery({ name: 'listingId', required: false, type: String, description: 'Filter by listing ID' })
  @ApiQuery({ name: 'isActive', required: false, type: Boolean, description: 'Filter active menus only' })
  async findAll(@Query() query: MenuQueryDto) {
    return this.menusService.findAll(query);
  }

  @Get('listing/:listingId')
  @ApiOperation({ summary: 'Get menus by listing' })
  @ApiParam({ name: 'listingId', description: 'Listing UUID' })
  @ApiQuery({ name: 'isActive', required: false, type: Boolean })
  async findByListing(
    @Param('listingId') listingId: string,
    @Query() query: MenuQueryDto,
  ) {
    return this.menusService.findByListing(listingId, query);
  }

  @Get(':id')
  @ApiOperation({ summary: 'Get menu by ID with all items' })
  @ApiParam({ name: 'id', description: 'Menu UUID' })
  @ApiResponse({ status: 200, description: 'Menu found' })
  @ApiResponse({ status: 404, description: 'Menu not found' })
  async findOne(@Param('id') id: string) {
    return this.menusService.findOne(id);
  }

  @Post()
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Create a new menu' })
  @ApiResponse({ status: 201, description: 'Menu created successfully' })
  @ApiResponse({ status: 403, description: 'Forbidden - not the owner' })
  async create(@Request() req, @Body() createMenuDto: CreateMenuDto) {
    return this.menusService.create(req.user.userId, createMenuDto);
  }

  @Put(':id')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Update a menu' })
  @ApiParam({ name: 'id', description: 'Menu UUID' })
  @ApiResponse({ status: 200, description: 'Menu updated successfully' })
  @ApiResponse({ status: 403, description: 'Forbidden - not the owner' })
  async update(
    @Param('id') id: string,
    @Request() req,
    @Body() updateMenuDto: UpdateMenuDto,
  ) {
    return this.menusService.update(id, req.user.userId, updateMenuDto);
  }

  @Delete(':id')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Delete a menu' })
  @ApiParam({ name: 'id', description: 'Menu UUID' })
  @ApiResponse({ status: 200, description: 'Menu deleted successfully' })
  async remove(@Param('id') id: string, @Request() req) {
    return this.menusService.remove(id, req.user.userId);
  }

  // Menu Categories
  @Get('categories')
  @ApiOperation({ summary: 'Get all menu categories' })
  async findAllCategories() {
    return this.menusService.findAllCategories();
  }

  @Get('categories/:id')
  @ApiOperation({ summary: 'Get menu category by ID' })
  @ApiParam({ name: 'id', description: 'Category UUID' })
  async findCategory(@Param('id') id: string) {
    return this.menusService.findCategory(id);
  }

  @Post('categories')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Create a menu category' })
  @ApiResponse({ status: 201, description: 'Category created successfully' })
  async createCategory(@Body() createCategoryDto: CreateMenuCategoryDto) {
    return this.menusService.createCategory(createCategoryDto);
  }

  @Put('categories/:id')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Update a menu category' })
  @ApiParam({ name: 'id', description: 'Category UUID' })
  async updateCategory(
    @Param('id') id: string,
    @Body() updateCategoryDto: UpdateMenuCategoryDto,
  ) {
    return this.menusService.updateCategory(id, updateCategoryDto);
  }

  @Delete('categories/:id')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Delete a menu category' })
  @ApiParam({ name: 'id', description: 'Category UUID' })
  @ApiResponse({ status: 200, description: 'Category deleted successfully' })
  @ApiResponse({ status: 400, description: 'Category has items' })
  async removeCategory(@Param('id') id: string) {
    return this.menusService.removeCategory(id);
  }

  // Menu Items
  @Post('items')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Create a menu item' })
  @ApiResponse({ status: 201, description: 'Item created successfully' })
  @ApiResponse({ status: 403, description: 'Forbidden - not the owner' })
  async createItem(@Request() req, @Body() createItemDto: CreateMenuItemDto) {
    return this.menusService.createItem(req.user.userId, createItemDto);
  }

  @Put('items/:itemId')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Update a menu item' })
  @ApiParam({ name: 'itemId', description: 'Item UUID' })
  @ApiResponse({ status: 200, description: 'Item updated successfully' })
  @ApiResponse({ status: 403, description: 'Forbidden - not the owner' })
  async updateItem(
    @Param('itemId') itemId: string,
    @Request() req,
    @Body() updateItemDto: UpdateMenuItemDto,
  ) {
    return this.menusService.updateItem(itemId, req.user.userId, updateItemDto);
  }

  @Delete('items/:itemId')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Delete a menu item' })
  @ApiParam({ name: 'itemId', description: 'Item UUID' })
  @ApiResponse({ status: 200, description: 'Item deleted successfully' })
  @ApiResponse({ status: 403, description: 'Forbidden - not the owner' })
  async removeItem(@Param('itemId') itemId: string, @Request() req) {
    return this.menusService.removeItem(itemId, req.user.userId);
  }
}

