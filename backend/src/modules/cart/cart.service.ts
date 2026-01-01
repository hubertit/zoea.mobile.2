import { Injectable, NotFoundException, BadRequestException } from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';
import { AddToCartDto, UpdateCartItemDto, CartItemType } from './dto/cart.dto';

@Injectable()
export class CartService {
  constructor(private prisma: PrismaService) {}

  async getCart(userId: string | null, sessionId: string | null) {
    if (userId) {
      let cart = await this.prisma.cart.findUnique({
        where: { userId },
        include: {
          items: {
            include: {
              product: {
                include: {
                  listing: { select: { id: true, name: true, slug: true } },
                  variants: { where: { isActive: true } },
                },
              },
              productVariant: true,
              service: {
                include: {
                  listing: { select: { id: true, name: true, slug: true } },
                },
              },
              menuItem: {
                include: {
                  menu: {
                    include: {
                      listing: { select: { id: true, name: true, slug: true } },
                    },
                  },
                  category: true,
                },
              },
            },
            orderBy: { createdAt: 'asc' },
          },
        },
      });

      if (!cart) {
        cart = await this.prisma.cart.create({
          data: { userId },
          include: {
            items: {
              include: {
                product: {
                  include: {
                    listing: { select: { id: true, name: true, slug: true } },
                    variants: { where: { isActive: true } },
                  },
                },
                productVariant: true,
                service: {
                  include: {
                    listing: { select: { id: true, name: true, slug: true } },
                  },
                },
                menuItem: {
                  include: {
                    menu: {
                      include: {
                        listing: { select: { id: true, name: true, slug: true } },
                      },
                    },
                    category: true,
                  },
                },
              },
              orderBy: { createdAt: 'asc' },
            },
          },
        });
      }

      return cart;
    } else if (sessionId) {
      let cart = await this.prisma.cart.findFirst({
        where: { sessionId },
        include: {
          items: {
            include: {
              product: {
                include: {
                  listing: { select: { id: true, name: true, slug: true } },
                  variants: { where: { isActive: true } },
                },
              },
              productVariant: true,
              service: {
                include: {
                  listing: { select: { id: true, name: true, slug: true } },
                },
              },
              menuItem: {
                include: {
                  menu: {
                    include: {
                      listing: { select: { id: true, name: true, slug: true } },
                    },
                  },
                  category: true,
                },
              },
            },
            orderBy: { createdAt: 'asc' },
          },
        },
      });

      if (!cart) {
        cart = await this.prisma.cart.create({
          data: { sessionId },
          include: {
            items: {
              include: {
                product: {
                  include: {
                    listing: { select: { id: true, name: true, slug: true } },
                    variants: { where: { isActive: true } },
                  },
                },
                productVariant: true,
                service: {
                  include: {
                    listing: { select: { id: true, name: true, slug: true } },
                  },
                },
                menuItem: {
                  include: {
                    menu: {
                      include: {
                        listing: { select: { id: true, name: true, slug: true } },
                      },
                    },
                    category: true,
                  },
                },
              },
              orderBy: { createdAt: 'asc' },
            },
          },
        });
      }

      return cart;
    } else {
      throw new BadRequestException('Either userId or sessionId is required');
    }
  }

