import { ApiPropertyOptional } from '@nestjs/swagger';
import { payment_status } from '@prisma/client';
import { IsEnum, IsOptional, IsString } from 'class-validator';
import { PaginationDto } from '../../dto/pagination.dto';

export class AdminListPayoutsDto extends PaginationDto {
  @ApiPropertyOptional({ enum: payment_status })
  @IsOptional()
  @IsEnum(payment_status)
  status?: payment_status;

  @ApiPropertyOptional({ description: 'Merchant ID', format: 'uuid' })
  @IsOptional()
  @IsString()
  merchantId?: string;

  @ApiPropertyOptional({ description: 'Search payout number/reference' })
  @IsOptional()
  @IsString()
  search?: string;
}


