import { Controller, Get, Param, Query } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiQuery } from '@nestjs/swagger';
import { CountriesService } from './countries.service';

@ApiTags('Countries & Cities')
@Controller()
export class CountriesController {
  constructor(private countriesService: CountriesService) {}

  @Get('countries')
  @ApiOperation({ summary: 'Get all countries' })
  @ApiQuery({ name: 'activeOnly', required: false })
  async findAllCountries(@Query('activeOnly') activeOnly?: string) {
    return this.countriesService.findAll(activeOnly !== 'false');
  }

  // Static routes MUST come before parameterized routes
  @Get('countries/cities')
  @ApiOperation({ summary: 'Get all cities' })
  @ApiQuery({ name: 'countryId', required: false })
  @ApiQuery({ name: 'featured', required: false })
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
  @ApiOperation({ summary: 'Get country by code' })
  async findByCode(@Param('code') code: string) {
    return this.countriesService.findByCode(code);
  }

  @Get('countries/:countryId/cities')
  @ApiOperation({ summary: 'Get cities in a country' })
  @ApiQuery({ name: 'activeOnly', required: false })
  @ApiQuery({ name: 'featured', required: false })
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
  @ApiOperation({ summary: 'Get regions in a country' })
  async getRegions(@Param('countryId') countryId: string) {
    return this.countriesService.getRegions(countryId);
  }

  @Get('countries/:id')
  @ApiOperation({ summary: 'Get country by ID' })
  async findOneCountry(@Param('id') id: string) {
    return this.countriesService.findOne(id);
  }

  @Get('cities/:id')
  @ApiOperation({ summary: 'Get city by ID' })
  async getCity(@Param('id') id: string) {
    return this.countriesService.getCity(id);
  }

  @Get('cities/:countryCode/:citySlug')
  @ApiOperation({ summary: 'Get city by country code and slug' })
  async getCityBySlug(@Param('countryCode') countryCode: string, @Param('citySlug') citySlug: string) {
    return this.countriesService.getCityBySlug(countryCode, citySlug);
  }

  @Get('cities/:cityId/districts')
  @ApiOperation({ summary: 'Get districts in a city' })
  async getDistricts(@Param('cityId') cityId: string) {
    return this.countriesService.getDistricts(cityId);
  }
}
