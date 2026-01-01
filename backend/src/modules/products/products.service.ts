import { Injectable, NotFoundException, BadRequestException, ForbiddenException } from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';
import { Prisma } from '@prisma/client';
import { CreateProductDto, UpdateProductDto, ProductQueryDto, CreateProductVariantDto, UpdateProductVariantDto } from './dto/product.dto';

@Injectable()
export class ProductsService {
  constructor(private prisma: PrismaService) {}

  async findAll(params: ProductQueryDto & { listingId?: string }) {
    const { page = 1, limit = 20, listingId, status, search, category, minPrice, maxPrice, isFeatured, sortBy = 'popular' } = params;
    const skip = (page - 1) * limit;

    const where: Prisma.ProductWhereInput = {
      deletedAt: null,
      ...(listingId && { listingId }),
      ...(status && { status: status as any }),
      ...(category && { category }),
      ...(minPrice && { basePrice: { gte: minPrice } }),
      ...(maxPrice && { basePrice: { lte: maxPrice } }),
      ...(isFeatured !== undefined && { isFeatured }),
      ...(search && {
        OR: [
          { name: { contains: search, mode: 'insensitive' } },
          { description: { contains: search, mode: 'insensitive' } },
          { shortDescription: { contains: search, mode: 'insensitive' } },
        ],
      }),
    };

    // Build orderBy based on sortBy parameter
    let orderBy: Prisma.ProductOrderByWithRelationInput[] | Prisma.ProductOrderByWithRelationInput;
    
    switch (sortBy) {
      case 'name_asc':
        orderBy = { name: 'asc' };
        break;
      case 'name_desc':
        orderBy = { name: 'desc' };
        break;
      case 'price_asc':
        orderBy = { basePrice: 'asc' };
        break;
      case 'price_desc':
        orderBy = { basePrice: 'desc' };
        break;
      case 'createdAt_desc':
        orderBy = { createdAt: 'desc' };
        break;
      case 'createdAt_asc':
        orderBy = { createdAt: 'asc' };
        break;
      case 'popular':
      default:
        // Default: featured first, then by order count, then by creation date
        orderBy = [{ isFeatured: 'desc' }, { orderCount: 'desc' }, { createdAt: 'desc' }];
        break;
    }

    const [products, total] = await Promise.all([
      this.prisma.product.findMany({
        where,
        skip,
        take: limit,
        include: {
          listing: { 
            select: { 
              id: true, 
              name: true, 
              slug: true,
              merchantId: true,
            } 
          },
          variants: {
            where: { isActive: true },
            orderBy: { createdAt: 'asc' },
          },
          _count: { 
            select: { 
              orderItems: true, 
              cartItems: true,
              variants: true,
            } 
          },
        },
        orderBy,
      }),
      this.prisma.product.count({ where }),
    ]);

    return {
      data: products,
      meta: {
        total,
        page,
        limit,
        totalPages: Math.ceil(total / limit),
      },
    };
  }

  async findOne(id: string) {
    const product = await this.prisma.product.findFirst({
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
        variants: {
          orderBy: { createdAt: 'asc' },
        },
        _count: { 
          select: { 
            orderItems: true, 
            cartItems: true,
            variants: true,
          } 
        },
      },
    });

    if (!product) {
      throw new NotFoundException(`Product with ID ${id} not found`);
    }

