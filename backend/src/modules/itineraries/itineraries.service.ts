import { Injectable, NotFoundException, ForbiddenException, BadRequestException } from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';
import { CreateItineraryDto, UpdateItineraryDto, CreateItineraryItemDto } from './dto/itinerary.dto';
import { randomBytes } from 'crypto';

@Injectable()
export class ItinerariesService {
  constructor(private prisma: PrismaService) {}

  async findAll(userId: string, params: { page?: number; limit?: number }) {
    const { page = 1, limit = 50 } = params;
    const skip = (page - 1) * limit;

    const where = {
      userId,
      deletedAt: null,
    };

    const [itineraries, total] = await Promise.all([
      this.prisma.itinerary.findMany({
        where,
        skip,
        take: limit,
        include: {
          country: { select: { id: true, name: true, code: true } },
          city: { select: { id: true, name: true } },
          items: {
            orderBy: { order: 'asc' },
            include: {
              listing: {
                select: {
                  id: true,
                  name: true,
                  slug: true,
                  type: true,
                  images: { include: { media: true }, take: 1, where: { isPrimary: true } },
                },
              },
              event: {
                select: {
                  id: true,
                  name: true,
                  slug: true,
                  startDate: true,
                  endDate: true,
                  locationName: true,
                  attachments: { include: { media: true }, take: 1, where: { isMainFlyer: true } },
                },
              },
              tour: {
                select: {
                  id: true,
                  name: true,
                  slug: true,
                  pricePerPerson: true,
                  currency: true,
                  images: { include: { media: true }, take: 1, where: { isPrimary: true } },
                },
              },
            },
          },
          _count: { select: { items: true } },
        },
        orderBy: { createdAt: 'desc' },
      }),
      this.prisma.itinerary.count({ where }),
    ]);

    return {
      data: itineraries,
      meta: {
        total,
        page,
        limit,
        totalPages: Math.ceil(total / limit),
      },
    };
  }

  async findOne(id: string, userId?: string) {
    const itinerary = await this.prisma.itinerary.findFirst({
      where: {
        id,
        deletedAt: null,
      },
      include: {
        user: {
          select: {
            id: true,
            fullName: true,
            username: true,
            profileImage: { select: { url: true } },
          },
        },
        country: { select: { id: true, name: true, code: true } },
        city: { select: { id: true, name: true } },
        items: {
          orderBy: { order: 'asc' },
          include: {
            listing: {
              select: {
                id: true,
                name: true,
                slug: true,
                type: true,
                description: true,
                address: true,
                rating: true,
                reviewCount: true,
                images: { include: { media: true }, take: 1, where: { isPrimary: true } },
                city: { select: { id: true, name: true } },
              },
            },
            event: {
              select: {
                id: true,
                name: true,
                slug: true,
                description: true,
                startDate: true,
                endDate: true,
                locationName: true,
                venueName: true,
                address: true,
                attachments: { include: { media: true }, take: 1, where: { isMainFlyer: true } },
                city: { select: { id: true, name: true } },
              },
            },
            tour: {
              select: {
                id: true,
                name: true,
                slug: true,
                description: true,
                pricePerPerson: true,
                currency: true,
                durationHours: true,
                images: { include: { media: true }, take: 1, where: { isPrimary: true } },
                city: { select: { id: true, name: true } },
              },
            },
          },
        },
        _count: { select: { items: true, shares: true } },
      },
    });

    if (!itinerary) {
      throw new NotFoundException('Itinerary not found');
    }

    // Check if user has access (owner or public)
    if (userId && itinerary.userId !== userId && !itinerary.isPublic) {
      throw new ForbiddenException('You do not have access to this itinerary');
    }

    return itinerary;
  }

  async create(userId: string, dto: CreateItineraryDto) {
    // Validate dates
    const startDate = new Date(dto.startDate);
    const endDate = new Date(dto.endDate);
    
    if (endDate < startDate) {
      throw new BadRequestException('End date must be after start date');
    }

    // Generate share token if public
    const shareToken = dto.isPublic ? this.generateShareToken() : null;

    const itinerary = await this.prisma.itinerary.create({
      data: {
        userId,
        title: dto.title,
        description: dto.description,
        startDate,
        endDate,
        location: dto.location,
        countryId: dto.countryId,
        cityId: dto.cityId,
        isPublic: dto.isPublic ?? false,
        shareToken,
        items: dto.items
          ? {
              create: dto.items.map((item) => this.mapItemDtoToCreate(item)),
            }
          : undefined,
      },
      include: {
        country: { select: { id: true, name: true, code: true } },
        city: { select: { id: true, name: true } },
        items: {
          orderBy: { order: 'asc' },
          include: {
            listing: {
              select: {
                id: true,
                name: true,
                slug: true,
                type: true,
                images: { include: { media: true }, take: 1, where: { isPrimary: true } },
              },
            },
            event: {
              select: {
                id: true,
                name: true,
                slug: true,
                startDate: true,
                endDate: true,
                locationName: true,
                attachments: { include: { media: true }, take: 1, where: { isMainFlyer: true } },
              },
            },
            tour: {
              select: {
                id: true,
                name: true,
                slug: true,
                pricePerPerson: true,
                currency: true,
                images: { include: { media: true }, take: 1, where: { isPrimary: true } },
              },
            },
          },
        },
      },
    });

    return itinerary;
  }

