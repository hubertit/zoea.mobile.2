import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { IsString, IsOptional, IsNumber, IsUUID, IsBoolean, IsArray, IsEnum, IsObject, Min, Max } from 'class-validator';
import { Transform } from 'class-transformer';

export enum ServicePriceUnit {
  FIXED = 'fixed',
  PER_HOUR = 'per_hour',
  PER_SESSION = 'per_session',
  PER_PERSON = 'per_person',
}

export enum ServiceStatus {
  ACTIVE = 'active',
  INACTIVE = 'inactive',
  UNAVAILABLE = 'unavailable',
}

export enum ServiceBookingStatus {
  PENDING = 'pending',
  CONFIRMED = 'confirmed',
  COMPLETED = 'completed',
  CANCELLED = 'cancelled',
  NO_SHOW = 'no_show',
}

export class CreateServiceDto {
  @ApiProperty({ description: 'Listing ID that owns this service' })
  @IsUUID()
  listingId: string;

  @ApiProperty({ example: 'Haircut & Styling' })
  @IsString()
  name: string;

  @ApiPropertyOptional({ example: 'haircut-styling' })
  @IsString()
  @IsOptional()
  slug?: string;

  @ApiPropertyOptional({ example: 'Professional haircut and styling service' })
  @IsString()
  @IsOptional()
  description?: string;

  @ApiPropertyOptional({ example: 'Professional haircut', maxLength: 500 })
  @IsString()
  @IsOptional()
  shortDescription?: string;

  @ApiProperty({ example: 15000, description: 'Base price in smallest currency unit' })
  @IsNumber()
  @Min(0)
  basePrice: number;

  @ApiPropertyOptional({ example: 'RWF', default: 'RWF' })
  @IsString()
  @IsOptional()
  currency?: string;

  @ApiPropertyOptional({ example: 'fixed', enum: ServicePriceUnit, default: 'fixed' })
  @IsEnum(ServicePriceUnit)
  @IsOptional()
  priceUnit?: ServicePriceUnit;

  @ApiPropertyOptional({ example: 60, description: 'Duration in minutes' })
  @IsNumber()
  @IsOptional()
  @Min(1)
  durationMinutes?: number;

  @ApiPropertyOptional({ example: true, default: true })
  @IsBoolean()
  @IsOptional()
  requiresBooking?: boolean;

  @ApiPropertyOptional({ example: 7, default: 7, description: 'Days in advance booking allowed' })
  @IsNumber()
  @IsOptional()
  @Min(0)
  advanceBookingDays?: number;

  @ApiPropertyOptional({ example: 1, default: 1, description: 'Max concurrent bookings at same time' })
  @IsNumber()
  @IsOptional()
  @Min(1)
  maxConcurrentBookings?: number;

  @ApiPropertyOptional({ 
    example: { 
      monday: { start: '09:00', end: '18:00' },
      tuesday: { start: '09:00', end: '18:00' }
    }, 
    description: 'Weekly availability schedule' 
  })
  @IsObject()
  @IsOptional()
  availabilitySchedule?: any;

  @ApiPropertyOptional({ example: true, default: true })
  @IsBoolean()
  @IsOptional()
  isAvailable?: boolean;

  @ApiPropertyOptional({ example: 'beauty', description: 'Service category' })
  @IsString()
  @IsOptional()
  category?: string;

  @ApiPropertyOptional({ example: ['haircut', 'styling'], description: 'Service tags' })
  @IsArray()
  @IsOptional()
  @IsString({ each: true })
  tags?: string[];

  @ApiPropertyOptional({ example: ['uuid1', 'uuid2'], description: 'Array of media IDs for service images' })
  @IsArray()
  @IsOptional()
  @IsUUID(undefined, { each: true })
  images?: string[];

  @ApiPropertyOptional({ example: 'active', enum: ServiceStatus, default: 'active' })
  @IsEnum(ServiceStatus)
  @IsOptional()
  status?: ServiceStatus;

  @ApiPropertyOptional({ example: false, default: false })
  @IsBoolean()
  @IsOptional()
  isFeatured?: boolean;
}

export class UpdateServiceDto {
  @ApiProperty({ description: 'Listing ID for authorization' })
  @IsUUID()
  listingId: string;

  @ApiPropertyOptional()
  @IsString()
  @IsOptional()
  name?: string;

  @ApiPropertyOptional()
  @IsString()
  @IsOptional()
  slug?: string;

  @ApiPropertyOptional()
  @IsString()
  @IsOptional()
  description?: string;

