import { ApiPropertyOptional } from '@nestjs/swagger';
import { booking_status, payment_status } from '@prisma/client';
import { Transform } from 'class-transformer';
import { IsDate, IsEnum, IsOptional, IsString } from 'class-validator';
import { PaginationDto } from '../../dto/pagination.dto';

export class AdminListBookingsDto extends PaginationDto {
  @ApiPropertyOptional({ description: 'Search booking number, user email/phone' })
  @IsOptional()
  @IsString()
  search?: string;

  @ApiPropertyOptional({ enum: booking_status })
  @IsOptional()
  @IsEnum(booking_status)
  status?: booking_status;

  @ApiPropertyOptional({ enum: payment_status })
  @IsOptional()
  @IsEnum(payment_status)
  paymentStatus?: payment_status;

  @ApiPropertyOptional({ description: 'Merchant ID', format: 'uuid' })
  @IsOptional()
  @IsString()
  merchantId?: string;

  @ApiPropertyOptional({ description: 'User ID', format: 'uuid' })
  @IsOptional()
  @IsString()
  userId?: string;

  @ApiPropertyOptional({ description: 'Start date filter (inclusive)', type: String, format: 'date-time' })
  @IsOptional()
  @Transform(({ value }) => (value ? new Date(value) : undefined))
  @IsDate()
  startDate?: Date;

  @ApiPropertyOptional({ description: 'End date filter (inclusive)', type: String, format: 'date-time' })
  @IsOptional()
  @Transform(({ value }) => (value ? new Date(value) : undefined))
  @IsDate()
  endDate?: Date;
}


