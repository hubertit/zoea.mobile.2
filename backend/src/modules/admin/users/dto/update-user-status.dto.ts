import { ApiPropertyOptional } from '@nestjs/swagger';
import { IsBoolean, IsEnum, IsOptional } from 'class-validator';
import { verification_status } from '@prisma/client';

export class AdminUpdateUserStatusDto {
  @ApiPropertyOptional({ description: 'Activate or deactivate user' })
  @IsOptional()
  @IsBoolean()
  isActive?: boolean;

  @ApiPropertyOptional({ description: 'Block or unblock user' })
  @IsOptional()
  @IsBoolean()
  isBlocked?: boolean;

  @ApiPropertyOptional({
    enum: verification_status,
    description: 'Update verification status',
  })
  @IsOptional()
  @IsEnum(verification_status)
  verificationStatus?: verification_status;
}

