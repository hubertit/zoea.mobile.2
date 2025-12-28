import { Injectable, NotFoundException } from '@nestjs/common';
import { Prisma, approval_status } from '@prisma/client';
import { PrismaService } from '../../../prisma/prisma.service';
import { AdminListNotificationRequestsDto } from './dto/list-notification-requests.dto';
import { AdminUpdateNotificationRequestDto } from './dto/update-notification-request.dto';
import { AdminCreateBroadcastDto } from './dto/create-broadcast.dto';

@Injectable()
export class AdminNotificationsService {
  constructor(private readonly prisma: PrismaService) {}

  async listRequests(dto: AdminListNotificationRequestsDto) {
    const page = dto.page ?? 1;
    const limit = dto.limit ?? 20;
    const skip = (page - 1) * limit;

    const where: Prisma.notification_requestsWhereInput = {};
    const andFilters: Prisma.notification_requestsWhereInput[] = [];
    if (dto.status) andFilters.push({ status: dto.status });
    if (dto.requesterId) andFilters.push({ requester_id: dto.requesterId });
    if (dto.search) {
      const search = dto.search.trim();
      andFilters.push({
        OR: [
          { title: { contains: search, mode: 'insensitive' } },
          { body: { contains: search, mode: 'insensitive' } },
        ],
      });
    }
    if (andFilters.length) where.AND = andFilters;

    const [data, total] = await Promise.all([
      this.prisma.notification_requests.findMany({
        where,
        skip,
        take: limit,
        orderBy: { created_at: 'desc' },
        select: {
          id: true,
          title: true,
          status: true,
          target_type: true,
          scheduled_at: true,
          requester_id: true,
          created_at: true,
        },
      }),
      this.prisma.notification_requests.count({ where }),
    ]);

    return { data, meta: { total, page, limit, totalPages: Math.max(Math.ceil(total / limit), 1) } };
  }

  async updateRequest(id: string, adminId: string, dto: AdminUpdateNotificationRequestDto) {
    await this.ensureRequestExists(id);

    const data: Prisma.notification_requestsUncheckedUpdateInput = {};
    if (dto.status) {
      data.status = dto.status as approval_status;
      data.reviewed_by = adminId;
      data.reviewed_at = new Date();
      if (dto.status === 'approved' && !data.sent_at) {
        data.sent_at = new Date();
      }
    }
    if (dto.rejectionReason !== undefined) data.rejection_reason = dto.rejectionReason;
    if (dto.revisionNotes !== undefined) data.revision_notes = dto.revisionNotes;

    const updated = await this.prisma.notification_requests.update({
      where: { id },
      data,
      select: {
        id: true,
        status: true,
        rejection_reason: true,
        revision_notes: true,
        reviewed_at: true,
        reviewed_by: true,
      },
    });

    return updated;
  }

  async createBroadcast(adminId: string, dto: AdminCreateBroadcastDto) {
    const request = await this.prisma.notification_requests.create({
      data: {
        requester_id: adminId,
        title: dto.title,
        body: dto.body,
        target_type: dto.targetType,
        target_segment: dto.segments ? (dto.segments as any) : undefined,
        action_url: dto.actionUrl,
        scheduled_at: dto.scheduleAt,
        status: dto.scheduleAt ? 'pending' : 'approved',
        reviewed_by: dto.scheduleAt ? null : adminId,
        reviewed_at: dto.scheduleAt ? null : new Date(),
        sent_at: dto.scheduleAt ? null : new Date(),
      },
      select: {
        id: true,
        title: true,
        status: true,
        scheduled_at: true,
        target_type: true,
      },
    });

    return request;
  }

  private async ensureRequestExists(id: string) {
    const exists = await this.prisma.notification_requests.findUnique({ where: { id }, select: { id: true } });
    if (!exists) throw new NotFoundException('Notification request not found');
  }
}


