import { IsEmail, IsString, IsOptional, MinLength } from 'class-validator';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';

export class RegisterDto {
  @ApiPropertyOptional()
  @IsEmail()
  @IsOptional()
  email?: string;

  @ApiPropertyOptional()
  @IsString()
  @IsOptional()
  phoneNumber?: string;

  @ApiProperty()
  @IsString()
  @MinLength(6)
  password: string;

  @ApiPropertyOptional()
  @IsString()
  @IsOptional()
  fullName?: string;
}

export class LoginDto {
  @ApiProperty({ description: 'Email or phone number' })
  @IsString()
  identifier: string;

  @ApiProperty()
  @IsString()
  password: string;
}

export class RefreshTokenDto {
  @ApiProperty()
  @IsString()
  refreshToken: string;
}

export class RequestPasswordResetDto {
  @ApiProperty({ 
    description: 'Email address or phone number',
    example: 'user@example.com' 
  })
  @IsString()
  identifier: string;
}

export class VerifyResetCodeDto {
  @ApiProperty({ 
    description: 'Email address or phone number',
    example: 'user@example.com' 
  })
  @IsString()
  identifier: string;

  @ApiProperty({ 
    description: 'Reset code sent to email/phone',
    example: '0000' 
  })
  @IsString()
  code: string;
}

export class ResetPasswordDto {
  @ApiProperty({ 
    description: 'Email address or phone number',
    example: 'user@example.com' 
  })
  @IsString()
  identifier: string;

  @ApiProperty({ 
    description: 'Reset code sent to email/phone',
    example: '0000' 
  })
  @IsString()
  code: string;

  @ApiProperty({ 
    description: 'New password (minimum 6 characters)',
    example: 'newPassword123',
    minLength: 6 
  })
  @IsString()
  @MinLength(6)
  newPassword: string;
}

