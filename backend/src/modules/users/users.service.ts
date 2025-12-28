import { Injectable, NotFoundException, BadRequestException } from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';

@Injectable()
export class UsersService {
  constructor(private prisma: PrismaService) {}

  async findOne(id: string) {
    const user = await this.prisma.user.findUnique({
      where: { id },
      include: {
        city: { select: { id: true, name: true } },
        country: { select: { id: true, name: true, code: true } },
        profileImage: { select: { id: true, url: true, thumbnailUrl: true } },
        _count: {
          select: {
            bookings: true,
            reviews: true,
            favorites: true,
          },
        },
      },
    });

    if (!user) throw new NotFoundException('User not found');
    const { passwordHash, ...safeUser } = user;
    return safeUser;
  }

  async findByEmail(email: string) {
    return this.prisma.user.findUnique({ where: { email } });
  }

  async findByUsername(username: string) {
    const user = await this.prisma.user.findUnique({
      where: { username },
      include: {
        city: { select: { name: true } },
        country: { select: { name: true } },
        profileImage: { select: { url: true, thumbnailUrl: true } },
      },
    });

    if (!user) throw new NotFoundException('User not found');
    const { passwordHash, email, phoneNumber, ...publicUser } = user;
    return publicUser;
  }

  async update(id: string, data: {
    fullName?: string;
    firstName?: string;
    lastName?: string;
    username?: string;
    bio?: string;
    dateOfBirth?: string;
    gender?: string;
    countryId?: string;
    cityId?: string;
    address?: string;
    postalCode?: string;
    profession?: string;
    company?: string;
    industry?: string;
    interests?: string[];
    dietaryPreferences?: string[];
    accessibilityNeeds?: string[];
    preferredCurrency?: string;
    preferredLanguage?: string;
    timezone?: string;
    maxDistance?: number;
    notificationPreferences?: any;
    marketingConsent?: boolean;
    isPrivate?: boolean;
  }) {
    if (data.username) {
      const existing = await this.prisma.user.findFirst({
        where: { username: data.username, id: { not: id } },
      });
      if (existing) throw new BadRequestException('Username already taken');
    }

    const updated = await this.prisma.user.update({
      where: { id },
      data: {
        ...data,
        dateOfBirth: data.dateOfBirth ? new Date(data.dateOfBirth) : undefined,
      },
      include: {
        city: { select: { id: true, name: true } },
        country: { select: { id: true, name: true } },
        profileImage: { select: { id: true, url: true } },
      },
    });

    const { passwordHash, ...safeUser } = updated;
    return safeUser;
  }

  async updateEmail(userId: string, email: string, password: string) {
    const user = await this.prisma.user.findUnique({ where: { id: userId } });
    if (!user) throw new NotFoundException('User not found');
    
    // Verify password
    const bcrypt = require('bcrypt');
    const valid = await bcrypt.compare(password, user.passwordHash);
    if (!valid) throw new BadRequestException('Invalid password');

    // Check email uniqueness
    const existing = await this.prisma.user.findFirst({
      where: { email, id: { not: userId } },
    });
    if (existing) throw new BadRequestException('Email already in use');

    return this.prisma.user.update({
      where: { id: userId },
      data: { email, emailVerifiedAt: null },
      select: { id: true, email: true },
    });
  }

  async updatePhone(userId: string, phoneNumber: string, password: string) {
    const user = await this.prisma.user.findUnique({ where: { id: userId } });
    if (!user) throw new NotFoundException('User not found');
    
    const bcrypt = require('bcrypt');
    const valid = await bcrypt.compare(password, user.passwordHash);
    if (!valid) throw new BadRequestException('Invalid password');

    const existing = await this.prisma.user.findFirst({
      where: { phoneNumber, id: { not: userId } },
    });
    if (existing) throw new BadRequestException('Phone number already in use');

    return this.prisma.user.update({
      where: { id: userId },
      data: { phoneNumber, phoneVerifiedAt: null },
      select: { id: true, phoneNumber: true },
    });
  }

  async changePassword(userId: string, currentPassword: string, newPassword: string) {
    const user = await this.prisma.user.findUnique({ where: { id: userId } });
    if (!user) throw new NotFoundException('User not found');
    
    const bcrypt = require('bcrypt');
    const valid = await bcrypt.compare(currentPassword, user.passwordHash);
    if (!valid) throw new BadRequestException('Current password is incorrect');

    const passwordHash = await bcrypt.hash(newPassword, 10);
    await this.prisma.user.update({
      where: { id: userId },
      data: { passwordHash },
    });

    return { success: true };
  }

