import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { IsString, IsOptional, IsNumber, IsUUID, IsArray, IsBoolean, IsEmail, IsDateString, IsEnum } from 'class-validator';

// ============ BUSINESS PROFILE DTOs ============
export class CreateBusinessDto {
  @ApiProperty({ example: 'Grand Hotel Kigali' })
  @IsString()
  businessName: string;

  @ApiProperty({ example: 'hotel', enum: ['hotel', 'restaurant', 'attraction', 'activity', 'rental', 'nightlife', 'spa', 'other'] })
  @IsString()
  businessType: string;

  @ApiPropertyOptional({ example: 'REG123456' })
  @IsString() @IsOptional()
  businessRegistrationNumber?: string;

  @ApiPropertyOptional({ example: 'TAX789' })
  @IsString() @IsOptional()
  taxId?: string;

  @ApiPropertyOptional({ example: 'Premier 5-star hotel in Kigali' })
  @IsString() @IsOptional()
  description?: string;

  @ApiPropertyOptional({ example: 'contact@hotel.com' })
  @IsEmail() @IsOptional()
  businessEmail?: string;

  @ApiPropertyOptional({ example: '+250788000000' })
  @IsString() @IsOptional()
  businessPhone?: string;

  @ApiPropertyOptional({ example: 'https://grandhotel.rw' })
  @IsString() @IsOptional()
  website?: string;

  @ApiPropertyOptional({ example: { facebook: 'url', instagram: 'url', twitter: 'url' } })
  @IsOptional()
  socialLinks?: any;

  @ApiPropertyOptional()
  @IsUUID() @IsOptional()
  countryId?: string;

  @ApiPropertyOptional()
  @IsUUID() @IsOptional()
  cityId?: string;

  @ApiPropertyOptional()
  @IsUUID() @IsOptional()
  districtId?: string;

  @ApiPropertyOptional({ example: 'KG 123 St, Kigali' })
  @IsString() @IsOptional()
  address?: string;

  @ApiPropertyOptional()
  @IsUUID() @IsOptional()
  logoId?: string;
}

export class UpdateBusinessDto {
  @ApiPropertyOptional({ example: 'Updated Hotel Name' })
  @IsString() @IsOptional()
  businessName?: string;

  @ApiPropertyOptional()
  @IsString() @IsOptional()
  businessType?: string;

  @ApiPropertyOptional()
  @IsString() @IsOptional()
  businessRegistrationNumber?: string;

  @ApiPropertyOptional()
  @IsString() @IsOptional()
  taxId?: string;

  @ApiPropertyOptional()
  @IsString() @IsOptional()
  description?: string;

  @ApiPropertyOptional()
  @IsEmail() @IsOptional()
  businessEmail?: string;

  @ApiPropertyOptional()
  @IsString() @IsOptional()
  businessPhone?: string;

  @ApiPropertyOptional()
  @IsString() @IsOptional()
  website?: string;

  @ApiPropertyOptional()
  @IsOptional()
  socialLinks?: any;

  @ApiPropertyOptional()
  @IsUUID() @IsOptional()
  countryId?: string;

  @ApiPropertyOptional()
  @IsUUID() @IsOptional()
  cityId?: string;

  @ApiPropertyOptional()
  @IsUUID() @IsOptional()
  districtId?: string;

  @ApiPropertyOptional()
  @IsString() @IsOptional()
  address?: string;

  @ApiPropertyOptional()
  @IsUUID() @IsOptional()
  logoId?: string;

  @ApiPropertyOptional({ example: { accountName: 'Business Name', bankName: 'Bank of Kigali', accountNumber: '123456' } })
  @IsOptional()
  bankAccountInfo?: any;

  @ApiPropertyOptional({ example: 'weekly', enum: ['daily', 'weekly', 'biweekly', 'monthly'] })
  @IsString() @IsOptional()
  payoutSchedule?: string;
}

// ============ LISTING DTOs ============
export class CreateMerchantListingDto {
  @ApiProperty({ example: 'Deluxe Suite' })
  @IsString()
  name: string;

  @ApiPropertyOptional({ example: 'deluxe-suite' })
  @IsString() @IsOptional()
  slug?: string;

  @ApiPropertyOptional({ example: 'Luxurious suite with panoramic city views' })
  @IsString() @IsOptional()
  description?: string;

  @ApiPropertyOptional({ example: 'Luxury suite with stunning views' })
  @IsString() @IsOptional()
  shortDescription?: string;

