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
  @ApiPropertyOptional({ description: 'Search query', example: 'hotel in Kigali' })
  @IsOptional()
  @IsString()
  query?: string;

  @ApiPropertyOptional({ description: 'Category name', example: 'Accommodation' })
  @IsOptional()
  @IsString()
  category?: string;

  @ApiPropertyOptional({ description: 'Category slug', example: 'accommodation' })
  @IsOptional()
  @IsString()
  categorySlug?: string;

  @ApiPropertyOptional({ description: 'Listing UUID (required for listing_view events)', example: '123e4567-e89b-12d3-a456-426614174000' })
  @IsOptional()
  @IsUUID()
  listingId?: string;

  @ApiPropertyOptional({ description: 'Event UUID (required for event_view events)', example: '123e4567-e89b-12d3-a456-426614174001' })
  @IsOptional()
  @IsUUID()
  eventId?: string;

  @ApiPropertyOptional({ description: 'Event type/category', example: 'music' })
  @IsOptional()
  @IsString()
  eventType?: string;

  @ApiPropertyOptional({ description: 'Zone for navigation (e.g., city name)', example: 'Kigali' })
  @IsOptional()
  @IsString()
  zone?: string;

  @ApiPropertyOptional({ description: 'Booking UUID (for booking events)', example: '123e4567-e89b-12d3-a456-426614174002' })
  @IsOptional()
  @IsUUID()
  bookingId?: string;

  @ApiPropertyOptional({ description: 'Listing type', example: 'hotel', enum: ['hotel', 'restaurant', 'attraction', 'activity'] })
  @IsOptional()
  @IsString()
  listingType?: string;

  @ApiPropertyOptional({ description: 'Interaction type', example: 'favorite', enum: ['favorite', 'share', 'book', 'contact'] })
  @IsOptional()
  @IsString()
  interactionType?: string;

  @ApiPropertyOptional({ description: 'Target ID (UUID of interacted item)', example: '123e4567-e89b-12d3-a456-426614174003' })
  @IsOptional()
  @IsString()
  targetId?: string;

  @ApiPropertyOptional({ description: 'Event timestamp in ISO 8601 format', example: '2024-01-15T10:30:00Z' })
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
  @ApiProperty({ 
    type: [AnalyticsEventDto], 
    description: 'Array of analytics events to process in batch (max 50 recommended)',
    example: [
      {
        type: 'listing_view',
        data: {
          listingId: '123e4567-e89b-12d3-a456-426614174000',
          category: 'Accommodation',
          timestamp: '2024-01-15T10:30:00Z'
        }
      },
      {
        type: 'search',
        data: {
          query: 'hotel in Kigali',
          category: 'Accommodation',
          timestamp: '2024-01-15T10:25:00Z'
        }
      }
    ]
  })
  @IsArray()
  @ValidateNested({ each: true })
  @Type(() => AnalyticsEventDto)
  events: AnalyticsEventDto[];

  @ApiPropertyOptional({ description: 'Session ID for tracking user session', example: '1705312200000_abc12345' })
  @IsOptional()
  @IsString()
  sessionId?: string;

  @ApiPropertyOptional({ description: 'Device type', example: 'ios', enum: ['ios', 'android', 'web', 'unknown'] })
  @IsOptional()
  @IsString()
  deviceType?: string;

  @ApiPropertyOptional({ description: 'Operating system version', example: 'iOS 17.0' })
  @IsOptional()
  @IsString()
  os?: string;

  @ApiPropertyOptional({ description: 'Browser name (for web)', example: 'Chrome' })
  @IsOptional()
  @IsString()
  browser?: string;

  @ApiPropertyOptional({ description: 'Mobile app version', example: '2.0.0' })
  @IsOptional()
  @IsString()
  appVersion?: string;

  @ApiPropertyOptional({ description: 'Client IP address (optional, will be extracted from request if not provided)', example: '192.168.1.1' })
  @IsOptional()
  @IsString()
  ipAddress?: string;
}

export class RecordContentViewDto {
  @ApiProperty({ 
    enum: ['listing', 'event'], 
    description: 'Type of content being viewed',
    example: 'listing'
  })
  @IsEnum(['listing', 'event'])
  contentType: 'listing' | 'event';

  @ApiProperty({ 
    description: 'UUID of the listing or event being viewed',
    example: '123e4567-e89b-12d3-a456-426614174000'
  })
  @IsUUID()
  contentId: string;

  @ApiPropertyOptional({ 
    description: 'Session ID for tracking user session',
    example: '1705312200000_abc12345'
  })
  @IsOptional()
  @IsString()
  sessionId?: string;

  @ApiPropertyOptional({ 
    description: 'Time spent viewing the content in seconds',
    example: 45,
    minimum: 0
  })
  @IsOptional()
  @IsNumber()
  durationSeconds?: number;

  @ApiPropertyOptional({ 
    description: 'Scroll depth as percentage (0-100)',
    example: 75,
    minimum: 0,
    maximum: 100
  })
  @IsOptional()
  @IsNumber()
  scrollDepth?: number;

  @ApiPropertyOptional({ 
    description: 'Whether user clicked the book/booking button',
    example: true
  })
  @IsOptional()
  @IsBoolean()
  clickedBook?: boolean;

  @ApiPropertyOptional({ 
    description: 'Whether user clicked the contact button',
    example: false
  })
  @IsOptional()
  @IsBoolean()
  clickedContact?: boolean;

  @ApiPropertyOptional({ 
    description: 'Whether user added the content to favorites',
    example: true
  })
  @IsOptional()
  @IsBoolean()
  addedToFavorites?: boolean;

  @ApiPropertyOptional({ 
    description: 'Source of the view (e.g., search, category, recommendation)',
    example: 'search',
    enum: ['search', 'category', 'recommendation', 'favorites', 'recent', 'direct']
  })
  @IsOptional()
  @IsString()
  source?: string;

  @ApiPropertyOptional({ 
    description: 'Referrer URL or identifier',
    example: 'https://zoea.africa/explore'
  })
  @IsOptional()
  @IsString()
  referrer?: string;
}

