import { Injectable } from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';

@Injectable()
export class CategoriesService {
  constructor(private prisma: PrismaService) {}

  async findAll(parentId?: string) {
    return this.prisma.category.findMany({
      where: {
        isActive: true,
        ...(parentId ? { parentId } : { parentId: null }),
      },
      include: {
        children: {
          where: { isActive: true },
          orderBy: { sortOrder: 'asc' },
        },
        _count: { select: { listings: true, tours: true } },
      },
      orderBy: { sortOrder: 'asc' },
    });
  }

  async findOne(id: string) {
    return this.prisma.category.findUnique({
      where: { id },
      include: {
        parent: true,
        children: { where: { isActive: true }, orderBy: { sortOrder: 'asc' } },
        _count: { select: { listings: true, tours: true } },
      },
    });
  }

  async findBySlug(slug: string) {
    return this.prisma.category.findUnique({
      where: { slug },
      include: {
        parent: true,
        children: { where: { isActive: true }, orderBy: { sortOrder: 'asc' } },
        _count: { select: { listings: true, tours: true } },
      },
    });
  }

  async getAmenities(category?: string) {
    return this.prisma.amenity.findMany({
      where: {
        ...(category && { category }),
      },
      orderBy: { name: 'asc' },
    });
  }

  async getTags(category?: string) {
    return this.prisma.tag.findMany({
      where: {
        ...(category && { category }),
      },
      orderBy: { name: 'asc' },
    });
  }

  async getEventContexts(parentId?: string) {
    return this.prisma.eventContext.findMany({
      where: {
        isActive: true,
        ...(parentId ? { parentId } : { parentId: null }),
      },
      include: {
        children: { where: { isActive: true } },
        _count: { select: { events: true } },
      },
      orderBy: { name: 'asc' },
    });
  }

  async create(data: {
    name: string;
    slug: string;
    parentId?: string;
    icon?: string;
    description?: string;
    sortOrder?: number;
    isActive?: boolean;
  }) {
    // Check if category with same slug already exists
    const existing = await this.prisma.category.findUnique({
      where: { slug: data.slug },
    });

    if (existing) {
      throw new Error(`Category with slug "${data.slug}" already exists`);
    }

    return this.prisma.category.create({
      data: {
        name: data.name,
        slug: data.slug,
        parentId: data.parentId,
        icon: data.icon,
        description: data.description,
        sortOrder: data.sortOrder ?? 0,
        isActive: data.isActive ?? true,
      },
      include: {
        parent: true,
        children: true,
        _count: { select: { listings: true, tours: true } },
      },
    });
  }
}

