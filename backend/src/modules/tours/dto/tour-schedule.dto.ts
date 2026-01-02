import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { IsString, IsOptional, IsNumber, IsUUID, IsDateString, IsBoolean } from 'class-validator';

export class CreateTourScheduleDto {
  @ApiProperty({ description: 'Tour ID', example: '123e4567-e89b-12d3-a456-426614174000' })
  @IsUUID()
  tourId: string;

  @ApiProperty({ description: 'Schedule date', example: '2025-01-15' })
  @IsDateString()
  date: string;

  @ApiPropertyOptional({ description: 'Start time', example: '08:00:00' })
  @IsString()
  @IsOptional()
  startTime?: string;

  @ApiProperty({ description: 'Available spots', example: 20 })
  @IsNumber()
  availableSpots: number;

  @ApiPropertyOptional({ description: 'Price override (optional, uses tour price if not provided)', example: 1500 })
  @IsNumber()
  @IsOptional()
  priceOverride?: number;

  @ApiPropertyOptional({ description: 'Is available', default: true })
  @IsBoolean()
  @IsOptional()
  isAvailable?: boolean;
}

export class UpdateTourScheduleDto {
  @ApiPropertyOptional({ description: 'Schedule date', example: '2025-01-15' })
  @IsDateString()
  @IsOptional()
  date?: string;

  @ApiPropertyOptional({ description: 'Start time', example: '08:00:00' })
  @IsString()
  @IsOptional()
  startTime?: string;

  @ApiPropertyOptional({ description: 'Available spots', example: 20 })
  @IsNumber()
  @IsOptional()
  availableSpots?: number;

  @ApiPropertyOptional({ description: 'Price override', example: 1500 })
  @IsNumber()
  @IsOptional()
  priceOverride?: number;

  @ApiPropertyOptional({ description: 'Is available' })
  @IsBoolean()
  @IsOptional()
  isAvailable?: boolean;
}

