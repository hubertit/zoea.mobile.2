import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';
import { Prisma } from '@prisma/client';

@Injectable()
export class EventsService {
  constructor(private prisma: PrismaService) {}

  async findAll(params: {
    page?: number;
    limit?: number;
    status?: string;
    cityId?: string;
    countryId?: string;
    contextId?: string;
    startDate?: Date;
    endDate?: Date;
    isFeatured?: boolean;
    search?: string;
  }) {
    const { page = 1, limit = 25, status, cityId, countryId, contextId, startDate, endDate, isFeatured, search } = params;
    const skip = (page - 1) * limit;

    const where: Prisma.EventWhereInput = {
      deletedAt: null,
      ...(status && { status: status as any }),
      ...(cityId && { cityId }),
      ...(countryId && { countryId }),
      ...(contextId && { eventContextId: contextId }),
      ...(isFeatured !== undefined && { isFeatured }),
      ...(startDate && { startDate: { gte: startDate } }),
      ...(endDate && { endDate: { lte: endDate } }),
      ...(search && {
        OR: [
          { name: { contains: search, mode: 'insensitive' } },
          { description: { contains: search, mode: 'insensitive' } },
        ],
      }),
    };

    const [events, total] = await Promise.all([
      this.prisma.event.findMany({
        where,
        skip,
        take: limit,
        include: {
          eventContext: { select: { id: true, name: true, slug: true } },
          city: { select: { id: true, name: true } },
          country: { select: { id: true, name: true } },
          organizer: { select: { id: true, organizationName: true, isVerified: true, userId: true } },
          tickets: { where: { isVisible: true }, orderBy: { price: 'asc' } },
          attachments: { include: { media: true }, orderBy: { sortOrder: 'asc' } },
          _count: { select: { likes: true, comments: true, bookings: true, attendees: true } },
        },
        orderBy: [{ startDate: 'asc' }],
      }),
      this.prisma.event.count({ where }),
    ]);

    return {
      data: events.map(e => this.transformEvent(e)),
      meta: {
        total,
        page,
        limit,
        totalPages: Math.ceil(total / limit),
      },
    };
  }

  async findOne(id: string) {
    const event = await this.prisma.event.findUnique({
      where: { id },
      include: {
        eventContext: true,
        city: true,
        country: true,
        organizer: {
          select: {
            id: true,
            organizationName: true,
            description: true,
            isVerified: true,
            userId: true,
            user: { select: { id: true, fullName: true, profileImageId: true, username: true } },
          },
        },
        tickets: { where: { isVisible: true }, orderBy: { sortOrder: 'asc' } },
        attachments: { include: { media: true }, orderBy: { sortOrder: 'asc' } },
        reviews: {
          where: { status: 'approved', deletedAt: null },
          take: 10,
          orderBy: { createdAt: 'desc' },
          include: { user: { select: { id: true, fullName: true, profileImageId: true } } },
        },
        _count: { select: { likes: true, comments: true, bookings: true, attendees: true, reviews: true } },
      },
    });

    if (!event) throw new NotFoundException('Event not found');

    // Increment view count
    await this.prisma.event.update({
      where: { id },
      data: { viewCount: { increment: 1 } },
    });

    return this.transformEvent(event);
  }

  async findBySlug(slug: string) {
    const event = await this.prisma.event.findUnique({
      where: { slug },
      include: {
        eventContext: true,
        city: true,
        country: true,
        organizer: {
          select: {
            id: true,
            organizationName: true,
            isVerified: true,
            user: { select: { id: true, fullName: true, profileImageId: true, username: true } },
          },
        },
        tickets: { where: { isVisible: true }, orderBy: { sortOrder: 'asc' } },
        attachments: { include: { media: true }, orderBy: { sortOrder: 'asc' } },
        _count: { select: { likes: true, comments: true, attendees: true } },
      },
    });

    if (!event) throw new NotFoundException('Event not found');
    return this.transformEvent(event);
  }

  async getUpcoming(limit = 10, cityId?: string) {
    const events = await this.prisma.event.findMany({
      where: {
        status: 'published',
        deletedAt: null,
        startDate: { gte: new Date() },
        ...(cityId && { cityId }),
      },
      take: limit,
      include: {
        city: { select: { name: true } },
        attachments: { include: { media: true }, take: 1, where: { isMainFlyer: true } },
        tickets: { where: { isVisible: true }, take: 1, orderBy: { price: 'asc' } },
      },
      orderBy: { startDate: 'asc' },
    });

    return events.map(e => this.transformEvent(e));
  }

  async getThisWeek(limit = 25, cityId?: string) {
    const now = new Date();
    const startOfWeek = new Date(now);
    startOfWeek.setDate(now.getDate() - now.getDay());
    startOfWeek.setHours(0, 0, 0, 0);
    
    const endOfWeek = new Date(startOfWeek);
    endOfWeek.setDate(startOfWeek.getDate() + 7);

    return this.findAll({
      limit,
      cityId,
      status: 'published',
      startDate: startOfWeek,
      endDate: endOfWeek,
    });
  }

