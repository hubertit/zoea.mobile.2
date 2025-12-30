import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { IsString, IsOptional, IsObject, IsArray, ValidateNested, IsEnum, IsUUID, IsNumber, IsBoolean } from 'class-validator';
import { Type } from 'class-transformer';

export enum AnalyticsEventType {
  SEARCH = 'search',
  LISTING_VIEW = 'listing_view',
  EVENT_VIEW = 'event_view',
  NAVIGATION = 'navigation',
  SESSION_START = 'session_start',
  BOOKING_ATTEMPT = 'booking_attempt',
  BOOKING_COMPLETION = 'booking_completion',
  INTERACTION = 'interaction',
}

export class AnalyticsEventDataDto {
  @ApiPropertyOptional({ description: 'Search query' })
  @IsOptional()
  @IsString()
  query?: string;

  @ApiPropertyOptional({ description: 'Category' })
  @IsOptional()
  @IsString()
  category?: string;

  @ApiPropertyOptional({ description: 'Category slug' })
  @IsOptional()
  @IsString()
  categorySlug?: string;

  @ApiPropertyOptional({ description: 'Listing ID' })
  @IsOptional()
  @IsUUID()
  listingId?: string;

  @ApiPropertyOptional({ description: 'Event ID' })
  @IsOptional()
  @IsUUID()
  eventId?: string;

  @ApiPropertyOptional({ description: 'Event type' })
  @IsOptional()
  @IsString()
  eventType?: string;

  @ApiPropertyOptional({ description: 'Zone for navigation' })
  @IsOptional()
  @IsString()
  zone?: string;

  @ApiPropertyOptional({ description: 'Booking ID' })
  @IsOptional()
  @IsUUID()
  bookingId?: string;

  @ApiPropertyOptional({ description: 'Listing type' })
  @IsOptional()
  @IsString()
  listingType?: string;

  @ApiPropertyOptional({ description: 'Interaction type' })
  @IsOptional()
  @IsString()
  interactionType?: string;

  @ApiPropertyOptional({ description: 'Target ID' })
  @IsOptional()
  @IsString()
  targetId?: string;

  @ApiPropertyOptional({ description: 'Timestamp' })
  @IsOptional()
  @IsString()
  timestamp?: string;

  @ApiPropertyOptional({ description: 'Additional metadata' })
  @IsOptional()
  @IsObject()
  metadata?: Record<string, any>;
}

export class AnalyticsEventDto {
  @ApiProperty({ enum: AnalyticsEventType, description: 'Event type' })
  @IsEnum(AnalyticsEventType)
  type: AnalyticsEventType;

  @ApiProperty({ type: AnalyticsEventDataDto, description: 'Event data' })
  @ValidateNested()
  @Type(() => AnalyticsEventDataDto)
  data: AnalyticsEventDataDto;
}

export class BatchAnalyticsEventsDto {
  @ApiProperty({ type: [AnalyticsEventDto], description: 'Array of analytics events' })
  @IsArray()
  @ValidateNested({ each: true })
  @Type(() => AnalyticsEventDto)
  events: AnalyticsEventDto[];

  @ApiPropertyOptional({ description: 'Session ID' })
  @IsOptional()
  @IsString()
  sessionId?: string;

  @ApiPropertyOptional({ description: 'Device type' })
  @IsOptional()
  @IsString()
  deviceType?: string;

  @ApiPropertyOptional({ description: 'OS' })
  @IsOptional()
  @IsString()
  os?: string;

  @ApiPropertyOptional({ description: 'Browser' })
  @IsOptional()
  @IsString()
  browser?: string;

  @ApiPropertyOptional({ description: 'App version' })
  @IsOptional()
  @IsString()
  appVersion?: string;

  @ApiPropertyOptional({ description: 'IP address' })
  @IsOptional()
  @IsString()
  ipAddress?: string;
}

export class RecordContentViewDto {
  @ApiProperty({ enum: ['listing', 'event'], description: 'Content type' })
  @IsEnum(['listing', 'event'])
  contentType: 'listing' | 'event';

  @ApiProperty({ description: 'Content ID (UUID)' })
  @IsUUID()
  contentId: string;

  @ApiPropertyOptional({ description: 'Session ID' })
  @IsOptional()
  @IsString()
  sessionId?: string;

  @ApiPropertyOptional({ description: 'Duration in seconds' })
  @IsOptional()
  @IsNumber()
  durationSeconds?: number;

  @ApiPropertyOptional({ description: 'Scroll depth percentage' })
  @IsOptional()
  @IsNumber()
  scrollDepth?: number;

  @ApiPropertyOptional({ description: 'Clicked book button' })
  @IsOptional()
  @IsBoolean()
  clickedBook?: boolean;

  @ApiPropertyOptional({ description: 'Clicked contact button' })
  @IsOptional()
  @IsBoolean()
  clickedContact?: boolean;

  @ApiPropertyOptional({ description: 'Added to favorites' })
  @IsOptional()
  @IsBoolean()
  addedToFavorites?: boolean;

  @ApiPropertyOptional({ description: 'Source' })
  @IsOptional()
  @IsString()
  source?: string;

  @ApiPropertyOptional({ description: 'Referrer' })
  @IsOptional()
  @IsString()
  referrer?: string;
}