  async addToCart(userId: string | null, sessionId: string | null, addToCartDto: AddToCartDto) {
    // Get or create cart
    const cart = await this.getCart(userId, sessionId);

    // Validate item exists and get price
    let unitPrice = 0;
    let itemName = '';
    let itemSku: string | null = null;
    let itemImageId: string | null = null;

    if (addToCartDto.itemType === CartItemType.PRODUCT) {
      if (!addToCartDto.productId) {
        throw new BadRequestException('productId is required for product items');
      }

      if (addToCartDto.productVariantId) {
        const variant = await this.prisma.productVariant.findFirst({
          where: { id: addToCartDto.productVariantId, productId: addToCartDto.productId },
          include: { product: true },
        });

        if (!variant) {
          throw new NotFoundException('Product variant not found');
        }

        if (!variant.isActive) {
          throw new BadRequestException('Product variant is not active');
        }

        // Check inventory
        if (variant.trackInventory && variant.inventoryQuantity < addToCartDto.quantity) {
          throw new BadRequestException(`Only ${variant.inventoryQuantity} items available`);
        }

        unitPrice = variant.price ? Number(variant.price) : Number(variant.product.basePrice);
        itemName = `${variant.product.name} - ${variant.name}`;
        itemSku = variant.sku;
        itemImageId = variant.imageId;
      } else {
        const product = await this.prisma.product.findFirst({
          where: { id: addToCartDto.productId, deletedAt: null, status: 'active' },
        });

        if (!product) {
          throw new NotFoundException('Product not found or not available');
        }

        // Check inventory
        if (product.trackInventory && product.inventoryQuantity < addToCartDto.quantity) {
          throw new BadRequestException(`Only ${product.inventoryQuantity} items available`);
        }

        unitPrice = Number(product.basePrice);
        itemName = product.name;
        itemSku = product.sku;
        itemImageId = product.images?.[0] || null;
      }
    } else if (addToCartDto.itemType === CartItemType.SERVICE) {
      if (!addToCartDto.serviceId) {
        throw new BadRequestException('serviceId is required for service items');
      }

      const service = await this.prisma.service.findFirst({
        where: { id: addToCartDto.serviceId, deletedAt: null, status: 'active', isAvailable: true },
      });

      if (!service) {
        throw new NotFoundException('Service not found or not available');
      }

      unitPrice = Number(service.basePrice);
      itemName = service.name;
      itemImageId = service.images?.[0] || null;
    } else if (addToCartDto.itemType === CartItemType.MENU_ITEM) {
      if (!addToCartDto.menuItemId) {
        throw new BadRequestException('menuItemId is required for menu items');
      }

      const menuItem = await this.prisma.menuItem.findFirst({
        where: { id: addToCartDto.menuItemId, isAvailable: true },
        include: { menu: { include: { listing: true } } },
      });

      if (!menuItem) {
        throw new NotFoundException('Menu item not found or not available');
      }

      unitPrice = Number(menuItem.price);
      itemName = menuItem.name;
      itemImageId = menuItem.imageId;
    } else {
      throw new BadRequestException('Invalid item type');
    }

    const totalPrice = unitPrice * addToCartDto.quantity;

    // Check if item already exists in cart (for products/menu items, not services)
    if (addToCartDto.itemType !== CartItemType.SERVICE) {
      const existingItem = await this.prisma.cartItem.findFirst({
        where: {
          cartId: cart.id,
          itemType: addToCartDto.itemType as any,
          productId: addToCartDto.productId || null,
          productVariantId: addToCartDto.productVariantId || null,
          menuItemId: addToCartDto.menuItemId || null,
        },
      });

      if (existingItem) {
        // Update quantity
        const newQuantity = existingItem.quantity + addToCartDto.quantity;
        const newTotalPrice = unitPrice * newQuantity;

        const updated = await this.prisma.cartItem.update({
          where: { id: existingItem.id },
          data: {
            quantity: newQuantity,
            totalPrice: newTotalPrice,
            ...(addToCartDto.customization && { customization: addToCartDto.customization }),
          },
          include: {
            product: {
              include: {
                listing: { select: { id: true, name: true, slug: true } },
                variants: { where: { isActive: true } },
              },
            },
            productVariant: true,
            service: {
              include: {
                listing: { select: { id: true, name: true, slug: true } },
              },
            },
            menuItem: {
              include: {
                menu: {
                  include: {
                    listing: { select: { id: true, name: true, slug: true } },
                  },
                },
                category: true,
              },
            },
          },
        });

        return updated;
      }
    }

    // Create new cart item
    const cartItem = await this.prisma.cartItem.create({
      data: {
        cartId: cart.id,
        itemType: addToCartDto.itemType as any,
        productId: addToCartDto.productId,
        productVariantId: addToCartDto.productVariantId,
        serviceId: addToCartDto.serviceId,
        menuItemId: addToCartDto.menuItemId,
        quantity: addToCartDto.quantity,
        unitPrice,
        totalPrice,
        currency: 'RWF',
        customization: addToCartDto.customization,
        serviceBookingDate: addToCartDto.serviceBookingDate ? new Date(addToCartDto.serviceBookingDate) : null,
        serviceBookingTime: addToCartDto.serviceBookingTime,
      },
      include: {
        product: {
          include: {
            listing: { select: { id: true, name: true, slug: true } },
            variants: { where: { isActive: true } },
          },
        },
        productVariant: true,
        service: {
          include: {
            listing: { select: { id: true, name: true, slug: true } },
          },
        },
        menuItem: {
          include: {
            menu: {
              include: {
                listing: { select: { id: true, name: true, slug: true } },
              },
            },
            category: true,
          },
        },
      },
    });

    return cartItem;
  }

