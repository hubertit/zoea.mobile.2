import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { IsString, IsOptional, IsNumber, IsUUID, IsBoolean, IsArray, IsEnum, IsIn } from 'class-validator';
import { Transform } from 'class-transformer';

export class CreateListingDto {
  @ApiProperty({ description: 'Merchant/Business ID that owns this listing' })
  @IsUUID()
  merchantId: string;

  @ApiProperty({ example: 'Grand Hotel Kigali' })
  @IsString()
  name: string;

  @ApiPropertyOptional({ example: 'grand-hotel-kigali' })
  @IsString() @IsOptional()
  slug?: string;

  @ApiPropertyOptional({ example: 'Luxury 5-star hotel in the heart of Kigali' })
  @IsString() @IsOptional()
  description?: string;

  @ApiPropertyOptional({ example: 'Luxury hotel with stunning views' })
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

  @ApiPropertyOptional({ example: '123 Main Street, Kigali' })
  @IsString() @IsOptional()
  address?: string;

  @ApiPropertyOptional({ example: '00000' })
  @IsString() @IsOptional()
  postalCode?: string;

  @ApiPropertyOptional({ example: 'Downtown Kigali' })
  @IsString() @IsOptional()
  locationName?: string;

  @ApiPropertyOptional({ example: -1.9403, description: 'Latitude for location coordinates' })
  @IsNumber() @IsOptional()
  @Transform(({ value }) => parseFloat(value))
  latitude?: number;

  @ApiPropertyOptional({ example: 29.8739, description: 'Longitude for location coordinates' })
  @IsNumber() @IsOptional()
  @Transform(({ value }) => parseFloat(value))
  longitude?: number;

  @ApiPropertyOptional({ example: 50 })
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

  @ApiPropertyOptional({ example: 'info@hotel.com' })
  @IsString() @IsOptional()
  contactEmail?: string;

  @ApiPropertyOptional({ example: 'https://hotel.com' })
  @IsString() @IsOptional()
  website?: string;

  @ApiPropertyOptional({ example: { monday: { open: '08:00', close: '22:00' } } })
  @IsOptional()
  operatingHours?: any;

  @ApiPropertyOptional({ example: false, description: 'Whether the listing accepts bookings' })
  @IsBoolean() @IsOptional()
  acceptsBookings?: boolean;

  @ApiPropertyOptional({ example: 'Grand Hotel Kigali | Best Luxury Hotel' })
  @IsString() @IsOptional()
  metaTitle?: string;

  @ApiPropertyOptional({ example: 'Book your stay at Grand Hotel Kigali' })
  @IsString() @IsOptional()
  metaDescription?: string;
}

export class UpdateListingDto {
  @ApiProperty({ description: 'Merchant/Business ID for authorization' })
  @IsUUID()
  merchantId: string;

  @ApiPropertyOptional({ example: 'Updated Hotel Name' })
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
  @IsUUID() @IsOptional()
  countryId?: string;

  @ApiPropertyOptional()
  @IsUUID() @IsOptional()
  cityId?: string;

  @ApiPropertyOptional()
  @IsString() @IsOptional()
  address?: string;

  @ApiPropertyOptional()
  @IsNumber() @IsOptional()
  minPrice?: number;

  @ApiPropertyOptional()
  @IsNumber() @IsOptional()
  maxPrice?: number;

  @ApiPropertyOptional()
  @IsString() @IsOptional()
  contactPhone?: string;

  @ApiPropertyOptional()
  @IsString() @IsOptional()
  contactEmail?: string;

  @ApiPropertyOptional()
  @IsString() @IsOptional()
  website?: string;

  @ApiPropertyOptional()
  @IsOptional()
  operatingHours?: any;

  @ApiPropertyOptional({ description: 'Whether the listing accepts bookings' })
  @IsBoolean() @IsOptional()
  acceptsBookings?: boolean;
}

export class AddListingImageDto {
  @ApiProperty({ description: 'Merchant ID for authorization' })
  @IsUUID()
  merchantId: string;

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

export class SetAmenitiesDto {
  @ApiProperty({ description: 'Merchant ID for authorization' })
  @IsUUID()
  merchantId: string;

