import { ApiPropertyOptional } from '@nestjs/swagger';
import { booking_status, payment_status } from '@prisma/client';
import { IsEnum, IsNumber, IsOptional, IsString, MaxLength } from 'class-validator';

export class AdminUpdateBookingStatusDto {
  @ApiPropertyOptional({ enum: booking_status })
  @IsOptional()
  @IsEnum(booking_status)
  status?: booking_status;

  @ApiPropertyOptional({ enum: payment_status })
  @IsOptional()
  @IsEnum(payment_status)
  paymentStatus?: payment_status;

  @ApiPropertyOptional({ description: 'Internal notes or cancellation reason' })
  @IsOptional()
  @IsString()
  @MaxLength(500)
  notes?: string;

  @ApiPropertyOptional({ description: 'Refund amount if issuing refund' })
  @IsOptional()
  @IsNumber()
  refundAmount?: number;
}


