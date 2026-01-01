import { Injectable, NotFoundException, BadRequestException, ForbiddenException } from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';
import { Prisma } from '@prisma/client';
import { CreateOrderDto, UpdateOrderStatusDto, CancelOrderDto, OrderQueryDto, OrderType, FulfillmentType } from './dto/order.dto';

@Injectable()
export class OrdersService {
  constructor(private prisma: PrismaService) {}

  async findAll(userId: string | null, params: OrderQueryDto) {
    const { page = 1, limit = 20, listingId, status, fulfillmentType, orderNumber } = params;
    const skip = (page - 1) * limit;

    const where: Prisma.OrderWhereInput = {
      ...(userId && { userId }),
      ...(listingId && { listingId }),
      ...(status && { status: status as any }),
      ...(fulfillmentType && { fulfillmentType: fulfillmentType as any }),
      ...(orderNumber && { orderNumber: { contains: orderNumber, mode: 'insensitive' } }),
    };

    const [orders, total] = await Promise.all([
      this.prisma.order.findMany({
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
          merchant: {
            select: { id: true, businessName: true },
          },
          items: {
            include: {
              product: {
                select: { id: true, name: true, slug: true },
              },
              productVariant: {
                select: { id: true, name: true },
              },
              service: {
                select: { id: true, name: true, slug: true },
              },
              menuItem: {
                select: { id: true, name: true },
              },
            },
          },
          _count: { select: { items: true } },
        },
        orderBy: { createdAt: 'desc' },
      }),
      this.prisma.order.count({ where }),
    ]);