  @ApiProperty({ example: 'hotel', enum: ['hotel', 'restaurant', 'attraction', 'activity', 'rental', 'nightlife', 'spa', 'other'] })
  @IsString()
  type: string;

  @ApiPropertyOptional()
  @IsUUID() @IsOptional()
  categoryId?: string;

  @ApiPropertyOptional()
  @IsUUID() @IsOptional()
  countryId?: string;

  @ApiPropertyOptional()
  @IsUUID() @IsOptional()
  cityId?: string;

  @ApiPropertyOptional()
  @IsUUID() @IsOptional()
  districtId?: string;

  @ApiPropertyOptional({ example: 'KG 123 St' })
  @IsString() @IsOptional()
  address?: string;

  @ApiPropertyOptional({ example: '00000' })
  @IsString() @IsOptional()
  postalCode?: string;

  @ApiPropertyOptional({ example: 'Downtown Kigali' })
  @IsString() @IsOptional()
  locationName?: string;

  @ApiPropertyOptional({ example: -1.9403 })
  @IsNumber() @IsOptional()
  latitude?: number;

  @ApiPropertyOptional({ example: 29.8739 })
  @IsNumber() @IsOptional()
  longitude?: number;

  @ApiPropertyOptional({ example: 100 })
  @IsNumber() @IsOptional()
  minPrice?: number;

  @ApiPropertyOptional({ example: 500 })
  @IsNumber() @IsOptional()
  maxPrice?: number;

  @ApiPropertyOptional({ example: 'USD', default: 'RWF' })
  @IsString() @IsOptional()
  currency?: string;

  @ApiPropertyOptional({ example: 'per_night', enum: ['per_night', 'per_person', 'per_hour', 'per_item', 'flat'] })
  @IsString() @IsOptional()
  priceUnit?: string;

  @ApiPropertyOptional({ example: '+250788000000' })
  @IsString() @IsOptional()
  contactPhone?: string;

  @ApiPropertyOptional({ example: 'info@listing.com' })
  @IsEmail() @IsOptional()
  contactEmail?: string;

  @ApiPropertyOptional({ example: 'https://listing.com' })
  @IsString() @IsOptional()
  website?: string;

  @ApiPropertyOptional({ example: { monday: { open: '08:00', close: '22:00', closed: false } } })
  @IsOptional()
  operatingHours?: any;

  @ApiPropertyOptional({ example: 'Best Hotel in Kigali | Book Now' })
  @IsString() @IsOptional()
  metaTitle?: string;

  @ApiPropertyOptional({ example: 'Book your stay at the best hotel in Kigali' })
  @IsString() @IsOptional()
  metaDescription?: string;

  @ApiPropertyOptional({ type: [String], description: 'Array of amenity IDs' })
  @IsArray() @IsOptional()
  @IsUUID('4', { each: true })
  amenityIds?: string[];

  @ApiPropertyOptional({ type: [String], description: 'Array of tag IDs' })
  @IsArray() @IsOptional()
  @IsUUID('4', { each: true })
  tagIds?: string[];
}

export class UpdateMerchantListingDto {
  @ApiPropertyOptional()
  @IsString() @IsOptional()
  name?: string;

  @ApiPropertyOptional()
  @IsString() @IsOptional()
  slug?: string;

  @ApiPropertyOptional()
  @IsString() @IsOptional()
  description?: string;

  @ApiPropertyOptional()
  @IsString() @IsOptional()
  shortDescription?: string;

  @ApiPropertyOptional()
  @IsUUID() @IsOptional()
  categoryId?: string;

  @ApiPropertyOptional()
  @IsString() @IsOptional()
  address?: string;

  @ApiPropertyOptional()
  @IsString() @IsOptional()
  locationName?: string;

  @ApiPropertyOptional()
  @IsNumber() @IsOptional()
  latitude?: number;

  @ApiPropertyOptional()
  @IsNumber() @IsOptional()
  longitude?: number;

  @ApiPropertyOptional()
  @IsNumber() @IsOptional()
  minPrice?: number;

  @ApiPropertyOptional()
  @IsNumber() @IsOptional()
  maxPrice?: number;

  @ApiPropertyOptional()
  @IsString() @IsOptional()
  currency?: string;

  @ApiPropertyOptional()
  @IsString() @IsOptional()
  priceUnit?: string;

  @ApiPropertyOptional()
  @IsString() @IsOptional()
  contactPhone?: string;

  @ApiPropertyOptional()
  @IsEmail() @IsOptional()
  contactEmail?: string;

