import { Injectable } from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';

@Injectable()
export class CountriesService {
  constructor(private prisma: PrismaService) {}

  async findAll(activeOnly = true) {
    return this.prisma.country.findMany({
      where: activeOnly ? { isActive: true } : {},
      include: {
        _count: { select: { cities: true, listings: true, events: true, tours: true } },
      },
      orderBy: { name: 'asc' },
    });
  }

  async findOne(id: string) {
    return this.prisma.country.findUnique({
      where: { id },
      include: {
        cities: { where: { isActive: true }, orderBy: { name: 'asc' } },
        regions: { where: { isActive: true }, orderBy: { name: 'asc' } },
        _count: { select: { listings: true, events: true, tours: true } },
      },
    });
  }

  async findByCode(code: string) {
    return this.prisma.country.findFirst({
      where: { OR: [{ code }, { code2: code }] },
      include: {
        cities: { where: { isActive: true }, orderBy: { name: 'asc' } },
        _count: { select: { listings: true, events: true, tours: true } },
      },
    });
  }

  async getAllCities(featured?: boolean) {
    return this.prisma.city.findMany({
      where: {
        isActive: true,
        ...(featured !== undefined && { isFeatured: featured }),
      },
      include: {
        country: { select: { id: true, name: true, code: true } },
        _count: { select: { listings: true, events: true, tours: true } },
      },
      orderBy: [{ isFeatured: 'desc' }, { name: 'asc' }],
    });
  }

  async getCities(countryId: string, params: { activeOnly?: boolean; featured?: boolean }) {
    const { activeOnly = true, featured } = params;
    return this.prisma.city.findMany({
      where: {
        countryId,
        ...(activeOnly && { isActive: true }),
        ...(featured !== undefined && { isFeatured: featured }),
      },
      include: {
        region: { select: { id: true, name: true } },
        _count: { select: { listings: true, events: true, tours: true } },
      },
      orderBy: [{ isFeatured: 'desc' }, { name: 'asc' }],
    });
  }

  async getCity(cityId: string) {
    return this.prisma.city.findUnique({
      where: { id: cityId },
      include: {
        country: { select: { id: true, name: true, code: true } },
        region: { select: { id: true, name: true } },
        districts: { where: { isActive: true }, orderBy: { name: 'asc' } },
        _count: { select: { listings: true, events: true, tours: true } },
      },
    });
  }

  async getCityBySlug(countryCode: string, citySlug: string) {
    const country = await this.prisma.country.findFirst({
      where: { OR: [{ code: countryCode }, { code2: countryCode }] },
    });

    if (!country) return null;

    return this.prisma.city.findFirst({
      where: { countryId: country.id, slug: citySlug },
      include: {
        country: { select: { id: true, name: true, code: true } },
        districts: { where: { isActive: true }, orderBy: { name: 'asc' } },
        _count: { select: { listings: true, events: true, tours: true } },
      },
    });
  }

  async getRegions(countryId: string) {
    return this.prisma.region.findMany({
      where: { countryId, isActive: true },
      include: {
        cities: { where: { isActive: true }, orderBy: { name: 'asc' } },
      },
      orderBy: { name: 'asc' },
    });
  }

  async getDistricts(cityId: string) {
    return this.prisma.district.findMany({
      where: { cityId, isActive: true },
      orderBy: { name: 'asc' },
    });
  }
}