  async updateCartItem(cartItemId: string, userId: string | null, sessionId: string | null, updateDto: UpdateCartItemDto) {
    const cartItem = await this.prisma.cartItem.findFirst({
      where: { id: cartItemId },
      include: { cart: true },
    });

    if (!cartItem) {
      throw new NotFoundException('Cart item not found');
    }

    // Verify cart ownership
    if (userId && cartItem.cart.userId !== userId) {
      throw new BadRequestException('Cart item does not belong to your cart');
    }
    if (sessionId && cartItem.cart.sessionId !== sessionId) {
      throw new BadRequestException('Cart item does not belong to your cart');
    }

    const newTotalPrice = Number(cartItem.unitPrice) * updateDto.quantity;

    const updated = await this.prisma.cartItem.update({
      where: { id: cartItemId },
      data: {
        quantity: updateDto.quantity,
        totalPrice: newTotalPrice,
        ...(updateDto.customization !== undefined && { customization: updateDto.customization }),
        ...(updateDto.serviceBookingDate !== undefined && { 
          serviceBookingDate: updateDto.serviceBookingDate ? new Date(updateDto.serviceBookingDate) : null 
        }),
        ...(updateDto.serviceBookingTime !== undefined && { serviceBookingTime: updateDto.serviceBookingTime }),
      },
      include: {
        product: {
          include: {
            listing: { select: { id: true, name: true, slug: true } },
            variants: { where: { isActive: true } },
          },
        },
        productVariant: true,
        service: {
          include: {
            listing: { select: { id: true, name: true, slug: true } },
          },
        },
        menuItem: {
          include: {
            menu: {
              include: {
                listing: { select: { id: true, name: true, slug: true } },
              },
            },
            category: true,
          },
        },
      },
    });

    return updated;
  }

  async removeCartItem(cartItemId: string, userId: string | null, sessionId: string | null) {
    const cartItem = await this.prisma.cartItem.findFirst({
      where: { id: cartItemId },
      include: { cart: true },
    });

    if (!cartItem) {
      throw new NotFoundException('Cart item not found');
    }

    // Verify cart ownership
    if (userId && cartItem.cart.userId !== userId) {
      throw new BadRequestException('Cart item does not belong to your cart');
    }
    if (sessionId && cartItem.cart.sessionId !== sessionId) {
      throw new BadRequestException('Cart item does not belong to your cart');
    }

    await this.prisma.cartItem.delete({
      where: { id: cartItemId },
    });

    return { message: 'Cart item removed successfully' };
  }

  async clearCart(userId: string | null, sessionId: string | null) {
    const cart = await this.getCart(userId, sessionId);

    await this.prisma.cartItem.deleteMany({
      where: { cartId: cart.id },
    });

    return { message: 'Cart cleared successfully' };
  }
}

