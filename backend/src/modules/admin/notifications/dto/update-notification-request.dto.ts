import { ApiPropertyOptional } from '@nestjs/swagger';
import { approval_status } from '@prisma/client';
import { IsEnum, IsOptional, IsString, MaxLength } from 'class-validator';

export class AdminUpdateNotificationRequestDto {
  @ApiPropertyOptional({ enum: approval_status })
  @IsOptional()
  @IsEnum(approval_status)
  status?: approval_status;

  @ApiPropertyOptional({ description: 'Rejection reason' })
  @IsOptional()
  @IsString()
  @MaxLength(500)
  rejectionReason?: string;

  @ApiPropertyOptional({ description: 'Revision notes' })
  @IsOptional()
  @IsString()
  @MaxLength(500)
  revisionNotes?: string;
}


