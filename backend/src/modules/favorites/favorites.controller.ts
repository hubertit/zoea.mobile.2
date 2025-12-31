import { Controller, Get, Post, Delete, Query, Body, UseGuards, Request } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth, ApiQuery } from '@nestjs/swagger';
import { FavoritesService } from './favorites.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { AddFavoriteDto, FavoriteQueryDto } from './dto/favorite.dto';

@ApiTags('Favorites')
@Controller('favorites')
@UseGuards(JwtAuthGuard)
@ApiBearerAuth()
export class FavoritesController {
  constructor(private favoritesService: FavoritesService) {}

  @Get()
  @ApiOperation({ 
    summary: 'Get my favorites',
    description: 'Retrieves paginated list of items (listings, events, tours) that the authenticated user has favorited. Can be filtered by content type.'
  })
  @ApiQuery({ name: 'page', required: false, type: Number, example: 1, description: 'Page number (default: 1)' })
  @ApiQuery({ name: 'limit', required: false, type: Number, example: 20, description: 'Items per page (default: 20)' })
  @ApiQuery({ name: 'type', required: false, enum: ['listing', 'event', 'tour'], description: 'Filter by content type', example: 'listing' })
  @ApiResponse({ 
    status: 200, 
    description: 'Favorites retrieved successfully',
    schema: {
      type: 'object',
      properties: {
        data: { type: 'array', items: { type: 'object' } },
        total: { type: 'number', example: 15 },
        page: { type: 'number', example: 1 },
        limit: { type: 'number', example: 20 }
      }
    }
  })
  @ApiResponse({ status: 401, description: 'Unauthorized - Invalid or missing token' })
  async findAll(@Request() req, @Query() query: FavoriteQueryDto) {
    return this.favoritesService.findAll(req.user.id, {
      page: query.page ? +query.page : 1,
      limit: query.limit ? +query.limit : 20,
      type: query.type,
    });
  }

  @Post()
  @ApiOperation({ 
    summary: 'Add to favorites',
    description: 'Adds a listing, event, or tour to the authenticated user\'s favorites. If the item is already favorited, no error is returned.'
  })
  @ApiBody({ type: AddFavoriteDto })
  @ApiResponse({ 
    status: 201, 
    description: 'Item added to favorites successfully',
    schema: {
      type: 'object',
      properties: {
        success: { type: 'boolean', example: true },
        message: { type: 'string', example: 'Item added to favorites' },
        favorite: { type: 'object' }
      }
    }
  })
  @ApiResponse({ status: 400, description: 'Bad request - Must specify at least one item (listingId, eventId, or tourId)' })
  @ApiResponse({ status: 401, description: 'Unauthorized - Invalid or missing token' })
  @ApiResponse({ status: 404, description: 'Item not found' })
  async add(@Request() req, @Body() data: AddFavoriteDto) {
    return this.favoritesService.add(req.user.id, data);
  }

  @Delete()
  @ApiOperation({ 
    summary: 'Remove from favorites',
    description: 'Removes a listing, event, or tour from the authenticated user\'s favorites. At least one item ID must be provided.'
  })
  @ApiQuery({ name: 'listingId', required: false, type: String, format: 'uuid', description: 'Listing UUID to remove from favorites', example: '123e4567-e89b-12d3-a456-426614174000' })
  @ApiQuery({ name: 'eventId', required: false, type: String, format: 'uuid', description: 'Event UUID to remove from favorites', example: '123e4567-e89b-12d3-a456-426614174000' })
  @ApiQuery({ name: 'tourId', required: false, type: String, format: 'uuid', description: 'Tour UUID to remove from favorites', example: '123e4567-e89b-12d3-a456-426614174000' })
  @ApiResponse({ 
    status: 200, 
    description: 'Item removed from favorites successfully',
    schema: {
      type: 'object',
      properties: {
        success: { type: 'boolean', example: true },
        message: { type: 'string', example: 'Item removed from favorites' }
      }
    }
  })
  @ApiResponse({ status: 400, description: 'Bad request - Must specify at least one item ID' })
  @ApiResponse({ status: 401, description: 'Unauthorized - Invalid or missing token' })
  @ApiResponse({ status: 404, description: 'Favorite not found' })
  async remove(
    @Request() req,
    @Query('listingId') listingId?: string,
    @Query('eventId') eventId?: string,
    @Query('tourId') tourId?: string,
  ) {
    return this.favoritesService.remove(req.user.id, { listingId, eventId, tourId });
  }

  @Post('toggle')
  @ApiOperation({ 
    summary: 'Toggle favorite status',
    description: 'Toggles the favorite status of an item. If the item is favorited, it will be removed from favorites. If not favorited, it will be added. Convenient for heart/like buttons.'
  })
  @ApiBody({ type: AddFavoriteDto })
  @ApiResponse({ 
    status: 200, 
    description: 'Favorite status toggled successfully',
    schema: {
      type: 'object',
      properties: {
        isFavorite: { type: 'boolean', example: true, description: 'Current favorite status after toggle' },
        favorite: { type: 'object', nullable: true }
      }
    }
  })
  @ApiResponse({ status: 400, description: 'Bad request - Must specify at least one item (listingId, eventId, or tourId)' })
  @ApiResponse({ status: 401, description: 'Unauthorized - Invalid or missing token' })
  @ApiResponse({ status: 404, description: 'Item not found' })
  async toggle(@Request() req, @Body() data: AddFavoriteDto) {
    return this.favoritesService.toggle(req.user.id, data);
  }

  @Get('check')
  @ApiOperation({ 
    summary: 'Check if item is favorited',
    description: 'Checks whether a specific listing, event, or tour is in the authenticated user\'s favorites. Useful for displaying favorite status in UI.'
  })
  @ApiQuery({ name: 'listingId', required: false, type: String, format: 'uuid', description: 'Listing UUID to check', example: '123e4567-e89b-12d3-a456-426614174000' })
  @ApiQuery({ name: 'eventId', required: false, type: String, format: 'uuid', description: 'Event UUID to check', example: '123e4567-e89b-12d3-a456-426614174000' })
  @ApiQuery({ name: 'tourId', required: false, type: String, format: 'uuid', description: 'Tour UUID to check', example: '123e4567-e89b-12d3-a456-426614174000' })
  @ApiResponse({ 
    status: 200, 
    description: 'Favorite status checked successfully',
    schema: {
      type: 'object',
      properties: {
        isFavorite: { type: 'boolean', example: true, description: 'Whether the item is favorited' }
      }
    }
  })
  @ApiResponse({ status: 400, description: 'Bad request - Must specify exactly one item ID' })
  @ApiResponse({ status: 401, description: 'Unauthorized - Invalid or missing token' })
  async check(
    @Request() req,
    @Query('listingId') listingId?: string,
    @Query('eventId') eventId?: string,
    @Query('tourId') tourId?: string,
  ) {
    return this.favoritesService.isFavorite(req.user.id, { listingId, eventId, tourId });
  }
}
