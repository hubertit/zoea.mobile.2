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
  @ApiOperation({ summary: 'Get my favorites' })
  @ApiQuery({ name: 'page', required: false, type: Number, example: 1 })
  @ApiQuery({ name: 'limit', required: false, type: Number, example: 20 })
  @ApiQuery({ name: 'type', required: false, enum: ['listing', 'event', 'tour'] })
  async findAll(@Request() req, @Query() query: FavoriteQueryDto) {
    return this.favoritesService.findAll(req.user.id, {
      page: query.page ? +query.page : 1,
      limit: query.limit ? +query.limit : 20,
      type: query.type,
    });
  }

  @Post()
  @ApiOperation({ summary: 'Add to favorites' })
  async add(@Request() req, @Body() data: AddFavoriteDto) {
    return this.favoritesService.add(req.user.id, data);
  }

  @Delete()
  @ApiOperation({ summary: 'Remove from favorites' })
  @ApiQuery({ name: 'listingId', required: false, type: String })
  @ApiQuery({ name: 'eventId', required: false, type: String })
  @ApiQuery({ name: 'tourId', required: false, type: String })
  async remove(
    @Request() req,
    @Query('listingId') listingId?: string,
    @Query('eventId') eventId?: string,
    @Query('tourId') tourId?: string,
  ) {
    return this.favoritesService.remove(req.user.id, { listingId, eventId, tourId });
  }

  @Post('toggle')
  @ApiOperation({ summary: 'Toggle favorite status' })
  async toggle(@Request() req, @Body() data: AddFavoriteDto) {
    return this.favoritesService.toggle(req.user.id, data);
  }

  @Get('check')
  @ApiOperation({ summary: 'Check if item is favorited' })
  @ApiQuery({ name: 'listingId', required: false, type: String })
  @ApiQuery({ name: 'eventId', required: false, type: String })
  @ApiQuery({ name: 'tourId', required: false, type: String })
  async check(
    @Request() req,
    @Query('listingId') listingId?: string,
    @Query('eventId') eventId?: string,
    @Query('tourId') tourId?: string,
  ) {
    return this.favoritesService.isFavorite(req.user.id, { listingId, eventId, tourId });
  }
}
