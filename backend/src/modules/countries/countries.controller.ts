import { Controller, Get, Param, Query } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiQuery } from '@nestjs/swagger';
import { CountriesService } from './countries.service';

@ApiTags('Countries & Cities')
@Controller()
export class CountriesController {
  constructor(private countriesService: CountriesService) {}

  @Get('countries')
  @ApiOperation({ 
    summary: 'Get all countries',
    description: 'Retrieves all countries in the system. Countries are used for location filtering and operational context. Can filter to show only active countries.'
  })
  @ApiQuery({ name: 'activeOnly', required: false, type: Boolean, description: 'Filter to show only active countries (default: true)', example: true })
  @ApiResponse({ 
    status: 200, 
    description: 'Countries retrieved successfully',
    schema: {
      type: 'array',
      items: {
        type: 'object',
        properties: {
          id: { type: 'string', format: 'uuid' },
          name: { type: 'string', example: 'Rwanda' },
          code: { type: 'string', example: 'RW', description: 'ISO 3166-1 alpha-2 country code' },
          code3: { type: 'string', example: 'RWA', description: 'ISO 3166-1 alpha-3 country code' },
          isActive: { type: 'boolean', example: true }
        }
      }
    }
  })
  async findAllCountries(@Query('activeOnly') activeOnly?: string) {
    return this.countriesService.findAll(activeOnly !== 'false');
  }

  // Static routes MUST come before parameterized routes
  @Get('countries/cities')
  @ApiOperation({ 
    summary: 'Get all cities',
    description: 'Retrieves all cities in the system. Can be filtered by country or featured status. Useful for location selection and filtering.'
  })
  @ApiQuery({ name: 'countryId', required: false, type: String, format: 'uuid', description: 'Filter cities by country UUID', example: '123e4567-e89b-12d3-a456-426614174000' })
  @ApiQuery({ name: 'featured', required: false, type: Boolean, description: 'Filter to show only featured cities', example: true })
  @ApiResponse({ 
    status: 200, 
    description: 'Cities retrieved successfully',
    schema: {
      type: 'array',
      items: {
        type: 'object',
        properties: {
          id: { type: 'string', format: 'uuid' },
          name: { type: 'string', example: 'Kigali' },
          slug: { type: 'string', example: 'kigali' },
          countryId: { type: 'string', format: 'uuid' },
          isFeatured: { type: 'boolean', example: true }
        }
      }
    }
  })
  async getAllCities(
    @Query('countryId') countryId?: string,
    @Query('featured') featured?: string,
  ) {
    if (countryId) {
      return this.countriesService.getCities(countryId, { featured: featured === 'true' ? true : undefined });
    }
    return this.countriesService.getAllCities(featured === 'true' ? true : undefined);
  }

  @Get('countries/code/:code')
  @ApiOperation({ 
    summary: 'Get country by code',
    description: 'Retrieves a country by its ISO country code (2-letter or 3-letter). Useful for country code lookups.'
  })
  @ApiParam({ name: 'code', type: String, description: 'ISO country code (2-letter or 3-letter)', example: 'RW' })
  @ApiResponse({ 
    status: 200, 
    description: 'Country retrieved successfully',
    schema: { type: 'object' }
  })
  @ApiResponse({ status: 404, description: 'Country not found' })
  async findByCode(@Param('code') code: string) {
    return this.countriesService.findByCode(code);
  }

  @Get('countries/:countryId/cities')
  @ApiOperation({ 
    summary: 'Get cities in a country',
    description: 'Retrieves all cities within a specific country. Can filter by active status and featured status. Useful for location-based filtering.'
  })
  @ApiParam({ name: 'countryId', type: String, format: 'uuid', description: 'Country UUID', example: '123e4567-e89b-12d3-a456-426614174000' })
  @ApiQuery({ name: 'activeOnly', required: false, type: Boolean, description: 'Filter to show only active cities (default: true)', example: true })
  @ApiQuery({ name: 'featured', required: false, type: Boolean, description: 'Filter to show only featured cities', example: true })
  @ApiResponse({ 
    status: 200, 
    description: 'Cities retrieved successfully',
    schema: {
      type: 'array',
      items: { type: 'object' }
    }
  })
  @ApiResponse({ status: 404, description: 'Country not found' })
  async getCities(
    @Param('countryId') countryId: string,
    @Query('activeOnly') activeOnly?: string,
    @Query('featured') featured?: string,
  ) {
    return this.countriesService.getCities(countryId, {
      activeOnly: activeOnly !== 'false',
      featured: featured ? featured === 'true' : undefined,
    });
  }

