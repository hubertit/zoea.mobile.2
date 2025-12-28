import { Injectable, NotFoundException } from '@nestjs/common';
import { Prisma, approval_status } from '@prisma/client';
import { PrismaService } from '../../../prisma/prisma.service';
import { AdminListMerchantsDto } from './dto/list-merchants.dto';
import { AdminUpdateMerchantStatusDto } from './dto/update-merchant-status.dto';
import { AdminUpdateMerchantSettingsDto } from './dto/update-merchant-settings.dto';
import { AdminCreateMerchantDto } from './dto/create-merchant.dto';
import { AdminUpdateMerchantDto } from './dto/update-merchant.dto';

@Injectable()
export class AdminMerchantsService {
  constructor(private readonly prisma: PrismaService) {}

  async listMerchants(params: AdminListMerchantsDto) {
    const page = params.page ?? 1;
    const limit = params.limit ?? 20;
    const skip = (page - 1) * limit;

    const where: Prisma.MerchantProfileWhereInput = {
      deletedAt: null,
    };

    const andFilters: Prisma.MerchantProfileWhereInput[] = [];

    if (params.search) {
      const search = params.search.trim();
      andFilters.push({
        OR: [
          { businessName: { contains: search, mode: 'insensitive' } },
          { businessEmail: { contains: search, mode: 'insensitive' } },
          { businessPhone: { contains: search, mode: 'insensitive' } },
          {
            user: {
              OR: [
                { fullName: { contains: search, mode: 'insensitive' } },
                { email: { contains: search, mode: 'insensitive' } },
              ],
            },
          },
        ],
      });
    }

    if (params.registrationStatus) {
      andFilters.push({ registrationStatus: params.registrationStatus });
    }

    if (params.isVerified !== undefined) {
      andFilters.push({ isVerified: params.isVerified });
    }

    if (params.countryId) {
      andFilters.push({ countryId: params.countryId });
    }

    if (params.cityId) {
      andFilters.push({ cityId: params.cityId });
    }

    if (andFilters.length) {
      where.AND = andFilters;
    }

    const [data, total] = await Promise.all([
      this.prisma.merchantProfile.findMany({
        where,
        skip,
        take: limit,
        orderBy: { createdAt: 'desc' },
        select: {
          id: true,
          businessName: true,
          registrationStatus: true,
          isVerified: true,
          commissionRate: true,
          payoutSchedule: true,
          country: { select: { id: true, name: true, code: true } },
          city: { select: { id: true, name: true } },
          user: { select: { id: true, fullName: true, email: true } },
          totalBookings: true,
          totalRevenue: true,
          averageRating: true,
          createdAt: true,
          updatedAt: true,
        },
      }),
      this.prisma.merchantProfile.count({ where }),
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

  async getMerchantById(id: string) {
    const merchant = await this.prisma.merchantProfile.findUnique({
      where: { id },
      include: {
        user: { select: { id: true, fullName: true, email: true, phoneNumber: true } },
        country: { select: { id: true, name: true, code: true } },
        city: { select: { id: true, name: true } },
        media: { select: { id: true, url: true } },
        listings: {
          where: { deletedAt: null },
          take: 5,
          orderBy: { createdAt: 'desc' },
          select: { id: true, name: true, status: true, rating: true, reviewCount: true },
        },
        _count: { select: { listings: true, bookings: true } },
      },
    });

    if (!merchant) {
      throw new NotFoundException('Merchant not found');
    }

    return merchant;
  }

  async createMerchant(dto: AdminCreateMerchantDto) {
    const merchant = await this.prisma.merchantProfile.create({
      data: {
        userId: dto.userId,
        businessName: dto.businessName,
        businessType: dto.businessType,
        businessRegistrationNumber: dto.businessRegistrationNumber,
        taxId: dto.taxId,
        description: dto.description,
        businessEmail: dto.businessEmail,
        businessPhone: dto.businessPhone,
        website: dto.website,
        socialLinks: dto.socialLinks as Prisma.InputJsonValue,
        countryId: dto.countryId,
        cityId: dto.cityId,
        districtId: dto.districtId,
        address: dto.address,
        registrationStatus: 'approved',
        isVerified: true,
        verifiedAt: new Date(),
      },
      include: {
        country: { select: { id: true, name: true, code: true } },
        city: { select: { id: true, name: true } },
        user: { select: { id: true, fullName: true, email: true } },
      },
    });

    return merchant;
  }

  async updateMerchant(id: string, dto: AdminUpdateMerchantDto) {
    await this.ensureMerchantExists(id);

    const updated = await this.prisma.merchantProfile.update({
      where: { id },
      data: {
        businessName: dto.businessName,
        businessType: dto.businessType,
        businessRegistrationNumber: dto.businessRegistrationNumber,
        taxId: dto.taxId,
        description: dto.description,
        businessEmail: dto.businessEmail,
        businessPhone: dto.businessPhone,
        website: dto.website,
        socialLinks: dto.socialLinks as Prisma.InputJsonValue,
        countryId: dto.countryId,
        cityId: dto.cityId,
        districtId: dto.districtId,
        address: dto.address,
      },
      select: {
        id: true,
        businessName: true,
        businessType: true,
        businessEmail: true,
        businessPhone: true,
        countryId: true,
        cityId: true,
        updatedAt: true,
      },
    });

    return updated;
  }

  async deleteMerchant(id: string) {
    await this.ensureMerchantExists(id);

    return this.prisma.merchantProfile.update({
      where: { id },
      data: { deletedAt: new Date() },
      select: { id: true, deletedAt: true },
    });
  }

  async restoreMerchant(id: string) {
    await this.ensureMerchantExists(id);

    return this.prisma.merchantProfile.update({
      where: { id },
      data: { deletedAt: null },
      select: { id: true, deletedAt: true },
    });
  }

  async updateMerchantStatus(id: string, adminId: string, dto: AdminUpdateMerchantStatusDto) {
    await this.ensureMerchantExists(id);

    const data: Prisma.MerchantProfileUncheckedUpdateInput = {};

    if (dto.registrationStatus) {
      data.registrationStatus = dto.registrationStatus;
      data.reviewedBy = adminId;
      data.reviewedAt = new Date();
    }

    if (dto.rejectionReason !== undefined) {
      data.rejectionReason = dto.rejectionReason;
    }

    if (dto.revisionNotes !== undefined) {
      data.revisionNotes = dto.revisionNotes;
    }

    if (dto.isVerified !== undefined) {
      data.isVerified = dto.isVerified;
      data.verifiedBy = dto.isVerified ? adminId : null;
      data.verifiedAt = dto.isVerified ? new Date() : null;
    }

    const updated = await this.prisma.merchantProfile.update({
      where: { id },
      data,
      select: {
        id: true,
        registrationStatus: true,
        rejectionReason: true,
        revisionNotes: true,
        isVerified: true,
        reviewedAt: true,
        reviewedBy: true,
        verifiedAt: true,
        verifiedBy: true,
      },
    });

    return updated;
  }

  async updateMerchantSettings(id: string, adminId: string, dto: AdminUpdateMerchantSettingsDto) {
    await this.ensureMerchantExists(id);

    const data: Prisma.MerchantProfileUncheckedUpdateInput = {};

    if (dto.commissionRate !== undefined) {
      data.commissionRate = dto.commissionRate;
    }

    if (dto.payoutSchedule !== undefined) {
      data.payoutSchedule = dto.payoutSchedule;
    }

    if (dto.bankAccountInfo !== undefined) {
      data.bankAccountInfo = dto.bankAccountInfo as Prisma.InputJsonValue;
    }

    if (dto.isVerified !== undefined) {
      data.isVerified = dto.isVerified;
      data.verifiedBy = dto.isVerified ? adminId : null;
      data.verifiedAt = dto.isVerified ? new Date() : null;
    }

    const updated = await this.prisma.merchantProfile.update({
      where: { id },
      data,
      select: {
        id: true,
        commissionRate: true,
        payoutSchedule: true,
        bankAccountInfo: true,
        isVerified: true,
        verifiedAt: true,
        verifiedBy: true,
      },
    });

    return updated;
  }

  private async ensureMerchantExists(id: string) {
    const exists = await this.prisma.merchantProfile.findUnique({
      where: { id },
      select: { id: true },
    });

    if (!exists) {
      throw new NotFoundException('Merchant not found');
    }
  }
}


