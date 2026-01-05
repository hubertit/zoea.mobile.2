import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { IsString, IsOptional, IsDateString, IsBoolean, IsArray, ValidateNested, IsEnum, IsUUID, IsInt, Min } from 'class-validator';
import { Type } from 'class-transformer';

export enum ItineraryItemType {
  LISTING = 'listing',
  EVENT = 'event',
  TOUR = 'tour',
  CUSTOM = 'custom',
}

export class CreateItineraryItemDto {
  @ApiPropertyOptional({ enum: ItineraryItemType, description: 'Type of item' })
  @IsEnum(ItineraryItemType)
  type: ItineraryItemType;

  @ApiPropertyOptional({ description: 'Listing ID if type is listing' })
  @IsOptional()
  @IsUUID()
  listingId?: string;

  @ApiPropertyOptional({ description: 'Event ID if type is event' })
  @IsOptional()
  @IsUUID()
  eventId?: string;

  @ApiPropertyOptional({ description: 'Tour ID if type is tour' })
  @IsOptional()
  @IsUUID()
  tourId?: string;

  @ApiPropertyOptional({ description: 'Custom name if type is custom' })
  @IsOptional()
  @IsString()
  customName?: string;

  @ApiPropertyOptional({ description: 'Custom description if type is custom' })
  @IsOptional()
  @IsString()
  customDescription?: string;

  @ApiPropertyOptional({ description: 'Custom location if type is custom' })
  @IsOptional()
  @IsString()
  customLocation?: string;

  @ApiProperty({ description: 'Start time for this item' })
  @IsDateString()
  startTime: string;

  @ApiPropertyOptional({ description: 'End time for this item' })
  @IsOptional()
  @IsDateString()
  endTime?: string;

  @ApiPropertyOptional({ description: 'Duration in minutes' })
  @IsOptional()
  @IsInt()
  @Min(0)
  durationMinutes?: number;

  @ApiProperty({ description: 'Order/position in itinerary', default: 0 })
  @IsInt()
  @Min(0)
  order: number;

  @ApiPropertyOptional({ description: 'Notes for this item' })
  @IsOptional()
  @IsString()
  notes?: string;

  @ApiPropertyOptional({ description: 'Additional metadata' })
  @IsOptional()
  metadata?: Record<string, any>;
}

export class CreateItineraryDto {
  @ApiProperty({ description: 'Itinerary title' })
  @IsString()
  title: string;

  @ApiPropertyOptional({ description: 'Itinerary description' })
  @IsOptional()
  @IsString()
  description?: string;

  @ApiProperty({ description: 'Start date' })
  @IsDateString()
  startDate: string;

  @ApiProperty({ description: 'End date' })
  @IsDateString()
  endDate: string;

  @ApiPropertyOptional({ description: 'Location name' })
  @IsOptional()
  @IsString()
  location?: string;

  @ApiPropertyOptional({ description: 'Country ID' })
  @IsOptional()
  @IsUUID()
  countryId?: string;

  @ApiPropertyOptional({ description: 'City ID' })
  @IsOptional()
  @IsUUID()
  cityId?: string;

  @ApiPropertyOptional({ description: 'Make itinerary public', default: false })
  @IsOptional()
  @IsBoolean()
  isPublic?: boolean;

  @ApiPropertyOptional({ description: 'Itinerary items', type: [CreateItineraryItemDto] })
  @IsOptional()
  @IsArray()
  @ValidateNested({ each: true })
  @Type(() => CreateItineraryItemDto)
  items?: CreateItineraryItemDto[];
}

export class UpdateItineraryDto {
  @ApiPropertyOptional({ description: 'Itinerary title' })
  @IsOptional()
  @IsString()
  title?: string;

  @ApiPropertyOptional({ description: 'Itinerary description' })
  @IsOptional()
  @IsString()
  description?: string;

  @ApiPropertyOptional({ description: 'Start date' })
  @IsOptional()
  @IsDateString()
  startDate?: string;

  @ApiPropertyOptional({ description: 'End date' })
  @IsOptional()
  @IsDateString()
  endDate?: string;

  @ApiPropertyOptional({ description: 'Location name' })
  @IsOptional()
  @IsString()
  location?: string;

  @ApiPropertyOptional({ description: 'Country ID' })
  @IsOptional()
  @IsUUID()
  countryId?: string;

  @ApiPropertyOptional({ description: 'City ID' })
  @IsOptional()
  @IsUUID()
  cityId?: string;

  @ApiPropertyOptional({ description: 'Make itinerary public' })
  @IsOptional()
  @IsBoolean()
  isPublic?: boolean;

  @ApiPropertyOptional({ description: 'Itinerary items', type: [CreateItineraryItemDto] })
  @IsOptional()
  @IsArray()
  @ValidateNested({ each: true })
  @Type(() => CreateItineraryItemDto)
  items?: CreateItineraryItemDto[];
}

export class ItineraryQueryDto {
  @ApiPropertyOptional({ description: 'Page number', default: 1, type: Number })
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  page?: number;

  @ApiPropertyOptional({ description: 'Items per page', default: 20, type: Number })
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  limit?: number;
}

