import { ApiPropertyOptional } from '@nestjs/swagger';
import { approval_status } from '@prisma/client';
import { IsBoolean, IsEnum, IsOptional, IsString, MaxLength } from 'class-validator';

export class AdminUpdateMerchantStatusDto {
  @ApiPropertyOptional({ enum: approval_status })
  @IsOptional()
  @IsEnum(approval_status)
  registrationStatus?: approval_status;

  @ApiPropertyOptional({ description: 'Rejection reason if declined' })
  @IsOptional()
  @IsString()
  @MaxLength(500)
  rejectionReason?: string;

  @ApiPropertyOptional({ description: 'Revision notes for merchant' })
  @IsOptional()
  @IsString()
  @MaxLength(500)
  revisionNotes?: string;

  @ApiPropertyOptional({ description: 'Mark merchant as verified', type: Boolean })
  @IsOptional()
  @IsBoolean()
  isVerified?: boolean;
}


