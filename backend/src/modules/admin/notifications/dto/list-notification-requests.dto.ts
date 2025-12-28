import { ApiPropertyOptional } from '@nestjs/swagger';
import { approval_status } from '@prisma/client';
import { IsEnum, IsOptional, IsString } from 'class-validator';
import { PaginationDto } from '../../dto/pagination.dto';

export class AdminListNotificationRequestsDto extends PaginationDto {
  @ApiPropertyOptional({ enum: approval_status })
  @IsOptional()
  @IsEnum(approval_status)
  status?: approval_status;

  @ApiPropertyOptional({ description: 'Requester ID', format: 'uuid' })
  @IsOptional()
  @IsString()
  requesterId?: string;

  @ApiPropertyOptional({ description: 'Search by title/body' })
  @IsOptional()
  @IsString()
  search?: string;
}