  @Get('countries/:countryId/regions')
  @ApiOperation({ 
    summary: 'Get regions in a country',
    description: 'Retrieves administrative regions or provinces within a country. Useful for location hierarchy and filtering.'
  })
  @ApiParam({ name: 'countryId', type: String, format: 'uuid', description: 'Country UUID', example: '123e4567-e89b-12d3-a456-426614174000' })
  @ApiResponse({ 
    status: 200, 
    description: 'Regions retrieved successfully',
    schema: {
      type: 'array',
      items: {
        type: 'object',
        properties: {
          id: { type: 'string', format: 'uuid' },
          name: { type: 'string', example: 'Kigali Province' },
          countryId: { type: 'string', format: 'uuid' }
        }
      }
    }
  })
  @ApiResponse({ status: 404, description: 'Country not found' })
  async getRegions(@Param('countryId') countryId: string) {
    return this.countriesService.getRegions(countryId);
  }

  @Get('countries/:id')
  @ApiOperation({ 
    summary: 'Get country by ID',
    description: 'Retrieves detailed information about a specific country including its cities, regions, and metadata.'
  })
  @ApiParam({ name: 'id', type: String, format: 'uuid', description: 'Country UUID', example: '123e4567-e89b-12d3-a456-426614174000' })
  @ApiResponse({ 
    status: 200, 
    description: 'Country retrieved successfully',
    schema: { type: 'object' }
  })
  @ApiResponse({ status: 404, description: 'Country not found' })
  async findOneCountry(@Param('id') id: string) {
    return this.countriesService.findOne(id);
  }

  @Get('cities/:id')
  @ApiOperation({ 
    summary: 'Get city by ID',
    description: 'Retrieves detailed information about a specific city including its districts, country, and metadata.'
  })
  @ApiParam({ name: 'id', type: String, format: 'uuid', description: 'City UUID', example: '123e4567-e89b-12d3-a456-426614174000' })
  @ApiResponse({ 
    status: 200, 
    description: 'City retrieved successfully',
    schema: { type: 'object' }
  })
  @ApiResponse({ status: 404, description: 'City not found' })
  async getCity(@Param('id') id: string) {
    return this.countriesService.getCity(id);
  }

  @Get('cities/:countryCode/:citySlug')
  @ApiOperation({ 
    summary: 'Get city by country code and slug',
    description: 'Retrieves a city by its country code and URL-friendly slug. Useful for SEO-friendly URLs and city detail pages.'
  })
  @ApiParam({ name: 'countryCode', type: String, description: 'ISO 2-letter country code', example: 'RW' })
  @ApiParam({ name: 'citySlug', type: String, description: 'City slug', example: 'kigali' })
  @ApiResponse({ 
    status: 200, 
    description: 'City retrieved successfully',
    schema: { type: 'object' }
  })
  @ApiResponse({ status: 404, description: 'City not found' })
  async getCityBySlug(@Param('countryCode') countryCode: string, @Param('citySlug') citySlug: string) {
    return this.countriesService.getCityBySlug(countryCode, citySlug);
  }

  @Get('cities/:cityId/districts')
  @ApiOperation({ 
    summary: 'Get districts in a city',
    description: 'Retrieves administrative districts or neighborhoods within a city. Useful for location hierarchy and detailed location filtering.'
  })
  @ApiParam({ name: 'cityId', type: String, format: 'uuid', description: 'City UUID', example: '123e4567-e89b-12d3-a456-426614174000' })
  @ApiResponse({ 
    status: 200, 
    description: 'Districts retrieved successfully',
    schema: {
      type: 'array',
      items: {
        type: 'object',
        properties: {
          id: { type: 'string', format: 'uuid' },
          name: { type: 'string', example: 'Nyarugenge' },
          cityId: { type: 'string', format: 'uuid' }
        }
      }
    }
  })
  @ApiResponse({ status: 404, description: 'City not found' })
  async getDistricts(@Param('cityId') cityId: string) {
    return this.countriesService.getDistricts(cityId);
  }
}
