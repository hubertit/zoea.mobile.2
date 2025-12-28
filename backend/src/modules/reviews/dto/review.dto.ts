import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { IsString, IsOptional, IsNumber, IsUUID, IsBoolean, Min, Max } from 'class-validator';
import { Transform } from 'class-transformer';

export class CreateReviewDto {
  @ApiPropertyOptional({ description: 'Listing ID to review' })
  @IsUUID() @IsOptional()
  listingId?: string;

  @ApiPropertyOptional({ description: 'Event ID to review' })
  @IsUUID() @IsOptional()
  eventId?: string;

  @ApiPropertyOptional({ description: 'Tour ID to review' })
  @IsUUID() @IsOptional()
  tourId?: string;

  @ApiProperty({ example: 5, minimum: 1, maximum: 5 })
  @IsNumber() @Min(1) @Max(5)
  rating: number;

  @ApiPropertyOptional({ example: 'Amazing experience!' })
  @IsString() @IsOptional()
  title?: string;

  @ApiProperty({ example: 'The hotel was fantastic, great service and beautiful views.' })
  @IsString()
  content: string;
}

export class UpdateReviewDto {
  @ApiPropertyOptional({ example: 4, minimum: 1, maximum: 5 })
  @IsNumber() @Min(1) @Max(5) @IsOptional()
  rating?: number;

  @ApiPropertyOptional({ example: 'Updated review title' })
  @IsString() @IsOptional()
  title?: string;

  @ApiPropertyOptional({ example: 'Updated review content' })
  @IsString() @IsOptional()
  content?: string;
}

export class MarkHelpfulDto {
  @ApiProperty({ example: true })
  @IsBoolean()
  isHelpful: boolean;
}

export class ReviewQueryDto {
  @ApiPropertyOptional({ example: 1 })
  @Transform(({ value }) => (value !== undefined ? Number(value) : undefined))
  @IsNumber() @IsOptional()
  page?: number;

  @ApiPropertyOptional({ example: 20 })
  @Transform(({ value }) => (value !== undefined ? Number(value) : undefined))
  @IsNumber() @IsOptional()
  limit?: number;

  @ApiPropertyOptional()
  @IsUUID() @IsOptional()
  listingId?: string;

  @ApiPropertyOptional()
  @IsUUID() @IsOptional()
  eventId?: string;

  @ApiPropertyOptional()
  @IsUUID() @IsOptional()
  tourId?: string;

  @ApiPropertyOptional()
  @IsUUID() @IsOptional()
  userId?: string;

  @ApiPropertyOptional({ enum: ['pending', 'approved', 'rejected'] })
  @IsString() @IsOptional()
  status?: string;
}

