import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { IsString, IsOptional, IsNumber, IsUUID, IsBoolean, IsArray, IsEnum, IsObject, Min } from 'class-validator';
import { Transform } from 'class-transformer';

export enum OrderType {
  PRODUCT = 'product',
  SERVICE = 'service',
  MENU_ITEM = 'menu_item',
  MIXED = 'mixed',
}

export enum FulfillmentType {
  DELIVERY = 'delivery',
  PICKUP = 'pickup',
  DINE_IN = 'dine_in',
}

export enum OrderStatus {
  PENDING = 'pending',
  CONFIRMED = 'confirmed',
  PROCESSING = 'processing',
  READY_FOR_PICKUP = 'ready_for_pickup',
  SHIPPED = 'shipped',
  OUT_FOR_DELIVERY = 'out_for_delivery',
  DELIVERED = 'delivered',
  CANCELLED = 'cancelled',
  REFUNDED = 'refunded',
}

export enum FulfillmentStatus {
  PENDING = 'pending',
  PREPARING = 'preparing',
  READY = 'ready',
  IN_TRANSIT = 'in_transit',
  COMPLETED = 'completed',
  CANCELLED = 'cancelled',
}

export class CreateOrderDto {
  @ApiProperty({ description: 'Listing ID (shop) for this order' })
  @IsUUID()
  listingId: string;

  @ApiProperty({ enum: FulfillmentType, description: 'How the order will be fulfilled' })
  @IsEnum(FulfillmentType)
  fulfillmentType: FulfillmentType;

  @ApiPropertyOptional({ 
    example: { street: '123 Main St', city: 'Kigali', country: 'Rwanda' },
    description: 'Delivery address (required if fulfillmentType is delivery)'
  })
  @IsObject()
  @IsOptional()
  deliveryAddress?: any;

  @ApiPropertyOptional({ example: 'Store Location A', description: 'Pickup location (required if fulfillmentType is pickup)' })
  @IsString()
  @IsOptional()
  pickupLocation?: string;

  @ApiPropertyOptional({ example: '2025-01-15', description: 'Delivery date (for delivery orders)' })
  @IsString()
  @IsOptional()
  deliveryDate?: string;

  @ApiPropertyOptional({ example: '14:00-16:00', description: 'Delivery time slot' })
  @IsString()
  @IsOptional()
  deliveryTimeSlot?: string;

  @ApiProperty({ example: 'John Doe' })
  @IsString()
  customerName: string;

  @ApiPropertyOptional({ example: 'john@example.com' })
  @IsString()
  @IsOptional()
  customerEmail?: string;

  @ApiProperty({ example: '+250788000000' })
  @IsString()
  customerPhone: string;

  @ApiPropertyOptional({ example: 'Please leave at door' })
  @IsString()
  @IsOptional()
  customerNotes?: string;

  @ApiPropertyOptional({ example: 0, description: 'Tax amount' })
  @IsNumber()
  @IsOptional()
  @Min(0)
  taxAmount?: number;

  @ApiPropertyOptional({ example: 0, description: 'Shipping amount' })
  @IsNumber()
  @IsOptional()
  @Min(0)
  shippingAmount?: number;

  @ApiPropertyOptional({ example: 0, description: 'Discount amount' })
  @IsNumber()
  @IsOptional()
  @Min(0)
  discountAmount?: number;
}

export class UpdateOrderStatusDto {
  @ApiProperty({ enum: OrderStatus })
  @IsEnum(OrderStatus)
  status: OrderStatus;

  @ApiPropertyOptional({ enum: FulfillmentStatus })
  @IsEnum(FulfillmentStatus)
  @IsOptional()
  fulfillmentStatus?: FulfillmentStatus;

  @ApiPropertyOptional({ example: 'Order is being prepared' })
  @IsString()
  @IsOptional()
  internalNotes?: string;
}

export class CancelOrderDto {
  @ApiProperty({ example: 'Changed my mind' })
  @IsString()
  cancellationReason: string;
}

export class OrderQueryDto {
  @ApiPropertyOptional({ example: 1, default: 1 })
  @Transform(({ value }) => parseInt(value))
  @IsNumber()
  @IsOptional()
  page?: number;

  @ApiPropertyOptional({ example: 20, default: 20 })
  @Transform(({ value }) => parseInt(value))
  @IsNumber()
  @IsOptional()
  limit?: number;

  @ApiPropertyOptional({ description: 'Filter by listing ID' })
  @IsUUID()
  @IsOptional()
  listingId?: string;

  @ApiPropertyOptional({ enum: OrderStatus, description: 'Filter by status' })
  @IsEnum(OrderStatus)
  @IsOptional()
  status?: OrderStatus;

  @ApiPropertyOptional({ enum: FulfillmentType, description: 'Filter by fulfillment type' })
  @IsEnum(FulfillmentType)
  @IsOptional()
  fulfillmentType?: FulfillmentType;

  @ApiPropertyOptional({ example: 'ORD-2025-001234', description: 'Search by order number' })
  @IsString()
  @IsOptional()
  orderNumber?: string;
}

