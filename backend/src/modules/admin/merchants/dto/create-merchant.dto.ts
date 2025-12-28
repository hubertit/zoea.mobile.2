import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { IsEmail, IsEnum, IsObject, IsOptional, IsString, IsUUID, MaxLength } from 'class-validator';
import { listing_type } from '@prisma/client';

export class AdminCreateMerchantDto {
  @ApiProperty({ description: 'Owner user ID', format: 'uuid' })
  @IsUUID()
  userId: string;

  @ApiProperty({ description: 'Business name' })
  @IsString()
  @MaxLength(255)
  businessName: string;

  @ApiPropertyOptional({ enum: listing_type })
  @IsOptional()
  @IsEnum(listing_type)
  businessType?: listing_type;

  @ApiPropertyOptional()
  @IsString()
  @MaxLength(100)
  @IsOptional()
  businessRegistrationNumber?: string;

  @ApiPropertyOptional()
  @IsString()
  @MaxLength(100)
  @IsOptional()
  taxId?: string;

  @ApiPropertyOptional()
  @IsString()
  @IsOptional()
  description?: string;

  @ApiPropertyOptional({ format: 'email' })
  @IsEmail()
  @IsOptional()
  businessEmail?: string;

  @ApiPropertyOptional()
  @IsString()
  @IsOptional()
  businessPhone?: string;

  @ApiPropertyOptional()
  @IsString()
  @IsOptional()
  website?: string;

  @ApiPropertyOptional({ description: 'JSON blob of social links' })
  @IsObject()
  @IsOptional()
  socialLinks?: Record<string, any>;

  @ApiPropertyOptional({ format: 'uuid' })
  @IsUUID()
  @IsOptional()
  countryId?: string;

  @ApiPropertyOptional({ format: 'uuid' })
  @IsUUID()
  @IsOptional()
  cityId?: string;

  @ApiPropertyOptional({ format: 'uuid' })
  @IsUUID()
  @IsOptional()
  districtId?: string;

  @ApiPropertyOptional()
  @IsString()
  @IsOptional()
  address?: string;
}


