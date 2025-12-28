import { ApiPropertyOptional } from '@nestjs/swagger';
import { payment_status } from '@prisma/client';
import { IsEnum, IsOptional, IsString, MaxLength } from 'class-validator';

export class AdminUpdatePayoutStatusDto {
  @ApiPropertyOptional({ enum: payment_status })
  @IsOptional()
  @IsEnum(payment_status)
  status?: payment_status;

  @ApiPropertyOptional({ description: 'External payment reference' })
  @IsOptional()
  @IsString()
  @MaxLength(255)
  paymentReference?: string;

  @ApiPropertyOptional({ description: 'Internal notes' })
  @IsOptional()
  @IsString()
  @MaxLength(500)
  notes?: string;
}


