import { ApiPropertyOptional } from '@nestjs/swagger';
import { listing_status } from '@prisma/client';
import { IsBoolean, IsEnum, IsOptional, IsString, MaxLength } from 'class-validator';

export class AdminUpdateListingStatusDto {
  @ApiPropertyOptional({ enum: listing_status })
  @IsOptional()
  @IsEnum(listing_status)
  status?: listing_status;

  @ApiPropertyOptional({ description: 'Feature on homepage', type: Boolean })
  @IsOptional()
  @IsBoolean()
  isFeatured?: boolean;

  @ApiPropertyOptional({ description: 'Verify listing', type: Boolean })
  @IsOptional()
  @IsBoolean()
  isVerified?: boolean;

  @ApiPropertyOptional({ description: 'Block listing from appearing', type: Boolean })
  @IsOptional()
  @IsBoolean()
  isBlocked?: boolean;

  @ApiPropertyOptional({ description: 'Internal review notes' })
  @IsOptional()
  @IsString()
  @MaxLength(500)
  reviewNotes?: string;
}