  async updateProfileImage(userId: string, mediaId: string) {
    return this.prisma.user.update({
      where: { id: userId },
      data: { profileImageId: mediaId },
      select: {
        id: true,
        profileImageId: true,
        profileImage: { select: { url: true, thumbnailUrl: true } },
      },
    });
  }

  async updateBackgroundImage(userId: string, mediaId: string) {
    return this.prisma.user.update({
      where: { id: userId },
      data: { backgroundImageId: mediaId },
      select: {
        id: true,
        backgroundImageId: true,
      },
    });
  }

  async getPreferences(userId: string) {
    const user = await this.prisma.user.findUnique({
      where: { id: userId },
      select: {
        preferredCurrency: true,
        preferredLanguage: true,
        timezone: true,
        maxDistance: true,
        notificationPreferences: true,
        marketingConsent: true,
        interests: true,
        dietaryPreferences: true,
        accessibilityNeeds: true,
        isPrivate: true,
      },
    });
    if (!user) throw new NotFoundException('User not found');
    return user;
  }

  async updatePreferences(userId: string, data: {
    preferredCurrency?: string;
    preferredLanguage?: string;
    timezone?: string;
    maxDistance?: number;
    notificationPreferences?: any;
    marketingConsent?: boolean;
    interests?: string[];
    dietaryPreferences?: string[];
    accessibilityNeeds?: string[];
    isPrivate?: boolean;
  }) {
    return this.prisma.user.update({
      where: { id: userId },
      data,
      select: {
        preferredCurrency: true,
        preferredLanguage: true,
        timezone: true,
        maxDistance: true,
        notificationPreferences: true,
        marketingConsent: true,
        interests: true,
        dietaryPreferences: true,
        accessibilityNeeds: true,
        isPrivate: true,
      },
    });
  }

  async getStats(userId: string) {
    const [bookings, reviews, favorites] = await Promise.all([
      this.prisma.booking.count({ where: { userId, status: 'completed' } }),
      this.prisma.review.count({ where: { userId, deletedAt: null } }),
      this.prisma.favorite.count({ where: { userId } }),
    ]);

    return { bookings, reviews, favorites, visitedPlaces: bookings };
  }

  async getVisitedPlaces(userId: string, page = 1, limit = 20) {
    const skip = (page - 1) * limit;

    const [bookings, total] = await Promise.all([
      this.prisma.booking.findMany({
        where: { userId, status: 'completed', listingId: { not: null } },
        skip,
        take: limit,
        select: {
          id: true,
          createdAt: true,
          listing: {
            select: {
              id: true,
              name: true,
              slug: true,
              type: true,
              city: { select: { name: true } },
              images: { include: { media: true }, take: 1, where: { isPrimary: true } },
            },
          },
        },
        orderBy: { createdAt: 'desc' },
        distinct: ['listingId'],
      }),
      this.prisma.booking.count({ where: { userId, status: 'completed', listingId: { not: null } } }),
    ]);

    return { data: bookings, meta: { total, page, limit } };
  }

  // ============ MERCHANT PROFILES (Multiple per user) ============
  async getMerchantProfiles(userId: string) {
    return this.prisma.merchantProfile.findMany({
      where: { userId, deletedAt: null },
      include: {
        city: { select: { id: true, name: true } },
        country: { select: { id: true, name: true } },
        _count: { select: { listings: true, bookings: true } },
      },
      orderBy: { createdAt: 'desc' },
    });
  }

  async getMerchantProfile(userId: string, profileId?: string) {
    if (profileId) {
      const profile = await this.prisma.merchantProfile.findFirst({
        where: { id: profileId, userId, deletedAt: null },
        include: {
          city: { select: { id: true, name: true } },
          country: { select: { id: true, name: true } },
          listings: { where: { deletedAt: null }, take: 10, orderBy: { createdAt: 'desc' } },
          _count: { select: { listings: true, bookings: true } },
        },
      });
      if (!profile) throw new NotFoundException('Merchant profile not found');
      return profile;
    }
    // Return first/primary profile for backwards compatibility
    return this.prisma.merchantProfile.findFirst({
      where: { userId, deletedAt: null },
      include: {
        city: { select: { id: true, name: true } },
        country: { select: { id: true, name: true } },
        listings: { where: { deletedAt: null }, take: 5, orderBy: { createdAt: 'desc' } },
        _count: { select: { listings: true, bookings: true } },
      },
      orderBy: { createdAt: 'asc' },
    });
  }

