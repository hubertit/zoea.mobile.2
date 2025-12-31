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

  async update(id: string, data: {
    name?: string;
    slug?: string;
    parentId?: string | null;
    icon?: string;
    description?: string;
    sortOrder?: number;
    isActive?: boolean;
  }) {
    // Check if category exists
    const existing = await this.prisma.category.findUnique({
      where: { id },
    });

    if (!existing) {
      throw new Error(`Category with id "${id}" not found`);
    }

    // If slug is being updated, check if new slug already exists
    if (data.slug && data.slug !== existing.slug) {
      const slugExists = await this.prisma.category.findUnique({
        where: { slug: data.slug },
      });

      if (slugExists) {
        throw new Error(`Category with slug "${data.slug}" already exists`);
      }
    }

    return this.prisma.category.update({
      where: { id },
      data: {
        ...(data.name && { name: data.name }),
        ...(data.slug && { slug: data.slug }),
        ...(data.parentId !== undefined && { parentId: data.parentId }),
        ...(data.icon !== undefined && { icon: data.icon }),
        ...(data.description !== undefined && { description: data.description }),
        ...(data.sortOrder !== undefined && { sortOrder: data.sortOrder }),
        ...(data.isActive !== undefined && { isActive: data.isActive }),
      },
      include: {
        parent: true,
        children: { where: { isActive: true }, orderBy: { sortOrder: 'asc' } },
        _count: { select: { listings: true, tours: true } },
      },
    });
  }

  async delete(id: string) {
    // Check if category exists
    const category = await this.prisma.category.findUnique({
      where: { id },
      include: {
        _count: { select: { listings: true, tours: true, children: true } },
      },
    });

    if (!category) {
      throw new Error(`Category with id "${id}" not found`);
    }

    // Prevent deletion if category has associated listings or tours
    if (category._count.listings > 0 || category._count.tours > 0) {
      throw new Error(
        `Cannot delete category "${category.name}" because it has ${category._count.listings} listings and ${category._count.tours} tours. Please remove or reassign them first.`
      );
    }

    // Prevent deletion if category has children
    if (category._count.children > 0) {
      throw new Error(
        `Cannot delete category "${category.name}" because it has ${category._count.children} subcategories. Please delete or reassign them first.`
      );
    }

    // Soft delete by setting isActive to false
    return this.prisma.category.update({
      where: { id },
      data: { isActive: false },
    });
  }
}

