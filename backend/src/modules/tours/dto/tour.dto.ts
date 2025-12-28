import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { IsString, IsOptional, IsNumber, IsUUID, IsArray } from 'class-validator';

export class CreateTourDto {
  @ApiProperty({ description: 'Tour operator profile ID' })
  @IsUUID()
  operatorId: string;

  @ApiProperty({ example: 'Gorilla Trekking Adventure' })
  @IsString()
  name: string;

  @ApiPropertyOptional({ example: 'gorilla-trekking-adventure' })
  @IsString() @IsOptional()
  slug?: string;

  @ApiPropertyOptional({ example: 'Experience the majestic mountain gorillas in their natural habitat' })
  @IsString() @IsOptional()
  description?: string;

  @ApiPropertyOptional({ example: 'Unforgettable gorilla encounter' })
  @IsString() @IsOptional()
  shortDescription?: string;

  @ApiPropertyOptional({ example: 'wildlife', enum: ['wildlife', 'cultural', 'adventure', 'hiking', 'city', 'beach', 'safari'] })
  @IsString() @IsOptional()
  type?: string;

  @ApiPropertyOptional()
  @IsUUID() @IsOptional()
  categoryId?: string;

  @ApiPropertyOptional()
  @IsUUID() @IsOptional()
  countryId?: string;

  @ApiPropertyOptional()
  @IsUUID() @IsOptional()
  cityId?: string;

  @ApiPropertyOptional({ example: 'Volcanoes National Park', description: 'Start location name' })
  @IsString() @IsOptional()
  startLocationName?: string;

  @ApiPropertyOptional({ example: 'Kigali City', description: 'End location name' })
  @IsString() @IsOptional()
  endLocationName?: string;

  @ApiPropertyOptional({ example: 3, description: 'Duration in days' })
  @IsNumber() @IsOptional()
  durationDays?: number;

  @ApiPropertyOptional({ example: 8, description: 'Duration in hours (for day tours)' })
  @IsNumber() @IsOptional()
  durationHours?: number;

  @ApiPropertyOptional({ example: 1500, description: 'Price per person' })
  @IsNumber() @IsOptional()
  pricePerPerson?: number;

  @ApiPropertyOptional({ example: 'USD', default: 'USD' })
  @IsString() @IsOptional()
  currency?: string;

  @ApiPropertyOptional({ example: 10, description: 'Group discount percentage' })
  @IsNumber() @IsOptional()
  groupDiscountPercentage?: number;

  @ApiPropertyOptional({ example: 20 })
  @IsNumber() @IsOptional()
  maxGroupSize?: number;

  @ApiPropertyOptional({ example: 1 })
  @IsNumber() @IsOptional()
  minGroupSize?: number;

  @ApiPropertyOptional({ example: 'moderate', enum: ['easy', 'moderate', 'challenging', 'difficult'] })
  @IsString() @IsOptional()
  difficultyLevel?: string;

  @ApiPropertyOptional({ example: ['en', 'fr'], type: [String], description: 'Languages offered' })
  @IsArray() @IsOptional()
  languages?: string[];

  @ApiPropertyOptional({ example: ['accommodation', 'meals', 'transport', 'guide'], type: [String], description: 'What is included' })
  @IsArray() @IsOptional()
  includes?: string[];

  @ApiPropertyOptional({ example: ['flights', 'visa', 'tips'], type: [String], description: 'What is excluded' })
  @IsArray() @IsOptional()
  excludes?: string[];

  @ApiPropertyOptional({ example: ['hiking boots', 'rain jacket', 'camera'], type: [String], description: 'Requirements/what to bring' })
  @IsArray() @IsOptional()
  requirements?: string[];

  @ApiPropertyOptional({ example: { day1: 'Arrival and briefing', day2: 'Trekking' }, description: 'Day-by-day itinerary' })
  @IsOptional()
  itinerary?: any;
}

export class UpdateTourDto {
  @ApiProperty({ description: 'Tour operator ID for authorization' })
  @IsUUID()
  operatorId: string;

  @ApiPropertyOptional()
  @IsString() @IsOptional()
  name?: string;

  @ApiPropertyOptional()
  @IsString() @IsOptional()
  slug?: string;

  @ApiPropertyOptional()
  @IsString() @IsOptional()
  description?: string;

  @ApiPropertyOptional()
  @IsString() @IsOptional()
  shortDescription?: string;

  @ApiPropertyOptional()
  @IsString() @IsOptional()
  type?: string;

  @ApiPropertyOptional()
  @IsUUID() @IsOptional()
  categoryId?: string;

  @ApiPropertyOptional()
  @IsNumber() @IsOptional()
  durationDays?: number;

  @ApiPropertyOptional()
  @IsNumber() @IsOptional()
  durationHours?: number;

  @ApiPropertyOptional()
  @IsNumber() @IsOptional()
  pricePerPerson?: number;

  @ApiPropertyOptional()
  @IsString() @IsOptional()
  currency?: string;

  @ApiPropertyOptional()
  @IsNumber() @IsOptional()
  groupDiscountPercentage?: number;

  @ApiPropertyOptional()
  @IsNumber() @IsOptional()
  maxGroupSize?: number;

  @ApiPropertyOptional()
  @IsNumber() @IsOptional()
  minGroupSize?: number;

  @ApiPropertyOptional()
  @IsString() @IsOptional()
  difficultyLevel?: string;

  @ApiPropertyOptional({ type: [String] })
  @IsArray() @IsOptional()
  languages?: string[];

  @ApiPropertyOptional({ type: [String] })
  @IsArray() @IsOptional()
  includes?: string[];

  @ApiPropertyOptional({ type: [String] })
  @IsArray() @IsOptional()
  excludes?: string[];

  @ApiPropertyOptional({ type: [String] })
  @IsArray() @IsOptional()
  requirements?: string[];

  @ApiPropertyOptional()
  @IsOptional()
  itinerary?: any;
}

