import { ApiProperty, ApiPropertyOptional, PartialType } from '@nestjs/swagger';
import { event_privacy, event_setup } from '@prisma/client';
import { IsBoolean, IsDateString, IsEnum, IsNumber, IsOptional, IsString, IsUUID } from 'class-validator';

export class AdminCreateEventDto {
  @ApiProperty({ description: 'Organizer profile ID', format: 'uuid' })
  @IsUUID()
  organizerId: string;

  @ApiProperty({ description: 'Event name' })
  @IsString()
  name: string;

  @ApiPropertyOptional()
  @IsString()
  @IsOptional()
  slug?: string;

  @ApiPropertyOptional()
  @IsString()
  @IsOptional()
  description?: string;

  @ApiPropertyOptional({ enum: event_privacy })
  @IsEnum(event_privacy)
  @IsOptional()
  privacy?: event_privacy;

  @ApiPropertyOptional({ enum: event_setup })
  @IsEnum(event_setup)
  @IsOptional()
  setup?: event_setup;

  @ApiPropertyOptional({ format: 'uuid' })
  @IsUUID()
  @IsOptional()
  countryId?: string;

  @ApiPropertyOptional({ format: 'uuid' })
  @IsUUID()
  @IsOptional()
  cityId?: string;

  @ApiPropertyOptional()
  @IsString()
  @IsOptional()
  address?: string;

  @ApiPropertyOptional()
  @IsDateString()
  startDate?: string;

  @ApiPropertyOptional()
  @IsDateString()
  endDate?: string;

  @ApiPropertyOptional()
  @IsNumber()
  @IsOptional()
  maxAttendance?: number;

  @ApiPropertyOptional()
  @IsBoolean()
  @IsOptional()
  isBlocked?: boolean;
}

export class AdminUpdateEventDto extends PartialType(AdminCreateEventDto) {}


