import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { IsString, IsNumber, IsOptional, Min } from 'class-validator';

export class DepositDto {
  @ApiProperty({ example: 50000, description: 'Amount to deposit' })
  @IsNumber()
  @Min(1)
  amount: number;

  @ApiPropertyOptional({ example: 'RWF', default: 'RWF' })
  @IsString() @IsOptional()
  currency?: string;

  @ApiPropertyOptional({ example: 'mobile_money', enum: ['mobile_money', 'card', 'bank_transfer'] })
  @IsString() @IsOptional()
  paymentMethod?: string;

  @ApiPropertyOptional({ example: 'Monthly savings deposit' })
  @IsString() @IsOptional()
  description?: string;
}

export class WithdrawDto {
  @ApiProperty({ example: 25000, description: 'Amount to withdraw' })
  @IsNumber()
  @Min(1)
  amount: number;

  @ApiPropertyOptional({ example: 'RWF', default: 'RWF' })
  @IsString() @IsOptional()
  currency?: string;

  @ApiPropertyOptional({ example: 'mobile_money', enum: ['mobile_money', 'bank_transfer'] })
  @IsString() @IsOptional()
  withdrawalMethod?: string;

  @ApiPropertyOptional({ example: '0788000000', description: 'Phone number or account for withdrawal' })
  @IsString() @IsOptional()
  destinationAccount?: string;

  @ApiPropertyOptional({ example: 'Cash withdrawal' })
  @IsString() @IsOptional()
  description?: string;
}

export class PayDto {
  @ApiProperty({ example: 15000, description: 'Amount to pay' })
  @IsNumber()
  @Min(1)
  amount: number;

  @ApiProperty({ example: 'Payment for hotel booking' })
  @IsString()
  description: string;

  @ApiPropertyOptional({ example: 'RWF', default: 'RWF' })
  @IsString() @IsOptional()
  currency?: string;

  @ApiPropertyOptional({ example: 'booking', enum: ['booking', 'event', 'tour', 'listing', 'other'] })
  @IsString() @IsOptional()
  paymentType?: string;

  @ApiPropertyOptional({ description: 'Booking ID if paying for a booking' })
  @IsString() @IsOptional()
  bookingId?: string;

  @ApiPropertyOptional({ description: 'Merchant ID if paying a merchant directly' })
  @IsString() @IsOptional()
  merchantId?: string;
}