  async createMerchantProfile(userId: string, data: {
    businessName: string;
    businessType: string;
    businessRegistrationNumber?: string;
    taxId?: string;
    description?: string;
    businessEmail?: string;
    businessPhone?: string;
    website?: string;
    socialLinks?: any;
    countryId?: string;
    cityId?: string;
    address?: string;
  }) {
    // Add merchant role if not already
    const user = await this.prisma.user.findUnique({ where: { id: userId } });
    if (user && !user.roles.includes('merchant')) {
      await this.prisma.user.update({
        where: { id: userId },
        data: { roles: { push: 'merchant' } },
      });
    }

    return this.prisma.merchantProfile.create({
      data: {
        userId,
        businessName: data.businessName,
        businessType: data.businessType as any,
        businessRegistrationNumber: data.businessRegistrationNumber,
        taxId: data.taxId,
        description: data.description,
        businessEmail: data.businessEmail,
        businessPhone: data.businessPhone,
        website: data.website,
        socialLinks: data.socialLinks,
        countryId: data.countryId,
        cityId: data.cityId,
        address: data.address,
        registrationStatus: 'pending',
      },
      include: {
        city: { select: { id: true, name: true } },
        country: { select: { id: true, name: true } },
      },
    });
  }

  async updateMerchantProfile(userId: string, profileId: string, data: {
    businessName?: string;
    description?: string;
    businessEmail?: string;
    businessPhone?: string;
    website?: string;
    socialLinks?: any;
    countryId?: string;
    cityId?: string;
    address?: string;
  }) {
    const profile = await this.prisma.merchantProfile.findFirst({
      where: { id: profileId, userId, deletedAt: null },
    });
    if (!profile) throw new NotFoundException('Merchant profile not found');

    return this.prisma.merchantProfile.update({
      where: { id: profileId },
      data,
    });
  }

  async deleteMerchantProfile(userId: string, profileId: string) {
    const profile = await this.prisma.merchantProfile.findFirst({
      where: { id: profileId, userId, deletedAt: null },
    });
    if (!profile) throw new NotFoundException('Merchant profile not found');

    return this.prisma.merchantProfile.update({
      where: { id: profileId },
      data: { deletedAt: new Date() },
    });
  }

  // ============ ORGANIZER PROFILES (Multiple per user) ============
  async getOrganizerProfiles(userId: string) {
    return this.prisma.organizerProfile.findMany({
      where: { userId, deletedAt: null },
      include: {
        city: { select: { id: true, name: true } },
        country: { select: { id: true, name: true } },
        _count: { select: { events: true, bookings: true } },
      },
      orderBy: { createdAt: 'desc' },
    });
  }

  async getOrganizerProfile(userId: string, profileId?: string) {
    if (profileId) {
      const profile = await this.prisma.organizerProfile.findFirst({
        where: { id: profileId, userId, deletedAt: null },
        include: {
          city: { select: { id: true, name: true } },
          country: { select: { id: true, name: true } },
          events: { where: { deletedAt: null }, take: 10, orderBy: { createdAt: 'desc' } },
          _count: { select: { events: true, bookings: true } },
        },
      });
      if (!profile) throw new NotFoundException('Organizer profile not found');
      return profile;
    }
    return this.prisma.organizerProfile.findFirst({
      where: { userId, deletedAt: null },
      include: {
        city: { select: { id: true, name: true } },
        country: { select: { id: true, name: true } },
        events: { where: { deletedAt: null }, take: 5, orderBy: { createdAt: 'desc' } },
        _count: { select: { events: true, bookings: true } },
      },
      orderBy: { createdAt: 'asc' },
    });
  }

  async createOrganizerProfile(userId: string, data: {
    organizationName: string;
    organizationType?: string;
    description?: string;
    contactEmail?: string;
    contactPhone?: string;
    website?: string;
    socialLinks?: any;
    countryId?: string;
    cityId?: string;
  }) {
    const user = await this.prisma.user.findUnique({ where: { id: userId } });
    if (user && !user.roles.includes('event_organizer')) {
      await this.prisma.user.update({
        where: { id: userId },
        data: { roles: { push: 'event_organizer' } },
      });
    }

    return this.prisma.organizerProfile.create({
      data: {
        userId,
        organizationName: data.organizationName,
        organizationType: data.organizationType,
        description: data.description,
        contactEmail: data.contactEmail,
        contactPhone: data.contactPhone,
        website: data.website,
        socialLinks: data.socialLinks,
        countryId: data.countryId,
        cityId: data.cityId,
        registrationStatus: 'pending',
      },
    });
  }

  async updateOrganizerProfile(userId: string, profileId: string, data: {
    organizationName?: string;
    organizationType?: string;
    description?: string;
    contactEmail?: string;
    contactPhone?: string;
    website?: string;
    socialLinks?: any;
    countryId?: string;
    cityId?: string;
  }) {
    const profile = await this.prisma.organizerProfile.findFirst({
      where: { id: profileId, userId, deletedAt: null },
    });
    if (!profile) throw new NotFoundException('Organizer profile not found');

    return this.prisma.organizerProfile.update({
      where: { id: profileId },
      data,
    });
  }

