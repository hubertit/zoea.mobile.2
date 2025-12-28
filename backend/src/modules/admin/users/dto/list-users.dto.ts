import { ApiPropertyOptional } from '@nestjs/swagger';
import { Transform } from 'class-transformer';
import { IsEnum, IsOptional, IsString } from 'class-validator';
import { user_role, verification_status } from '@prisma/client';
import { PaginationDto } from '../../dto/pagination.dto';

export class AdminListUsersDto extends PaginationDto {
  @ApiPropertyOptional({ description: 'Search by name, email or phone' })
  @IsOptional()
  @IsString()
  search?: string;

  @ApiPropertyOptional({ enum: user_role, description: 'Filter by user role' })
  @IsOptional()
  @IsEnum(user_role, { each: false })
  role?: user_role;

  @ApiPropertyOptional({
    enum: verification_status,
    description: 'Filter by verification status',
  })
  @IsOptional()
  @IsEnum(verification_status, { each: false })
  verificationStatus?: verification_status;

  @ApiPropertyOptional({
    description: 'Filter by active state',
    type: Boolean,
  })
  @IsOptional()
  @Transform(({ value }) => {
    if (value === undefined || value === null) return undefined;
    return value === 'true' || value === true;
  })
  isActive?: boolean;
}

