import { Injectable, NotFoundException, BadRequestException, ForbiddenException } from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';
import { Prisma } from '@prisma/client';
import { 
  CreateMenuDto, 
  UpdateMenuDto, 
  MenuQueryDto,
  CreateMenuCategoryDto,
  UpdateMenuCategoryDto,
  CreateMenuItemDto,
  UpdateMenuItemDto,
} from './dto/menu.dto';

@Injectable()
export class MenusService {
  constructor(private prisma: PrismaService) {}

  // Menus
  async findAll(params: MenuQueryDto) {
    const { listingId, isActive } = params;

    const where: Prisma.MenuWhereInput = {
      deletedAt: null,
      ...(listingId && { listingId }),
      ...(isActive !== undefined && { isActive }),
    };

    const menus = await this.prisma.menu.findMany({
      where,
      include: {
        listing: { 
          select: { 
            id: true, 
            name: true, 
            slug: true,
            merchantId: true,
          } 
        },
        items: {
          where: { isAvailable: true },
          orderBy: [
            { category: { sortOrder: 'asc' } },
            { sortOrder: 'asc' },
          ],
          include: {
            category: true,
          },
        },
        _count: { 
          select: { 
            items: true,
          } 
        },
      },
      orderBy: [
        { isDefault: 'desc' },
        { sortOrder: 'asc' },
        { createdAt: 'asc' },
      ],
    });

    return menus;
  }

  async findOne(id: string) {
    const menu = await this.prisma.menu.findFirst({
      where: { id, deletedAt: null },
      include: {
        listing: { 
          select: { 
            id: true, 
            name: true, 
            slug: true,
            merchantId: true,
          } 
        },
        items: {
          orderBy: [
            { category: { sortOrder: 'asc' } },
            { sortOrder: 'asc' },
          ],
          include: {
            category: true,
          },
        },
      },
    });

    if (!menu) {
      throw new NotFoundException(`Menu with ID ${id} not found`);
    }

    return menu;
  }

  async findByListing(listingId: string, params: MenuQueryDto) {
    return this.findAll({ ...params, listingId });
  }

  async create(userId: string, createMenuDto: CreateMenuDto) {
    // Verify listing exists and user owns it
    const listing = await this.prisma.listing.findFirst({
      where: { 
        id: createMenuDto.listingId,
        deletedAt: null,
      },
      include: {
        merchant: {
          select: { userId: true },
        },
      },
    });

    if (!listing) {
      throw new NotFoundException(`Listing with ID ${createMenuDto.listingId} not found`);
    }

    if (listing.merchant?.userId !== userId) {
      throw new ForbiddenException('You do not have permission to create menus for this listing');
    }

    // If setting as default, unset other default menus
    if (createMenuDto.isDefault) {
      await this.prisma.menu.updateMany({
        where: {
          listingId: createMenuDto.listingId,
          isDefault: true,
        },
        data: {
          isDefault: false,
        },
      });
    }

    const menu = await this.prisma.menu.create({
      data: {
        listingId: createMenuDto.listingId,
        name: createMenuDto.name,
        description: createMenuDto.description,
        availableDays: createMenuDto.availableDays || [],
        startTime: createMenuDto.startTime,
        endTime: createMenuDto.endTime,
        isActive: createMenuDto.isActive ?? true,
        isDefault: createMenuDto.isDefault ?? false,
        sortOrder: createMenuDto.sortOrder ?? 0,
      },
      include: {
        listing: { 
          select: { 
            id: true, 
            name: true, 
            slug: true,
          } 
        },
        items: true,
      },
    });

    return menu;
  }

  async update(id: string, userId: string, updateMenuDto: UpdateMenuDto) {
    const menu = await this.findOne(id);

    // Verify user owns the listing
    const listing = await this.prisma.listing.findFirst({
      where: { 
        id: menu.listingId,
        deletedAt: null,
      },
      include: {
        merchant: {
          select: { userId: true },
        },
      },
    });

    if (!listing || listing.merchant?.userId !== userId) {
      throw new ForbiddenException('You do not have permission to update this menu');
    }

    // If setting as default, unset other default menus
    if (updateMenuDto.isDefault) {
      await this.prisma.menu.updateMany({
        where: {
          listingId: menu.listingId,
          isDefault: true,
          id: { not: id },
        },
        data: {
          isDefault: false,
        },
      });
    }

    const updated = await this.prisma.menu.update({
      where: { id },
      data: {
        ...(updateMenuDto.name !== undefined && { name: updateMenuDto.name }),
        ...(updateMenuDto.description !== undefined && { description: updateMenuDto.description }),
        ...(updateMenuDto.availableDays !== undefined && { availableDays: updateMenuDto.availableDays }),
        ...(updateMenuDto.startTime !== undefined && { startTime: updateMenuDto.startTime }),
        ...(updateMenuDto.endTime !== undefined && { endTime: updateMenuDto.endTime }),
        ...(updateMenuDto.isActive !== undefined && { isActive: updateMenuDto.isActive }),
        ...(updateMenuDto.isDefault !== undefined && { isDefault: updateMenuDto.isDefault }),
        ...(updateMenuDto.sortOrder !== undefined && { sortOrder: updateMenuDto.sortOrder }),
      },
      include: {
        listing: { 
          select: { 
            id: true, 
            name: true, 
            slug: true,
          } 
        },
        items: true,
      },
    });

    return updated;
  }

