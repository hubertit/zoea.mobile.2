import { ApiProperty } from '@nestjs/swagger';
import { IsArray, IsEnum, ArrayMinSize } from 'class-validator';
import { user_role } from '@prisma/client';

export class AdminUpdateUserRolesDto {
  @ApiProperty({ type: [String], enum: user_role, description: 'List of roles' })
  @IsArray()
  @ArrayMinSize(1)
  @IsEnum(user_role, { each: true })
  roles: user_role[];
}

