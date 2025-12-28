import { Injectable, NotFoundException } from '@nestjs/common';
import { Prisma, listing_status } from '@prisma/client';
import { PrismaService } from '../../../prisma/prisma.service';
import { AdminListListingsDto } from './dto/list-listings.dto';
import { AdminUpdateListingStatusDto } from './dto/update-listing-status.dto';
import { AdminCreateListingDto, AdminUpdateListingDto } from './dto/create-listing.dto';

@Injectable()
export class AdminListingsService {
  constructor(private readonly prisma: PrismaService) {}

  async listListings(dto: AdminListListingsDto) {
    const page = dto.page ?? 1;
    const limit = dto.limit ?? 20;
    const skip = (page - 1) * limit;

    const where: Prisma.ListingWhereInput = {
      deletedAt: null,
    };

    const andFilters: Prisma.ListingWhereInput[] = [];

    if (dto.search) {
      const search = dto.search.trim();
      andFilters.push({
        OR: [
          { name: { contains: search, mode: 'insensitive' } },
          { slug: { contains: search, mode: 'insensitive' } },
          { merchant: { businessName: { contains: search, mode: 'insensitive' } } },
        ],
      });
    }

    if (dto.status) andFilters.push({ status: dto.status });
    if (dto.type) andFilters.push({ type: dto.type });
    if (dto.isFeatured !== undefined) andFilters.push({ isFeatured: dto.isFeatured });
    if (dto.isVerified !== undefined) andFilters.push({ isVerified: dto.isVerified });
    if (dto.merchantId) andFilters.push({ merchantId: dto.merchantId });
    if (dto.countryId) andFilters.push({ countryId: dto.countryId });
    if (dto.cityId) andFilters.push({ cityId: dto.cityId });

    if (andFilters.length) {
      where.AND = andFilters;
    }

    const [data, total] = await Promise.all([
      this.prisma.listing.findMany({
        where,
        skip,
        take: limit,
        orderBy: { createdAt: 'desc' },
        select: {
          id: true,
          name: true,
          status: true,
          type: true,
          isFeatured: true,
          isVerified: true,
          isBlocked: true,
          country: { select: { id: true, name: true, code: true } },
          city: { select: { id: true, name: true } },
          merchant: { select: { id: true, businessName: true } },
          rating: true,
          reviewCount: true,
          bookingCount: true,
          createdAt: true,
          updatedAt: true,
        },
      }),
      this.prisma.listing.count({ where }),
    ]);

    return {
      data,
      meta: {
        total,
        page,
        limit,
        totalPages: Math.max(Math.ceil(total / limit), 1),
      },
    };
  }

  async getListingById(id: string) {
    const listing = await this.prisma.listing.findUnique({
      where: { id },
      include: {
        merchant: { select: { id: true, businessName: true, registrationStatus: true } },
        country: { select: { id: true, name: true, code: true } },
        city: { select: { id: true, name: true } },
        category: { select: { id: true, name: true } },
        images: { include: { media: true }, orderBy: { sortOrder: 'asc' } },
        amenities: { include: { amenity: true } },
        tags: { include: { tag: true } },
        _count: { select: { bookings: true, reviews: true, favorites: true } },
      },
    });

    if (!listing) {
      throw new NotFoundException('Listing not found');
    }

    return listing;
  }

  async updateListingStatus(id: string, dto: AdminUpdateListingStatusDto) {
    const listing = await this.prisma.listing.findUnique({ where: { id } });
    if (!listing) throw new NotFoundException('Listing not found');

    const data: Prisma.ListingUncheckedUpdateInput = {};

    if (dto.status) {
      data.status = dto.status as listing_status;
    }
    if (dto.isFeatured !== undefined) {
      data.isFeatured = dto.isFeatured;
    }
    if (dto.isVerified !== undefined) {
      data.isVerified = dto.isVerified;
    }
    if (dto.isBlocked !== undefined) {
      data.isBlocked = dto.isBlocked;
    }
    if (dto.reviewNotes !== undefined) {
      data.metaDescription = dto.reviewNotes;
    }

    const updated = await this.prisma.listing.update({
      where: { id },
      data,
      select: {
        id: true,
        status: true,
        isFeatured: true,
        isVerified: true,
        isBlocked: true,
        metaDescription: true,
        updatedAt: true,
      },
    });

    return updated;
  }

