import { Injectable } from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';

@Injectable()
export class CountriesService {
  constructor(private prisma: PrismaService) {}

  /**
   * Get all active countries
   */
  async findActive() {
    return this.prisma.country.findMany({
      where: {
        isActive: true,
      },
      orderBy: {
        name: 'asc',
      },
    });
  }

  /**
   * Get country by ID
   */
  async findById(id: string) {
    return this.prisma.country.findUnique({
      where: { id },
    });
  }

  /**
   * Get country by 2-letter code (RW, KE, UG, TZ)
   */
  async findByCode(code: string) {
    return this.prisma.country.findFirst({
      where: {
        code2: code.toUpperCase(),
      },
    });
  }

  /**
   * Get cities for a country
   */
  async findCitiesByCountry(countryId: string) {
    return this.prisma.city.findMany({
      where: {
        countryId,
      },
      orderBy: {
        name: 'asc',
      },
    });
  }

  /**
   * Get all countries (including inactive)
   */
  async findAll() {
    return this.prisma.country.findMany({
      orderBy: {
        name: 'asc',
      },
    });
  }
}