  async likeEvent(eventId: string, userId: string) {
    const existing = await this.prisma.eventLike.findUnique({
      where: { userId_eventId: { userId, eventId } },
    });

    if (existing) {
      await this.prisma.eventLike.delete({
        where: { userId_eventId: { userId, eventId } },
      });
      await this.prisma.event.update({
        where: { id: eventId },
        data: { likeCount: { decrement: 1 } },
      });
      return { liked: false };
    } else {
      await this.prisma.eventLike.create({
        data: { userId, eventId },
      });
      await this.prisma.event.update({
        where: { id: eventId },
        data: { likeCount: { increment: 1 } },
      });
      return { liked: true };
    }
  }

  async getComments(eventId: string, page = 1, limit = 20) {
    const skip = (page - 1) * limit;
    
    const [comments, total] = await Promise.all([
      this.prisma.eventComment.findMany({
        where: { eventId, parentId: null, isHidden: false, deletedAt: null },
        skip,
        take: limit,
        include: {
          user: { select: { id: true, fullName: true, profileImageId: true, username: true } },
          replies: {
            where: { isHidden: false, deletedAt: null },
            include: { user: { select: { id: true, fullName: true, profileImageId: true } } },
            orderBy: { createdAt: 'asc' },
          },
        },
        orderBy: [{ isPinned: 'desc' }, { createdAt: 'desc' }],
      }),
      this.prisma.eventComment.count({ where: { eventId, parentId: null, isHidden: false, deletedAt: null } }),
    ]);

    return { data: comments, meta: { total, page, limit } };
  }

  async addComment(eventId: string, userId: string, content: string, parentId?: string) {
    const comment = await this.prisma.eventComment.create({
      data: { eventId, userId, content, parentId },
      include: { user: { select: { id: true, fullName: true, profileImageId: true } } },
    });

    await this.prisma.event.update({
      where: { id: eventId },
      data: { commentCount: { increment: 1 } },
    });

    return comment;
  }

  private transformEvent(event: any) {
    const mainFlyer = event.attachments?.find((a: any) => a.isMainFlyer) || event.attachments?.[0];
    
    return {
      id: event.id,
      eventId: event.id,
      userId: event.organizer?.userId,
      creatorId: event.organizer?.userId,
      isBlocked: event.isBlocked,
      slug: event.slug,
      organizerProfileId: event.organizerId,
      type: event.type || 'event',
      createdAt: event.createdAt,
      updatedAt: event.updatedAt,
      commentcount: String(event._count?.comments || event.commentCount || 0),
      likecount: String(event._count?.likes || event.likeCount || 0),
      sinccount: String(event._count?.attendees || event.attendingCount || 0),
      hasLiked: false, // Would need user context
      Event: {
        id: event.id,
        userId: event.organizer?.userId,
        name: event.name,
        description: event.description,
        OrganizerProfileId: event.organizerId,
        flyer: mainFlyer?.media?.url || '',
        imageId: mainFlyer?.mediaId,
        fileId: mainFlyer?.id,
        location: {
          type: 'Point',
          coordinates: [Number(event.longitude) || 0, Number(event.latitude) || 0],
        },
        locationName: event.locationName || event.venueName || '',
        isAcceptable: true,
        EventContextId: event.eventContextId,
        maxAttendance: event.maxAttendance || 0,
        attending: event.attendingCount || 0,
        startDate: event.startDate,
        endDate: event.endDate,
        createdAt: event.createdAt,
        updatedAt: event.updatedAt,
        setup: event.setup || 'in_person',
        privacy: event.privacy || 'public',
        PostId: null,
        ongoing: event.status === 'ongoing',
        Tickets: event.tickets?.map((t: any) => ({
          id: t.id,
          price: Number(t.price) || 0,
          name: t.name,
          disabled: t.status !== 'available',
          type: t.type || 'paid',
          orderType: t.orderType || 'first_come',
          currency: t.currency || 'RWF',
          createdAt: t.createdAt,
          updatedAt: t.updatedAt,
          description: t.description,
        })) || [],
        Attachments: event.attachments?.map((a: any) => ({
          id: a.id,
          blurhash: a.media?.blurhash || '',
          url: a.media?.url || '',
          fileType: a.media?.mediaType || 'image',
          imageId: a.mediaId,
          width: a.media?.width || 0,
          height: a.media?.height || 0,
          videoId: null,
          fileId: a.id,
          createdAt: a.createdAt,
          updatedAt: a.media?.createdAt,
          ContentId: null,
          EventId: event.id,
          color: a.media?.color || '',
          medium: a.media?.mediumUrl,
          small: a.media?.thumbnailUrl,
          isDark: a.media?.isDark || false,
          isMainFlyer: a.isMainFlyer || false,
        })) || [],
        EventContext: event.eventContext ? {
          id: event.eventContext.id,
          name: event.eventContext.name,
          description: event.eventContext.description,
          createdAt: event.eventContext.createdAt,
          updatedAt: event.eventContext.updatedAt,
        } : null,
      },
      owner: event.organizer?.user ? {
        id: event.organizer.user.id,
        username: event.organizer.user.username || '',
        name: event.organizer.organizationName || event.organizer.user.fullName || '',
        email: '',
        imageUrl: '',
        bgUrl: null,
        isPrivate: false,
        accountType: 'business',
        isActive: true,
        createdAt: event.createdAt,
        maxDistance: 50,
        bio: event.organizer.description,
        isVerified: event.organizer.isVerified || false,
        OrganizerProfileVerified: event.organizer.isVerified || false,
        isCallerSubscribedToUser: false,
        isUserSubscribedToCaller: false,
      } : null,
    };
  }
}
