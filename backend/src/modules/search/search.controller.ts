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
  @ApiOperation({ 
    summary: 'Search listings, events, and tours',
    description: 'Performs a global search across listings, events, and tours. Authentication is optional but recommended for personalized results. Search queries are tracked for analytics when authenticated. Results are ranked by relevance.'
  })
  @ApiQuery({ name: 'q', required: true, description: 'Search query string', example: 'hotel kigali' })
  @ApiQuery({ name: 'type', required: false, enum: ['all', 'listing', 'event', 'tour'], description: 'Filter by content type (default: all)', example: 'listing' })
  @ApiQuery({ name: 'cityId', required: false, type: String, description: 'Filter by city UUID', example: '123e4567-e89b-12d3-a456-426614174000' })
  @ApiQuery({ name: 'countryId', required: false, type: String, description: 'Filter by country UUID', example: '123e4567-e89b-12d3-a456-426614174000' })
  @ApiQuery({ name: 'page', required: false, type: Number, example: 1, description: 'Page number (default: 1)' })
  @ApiQuery({ name: 'limit', required: false, type: Number, example: 20, description: 'Items per page (default: 20)' })
  @ApiResponse({ 
    status: 200, 
    description: 'Search results retrieved successfully',
    schema: {
      type: 'object',
      properties: {
        listings: { type: 'array', items: { type: 'object' }, description: 'Matching listings' },
        events: { type: 'array', items: { type: 'object' }, description: 'Matching events' },
        tours: { type: 'array', items: { type: 'object' }, description: 'Matching tours' },
        total: { type: 'number', example: 45, description: 'Total number of results' },
        page: { type: 'number', example: 1 },
        limit: { type: 'number', example: 20 }
      }
    }
  })
  @ApiResponse({ status: 400, description: 'Bad request - Missing or invalid search query' })
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
  @ApiOperation({ 
    summary: 'Get trending searches and featured content',
    description: 'Returns trending search queries and featured listings, events, and tours. Results are location-aware if cityId or countryId is provided. Useful for displaying popular content on the explore screen.'
  })
  @ApiQuery({ name: 'cityId', required: false, type: String, description: 'Filter by city UUID for location-specific trends', example: '123e4567-e89b-12d3-a456-426614174000' })
  @ApiQuery({ name: 'countryId', required: false, type: String, description: 'Filter by country UUID for location-specific trends', example: '123e4567-e89b-12d3-a456-426614174000' })
  @ApiResponse({ 
    status: 200, 
    description: 'Trending content retrieved successfully',
    schema: {
      type: 'object',
      properties: {
        trendingSearches: { type: 'array', items: { type: 'string' }, example: ['hotel', 'restaurant', 'museum'] },
        featuredListings: { type: 'array', items: { type: 'object' } },
        featuredEvents: { type: 'array', items: { type: 'object' } },
        featuredTours: { type: 'array', items: { type: 'object' } }
      }
    }
  })
  async getTrending(@Query('cityId') cityId?: string, @Query('countryId') countryId?: string) {
    return this.searchService.getTrending(cityId, countryId);
  }

  @Get('history')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ 
    summary: 'Get search history',
    description: 'Retrieves the authenticated user\'s recent search queries. Only searches submitted (not typed) are stored. Results are sorted by most recent first.'
  })
  @ApiQuery({ name: 'limit', required: false, type: Number, example: 5, description: 'Maximum number of recent searches to return (default: 5)' })
  @ApiResponse({ 
    status: 200, 
    description: 'Search history retrieved successfully',
    schema: {
      type: 'array',
      items: {
        type: 'object',
        properties: {
          query: { type: 'string', example: 'hotel kigali' },
          createdAt: { type: 'string', example: '2024-12-30T16:00:00Z' }
        }
      }
    }
  })
  @ApiResponse({ status: 401, description: 'Unauthorized - Invalid or missing token' })
  async getHistory(@Request() req, @Query('limit') limit?: string) {
    return this.searchService.getSearchHistory(req.user.id, limit ? +limit : 5);
  }

  @Delete('history')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ 
    summary: 'Clear search history',
    description: 'Deletes all search history for the authenticated user. This action cannot be undone.'
  })
  @ApiResponse({ 
    status: 200, 
    description: 'Search history cleared successfully',
    schema: {
      type: 'object',
      properties: {
        success: { type: 'boolean', example: true },
        message: { type: 'string', example: 'Search history cleared successfully' }
      }
    }
  })
  @ApiResponse({ status: 401, description: 'Unauthorized - Invalid or missing token' })
  async clearHistory(@Request() req) {
    return this.searchService.clearSearchHistory(req.user.id);
  }

  @Get('recently-viewed')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ 
    summary: 'Get recently viewed items',
    description: 'Retrieves listings, events, and tours that the authenticated user has recently viewed. Useful for displaying "Continue Exploring" or "Recently Viewed" sections.'
  })
  @ApiQuery({ name: 'limit', required: false, type: Number, example: 10, description: 'Maximum number of items to return (default: 10)' })
  @ApiResponse({ 
    status: 200, 
    description: 'Recently viewed items retrieved successfully',
    schema: {
      type: 'array',
      items: {
        type: 'object',
        properties: {
          id: { type: 'string' },
          type: { type: 'string', enum: ['listing', 'event', 'tour'] },
          name: { type: 'string' },
          viewedAt: { type: 'string' }
        }
      }
    }
  })
  @ApiResponse({ status: 401, description: 'Unauthorized - Invalid or missing token' })
  async getRecentlyViewed(@Request() req, @Query('limit') limit?: string) {
    return this.searchService.getRecentlyViewed(req.user.id, limit ? +limit : 10);
  }
}

