import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { IsUUID, IsOptional, IsNumber, IsString } from 'class-validator';
import { Transform } from 'class-transformer';

export class AddFavoriteDto {
  @ApiPropertyOptional({ description: 'Listing ID to favorite' })
  @IsUUID() @IsOptional()
  listingId?: string;

  @ApiPropertyOptional({ description: 'Event ID to favorite' })
  @IsUUID() @IsOptional()
  eventId?: string;

  @ApiPropertyOptional({ description: 'Tour ID to favorite' })
  @IsUUID() @IsOptional()
  tourId?: string;
}

export class CheckFavoriteDto {
  @ApiPropertyOptional()
  listingId?: string;

  @ApiPropertyOptional()
  eventId?: string;

  @ApiPropertyOptional()
  tourId?: string;
}

export class FavoriteQueryDto {
  @ApiPropertyOptional({ example: 1 })
  @Transform(({ value }) => (value !== undefined ? Number(value) : undefined))
  @IsNumber() @IsOptional()
  page?: number;

  @ApiPropertyOptional({ example: 20 })
  @Transform(({ value }) => (value !== undefined ? Number(value) : undefined))
  @IsNumber() @IsOptional()
  limit?: number;

  @ApiPropertyOptional({ enum: ['listing', 'event', 'tour'] })
  @IsString() @IsOptional()
  type?: string;
}

