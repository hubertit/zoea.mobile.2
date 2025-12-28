import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../../../prisma/prisma.service';
import { AdminListUsersDto } from './dto/list-users.dto';
import { AdminUpdateUserStatusDto } from './dto/update-user-status.dto';
import { AdminUpdateUserRolesDto } from './dto/update-user-roles.dto';

@Injectable()
export class AdminUsersService {
  constructor(private readonly prisma: PrismaService) {}

  async listUsers(params: AdminListUsersDto) {
    const page = params.page ?? 1;
    const limit = params.limit ?? 20;
    const skip = (page - 1) * limit;

    const where: any = {
      deletedAt: null,
    };

    const andFilters = [];

    if (params.search) {
      const searchTerm = params.search.trim();
      andFilters.push({
        OR: [
          { fullName: { contains: searchTerm, mode: 'insensitive' } },
          { email: { contains: searchTerm, mode: 'insensitive' } },
          { phoneNumber: { contains: searchTerm, mode: 'insensitive' } },
        ],
      });
    }

    if (params.role) {
      andFilters.push({
        roles: {
          has: params.role,
        },
      });
    }

    if (params.verificationStatus) {
      andFilters.push({
        verificationStatus: params.verificationStatus,
      });
    }

    if (params.isActive !== undefined) {
      andFilters.push({
        isActive: params.isActive,
      });
    }

    if (andFilters.length) {
      where.AND = andFilters;
    }

    const [data, total] = await Promise.all([
      this.prisma.user.findMany({
        where,
        take: limit,
        skip,
        orderBy: { createdAt: 'desc' },
        select: {
          id: true,
          fullName: true,
          email: true,
          phoneNumber: true,
          roles: true,
          verificationStatus: true,
          isActive: true,
          isBlocked: true,
          createdAt: true,
          country: { select: { id: true, name: true, code: true } },
          city: { select: { id: true, name: true } },
        },
      }),
      this.prisma.user.count({ where }),
    ]);

    return {
      data,
      meta: {
        total,
        page,
        limit,
        totalPages: Math.ceil(total / limit) || 1,
      },
    };
  }

  async getUserById(id: string) {
    const user = await this.prisma.user.findUnique({
      where: { id },
      include: {
        city: { select: { id: true, name: true } },
        country: { select: { id: true, name: true, code: true } },
        merchantProfiles: {
          select: {
            id: true,
            businessName: true,
            registrationStatus: true,
            createdAt: true,
            _count: { select: { listings: true, bookings: true } },
          },
        },
        bookings: { take: 5, select: { id: true, status: true, createdAt: true } },
        reviews: { take: 5, select: { id: true, rating: true, createdAt: true } },
      },
    });

    if (!user) {
      throw new NotFoundException('User not found');
    }

    const { passwordHash, ...safeUser } = user;
    return safeUser;
  }

  async updateUserStatus(id: string, data: AdminUpdateUserStatusDto) {
    await this.ensureUserExists(id);

    const updated = await this.prisma.user.update({
      where: { id },
      data: {
        isActive: data.isActive,
        isBlocked: data.isBlocked,
        verificationStatus: data.verificationStatus,
      },
      select: {
        id: true,
        isActive: true,
        isBlocked: true,
        verificationStatus: true,
        updatedAt: true,
      },
    });

    return updated;
  }

  async updateUserRoles(id: string, data: AdminUpdateUserRolesDto) {
    const uniqueRoles = Array.from(new Set(data.roles));
    await this.ensureUserExists(id);

    const updated = await this.prisma.user.update({
      where: { id },
      data: {
        roles: uniqueRoles as any,
      },
      select: {
        id: true,
        roles: true,
        updatedAt: true,
      },
    });

    return updated;
  }

  private async ensureUserExists(id: string) {
    const exists = await this.prisma.user.findUnique({
      where: { id },
      select: { id: true },
    });

    if (!exists) {
      throw new NotFoundException('User not found');
    }
  }
}