  async update(id: string, userId: string, dto: UpdateItineraryDto) {
    const itinerary = await this.prisma.itinerary.findFirst({
      where: { id, deletedAt: null },
    });

    if (!itinerary) {
      throw new NotFoundException('Itinerary not found');
    }

    if (itinerary.userId !== userId) {
      throw new ForbiddenException('You can only update your own itineraries');
    }

    // Validate dates if provided
    if (dto.startDate && dto.endDate) {
      const startDate = new Date(dto.startDate);
      const endDate = new Date(dto.endDate);
      
      if (endDate < startDate) {
        throw new BadRequestException('End date must be after start date');
      }
    }

    // Generate share token if making public and doesn't have one
    let shareToken = itinerary.shareToken;
    if (dto.isPublic === true && !shareToken) {
      shareToken = this.generateShareToken();
    }

    // Update items if provided
    if (dto.items) {
      // Delete existing items
      await this.prisma.itineraryItem.deleteMany({
        where: { itineraryId: id },
      });

      // Create new items
      await this.prisma.itineraryItem.createMany({
        data: dto.items.map((item) => ({
          ...this.mapItemDtoToCreate(item),
          itineraryId: id,
        })),
      });
    }

    const updated = await this.prisma.itinerary.update({
      where: { id },
      data: {
        ...(dto.title && { title: dto.title }),
        ...(dto.description !== undefined && { description: dto.description }),
        ...(dto.startDate && { startDate: new Date(dto.startDate) }),
        ...(dto.endDate && { endDate: new Date(dto.endDate) }),
        ...(dto.location !== undefined && { location: dto.location }),
        ...(dto.countryId !== undefined && { countryId: dto.countryId }),
        ...(dto.cityId !== undefined && { cityId: dto.cityId }),
        ...(dto.isPublic !== undefined && { isPublic: dto.isPublic }),
        ...(shareToken && { shareToken }),
      },
      include: {
        country: { select: { id: true, name: true, code: true } },
        city: { select: { id: true, name: true } },
        items: {
          orderBy: { order: 'asc' },
          include: {
            listing: {
              select: {
                id: true,
                name: true,
                slug: true,
                type: true,
                images: { include: { media: true }, take: 1, where: { isPrimary: true } },
              },
            },
            event: {
              select: {
                id: true,
                name: true,
                slug: true,
                startDate: true,
                endDate: true,
                locationName: true,
                attachments: { include: { media: true }, take: 1, where: { isMainFlyer: true } },
              },
            },
            tour: {
              select: {
                id: true,
                name: true,
                slug: true,
                pricePerPerson: true,
                currency: true,
                images: { include: { media: true }, take: 1, where: { isPrimary: true } },
              },
            },
          },
        },
      },
    });

    return updated;
  }

  async delete(id: string, userId: string) {
    const itinerary = await this.prisma.itinerary.findFirst({
      where: { id, deletedAt: null },
    });

    if (!itinerary) {
      throw new NotFoundException('Itinerary not found');
    }

    if (itinerary.userId !== userId) {
      throw new ForbiddenException('You can only delete your own itineraries');
    }

    await this.prisma.itinerary.update({
      where: { id },
      data: { deletedAt: new Date() },
    });

    return { success: true, message: 'Itinerary deleted successfully' };
  }

  async share(id: string, userId: string) {
    const itinerary = await this.prisma.itinerary.findFirst({
      where: { id, deletedAt: null },
    });

    if (!itinerary) {
      throw new NotFoundException('Itinerary not found');
    }

    if (itinerary.userId !== userId) {
      throw new ForbiddenException('You can only share your own itineraries');
    }

    // Generate share token if doesn't exist
    let shareToken = itinerary.shareToken;
    if (!shareToken) {
      shareToken = this.generateShareToken();
      await this.prisma.itinerary.update({
        where: { id },
        data: { shareToken, isPublic: true },
      });
    }

    return { shareToken };
  }

  async findByShareToken(shareToken: string) {
    const itinerary = await this.prisma.itinerary.findFirst({
      where: {
        shareToken,
        deletedAt: null,
        isPublic: true,
      },
      include: {
        user: {
          select: {
            id: true,
            fullName: true,
            username: true,
            profileImage: { select: { url: true } },
          },
        },
        country: { select: { id: true, name: true, code: true } },
        city: { select: { id: true, name: true } },
        items: {
          orderBy: { order: 'asc' },
          include: {
            listing: {
              select: {
                id: true,
                name: true,
                slug: true,
                type: true,
                description: true,
                address: true,
                rating: true,
                reviewCount: true,
                images: { include: { media: true }, take: 1, where: { isPrimary: true } },
                city: { select: { id: true, name: true } },
              },
            },
            event: {
              select: {
                id: true,
                name: true,
                slug: true,
                description: true,
                startDate: true,
                endDate: true,
                locationName: true,
                venueName: true,
                address: true,
                attachments: { include: { media: true }, take: 1, where: { isMainFlyer: true } },
                city: { select: { id: true, name: true } },
              },
            },
            tour: {
              select: {
                id: true,
                name: true,
                slug: true,
                description: true,
                pricePerPerson: true,
                currency: true,
                durationHours: true,
                images: { include: { media: true }, take: 1, where: { isPrimary: true } },
                city: { select: { id: true, name: true } },
              },
            },
          },
        },
        _count: { select: { items: true } },
      },
    });

    if (!itinerary) {
      throw new NotFoundException('Shared itinerary not found');
    }

    return itinerary;
  }

  private mapItemDtoToCreate(item: CreateItineraryItemDto) {
    return {
      type: item.type as any,
      listingId: item.listingId,
      eventId: item.eventId,
      tourId: item.tourId,
      customName: item.customName,
      customDescription: item.customDescription,
      customLocation: item.customLocation,
      startTime: new Date(item.startTime),
      endTime: item.endTime ? new Date(item.endTime) : null,
      durationMinutes: item.durationMinutes,
      order: item.order,
      notes: item.notes,
      metadata: item.metadata,
    };
  }

  private generateShareToken(): string {
    return randomBytes(32).toString('hex');
  }
}