  async remove(id: string, userId: string) {
    const menu = await this.findOne(id);

    // Verify user owns the listing
    const listing = await this.prisma.listing.findFirst({
      where: { 
        id: menu.listingId,
        deletedAt: null,
      },
      include: {
        merchant: {
          select: { userId: true },
        },
      },
    });

    if (!listing || listing.merchant?.userId !== userId) {
      throw new ForbiddenException('You do not have permission to delete this menu');
    }

    // Soft delete
    await this.prisma.menu.update({
      where: { id },
      data: { deletedAt: new Date() },
    });

    return { message: 'Menu deleted successfully' };
  }

  // Menu Categories
  async findAllCategories() {
    return this.prisma.menuCategory.findMany({
      orderBy: { sortOrder: 'asc' },
      include: {
        _count: { select: { items: true } },
      },
    });
  }

  async findCategory(id: string) {
    const category = await this.prisma.menuCategory.findFirst({
      where: { id },
      include: {
        items: {
          orderBy: { sortOrder: 'asc' },
        },
      },
    });

    if (!category) {
      throw new NotFoundException(`Menu category with ID ${id} not found`);
    }

    return category;
  }

  async createCategory(createCategoryDto: CreateMenuCategoryDto) {
    const category = await this.prisma.menuCategory.create({
      data: {
        name: createCategoryDto.name,
        description: createCategoryDto.description,
        sortOrder: createCategoryDto.sortOrder ?? 0,
      },
    });

    return category;
  }

  async updateCategory(id: string, updateCategoryDto: UpdateMenuCategoryDto) {
    const category = await this.findCategory(id);

    const updated = await this.prisma.menuCategory.update({
      where: { id },
      data: {
        ...(updateCategoryDto.name !== undefined && { name: updateCategoryDto.name }),
        ...(updateCategoryDto.description !== undefined && { description: updateCategoryDto.description }),
        ...(updateCategoryDto.sortOrder !== undefined && { sortOrder: updateCategoryDto.sortOrder }),
      },
    });

    return updated;
  }

  async removeCategory(id: string) {
    const category = await this.findCategory(id);

    // Check if category has items
    const itemCount = await this.prisma.menuItem.count({
      where: { categoryId: id },
    });

    if (itemCount > 0) {
      throw new BadRequestException(`Cannot delete category with ${itemCount} items. Please remove items first.`);
    }

    await this.prisma.menuCategory.delete({
      where: { id },
    });

    return { message: 'Category deleted successfully' };
  }

  // Menu Items
  async createItem(userId: string, createItemDto: CreateMenuItemDto) {
    const menu = await this.findOne(createItemDto.menuId);

    // Verify user owns the listing
    const listing = await this.prisma.listing.findFirst({
      where: { 
        id: menu.listingId,
        deletedAt: null,
      },
      include: {
        merchant: {
          select: { userId: true },
        },
      },
    });

    if (!listing || listing.merchant?.userId !== userId) {
      throw new ForbiddenException('You do not have permission to create items for this menu');
    }

    // Verify category exists if provided
    if (createItemDto.categoryId) {
      const category = await this.prisma.menuCategory.findFirst({
        where: { id: createItemDto.categoryId },
      });

      if (!category) {
        throw new NotFoundException(`Menu category with ID ${createItemDto.categoryId} not found`);
      }
    }

    const item = await this.prisma.menuItem.create({
      data: {
        menuId: createItemDto.menuId,
        categoryId: createItemDto.categoryId,
        name: createItemDto.name,
        description: createItemDto.description,
        price: createItemDto.price,
        currency: createItemDto.currency || 'RWF',
        compareAtPrice: createItemDto.compareAtPrice,
        dietaryTags: createItemDto.dietaryTags || [],
        allergens: createItemDto.allergens || [],
        spiceLevel: createItemDto.spiceLevel,
        isAvailable: createItemDto.isAvailable ?? true,
        isPopular: createItemDto.isPopular ?? false,
        isChefSpecial: createItemDto.isChefSpecial ?? false,
        allowCustomization: createItemDto.allowCustomization ?? false,
        customizationOptions: createItemDto.customizationOptions,
        imageId: createItemDto.imageId,
        estimatedPrepTime: createItemDto.estimatedPrepTime,
        sortOrder: createItemDto.sortOrder ?? 0,
      },
      include: {
        menu: {
          select: { id: true, name: true },
        },
        category: true,
      },
    });

    return item;
  }

