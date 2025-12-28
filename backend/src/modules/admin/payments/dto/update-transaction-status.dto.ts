import { ApiProperty } from '@nestjs/swagger';
import { transaction_status } from '@prisma/client';
import { IsEnum } from 'class-validator';

export class AdminUpdateTransactionStatusDto {
  @ApiProperty({ enum: transaction_status })
  @IsEnum(transaction_status)
  status: transaction_status;
}