  @ApiPropertyOptional()
  @IsString()
  @IsOptional()
  shortDescription?: string;

  @ApiPropertyOptional()
  @IsNumber()
  @IsOptional()
  @Min(0)
  basePrice?: number;

  @ApiPropertyOptional()
  @IsString()
  @IsOptional()
  currency?: string;

  @ApiPropertyOptional({ enum: ServicePriceUnit })
  @IsEnum(ServicePriceUnit)
  @IsOptional()
  priceUnit?: ServicePriceUnit;

  @ApiPropertyOptional()
  @IsNumber()
  @IsOptional()
  @Min(1)
  durationMinutes?: number;

  @ApiPropertyOptional()
  @IsBoolean()
  @IsOptional()
  requiresBooking?: boolean;

  @ApiPropertyOptional()
  @IsNumber()
  @IsOptional()
  @Min(0)
  advanceBookingDays?: number;

  @ApiPropertyOptional()
  @IsNumber()
  @IsOptional()
  @Min(1)
  maxConcurrentBookings?: number;

  @ApiPropertyOptional()
  @IsObject()
  @IsOptional()
  availabilitySchedule?: any;

  @ApiPropertyOptional()
  @IsBoolean()
  @IsOptional()
  isAvailable?: boolean;

  @ApiPropertyOptional()
  @IsString()
  @IsOptional()
  category?: string;

  @ApiPropertyOptional()
  @IsArray()
  @IsOptional()
  @IsString({ each: true })
  tags?: string[];

  @ApiPropertyOptional()
  @IsArray()
  @IsOptional()
  @IsUUID(undefined, { each: true })
  images?: string[];

  @ApiPropertyOptional({ enum: ServiceStatus })
  @IsEnum(ServiceStatus)
  @IsOptional()
  status?: ServiceStatus;

  @ApiPropertyOptional()
  @IsBoolean()
  @IsOptional()
  isFeatured?: boolean;
}

export class ServiceQueryDto {
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

  @ApiPropertyOptional({ enum: ServiceStatus, description: 'Filter by status' })
  @IsEnum(ServiceStatus)
  @IsOptional()
  status?: ServiceStatus;

  @ApiPropertyOptional({ example: 'haircut', description: 'Search in name and description' })
  @IsString()
  @IsOptional()
  search?: string;

  @ApiPropertyOptional({ example: 'beauty', description: 'Filter by category' })
  @IsString()
  @IsOptional()
  category?: string;

  @ApiPropertyOptional({ example: 10000, description: 'Minimum price' })
  @Transform(({ value }) => parseFloat(value))
  @IsNumber()
  @IsOptional()
  minPrice?: number;

  @ApiPropertyOptional({ example: 50000, description: 'Maximum price' })
  @Transform(({ value }) => parseFloat(value))
  @IsNumber()
  @IsOptional()
  maxPrice?: number;

  @ApiPropertyOptional({ example: true, description: 'Filter featured services only' })
  @Transform(({ value }) => value === 'true' || value === true)
  @IsBoolean()
  @IsOptional()
  isFeatured?: boolean;

  @ApiPropertyOptional({ 
    example: 'popular', 
    enum: ['popular', 'name_asc', 'name_desc', 'price_asc', 'price_desc', 'createdAt_desc', 'createdAt_asc'],
    description: 'Sort order'
  })
  @IsString()
  @IsOptional()
  sortBy?: string;
}

export class CreateServiceBookingDto {
  @ApiProperty({ example: '2025-01-15', description: 'Booking date (YYYY-MM-DD)' })
  @IsString()
  bookingDate: string;

  @ApiProperty({ example: '14:00', description: 'Booking time (HH:mm)' })
  @IsString()
  bookingTime: string;

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

  @ApiPropertyOptional({ example: 'Window seat preferred' })
  @IsString()
  @IsOptional()
  specialRequests?: string;

  @ApiPropertyOptional({ description: 'Order ID if booking is part of an order' })
  @IsUUID()
  @IsOptional()
  orderId?: string;

  @ApiPropertyOptional({ description: 'Order item ID if booking is part of an order' })
  @IsUUID()
  @IsOptional()
  orderItemId?: string;
}

export class UpdateServiceBookingDto {
  @ApiPropertyOptional({ enum: ServiceBookingStatus })
  @IsEnum(ServiceBookingStatus)
  @IsOptional()
  status?: ServiceBookingStatus;

  @ApiPropertyOptional()
  @IsString()
  @IsOptional()
  specialRequests?: string;
}

