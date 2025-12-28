import { ApiPropertyOptional } from '@nestjs/swagger';
import { event_status } from '@prisma/client';
import { IsBoolean, IsEnum, IsOptional, IsString, MaxLength } from 'class-validator';

export class AdminUpdateEventStatusDto {
  @ApiPropertyOptional({ enum: event_status })
  @IsOptional()
  @IsEnum(event_status)
  status?: event_status;

  @ApiPropertyOptional({ description: 'Block event from being visible', type: Boolean })
  @IsOptional()
  @IsBoolean()
  isBlocked?: boolean;

  @ApiPropertyOptional({ description: 'Cancellation / review notes' })
  @IsOptional()
  @IsString()
  @MaxLength(500)
  reviewNotes?: string;
}


