import { ApiPropertyOptional } from '@nestjs/swagger';
import { transaction_status, transaction_type } from '@prisma/client';
import { Transform } from 'class-transformer';
import { IsEnum, IsOptional, IsString } from 'class-validator';
import { PaginationDto } from '../../dto/pagination.dto';

export class AdminListTransactionsDto extends PaginationDto {
  @ApiPropertyOptional({ enum: transaction_type })
  @IsOptional()
  @IsEnum(transaction_type)
  type?: transaction_type;

  @ApiPropertyOptional({ enum: transaction_status })
  @IsOptional()
  @IsEnum(transaction_status)
  status?: transaction_status;

  @ApiPropertyOptional({ description: 'Merchant ID', format: 'uuid' })
  @IsOptional()
  @IsString()
  merchantId?: string;

  @ApiPropertyOptional({ description: 'User ID', format: 'uuid' })
  @IsOptional()
  @IsString()
  userId?: string;

  @ApiPropertyOptional({ description: 'Search by reference/description' })
  @IsOptional()
  @IsString()
  search?: string;
}