    return {
      data: orders,
      meta: {
        total,
        page,
        limit,
        totalPages: Math.ceil(total / limit),
      },
    };
  }

  async findOne(id: string, userId: string | null) {
    const order = await this.prisma.order.findFirst({
      where: { id },
      include: {
        listing: { 
          select: { 
            id: true, 
            name: true, 
            slug: true,
            merchantId: true,
          } 
        },
        merchant: {
          select: { id: true, businessName: true },
        },
        items: {
          include: {
            product: {
              select: { id: true, name: true, slug: true },
            },
            productVariant: {
              select: { id: true, name: true },
            },
            service: {
              select: { id: true, name: true, slug: true },
            },
            menuItem: {
              select: { id: true, name: true },
            },
            serviceBooking: true,
          },
        },
      },
    });

    if (!order) {
      throw new NotFoundException(`Order with ID ${id} not found`);
    }

    // Verify user owns the order or is the merchant
    if (userId) {
      const listing = await this.prisma.listing.findFirst({
        where: { id: order.listingId },
        include: {
          merchant: {
            select: { userId: true },
          },
        },
      });

      const isOwner = order.userId === userId;
      const isMerchant = listing?.merchant?.userId === userId;

      if (!isOwner && !isMerchant) {
        throw new ForbiddenException('You do not have permission to view this order');
      }
    }

    return order;
  }

  async create(userId: string | null, sessionId: string | null, createOrderDto: CreateOrderDto) {
    // Get cart
    const cart = await this.prisma.cart.findFirst({
      where: {
        ...(userId ? { userId } : { sessionId }),
      },
      include: {
        items: {
          include: {
            product: true,
            productVariant: true,
            service: true,
            menuItem: true,
          },
        },
      },
    });

    if (!cart || cart.items.length === 0) {
      throw new BadRequestException('Cart is empty');
    }

    // Verify listing exists
    const listing = await this.prisma.listing.findFirst({
      where: { 
        id: createOrderDto.listingId,
        deletedAt: null,
      },
      include: {
        merchant: true,
      },
    });

    if (!listing) {
      throw new NotFoundException(`Listing with ID ${createOrderDto.listingId} not found`);
    }

    // Verify all cart items belong to this listing
    const itemsFromOtherListings = cart.items.filter(item => {
      if (item.productId) {
        return item.product.listingId !== createOrderDto.listingId;
      }
      if (item.serviceId) {
        return item.service.listingId !== createOrderDto.listingId;
      }
      if (item.menuItemId) {
        // Need to check menu's listing
        return false; // Will check below
      }
      return false;
    });

    // Check menu items
    for (const item of cart.items.filter(i => i.menuItemId)) {
      const menuItem = await this.prisma.menuItem.findFirst({
        where: { id: item.menuItemId },
        include: {
          menu: {
            include: {
              listing: true,
            },
          },
        },
      });

      if (menuItem?.menu.listingId !== createOrderDto.listingId) {
        throw new BadRequestException('Cart contains items from different listings');
      }
    }

    // Calculate totals
    const subtotal = cart.items.reduce((sum, item) => sum + Number(item.totalPrice), 0);
    const taxAmount = createOrderDto.taxAmount || 0;
    const shippingAmount = createOrderDto.shippingAmount || 0;
    const discountAmount = createOrderDto.discountAmount || 0;
    const totalAmount = subtotal + taxAmount + shippingAmount - discountAmount;

    // Determine order type
    const itemTypes = new Set(cart.items.map(item => item.itemType));
    let orderType: OrderType;
    if (itemTypes.size === 1) {
      orderType = itemTypes.values().next().value as OrderType;
    } else {
      orderType = OrderType.MIXED;
    }

    // Generate order number
    const orderNumber = `ORD-${new Date().getFullYear()}-${Date.now().toString().slice(-6)}`;

    // Validate fulfillment type requirements
    if (createOrderDto.fulfillmentType === FulfillmentType.DELIVERY && !createOrderDto.deliveryAddress) {
      throw new BadRequestException('Delivery address is required for delivery orders');
    }
    if (createOrderDto.fulfillmentType === FulfillmentType.PICKUP && !createOrderDto.pickupLocation) {
      throw new BadRequestException('Pickup location is required for pickup orders');
    }

    // Create order
    const order = await this.prisma.order.create({
      data: {
        orderNumber,
        userId: userId || null,
        listingId: createOrderDto.listingId,
        merchantId: listing.merchantId,
        orderType: orderType as any,
        subtotal,
        taxAmount,
        shippingAmount,
        discountAmount,
        totalAmount,
        currency: 'RWF',
        fulfillmentType: createOrderDto.fulfillmentType as any,
        deliveryAddress: createOrderDto.deliveryAddress,
        pickupLocation: createOrderDto.pickupLocation,
        deliveryDate: createOrderDto.deliveryDate ? new Date(createOrderDto.deliveryDate) : null,
        deliveryTimeSlot: createOrderDto.deliveryTimeSlot,
        customerName: createOrderDto.customerName,
        customerEmail: createOrderDto.customerEmail,
        customerPhone: createOrderDto.customerPhone,
        customerNotes: createOrderDto.customerNotes,
        status: 'pending',
        fulfillmentStatus: 'pending',
        paymentStatus: 'pending',
      },
    });

    // Create order items and service bookings
    const orderItems = [];
    for (const cartItem of cart.items) {
      // Get item details for snapshot
      let itemName = '';
      let itemSku: string | null = null;
      let itemImageId: string | null = null;

      if (cartItem.productId) {
        const product = cartItem.productVariantId 
          ? await this.prisma.productVariant.findFirst({
              where: { id: cartItem.productVariantId },
              include: { product: true },
            })
          : null;
        
        itemName = product ? `${product.product.name} - ${product.name}` : cartItem.product.name;
        itemSku = product?.sku || cartItem.product.sku;
        itemImageId = product?.imageId || cartItem.product.images?.[0] || null;
      } else if (cartItem.serviceId) {
        itemName = cartItem.service.name;
        itemImageId = cartItem.service.images?.[0] || null;
      } else if (cartItem.menuItemId) {
        itemName = cartItem.menuItem.name;
        itemImageId = cartItem.menuItem.imageId;
      }

      const orderItem = await this.prisma.orderItem.create({
        data: {
          orderId: order.id,
          itemType: cartItem.itemType as any,
          productId: cartItem.productId,
          productVariantId: cartItem.productVariantId,
          serviceId: cartItem.serviceId,
          menuItemId: cartItem.menuItemId,
          itemName,
          itemSku,
          itemImageId,
          quantity: cartItem.quantity,
          unitPrice: cartItem.unitPrice,
          totalPrice: cartItem.totalPrice,
          currency: cartItem.currency,
          customization: cartItem.customization,
          serviceBookingDate: cartItem.serviceBookingDate,
          serviceBookingTime: cartItem.serviceBookingTime,
        },
      });

      // Create service booking if it's a service
      if (cartItem.serviceId && cartItem.serviceBookingDate && cartItem.serviceBookingTime) {
        const serviceBooking = await this.prisma.serviceBooking.create({
          data: {
            userId: userId || null,
            serviceId: cartItem.serviceId,
            listingId: createOrderDto.listingId,
            orderId: order.id,
            orderItemId: orderItem.id,
            bookingDate: cartItem.serviceBookingDate,
            bookingTime: cartItem.serviceBookingTime,
            customerName: createOrderDto.customerName,
            customerEmail: createOrderDto.customerEmail,
            customerPhone: createOrderDto.customerPhone,
            status: 'pending',
          },
        });
      }

      orderItems.push(orderItem);
    }

    // Clear cart
    await this.prisma.cartItem.deleteMany({
      where: { cartId: cart.id },
    });

    // Return order with items
    return this.findOne(order.id, userId);
  }

  async updateStatus(id: string, userId: string, updateDto: UpdateOrderStatusDto) {
    const order = await this.findOne(id, userId);

    // Verify user is the merchant
    const listing = await this.prisma.listing.findFirst({
      where: { id: order.listingId },
      include: {
        merchant: {
          select: { userId: true },
        },
      },
    });

    if (!listing || listing.merchant?.userId !== userId) {
      throw new ForbiddenException('You do not have permission to update this order');
    }

    const updateData: any = {
      status: updateDto.status as any,
      ...(updateDto.fulfillmentStatus !== undefined && { fulfillmentStatus: updateDto.fulfillmentStatus as any }),
      ...(updateDto.internalNotes !== undefined && { internalNotes: updateDto.internalNotes }),
    };

    // Set timestamps based on status
    if (updateDto.status === 'confirmed' && !order.confirmedAt) {
      updateData.confirmedAt = new Date();
    }
    if (updateDto.fulfillmentStatus === 'ready' && !order.shippedAt && order.fulfillmentType === 'pickup') {
      updateData.shippedAt = new Date();
    }
    if (updateDto.fulfillmentStatus === 'in_transit' && !order.shippedAt && order.fulfillmentType === 'delivery') {
      updateData.shippedAt = new Date();
    }
    if (updateDto.status === 'delivered' && !order.deliveredAt) {
      updateData.deliveredAt = new Date();
    }

    const updated = await this.prisma.order.update({
      where: { id },
      data: updateData,
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

  async cancel(id: string, userId: string | null, cancelDto: CancelOrderDto) {
    const order = await this.findOne(id, userId);

    // Verify user owns the order or is the merchant
    const listing = await this.prisma.listing.findFirst({
      where: { id: order.listingId },
      include: {
        merchant: {
          select: { userId: true },
        },
      },
    });

    const isOwner = order.userId === userId;
    const isMerchant = listing?.merchant?.userId === userId;

    if (!isOwner && !isMerchant) {
      throw new ForbiddenException('You do not have permission to cancel this order');
    }

    // Check if order can be cancelled
    if (['delivered', 'cancelled', 'refunded'].includes(order.status)) {
      throw new BadRequestException(`Order cannot be cancelled. Current status: ${order.status}`);
    }

    const updated = await this.prisma.order.update({
      where: { id },
      data: {
        status: 'cancelled',
        cancelledAt: new Date(),
        cancelledBy: userId || null,
        cancellationReason: cancelDto.cancellationReason,
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

  async getMerchantOrders(merchantId: string, params: OrderQueryDto) {
    const merchant = await this.prisma.merchantProfile.findFirst({
      where: { id: merchantId },
    });

    if (!merchant) {
      throw new NotFoundException(`Merchant with ID ${merchantId} not found`);
    }

    return this.findAll(null, { ...params, listingId: undefined });
  }
}

