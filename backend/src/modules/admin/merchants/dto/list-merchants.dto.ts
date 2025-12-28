import { ApiPropertyOptional } from '@nestjs/swagger';
import { approval_status } from '@prisma/client';
import { Transform } from 'class-transformer';
import { IsBoolean, IsEnum, IsOptional, IsString } from 'class-validator';
import { PaginationDto } from '../../dto/pagination.dto';

export class AdminListMerchantsDto extends PaginationDto {
  @ApiPropertyOptional({ description: 'Search business name, email, phone or owner' })
  @IsOptional()
  @IsString()
  search?: string;

  @ApiPropertyOptional({ enum: approval_status, description: 'Registration status filter' })
  @IsOptional()
  @IsEnum(approval_status)
  registrationStatus?: approval_status;

  @ApiPropertyOptional({ description: 'Filter by verification state', type: Boolean })
  @IsOptional()
  @Transform(({ value }) => {
    if (value === undefined || value === null) return undefined;
    return value === true || value === 'true';
  })
  @IsBoolean()
  isVerified?: boolean;

  @ApiPropertyOptional({ description: 'Country ID filter', format: 'uuid' })
  @IsOptional()
  @IsString()
  countryId?: string;

  @ApiPropertyOptional({ description: 'City ID filter', format: 'uuid' })
  @IsOptional()
  @IsString()
  cityId?: string;
}