  async deleteOrganizerProfile(userId: string, profileId: string) {
    const profile = await this.prisma.organizerProfile.findFirst({
      where: { id: profileId, userId, deletedAt: null },
    });
    if (!profile) throw new NotFoundException('Organizer profile not found');

    return this.prisma.organizerProfile.update({
      where: { id: profileId },
      data: { deletedAt: new Date() },
    });
  }

  // ============ TOUR OPERATOR PROFILES (Multiple per user) ============
  async getTourOperatorProfiles(userId: string) {
    return this.prisma.tourOperatorProfile.findMany({
      where: { userId, deletedAt: null },
      include: {
        city: { select: { id: true, name: true } },
        country: { select: { id: true, name: true } },
        _count: { select: { tours: true, bookings: true } },
      },
      orderBy: { createdAt: 'desc' },
    });
  }

  async getTourOperatorProfile(userId: string, profileId?: string) {
    if (profileId) {
      const profile = await this.prisma.tourOperatorProfile.findFirst({
        where: { id: profileId, userId, deletedAt: null },
        include: {
          city: { select: { id: true, name: true } },
          country: { select: { id: true, name: true } },
          tours: { where: { deletedAt: null }, take: 10, orderBy: { createdAt: 'desc' } },
          _count: { select: { tours: true, bookings: true } },
        },
      });
      if (!profile) throw new NotFoundException('Tour operator profile not found');
      return profile;
    }
    return this.prisma.tourOperatorProfile.findFirst({
      where: { userId, deletedAt: null },
      include: {
        city: { select: { id: true, name: true } },
        country: { select: { id: true, name: true } },
        tours: { where: { deletedAt: null }, take: 5, orderBy: { createdAt: 'desc' } },
        _count: { select: { tours: true, bookings: true } },
      },
      orderBy: { createdAt: 'asc' },
    });
  }

  async createTourOperatorProfile(userId: string, data: {
    companyName: string;
    licenseNumber?: string;
    description?: string;
    specializations?: string[];
    languagesOffered?: string[];
    contactEmail?: string;
    contactPhone?: string;
    website?: string;
    socialLinks?: any;
    countryId?: string;
    cityId?: string;
    operatingRegions?: string[];
  }) {
    const user = await this.prisma.user.findUnique({ where: { id: userId } });
    if (user && !user.roles.includes('tour_operator')) {
      await this.prisma.user.update({
        where: { id: userId },
        data: { roles: { push: 'tour_operator' } },
      });
    }

    return this.prisma.tourOperatorProfile.create({
      data: {
        userId,
        companyName: data.companyName,
        licenseNumber: data.licenseNumber,
        description: data.description,
        specializations: data.specializations || [],
        languagesOffered: data.languagesOffered || ['en'],
        contactEmail: data.contactEmail,
        contactPhone: data.contactPhone,
        website: data.website,
        socialLinks: data.socialLinks,
        countryId: data.countryId,
        cityId: data.cityId,
        operatingRegions: data.operatingRegions || [],
        registrationStatus: 'pending',
      },
    });
  }

  async updateTourOperatorProfile(userId: string, profileId: string, data: {
    companyName?: string;
    description?: string;
    specializations?: string[];
    languagesOffered?: string[];
    contactEmail?: string;
    contactPhone?: string;
    website?: string;
    socialLinks?: any;
    countryId?: string;
    cityId?: string;
    operatingRegions?: string[];
  }) {
    const profile = await this.prisma.tourOperatorProfile.findFirst({
      where: { id: profileId, userId, deletedAt: null },
    });
    if (!profile) throw new NotFoundException('Tour operator profile not found');

    return this.prisma.tourOperatorProfile.update({
      where: { id: profileId },
      data,
    });
  }

  async deleteTourOperatorProfile(userId: string, profileId: string) {
    const profile = await this.prisma.tourOperatorProfile.findFirst({
      where: { id: profileId, userId, deletedAt: null },
    });
    if (!profile) throw new NotFoundException('Tour operator profile not found');

    return this.prisma.tourOperatorProfile.update({
      where: { id: profileId },
      data: { deletedAt: new Date() },
    });
  }

  async deleteAccount(userId: string) {
    await this.prisma.user.update({
      where: { id: userId },
      data: {
        deletedAt: new Date(),
        isActive: false,
        email: `deleted_${userId}@zoea.africa`,
        phoneNumber: null,
        username: `deleted_${userId}`,
      },
    });

    return { success: true };
  }
}
