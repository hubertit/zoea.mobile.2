import { Controller, Get, Post, Put, Delete, Param, Body, Query, UseGuards, Request, HttpCode, HttpStatus, Headers } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth, ApiQuery, ApiParam, ApiResponse, ApiHeader, ApiBody } from '@nestjs/swagger';
import { OrdersService } from './orders.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { OptionalJwtAuthGuard } from '../auth/guards/optional-jwt-auth.guard';
import { CreateOrderDto, UpdateOrderStatusDto, CancelOrderDto, OrderQueryDto, OrderStatus, FulfillmentType } from './dto/order.dto';

@ApiTags('Orders')
@Controller('orders')
export class OrdersController {
  constructor(private ordersService: OrdersService) {}

  @Get()
  @UseGuards(OptionalJwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ 
    summary: 'Get all orders',
    description: 'Retrieve paginated orders with optional filters. For authenticated users, returns their own orders. For merchants, can filter by listingId to see orders for their listings. Supports filtering by status, fulfillment type, and order number search.'
  })
  @ApiQuery({ name: 'page', required: false, type: Number, example: 1, description: 'Page number (default: 1)' })
  @ApiQuery({ name: 'limit', required: false, type: Number, example: 20, description: 'Items per page (default: 20)' })
  @ApiQuery({ name: 'listingId', required: false, type: String, description: 'Filter by listing UUID' })
  @ApiQuery({ name: 'status', required: false, enum: OrderStatus, description: 'Filter by order status', example: 'pending' })
  @ApiQuery({ name: 'fulfillmentType', required: false, enum: FulfillmentType, description: 'Filter by fulfillment type', example: 'delivery' })
  @ApiQuery({ name: 'orderNumber', required: false, type: String, description: 'Search by order number', example: 'ORD-2025-001234' })
  @ApiResponse({ 
    status: 200, 
    description: 'Orders retrieved successfully',
    schema: {
      type: 'object',
      properties: {
        data: { type: 'array', items: { type: 'object' } },
        meta: {
          type: 'object',
          properties: {
            total: { type: 'number', example: 45 },
            page: { type: 'number', example: 1 },
            limit: { type: 'number', example: 20 },
            totalPages: { type: 'number', example: 3 }
          }
        }
      }
    }
  })
  async findAll(@Request() req, @Query() query: OrderQueryDto) {
    const userId = req.user?.userId || null;
    return this.ordersService.findAll(userId, query);
  }

  @Get('merchant/:merchantId')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ 
    summary: 'Get orders for a merchant',
    description: 'Retrieve all orders for a specific merchant across all their listings. Requires authentication. Useful for merchant dashboard to view all orders.'
  })
  @ApiParam({ name: 'merchantId', type: String, description: 'Merchant UUID', example: '123e4567-e89b-12d3-a456-426614174000' })
  @ApiQuery({ name: 'page', required: false, type: Number, example: 1 })
  @ApiQuery({ name: 'limit', required: false, type: Number, example: 20 })
  @ApiQuery({ name: 'status', required: false, enum: OrderStatus })
  @ApiQuery({ name: 'fulfillmentType', required: false, enum: FulfillmentType })
  @ApiResponse({ 
    status: 200, 
    description: 'Merchant orders retrieved successfully',
    schema: { type: 'object' }
  })
  @ApiResponse({ status: 401, description: 'Unauthorized - Invalid or missing token' })
  @ApiResponse({ status: 404, description: 'Merchant not found' })
  async getMerchantOrders(
    @Param('merchantId') merchantId: string,
    @Query() query: OrderQueryDto,
  ) {
    return this.ordersService.getMerchantOrders(merchantId, query);
  }

  @Get(':id')
  @UseGuards(OptionalJwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ 
    summary: 'Get order by ID',
    description: 'Retrieve detailed information about a specific order including all items, pricing breakdown, fulfillment details, and status. Accessible by the customer (order owner) or the merchant (listing owner).'
  })
  @ApiParam({ name: 'id', type: String, description: 'Order UUID', example: '123e4567-e89b-12d3-a456-426614174000' })
  @ApiResponse({ 
    status: 200, 
    description: 'Order retrieved successfully',
    schema: {
      type: 'object',
      properties: {
        id: { type: 'string' },
        orderNumber: { type: 'string', example: 'ORD-2025-001234' },
        status: { type: 'string', enum: ['pending', 'confirmed', 'processing', 'ready_for_pickup', 'shipped', 'out_for_delivery', 'delivered', 'cancelled', 'refunded'] },
        totalAmount: { type: 'number', example: 150000 },
        items: { type: 'array', items: { type: 'object' } }
      }
    }
  })
  @ApiResponse({ status: 403, description: 'Forbidden - Not authorized to view this order' })
  @ApiResponse({ status: 404, description: 'Order not found' })
  async findOne(@Param('id') id: string, @Request() req) {
    const userId = req.user?.userId || null;
    return this.ordersService.findOne(id, userId);
  }

  @Post()
  @UseGuards(OptionalJwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ 
    summary: 'Create order from cart',
    description: 'Create an order from the current cart. Works with both authenticated and guest users. Validates cart contents, calculates totals (subtotal, tax, shipping, discount), creates order items, automatically creates service bookings for service items, generates order number, and clears the cart after successful order creation. Requires fulfillment details (delivery address for delivery, pickup location for pickup).'
  })
  @ApiHeader({ name: 'X-Session-Id', required: false, description: 'Session ID for guest users (UUID format)' })
  @ApiBody({ type: CreateOrderDto })
  @ApiResponse({ 
    status: 201, 
    description: 'Order created successfully',
    schema: {
      type: 'object',
      properties: {
        id: { type: 'string' },
        orderNumber: { type: 'string', example: 'ORD-2025-001234' },
        status: { type: 'string', enum: ['pending'], example: 'pending' },
        totalAmount: { type: 'number', example: 150000 },
        fulfillmentType: { type: 'string', enum: ['delivery', 'pickup', 'dine_in'] },
        items: { type: 'array', items: { type: 'object' } }
      }
    }
  })
  @ApiResponse({ status: 400, description: 'Bad request - Empty cart, invalid fulfillment type, missing delivery address (for delivery), missing pickup location (for pickup), or cart contains items from different listings' })
  @ApiResponse({ status: 404, description: 'Listing not found' })
  async create(
    @Request() req,
    @Headers('x-session-id') sessionId: string | undefined,
    @Body() createOrderDto: CreateOrderDto,
  ) {
    const userId = req.user?.userId || null;
    return this.ordersService.create(userId, sessionId || null, createOrderDto);
  }

  @Put(':id/status')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ 
    summary: 'Update order status (merchant only)',
    description: 'Update order and fulfillment status. Only the merchant who owns the listing can update order status. Automatically sets timestamps (confirmedAt, shippedAt, deliveredAt) based on status changes. Supports updating both order status and fulfillment status.'
  })
  @ApiParam({ name: 'id', type: String, description: 'Order UUID', example: '123e4567-e89b-12d3-a456-426614174000' })
  @ApiBody({ type: UpdateOrderStatusDto })
  @ApiResponse({ 
    status: 200, 
    description: 'Order status updated successfully',
    schema: { type: 'object' }
  })
  @ApiResponse({ status: 401, description: 'Unauthorized - Invalid or missing token' })
  @ApiResponse({ status: 403, description: 'Forbidden - Not the merchant' })
  @ApiResponse({ status: 404, description: 'Order not found' })
  async updateStatus(
    @Param('id') id: string,
    @Request() req,
    @Body() updateDto: UpdateOrderStatusDto,
  ) {
    return this.ordersService.updateStatus(id, req.user.userId, updateDto);
  }

  @Put(':id/cancel')
  @UseGuards(OptionalJwtAuthGuard)
  @ApiBearerAuth()
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ 
    summary: 'Cancel an order',
    description: 'Cancel an order. Can be done by either the customer (order owner) or the merchant (listing owner). Requires a cancellation reason. Orders that are already delivered, cancelled, or refunded cannot be cancelled. Sets cancelledAt timestamp and stores cancellation reason.'
  })
  @ApiParam({ name: 'id', type: String, description: 'Order UUID', example: '123e4567-e89b-12d3-a456-426614174000' })
  @ApiBody({ type: CancelOrderDto })
  @ApiResponse({ 
    status: 200, 
    description: 'Order cancelled successfully',
    schema: {
      type: 'object',
      properties: {
        id: { type: 'string' },
        status: { type: 'string', enum: ['cancelled'], example: 'cancelled' },
        cancelledAt: { type: 'string', format: 'date-time' },
        cancellationReason: { type: 'string', example: 'Changed my mind' }
      }
    }
  })
  @ApiResponse({ status: 400, description: 'Bad request - Order cannot be cancelled (already delivered, cancelled, or refunded)' })
  @ApiResponse({ status: 401, description: 'Unauthorized - Invalid or missing token' })
  @ApiResponse({ status: 403, description: 'Forbidden - Not authorized to cancel this order' })
  @ApiResponse({ status: 404, description: 'Order not found' })
  async cancel(
    @Param('id') id: string,
    @Request() req,
    @Body() cancelDto: CancelOrderDto,
  ) {
    const userId = req.user?.userId || null;
    return this.ordersService.cancel(id, userId, cancelDto);
  }
}