  @ApiProperty({ description: 'Array of amenity IDs', type: [String] })
  @IsArray()
  @IsUUID('4', { each: true })
  amenityIds: string[];
}

export class CreateRoomTypeDto {
  @ApiProperty({ description: 'Merchant ID for authorization' })
  @IsUUID()
  merchantId: string;

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

  @ApiPropertyOptional({ description: 'Array of amenity names', type: [String] })
  @IsArray() @IsOptional()
  amenities?: string[];
}

export class CreateTableDto {
  @ApiProperty({ description: 'Merchant ID for authorization' })
  @IsUUID()
  merchantId: string;

  @ApiProperty({ example: 'T1' })
  @IsString()
  tableNumber: string;

  @ApiProperty({ example: 4 })
  @IsNumber()
  capacity: number;

  @ApiPropertyOptional({ example: 2 })
  @IsNumber() @IsOptional()
  minCapacity?: number;

  @ApiPropertyOptional({ example: 'window', enum: ['window', 'patio', 'indoor', 'private', 'bar'] })
  @IsString() @IsOptional()
  location?: string;
}

export class ListingQueryDto {
  @ApiPropertyOptional({ example: 1 })
  @Transform(({ value }) => (value !== undefined ? Number(value) : undefined))
  @IsNumber() @IsOptional()
  page?: number;

  @ApiPropertyOptional({ example: 20 })
  @Transform(({ value }) => (value !== undefined ? Number(value) : undefined))
  @IsNumber() @IsOptional()
  limit?: number;

  @ApiPropertyOptional({ enum: ['hotel', 'restaurant', 'attraction', 'activity', 'rental', 'nightlife', 'spa'] })
  @IsString() @IsOptional()
  type?: string;

  @ApiPropertyOptional({ enum: ['draft', 'pending_review', 'active', 'inactive'] })
  @IsString() @IsOptional()
  status?: string;

  @ApiPropertyOptional()
  @IsUUID() @IsOptional()
  cityId?: string;

  @ApiPropertyOptional()
  @IsUUID() @IsOptional()
  countryId?: string;

  @ApiPropertyOptional()
  @IsUUID() @IsOptional()
  categoryId?: string;

  @ApiPropertyOptional()
  @IsString() @IsOptional()
  search?: string;

  @ApiPropertyOptional()
  @Transform(({ value }) => (value !== undefined ? Number(value) : undefined))
  @IsNumber() @IsOptional()
  minPrice?: number;

  @ApiPropertyOptional()
  @Transform(({ value }) => (value !== undefined ? Number(value) : undefined))
  @IsNumber() @IsOptional()
  maxPrice?: number;

  @ApiPropertyOptional()
  @Transform(({ value }) => (value !== undefined ? Number(value) : undefined))
  @IsNumber() @IsOptional()
  rating?: number;

  @ApiPropertyOptional()
  @Transform(({ value }) => (value === undefined ? undefined : value === true || value === 'true'))
  @IsBoolean() @IsOptional()
  isFeatured?: boolean;

  @ApiPropertyOptional({ 
    enum: ['popular', 'rating_desc', 'rating_asc', 'name_asc', 'name_desc', 'price_asc', 'price_desc', 'createdAt_desc', 'createdAt_asc'],
    description: 'Sort order for listings. Default: popular (featured first, then by rating, then by creation date)',
    example: 'rating_desc'
  })
  @IsString() @IsOptional()
  @IsIn(['popular', 'rating_desc', 'rating_asc', 'name_asc', 'name_desc', 'price_asc', 'price_desc', 'createdAt_desc', 'createdAt_asc'])
  sortBy?: string;
}

export class SubmitListingDto {
  @ApiProperty({ description: 'Merchant ID for authorization' })
  @IsUUID()
  merchantId: string;
}

export class ReorderImagesDto {
  @ApiProperty({ description: 'Merchant ID for authorization' })
  @IsUUID()
  merchantId: string;

  @ApiProperty({ description: 'Array of image IDs in desired order', type: [String] })
  @IsArray()
  @IsUUID('4', { each: true })
  imageIds: string[];
}

export class UpdateRoomTypeDto {
  @ApiProperty({ description: 'Merchant ID for authorization' })
  @IsUUID()
  merchantId: string;

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
}

export class UpdateTableDto {
  @ApiProperty({ description: 'Merchant ID for authorization' })
  @IsUUID()
  merchantId: string;

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

