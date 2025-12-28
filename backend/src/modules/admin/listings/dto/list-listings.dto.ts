import { ApiPropertyOptional } from '@nestjs/swagger';
import { listing_status, listing_type } from '@prisma/client';
import { Transform } from 'class-transformer';
import { IsBoolean, IsEnum, IsOptional, IsString } from 'class-validator';
import { PaginationDto } from '../../dto/pagination.dto';

export class AdminListListingsDto extends PaginationDto {
  @ApiPropertyOptional({ description: 'Search name, slug, merchant name' })
  @IsOptional()
  @IsString()
  search?: string;

  @ApiPropertyOptional({ enum: listing_status })
  @IsOptional()
  @IsEnum(listing_status)
  status?: listing_status;

  @ApiPropertyOptional({ enum: listing_type })
  @IsOptional()
  @IsEnum(listing_type)
  type?: listing_type;

  @ApiPropertyOptional({ description: 'Filter by feature flag', type: Boolean })
  @IsOptional()
  @Transform(({ value }) => (value === undefined ? undefined : value === true || value === 'true'))
  @IsBoolean()
  isFeatured?: boolean;

  @ApiPropertyOptional({ description: 'Filter by verification flag', type: Boolean })
  @IsOptional()
  @Transform(({ value }) => (value === undefined ? undefined : value === true || value === 'true'))
  @IsBoolean()
  isVerified?: boolean;

  @ApiPropertyOptional({ description: 'Merchant ID', format: 'uuid' })
  @IsOptional()
  @IsString()
  merchantId?: string;

  @ApiPropertyOptional({ description: 'Country ID', format: 'uuid' })
  @IsOptional()
  @IsString()
  countryId?: string;

  @ApiPropertyOptional({ description: 'City ID', format: 'uuid' })
  @IsOptional()
  @IsString()
  cityId?: string;
}