  @ApiPropertyOptional()
  @IsString() @IsOptional()
  website?: string;

  @ApiPropertyOptional()
  @IsOptional()
  operatingHours?: any;

  @ApiPropertyOptional()
  @IsString() @IsOptional()
  metaTitle?: string;

  @ApiPropertyOptional()
  @IsString() @IsOptional()
  metaDescription?: string;

  @ApiPropertyOptional({ type: [String] })
  @IsArray() @IsOptional()
  @IsUUID('4', { each: true })
  amenityIds?: string[];

  @ApiPropertyOptional({ type: [String] })
  @IsArray() @IsOptional()
  @IsUUID('4', { each: true })
  tagIds?: string[];
}

// ============ ROOM TYPE DTOs ============
export class CreateMerchantRoomTypeDto {
  @ApiProperty({ example: 'Deluxe Suite' })
  @IsString()
  name: string;

  @ApiPropertyOptional({ example: 'Spacious suite with city view' })
  @IsString() @IsOptional()
  description?: string;

  @ApiProperty({ example: 2 })
  @IsNumber()
  maxOccupancy: number;

  @ApiPropertyOptional({ example: 'king', enum: ['single', 'double', 'queen', 'king', 'twin'] })
  @IsString() @IsOptional()
  bedType?: string;

  @ApiPropertyOptional({ example: 1 })
  @IsNumber() @IsOptional()
  bedCount?: number;

  @ApiPropertyOptional({ example: 45.5, description: 'Room size in square meters' })
  @IsNumber() @IsOptional()
  roomSize?: number;

  @ApiProperty({ example: 150 })
  @IsNumber()
  basePrice: number;

  @ApiPropertyOptional({ example: 'USD', default: 'RWF' })
  @IsString() @IsOptional()
  currency?: string;

  @ApiProperty({ example: 10 })
  @IsNumber()
  totalRooms: number;

  @ApiPropertyOptional({ type: [String], description: 'Room amenities' })
  @IsArray() @IsOptional()
  amenities?: string[];
}

// ============ TABLE DTOs ============
export class CreateMerchantTableDto {
  @ApiProperty({ example: 'T1' })
  @IsString()
  tableNumber: string;

  @ApiProperty({ example: 4 })
  @IsNumber()
  capacity: number;

  @ApiPropertyOptional({ example: 2 })
  @IsNumber() @IsOptional()
  minCapacity?: number;

  @ApiPropertyOptional({ example: 'window', enum: ['window', 'patio', 'indoor', 'private', 'bar', 'rooftop'] })
  @IsString() @IsOptional()
  location?: string;

  @ApiPropertyOptional({ example: true })
  @IsBoolean() @IsOptional()
  isActive?: boolean;
}

// ============ BOOKING MANAGEMENT DTOs ============
export class UpdateBookingStatusDto {
  @ApiProperty({ enum: ['confirmed', 'cancelled', 'completed', 'no_show'] })
  @IsString()
  status: string;

  @ApiPropertyOptional({ example: 'Guest did not show up' })
  @IsString() @IsOptional()
  notes?: string;

  @ApiPropertyOptional({ example: 'Customer requested cancellation' })
  @IsString() @IsOptional()
  cancellationReason?: string;
}

// ============ PROMOTION DTOs ============
export class CreatePromotionDto {
  @ApiProperty({ example: 'Summer Sale' })
  @IsString()
  name: string;

  @ApiPropertyOptional({ example: 'Get 20% off all bookings' })
  @IsString() @IsOptional()
  description?: string;

  @ApiProperty({ example: 'percentage', enum: ['percentage', 'fixed_amount', 'free_item'] })
  @IsString()
  discountType: string;

  @ApiProperty({ example: 20 })
  @IsNumber()
  discountValue: number;

  @ApiPropertyOptional({ example: 'RWF' })
  @IsString() @IsOptional()
  currency?: string;

  @ApiPropertyOptional({ example: 50000, description: 'Minimum order amount to apply' })
  @IsNumber() @IsOptional()
  minOrderAmount?: number;

  @ApiPropertyOptional({ example: 100000, description: 'Maximum discount amount' })
  @IsNumber() @IsOptional()
  maxDiscountAmount?: number;

  @ApiProperty({ example: '2024-06-01' })
  @IsDateString()
  startDate: string;

  @ApiProperty({ example: '2024-08-31' })
  @IsDateString()
  endDate: string;

