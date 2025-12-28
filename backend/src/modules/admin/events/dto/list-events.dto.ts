import { ApiPropertyOptional } from '@nestjs/swagger';
import { event_status } from '@prisma/client';
import { IsEnum, IsOptional, IsString } from 'class-validator';
import { PaginationDto } from '../../dto/pagination.dto';

export class AdminListEventsDto extends PaginationDto {
  @ApiPropertyOptional({ description: 'Search by title or organizer' })
  @IsOptional()
  @IsString()
  search?: string;

  @ApiPropertyOptional({ enum: event_status })
  @IsOptional()
  @IsEnum(event_status)
  status?: event_status;

  @ApiPropertyOptional({ description: 'Organizer ID', format: 'uuid' })
  @IsOptional()
  @IsString()
  organizerId?: string;

  @ApiPropertyOptional({ description: 'City ID', format: 'uuid' })
  @IsOptional()
  @IsString()
  cityId?: string;
}


