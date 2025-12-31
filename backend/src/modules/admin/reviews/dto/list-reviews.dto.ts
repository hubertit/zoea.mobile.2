import { ApiPropertyOptional } from '@nestjs/swagger';
import { Transform } from 'class-transformer';
import { IsEnum, IsOptional, IsUUID, IsString } from 'class-validator';
import { review_status } from '@prisma/client';
import { PaginationDto } from '../../dto/pagination.dto';

export class AdminListReviewsDto extends PaginationDto {
  @ApiPropertyOptional({ description: 'Search by user name, item name, or review content' })
  @IsOptional()
  @IsString()
  search?: string;

  @ApiPropertyOptional({ enum: review_status, description: 'Filter by review status' })
  @IsOptional()
  @IsEnum(review_status)
  status?: review_status;

  @ApiPropertyOptional({ description: 'Filter by listing ID' })
  @IsOptional()
  @IsUUID()
  listingId?: string;

  @ApiPropertyOptional({ description: 'Filter by event ID' })
  @IsOptional()
  @IsUUID()
  eventId?: string;

  @ApiPropertyOptional({ description: 'Filter by tour ID' })
  @IsOptional()
  @IsUUID()
  tourId?: string;

  @ApiPropertyOptional({ description: 'Filter by user ID' })
  @IsOptional()
  @IsUUID()
  userId?: string;
}

