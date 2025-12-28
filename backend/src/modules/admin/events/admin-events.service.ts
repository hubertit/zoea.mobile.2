import { Injectable, NotFoundException } from '@nestjs/common';
import { Prisma, event_status } from '@prisma/client';
import { PrismaService } from '../../../prisma/prisma.service';
import { AdminListEventsDto } from './dto/list-events.dto';
import { AdminUpdateEventStatusDto } from './dto/update-event-status.dto';
import { AdminCreateEventDto, AdminUpdateEventDto } from './dto/create-event.dto';

@Injectable()
export class AdminEventsService {
  constructor(private readonly prisma: PrismaService) {}

  async listEvents(dto: AdminListEventsDto) {
    const page = dto.page ?? 1;
    const limit = dto.limit ?? 20;
    const skip = (page - 1) * limit;

    const where: Prisma.EventWhereInput = { deletedAt: null };
    const andFilters: Prisma.EventWhereInput[] = [];

    if (dto.search) {
      const search = dto.search.trim();
      andFilters.push({
        OR: [
          { name: { contains: search, mode: 'insensitive' } },
          { organizer: { organizationName: { contains: search, mode: 'insensitive' } } },
        ],
      });
    }
    if (dto.status) andFilters.push({ status: dto.status });
    if (dto.organizerId) andFilters.push({ organizerId: dto.organizerId });
    if (dto.cityId) andFilters.push({ cityId: dto.cityId });
    if (andFilters.length) where.AND = andFilters;

    const [data, total] = await Promise.all([
      this.prisma.event.findMany({
        where,
        skip,
        take: limit,
        orderBy: { createdAt: 'desc' },
        select: {
          id: true,
          name: true,
          status: true,
          startDate: true,
          endDate: true,
          city: { select: { id: true, name: true } },
          organizer: { select: { id: true, organizationName: true } },
          isBlocked: true,
        },
      }),
      this.prisma.event.count({ where }),
    ]);

    return { data, meta: { total, page, limit, totalPages: Math.max(Math.ceil(total / limit), 1) } };
  }

  async getEvent(id: string) {
    const event = await this.prisma.event.findUnique({
      where: { id },
      include: {
        organizer: { select: { id: true, organizationName: true } },
        city: { select: { id: true, name: true } },
        tickets: true,
        attachments: true,
        attendees: true,
      },
    });
    if (!event) throw new NotFoundException('Event not found');
    return event;
  }

  async updateEventStatus(id: string, dto: AdminUpdateEventStatusDto) {
    await this.ensureEventExists(id);
    const data: Prisma.EventUncheckedUpdateInput = {};
    if (dto.status) data.status = dto.status as event_status;
    if (dto.isBlocked !== undefined) data.isBlocked = dto.isBlocked;
    if (dto.reviewNotes !== undefined) data.cancellationReason = dto.reviewNotes;

    const updated = await this.prisma.event.update({
      where: { id },
      data,
      select: {
        id: true,
        status: true,
        isBlocked: true,
        cancellationReason: true,
        updatedAt: true,
      },
    });
    return updated;
  }

  async createEvent(dto: AdminCreateEventDto) {
    const event = await this.prisma.event.create({
      data: {
        organizerId: dto.organizerId,
        name: dto.name,
        slug: dto.slug || `${dto.name.toLowerCase().replace(/\s+/g, '-')}-${Date.now().toString(36)}`,
        description: dto.description,
        privacy: dto.privacy,
        setup: dto.setup,
        countryId: dto.countryId,
        cityId: dto.cityId,
        address: dto.address,
        startDate: dto.startDate ? new Date(dto.startDate) : undefined,
        endDate: dto.endDate ? new Date(dto.endDate) : undefined,
        maxAttendance: dto.maxAttendance,
        isBlocked: dto.isBlocked ?? false,
        status: 'published',
      },
    });
    return this.getEvent(event.id);
  }

  async updateEvent(id: string, dto: AdminUpdateEventDto) {
    await this.ensureEventExists(id);
    await this.prisma.event.update({
      where: { id },
      data: {
        organizerId: dto.organizerId,
        name: dto.name,
        slug: dto.slug,
        description: dto.description,
        privacy: dto.privacy,
        setup: dto.setup,
        countryId: dto.countryId,
        cityId: dto.cityId,
        address: dto.address,
        startDate: dto.startDate ? new Date(dto.startDate) : undefined,
        endDate: dto.endDate ? new Date(dto.endDate) : undefined,
        maxAttendance: dto.maxAttendance,
        isBlocked: dto.isBlocked,
      },
    });
    return this.getEvent(id);
  }

  async deleteEvent(id: string) {
    await this.ensureEventExists(id);
    return this.prisma.event.update({
      where: { id },
      data: { deletedAt: new Date() },
      select: { id: true, deletedAt: true },
    });
  }

  async restoreEvent(id: string) {
    await this.ensureEventExists(id);
    return this.prisma.event.update({
      where: { id },
      data: { deletedAt: null },
      select: { id: true, deletedAt: true },
    });
  }

  private async ensureEventExists(id: string) {
    const exists = await this.prisma.event.findUnique({ where: { id }, select: { id: true } });
    if (!exists) throw new NotFoundException('Event not found');
  }
}