  async createListing(dto: AdminCreateListingDto) {
    const slug = dto.slug || `${dto.name.toLowerCase().replace(/\s+/g, '-')}-${Date.now().toString(36)}`;

    const created = await this.prisma.listing.create({
      data: {
        merchantId: dto.merchantId,
        name: dto.name,
        slug,
        description: dto.description,
        shortDescription: dto.shortDescription,
        type: dto.type,
        categoryId: dto.categoryId,
        countryId: dto.countryId,
        cityId: dto.cityId,
        districtId: dto.districtId,
        address: dto.address,
        postalCode: dto.postalCode,
        minPrice: dto.minPrice as any,
        maxPrice: dto.maxPrice as any,
        priceUnit: dto.priceUnit,
        contactPhone: dto.contactPhone,
        contactEmail: dto.contactEmail,
        website: dto.website,
        isFeatured: dto.isFeatured ?? false,
        isVerified: dto.isVerified ?? false,
        status: dto.status ?? 'active',
      },
      select: {
        id: true,
        name: true,
        slug: true,
        status: true,
        merchantId: true,
      },
    });

    await this.syncListingRelations(created.id, dto.amenityIds, dto.tagIds);

    return this.getListingById(created.id);
  }

  async updateListing(id: string, dto: AdminUpdateListingDto) {
    await this.ensureListingExists(id);

    const updated = await this.prisma.listing.update({
      where: { id },
      data: {
        ...(dto.name && { name: dto.name }),
        ...(dto.slug && { slug: dto.slug }),
        ...(dto.description && { description: dto.description }),
        ...(dto.shortDescription && { shortDescription: dto.shortDescription }),
        ...(dto.type && { type: dto.type }),
        ...(dto.categoryId && { categoryId: dto.categoryId }),
        ...(dto.countryId && { countryId: dto.countryId }),
        ...(dto.cityId && { cityId: dto.cityId }),
        ...(dto.districtId && { districtId: dto.districtId }),
        ...(dto.address && { address: dto.address }),
        ...(dto.postalCode && { postalCode: dto.postalCode }),
        ...(dto.merchantId && { merchantId: dto.merchantId }),
        minPrice: dto.minPrice as any,
        maxPrice: dto.maxPrice as any,
        priceUnit: dto.priceUnit,
        contactPhone: dto.contactPhone,
        contactEmail: dto.contactEmail,
        website: dto.website,
        isFeatured: dto.isFeatured,
        isVerified: dto.isVerified,
        status: dto.status,
      },
      select: { id: true },
    });

    if (dto.amenityIds || dto.tagIds) {
      await this.syncListingRelations(id, dto.amenityIds, dto.tagIds);
    }

    return this.getListingById(updated.id);
  }

  async deleteListing(id: string) {
    await this.ensureListingExists(id);
    return this.prisma.listing.update({
      where: { id },
      data: { deletedAt: new Date() },
      select: { id: true, deletedAt: true },
    });
  }

  async restoreListing(id: string) {
    await this.ensureListingExists(id);
    return this.prisma.listing.update({
      where: { id },
      data: { deletedAt: null },
      select: { id: true, deletedAt: true },
    });
  }

  private async syncListingRelations(listingId: string, amenityIds?: string[], tagIds?: string[]) {
    if (amenityIds) {
      await this.prisma.listingAmenity.deleteMany({ where: { listingId } });
      if (amenityIds.length) {
        await this.prisma.listingAmenity.createMany({
          data: amenityIds.map((amenityId, idx) => ({
            listingId,
            amenityId,
            sortOrder: idx,
          })),
        });
      }
    }

    if (tagIds) {
      await this.prisma.listingTag.deleteMany({ where: { listingId } });
      if (tagIds.length) {
        await this.prisma.listingTag.createMany({
          data: tagIds.map((tagId) => ({
            listingId,
            tagId,
          })),
        });
      }
    }
  }

  private async ensureListingExists(id: string) {
    const exists = await this.prisma.listing.findUnique({ where: { id }, select: { id: true } });
    if (!exists) {
      throw new NotFoundException('Listing not found');
    }
  }
}


