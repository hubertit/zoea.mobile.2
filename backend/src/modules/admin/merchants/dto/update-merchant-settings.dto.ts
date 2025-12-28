import { ApiPropertyOptional } from '@nestjs/swagger';
import { Transform } from 'class-transformer';
import { IsBoolean, IsNumber, IsObject, IsOptional, IsString, Max, Min } from 'class-validator';

export class AdminUpdateMerchantSettingsDto {
  @ApiPropertyOptional({ description: 'Commission rate percentage (e.g. 12.5)' })
  @IsOptional()
  @Transform(({ value }) => (value !== undefined ? Number(value) : value))
  @IsNumber()
  @Min(0)
  @Max(100)
  commissionRate?: number;

  @ApiPropertyOptional({ description: 'Payout schedule e.g. weekly, monthly' })
  @IsOptional()
  @IsString()
  payoutSchedule?: string;

  @ApiPropertyOptional({ description: 'Update stored bank account info' })
  @IsOptional()
  @IsObject()
  bankAccountInfo?: Record<string, any>;

  @ApiPropertyOptional({ description: 'Mark as verified/unverified', type: Boolean })
  @IsOptional()
  @IsBoolean()
  isVerified?: boolean;
}