    return product;
  }

  async findByListing(listingId: string, params: ProductQueryDto) {
    return this.findAll({ ...params, listingId });
  }

  async create(userId: string, createProductDto: CreateProductDto) {
    // Verify listing exists and user owns it
    const listing = await this.prisma.listing.findFirst({
      where: { 
        id: createProductDto.listingId,
        deletedAt: null,
      },
      include: {
        merchant: {
          select: { userId: true },
        },
      },
    });

    if (!listing) {
      throw new NotFoundException(`Listing with ID ${createProductDto.listingId} not found`);
    }

    if (listing.merchant?.userId !== userId) {
      throw new ForbiddenException('You do not have permission to create products for this listing');
    }

    // Generate slug if not provided
    let slug = createProductDto.slug;
    if (!slug) {
      slug = createProductDto.name
        .toLowerCase()
        .replace(/[^a-z0-9]+/g, '-')
        .replace(/(^-|-$)/g, '');
      
      // Ensure uniqueness
      const existing = await this.prisma.product.findFirst({
        where: { slug },
      });
      
      if (existing) {
        slug = `${slug}-${Date.now()}`;
      }
    } else {
      // Check if slug is unique
      const existing = await this.prisma.product.findFirst({
        where: { slug },
      });
      
      if (existing) {
        throw new BadRequestException(`Product with slug "${slug}" already exists`);
      }
    }

    // Check SKU uniqueness if provided
    if (createProductDto.sku) {
      const existingSku = await this.prisma.product.findFirst({
        where: { sku: createProductDto.sku },
      });
      
      if (existingSku) {
        throw new BadRequestException(`Product with SKU "${createProductDto.sku}" already exists`);
      }
    }

    const product = await this.prisma.product.create({
      data: {
        listingId: createProductDto.listingId,
        name: createProductDto.name,
        slug,
        description: createProductDto.description,
        shortDescription: createProductDto.shortDescription,
        basePrice: createProductDto.basePrice,
        compareAtPrice: createProductDto.compareAtPrice,
        currency: createProductDto.currency || 'RWF',
        costPrice: createProductDto.costPrice,
        sku: createProductDto.sku,
        trackInventory: createProductDto.trackInventory ?? true,
        inventoryQuantity: createProductDto.inventoryQuantity ?? 0,
        lowStockThreshold: createProductDto.lowStockThreshold ?? 5,
        allowBackorders: createProductDto.allowBackorders ?? false,
        weight: createProductDto.weight,
        dimensions: createProductDto.dimensions,
        category: createProductDto.category,
        tags: createProductDto.tags || [],
        hasVariants: createProductDto.hasVariants ?? false,
        variantOptions: createProductDto.variantOptions,
        status: createProductDto.status || 'draft',
        isFeatured: createProductDto.isFeatured ?? false,
        images: createProductDto.images || [],
      },
      include: {
        listing: { 
          select: { 
            id: true, 
            name: true, 
            slug: true,
          } 
        },
        variants: true,
      },
    });

    return product;
  }

  async update(id: string, userId: string, updateProductDto: UpdateProductDto) {
    const product = await this.findOne(id);

    // Verify user owns the listing
    const listing = await this.prisma.listing.findFirst({
      where: { 
        id: product.listingId,
        deletedAt: null,
      },
      include: {
        merchant: {
          select: { userId: true },
        },
      },
    });

    if (!listing || listing.merchant?.userId !== userId) {
      throw new ForbiddenException('You do not have permission to update this product');
    }

    // Check slug uniqueness if being updated
    if (updateProductDto.slug && updateProductDto.slug !== product.slug) {
      const existing = await this.prisma.product.findFirst({
        where: { slug: updateProductDto.slug },
      });
      
      if (existing) {
        throw new BadRequestException(`Product with slug "${updateProductDto.slug}" already exists`);
      }
    }

    // Check SKU uniqueness if being updated
    if (updateProductDto.sku && updateProductDto.sku !== product.sku) {
      const existingSku = await this.prisma.product.findFirst({
        where: { sku: updateProductDto.sku },
      });
      
      if (existingSku) {
        throw new BadRequestException(`Product with SKU "${updateProductDto.sku}" already exists`);
      }
    }

    const updated = await this.prisma.product.update({
      where: { id },
      data: {
        ...(updateProductDto.name && { name: updateProductDto.name }),
        ...(updateProductDto.slug && { slug: updateProductDto.slug }),
        ...(updateProductDto.description !== undefined && { description: updateProductDto.description }),
        ...(updateProductDto.shortDescription !== undefined && { shortDescription: updateProductDto.shortDescription }),
        ...(updateProductDto.basePrice !== undefined && { basePrice: updateProductDto.basePrice }),
        ...(updateProductDto.compareAtPrice !== undefined && { compareAtPrice: updateProductDto.compareAtPrice }),
        ...(updateProductDto.currency !== undefined && { currency: updateProductDto.currency }),
        ...(updateProductDto.costPrice !== undefined && { costPrice: updateProductDto.costPrice }),
        ...(updateProductDto.sku !== undefined && { sku: updateProductDto.sku }),
        ...(updateProductDto.trackInventory !== undefined && { trackInventory: updateProductDto.trackInventory }),
        ...(updateProductDto.inventoryQuantity !== undefined && { inventoryQuantity: updateProductDto.inventoryQuantity }),
        ...(updateProductDto.lowStockThreshold !== undefined && { lowStockThreshold: updateProductDto.lowStockThreshold }),
        ...(updateProductDto.allowBackorders !== undefined && { allowBackorders: updateProductDto.allowBackorders }),
        ...(updateProductDto.weight !== undefined && { weight: updateProductDto.weight }),
        ...(updateProductDto.dimensions !== undefined && { dimensions: updateProductDto.dimensions }),
        ...(updateProductDto.category !== undefined && { category: updateProductDto.category }),
        ...(updateProductDto.tags !== undefined && { tags: updateProductDto.tags }),
        ...(updateProductDto.hasVariants !== undefined && { hasVariants: updateProductDto.hasVariants }),
        ...(updateProductDto.variantOptions !== undefined && { variantOptions: updateProductDto.variantOptions }),
        ...(updateProductDto.status !== undefined && { status: updateProductDto.status as any }),
        ...(updateProductDto.isFeatured !== undefined && { isFeatured: updateProductDto.isFeatured }),
        ...(updateProductDto.images !== undefined && { images: updateProductDto.images }),
      },
      include: {
        listing: { 
          select: { 
            id: true, 
            name: true, 
            slug: true,
          } 
        },
        variants: true,
      },
    });

    return updated;
  }

  async remove(id: string, userId: string) {
    const product = await this.findOne(id);

    // Verify user owns the listing
    const listing = await this.prisma.listing.findFirst({
      where: { 
        id: product.listingId,
        deletedAt: null,
      },
      include: {
        merchant: {
          select: { userId: true },
        },
      },
    });

    if (!listing || listing.merchant?.userId !== userId) {
      throw new ForbiddenException('You do not have permission to delete this product');
    }

    // Soft delete
    await this.prisma.product.update({
      where: { id },
      data: { deletedAt: new Date() },
    });

    return { message: 'Product deleted successfully' };
  }

  // Product Variants
  async createVariant(productId: string, userId: string, createVariantDto: CreateProductVariantDto) {
    const product = await this.findOne(productId);

    // Verify user owns the listing
    const listing = await this.prisma.listing.findFirst({
      where: { 
        id: product.listingId,
        deletedAt: null,
      },
      include: {
        merchant: {
          select: { userId: true },
        },
      },
    });

    if (!listing || listing.merchant?.userId !== userId) {
      throw new ForbiddenException('You do not have permission to create variants for this product');
    }

    // Check SKU uniqueness if provided
    if (createVariantDto.sku) {
      const existingSku = await this.prisma.productVariant.findFirst({
        where: { sku: createVariantDto.sku },
      });
      
      if (existingSku) {
        throw new BadRequestException(`Variant with SKU "${createVariantDto.sku}" already exists`);
      }
    }

    const variant = await this.prisma.productVariant.create({
      data: {
        productId,
        name: createVariantDto.name,
        sku: createVariantDto.sku,
        price: createVariantDto.price,
        compareAtPrice: createVariantDto.compareAtPrice,
        attributes: createVariantDto.attributes,
        inventoryQuantity: createVariantDto.inventoryQuantity ?? 0,
        trackInventory: createVariantDto.trackInventory ?? true,
        imageId: createVariantDto.imageId,
        isActive: createVariantDto.isActive ?? true,
      },
      include: {
        product: {
          select: { id: true, name: true, slug: true },
        },
      },
    });

    return variant;
  }

  async updateVariant(variantId: string, userId: string, updateVariantDto: UpdateProductVariantDto) {
    const variant = await this.prisma.productVariant.findFirst({
      where: { id: variantId },
      include: {
        product: {
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

    if (!variant) {
      throw new NotFoundException(`Variant with ID ${variantId} not found`);
    }

    // Verify user owns the listing
    if (variant.product.listing.merchant?.userId !== userId) {
      throw new ForbiddenException('You do not have permission to update this variant');
    }

    // Check SKU uniqueness if being updated
    if (updateVariantDto.sku && updateVariantDto.sku !== variant.sku) {
      const existingSku = await this.prisma.productVariant.findFirst({
        where: { sku: updateVariantDto.sku },
      });
      
      if (existingSku) {
        throw new BadRequestException(`Variant with SKU "${updateVariantDto.sku}" already exists`);
      }
    }

    const updated = await this.prisma.productVariant.update({
      where: { id: variantId },
      data: {
        ...(updateVariantDto.name !== undefined && { name: updateVariantDto.name }),
        ...(updateVariantDto.sku !== undefined && { sku: updateVariantDto.sku }),
        ...(updateVariantDto.price !== undefined && { price: updateVariantDto.price }),
        ...(updateVariantDto.compareAtPrice !== undefined && { compareAtPrice: updateVariantDto.compareAtPrice }),
        ...(updateVariantDto.attributes !== undefined && { attributes: updateVariantDto.attributes }),
        ...(updateVariantDto.inventoryQuantity !== undefined && { inventoryQuantity: updateVariantDto.inventoryQuantity }),
        ...(updateVariantDto.trackInventory !== undefined && { trackInventory: updateVariantDto.trackInventory }),
        ...(updateVariantDto.imageId !== undefined && { imageId: updateVariantDto.imageId }),
        ...(updateVariantDto.isActive !== undefined && { isActive: updateVariantDto.isActive }),
      },
      include: {
        product: {
          select: { id: true, name: true, slug: true },
        },
      },
    });

    return updated;
  }

  async removeVariant(variantId: string, userId: string) {
    const variant = await this.prisma.productVariant.findFirst({
      where: { id: variantId },
      include: {
        product: {
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

    if (!variant) {
      throw new NotFoundException(`Variant with ID ${variantId} not found`);
    }

    // Verify user owns the listing
    if (variant.product.listing.merchant?.userId !== userId) {
      throw new ForbiddenException('You do not have permission to delete this variant');
    }

    await this.prisma.productVariant.delete({
      where: { id: variantId },
    });

    return { message: 'Variant deleted successfully' };
  }
}