  async updateItem(itemId: string, userId: string, updateItemDto: UpdateMenuItemDto) {
    const item = await this.prisma.menuItem.findFirst({
      where: { id: itemId },
      include: {
        menu: {
          include: {
            listing: {
              include: {
                merchant: {
                  select: { userId: true },
                },
              },
            },
          },
        },
      },
    });

    if (!item) {
      throw new NotFoundException(`Menu item with ID ${itemId} not found`);
    }

    // Verify user owns the listing
    if (item.menu.listing.merchant?.userId !== userId) {
      throw new ForbiddenException('You do not have permission to update this menu item');
    }

    // Verify category exists if being updated
    if (updateItemDto.categoryId && updateItemDto.categoryId !== item.categoryId) {
      const category = await this.prisma.menuCategory.findFirst({
        where: { id: updateItemDto.categoryId },
      });

      if (!category) {
        throw new NotFoundException(`Menu category with ID ${updateItemDto.categoryId} not found`);
      }
    }

    const updated = await this.prisma.menuItem.update({
      where: { id: itemId },
      data: {
        ...(updateItemDto.categoryId !== undefined && { categoryId: updateItemDto.categoryId }),
        ...(updateItemDto.name !== undefined && { name: updateItemDto.name }),
        ...(updateItemDto.description !== undefined && { description: updateItemDto.description }),
        ...(updateItemDto.price !== undefined && { price: updateItemDto.price }),
        ...(updateItemDto.currency !== undefined && { currency: updateItemDto.currency }),
        ...(updateItemDto.compareAtPrice !== undefined && { compareAtPrice: updateItemDto.compareAtPrice }),
        ...(updateItemDto.dietaryTags !== undefined && { dietaryTags: updateItemDto.dietaryTags }),
        ...(updateItemDto.allergens !== undefined && { allergens: updateItemDto.allergens }),
        ...(updateItemDto.spiceLevel !== undefined && { spiceLevel: updateItemDto.spiceLevel }),
        ...(updateItemDto.isAvailable !== undefined && { isAvailable: updateItemDto.isAvailable }),
        ...(updateItemDto.isPopular !== undefined && { isPopular: updateItemDto.isPopular }),
        ...(updateItemDto.isChefSpecial !== undefined && { isChefSpecial: updateItemDto.isChefSpecial }),
        ...(updateItemDto.allowCustomization !== undefined && { allowCustomization: updateItemDto.allowCustomization }),
        ...(updateItemDto.customizationOptions !== undefined && { customizationOptions: updateItemDto.customizationOptions }),
        ...(updateItemDto.imageId !== undefined && { imageId: updateItemDto.imageId }),
        ...(updateItemDto.estimatedPrepTime !== undefined && { estimatedPrepTime: updateItemDto.estimatedPrepTime }),
        ...(updateItemDto.sortOrder !== undefined && { sortOrder: updateItemDto.sortOrder }),
      },
      include: {
        menu: {
          select: { id: true, name: true },
        },
        category: true,
      },
    });

    return updated;
  }

  async removeItem(itemId: string, userId: string) {
    const item = await this.prisma.menuItem.findFirst({
      where: { id: itemId },
      include: {
        menu: {
          include: {
            listing: {
              include: {
                merchant: {
                  select: { userId: true },
                },
              },
            },
          },
        },
      },
    });

    if (!item) {
      throw new NotFoundException(`Menu item with ID ${itemId} not found`);
    }

    // Verify user owns the listing
    if (item.menu.listing.merchant?.userId !== userId) {
      throw new ForbiddenException('You do not have permission to delete this menu item');
    }

    await this.prisma.menuItem.delete({
      where: { id: itemId },
    });

    return { message: 'Menu item deleted successfully' };
  }
}

