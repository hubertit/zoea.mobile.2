import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { IsString, IsOptional, IsUUID, IsNumber, IsObject, ValidateNested } from 'class-validator';
import { Type } from 'class-transformer';

class LocationDto {
  @ApiProperty({ description: 'Latitude', example: -1.9403 })
  @IsNumber()
  lat: number;

  @ApiProperty({ description: 'Longitude', example: 30.0644 })
  @IsNumber()
  lng: number;
}

export class ChatDto {
  @ApiPropertyOptional({ 
    description: 'Conversation ID (omit to create new conversation)',
    example: '123e4567-e89b-12d3-a456-426614174000'
  })
  @IsUUID()
  @IsOptional()
  conversationId?: string;

  @ApiProperty({ 
    description: 'User message',
    example: 'Find 5 restaurants in Kigali'
  })
  @IsString()
  message: string;

  @ApiPropertyOptional({ 
    description: 'User location (for "near me" queries)',
    type: LocationDto
  })
  @IsOptional()
  @IsObject()
  @ValidateNested()
  @Type(() => LocationDto)
  location?: LocationDto;

  @ApiPropertyOptional({ 
    description: 'Country code to filter content (ISO 2-letter code)',
    example: 'RW'
  })
  @IsOptional()
  @IsString()
  countryCode?: string;
}

