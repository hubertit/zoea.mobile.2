import { Controller, Get, Param, UseGuards } from '@nestjs/common';
import { CountriesService } from './countries.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';

@Controller('countries')
@UseGuards(JwtAuthGuard)
export class CountriesController {
  constructor(private readonly countriesService: CountriesService) {}

  /**
   * Get all active countries
   */
  @Get('active')
  async getActiveCountries() {
    return this.countriesService.findActive();
  }

  /**
   * Get country by ID
   */
  @Get(':id')
  async getCountryById(@Param('id') id: string) {
    return this.countriesService.findById(id);
  }

  /**
   * Get country by 2-letter code
   */
  @Get('code/:code')
  async getCountryByCode(@Param('code') code: string) {
    return this.countriesService.findByCode(code);
  }

  /**
   * Get cities for a country
   */
  @Get(':id/cities')
  async getCountryCities(@Param('id') id: string) {
    return this.countriesService.findCitiesByCountry(id);
  }

  /**
   * Get all countries (including inactive)
   */
  @Get()
  async getAllCountries() {
    return this.countriesService.findAll();
  }
}
