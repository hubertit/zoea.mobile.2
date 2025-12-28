import { Controller, Get, Delete, Query, UseGuards, Request } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth, ApiQuery } from '@nestjs/swagger';
import { SearchService } from './search.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { OptionalJwtAuthGuard } from '../auth/guards/optional-jwt-auth.guard';

@ApiTags('Search')
@Controller('search')
export class SearchController {
  constructor(private searchService: SearchService) {}

  @Get()
  @UseGuards(OptionalJwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Search listings, events, and tours' })
  @ApiQuery({ name: 'q', required: true, description: 'Search query' })
  @ApiQuery({ name: 'type', required: false, enum: ['all', 'listing', 'event', 'tour'] })
  @ApiQuery({ name: 'cityId', required: false })
  @ApiQuery({ name: 'countryId', required: false })
  @ApiQuery({ name: 'page', required: false })
  @ApiQuery({ name: 'limit', required: false })
  async search(
    @Request() req,
    @Query('q') query: string,
    @Query('type') type?: string,
    @Query('cityId') cityId?: string,
    @Query('countryId') countryId?: string,
    @Query('page') page?: string,
    @Query('limit') limit?: string,
  ) {
    return this.searchService.search({
      query,
      type: type || 'all',
      cityId,
      countryId,
      page: page ? +page : 1,
      limit: limit ? +limit : 20,
      userId: req.user?.id, // Extract userId from JWT token if authenticated
    });
  }

  @Get('trending')
  @ApiOperation({ summary: 'Get trending searches and featured content' })
  @ApiQuery({ name: 'cityId', required: false })
  @ApiQuery({ name: 'countryId', required: false })
  async getTrending(@Query('cityId') cityId?: string, @Query('countryId') countryId?: string) {
    return this.searchService.getTrending(cityId, countryId);
  }

  @Get('history')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Get search history' })
  @ApiQuery({ name: 'limit', required: false })
  async getHistory(@Request() req, @Query('limit') limit?: string) {
    return this.searchService.getSearchHistory(req.user.id, limit ? +limit : 10);
  }

  @Delete('history')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Clear search history' })
  async clearHistory(@Request() req) {
    return this.searchService.clearSearchHistory(req.user.id);
  }

  @Get('recently-viewed')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Get recently viewed items' })
  @ApiQuery({ name: 'limit', required: false })
  async getRecentlyViewed(@Request() req, @Query('limit') limit?: string) {
    return this.searchService.getRecentlyViewed(req.user.id, limit ? +limit : 10);
  }
}