  @ApiPropertyOptional({ example: 100, description: 'Maximum number of uses' })
  @IsNumber() @IsOptional()
  maxUses?: number;

  @ApiPropertyOptional({ example: 1, description: 'Max uses per customer' })
  @IsNumber() @IsOptional()
  maxUsesPerCustomer?: number;

  @ApiPropertyOptional({ type: [String], description: 'Applicable listing IDs (empty = all)' })
  @IsArray() @IsOptional()
  @IsUUID('4', { each: true })
  applicableListingIds?: string[];

  @ApiPropertyOptional({ example: true })
  @IsBoolean() @IsOptional()
  isActive?: boolean;
}

// ============ COUPON DTOs ============
export class CreateCouponDto {
  @ApiProperty({ example: 'SUMMER20' })
  @IsString()
  code: string;

  @ApiPropertyOptional({ example: 'Summer discount code' })
  @IsString() @IsOptional()
  description?: string;

  @ApiProperty({ example: 'percentage', enum: ['percentage', 'fixed_amount'] })
  @IsString()
  discountType: string;

  @ApiProperty({ example: 20 })
  @IsNumber()
  discountValue: number;

  @ApiPropertyOptional({ example: 'RWF' })
  @IsString() @IsOptional()
  currency?: string;

  @ApiPropertyOptional({ example: 10000 })
  @IsNumber() @IsOptional()
  minOrderAmount?: number;

  @ApiPropertyOptional({ example: 50000 })
  @IsNumber() @IsOptional()
  maxDiscountAmount?: number;

  @ApiProperty({ example: '2024-12-31' })
  @IsDateString()
  expiresAt: string;

  @ApiPropertyOptional({ example: 500 })
  @IsNumber() @IsOptional()
  maxUses?: number;

  @ApiPropertyOptional({ example: 1 })
  @IsNumber() @IsOptional()
  maxUsesPerUser?: number;

  @ApiPropertyOptional({ example: true })
  @IsBoolean() @IsOptional()
  isActive?: boolean;
}

// ============ IMAGE DTOs ============
export class AddListingImageDto {
  @ApiProperty({ description: 'Media ID from uploaded file' })
  @IsUUID()
  mediaId: string;

  @ApiPropertyOptional({ example: false })
  @IsBoolean() @IsOptional()
  isPrimary?: boolean;

  @ApiPropertyOptional({ example: 'Hotel lobby view' })
  @IsString() @IsOptional()
  caption?: string;
}

// ============ ROOM TYPE UPDATE DTO ============
export class UpdateMerchantRoomTypeDto {
  @ApiPropertyOptional({ example: 'Updated Suite Name' })
  @IsString() @IsOptional()
  name?: string;

  @ApiPropertyOptional()
  @IsString() @IsOptional()
  description?: string;

  @ApiPropertyOptional()
  @IsNumber() @IsOptional()
  maxOccupancy?: number;

  @ApiPropertyOptional()
  @IsString() @IsOptional()
  bedType?: string;

  @ApiPropertyOptional()
  @IsNumber() @IsOptional()
  bedCount?: number;

  @ApiPropertyOptional()
  @IsNumber() @IsOptional()
  roomSize?: number;

  @ApiPropertyOptional()
  @IsNumber() @IsOptional()
  basePrice?: number;

  @ApiPropertyOptional()
  @IsString() @IsOptional()
  currency?: string;

  @ApiPropertyOptional()
  @IsNumber() @IsOptional()
  totalRooms?: number;

  @ApiPropertyOptional({ type: [String] })
  @IsArray() @IsOptional()
  amenities?: string[];

  @ApiPropertyOptional()
  @IsBoolean() @IsOptional()
  isActive?: boolean;
}

// ============ TABLE UPDATE DTO ============
export class UpdateMerchantTableDto {
  @ApiPropertyOptional()
  @IsString() @IsOptional()
  tableNumber?: string;

  @ApiPropertyOptional()
  @IsNumber() @IsOptional()
  capacity?: number;

  @ApiPropertyOptional()
  @IsNumber() @IsOptional()
  minCapacity?: number;

  @ApiPropertyOptional()
  @IsString() @IsOptional()
  location?: string;

  @ApiPropertyOptional()
  @IsBoolean() @IsOptional()
  isActive?: boolean;
}

// ============ REVIEW RESPONSE DTO ============
export class ReviewResponseDto {
  @ApiProperty({ example: 'Thank you for your feedback! We appreciate your kind words.' })
  @IsString()
  response: string;
}

