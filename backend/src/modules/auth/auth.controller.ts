import { Controller, Post, Get, Body, UseGuards, Request, HttpCode, HttpStatus } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth, ApiResponse, ApiBody } from '@nestjs/swagger';
import { AuthService } from './auth.service';
import { RegisterDto, LoginDto, RefreshTokenDto, RequestPasswordResetDto, VerifyResetCodeDto, ResetPasswordDto } from './dto/auth.dto';
import { JwtAuthGuard } from './guards/jwt-auth.guard';

@ApiTags('Auth')
@Controller('auth')
export class AuthController {
  constructor(private authService: AuthService) {}

  @Post('register')
  @HttpCode(HttpStatus.CREATED)
  @ApiOperation({ 
    summary: 'Register a new user',
    description: 'Creates a new user account. Requires either email or phone number, and a password (minimum 6 characters). User type defaults to "customer". Returns JWT access and refresh tokens upon successful registration.'
  })
  @ApiBody({ type: RegisterDto })
  @ApiResponse({ 
    status: 201, 
    description: 'User registered successfully',
    schema: {
      type: 'object',
      properties: {
        user: { 
          type: 'object',
          properties: {
            id: { type: 'string', format: 'uuid', example: '123e4567-e89b-12d3-a456-426614174000' },
            email: { type: 'string', example: 'user@example.com' },
            phoneNumber: { type: 'string', example: '+250788000000' },
            fullName: { type: 'string', example: 'John Doe' },
            userType: { type: 'string', enum: ['customer', 'merchant', 'organizer', 'tour_operator'], example: 'customer' }
          }
        },
        accessToken: { type: 'string', example: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...' },
        refreshToken: { type: 'string', example: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...' }
      }
    }
  })
  @ApiResponse({ status: 400, description: 'Bad request - Email or phone already exists, or invalid input' })
  @ApiResponse({ status: 409, description: 'Conflict - User with this email or phone already exists' })
  async register(@Body() dto: RegisterDto) {
    return this.authService.register(dto);
  }

  @Post('login')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ 
    summary: 'Login user',
    description: 'Authenticates a user with email/phone and password. Returns JWT access and refresh tokens. The identifier can be either an email address or phone number.'
  })
  @ApiBody({ type: LoginDto })
  @ApiResponse({ 
    status: 200, 
    description: 'Login successful',
    schema: {
      type: 'object',
      properties: {
        user: { 
          type: 'object',
          properties: {
            id: { type: 'string', format: 'uuid', example: '123e4567-e89b-12d3-a456-426614174000' },
            email: { type: 'string', example: 'user@example.com' },
            phoneNumber: { type: 'string', example: '+250788000000' },
            fullName: { type: 'string', example: 'John Doe' }
          }
        },
        accessToken: { type: 'string', example: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...' },
        refreshToken: { type: 'string', example: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...' }
      }
    }
  })
  @ApiResponse({ status: 401, description: 'Unauthorized - Invalid credentials' })
  @ApiResponse({ status: 404, description: 'User not found' })
  async login(@Body() dto: LoginDto) {
    return this.authService.login(dto);
  }

  @Post('refresh')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ 
    summary: 'Refresh access token',
    description: 'Generates a new access token using a valid refresh token. Use this endpoint when the access token expires. The refresh token must be valid and not expired.'
  })
  @ApiBody({ type: RefreshTokenDto })
  @ApiResponse({ 
    status: 200, 
    description: 'Token refreshed successfully',
    schema: {
      type: 'object',
      properties: {
        accessToken: { type: 'string', example: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...' },
        refreshToken: { type: 'string', example: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...', description: 'New refresh token (may be same or rotated)' }
      }
    }
  })
  @ApiResponse({ status: 401, description: 'Unauthorized - Invalid or expired refresh token' })
  async refresh(@Body() dto: RefreshTokenDto) {
    return this.authService.refreshToken(dto.refreshToken);
  }

  @Get('profile')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ 
    summary: 'Get current user profile',
    description: 'Retrieves the authenticated user\'s complete profile including preferences, demographics, and statistics. Requires a valid JWT access token.'
  })
  @ApiResponse({ 
    status: 200, 
    description: 'User profile retrieved successfully',
    schema: {
      type: 'object',
      properties: {
        id: { type: 'string', format: 'uuid', example: '123e4567-e89b-12d3-a456-426614174000' },
        email: { type: 'string', example: 'user@example.com' },
        phoneNumber: { type: 'string', example: '+250788000000' },
        fullName: { type: 'string', example: 'John Doe' },
        userType: { type: 'string', enum: ['customer', 'merchant', 'organizer', 'tour_operator'], example: 'customer' }
      }
    }
  })
  @ApiResponse({ status: 401, description: 'Unauthorized - Invalid or missing token' })
  @ApiResponse({ status: 404, description: 'User not found' })
  async getProfile(@Request() req) {
    return this.authService.getProfile(req.user.id);
  }

  @Post('password/reset/request')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ 
    summary: 'Request password reset',
    description: 'Sends a reset code to the user\'s email or phone. Currently uses placeholder code "0000". SMS and email notifications will be implemented later.'
  })
  @ApiBody({ type: RequestPasswordResetDto })
  @ApiResponse({ 
    status: 200, 
    description: 'Reset code sent successfully (if account exists)',
    schema: {
      type: 'object',
      properties: {
        success: { type: 'boolean', example: true },
        message: { type: 'string', example: 'If the account exists, a reset code has been sent.' },
        code: { type: 'string', example: '0000', description: 'Only returned in development mode' }
      }
    }
  })
  async requestPasswordReset(@Body() dto: RequestPasswordResetDto) {
    return this.authService.requestPasswordReset(dto);
  }

  @Post('password/reset/verify')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ 
    summary: 'Verify reset code',
    description: 'Verifies that the reset code is valid and not expired. Code expires after 15 minutes.'
  })
  @ApiBody({ type: VerifyResetCodeDto })
  @ApiResponse({ 
    status: 200, 
    description: 'Reset code verified successfully',
    schema: {
      type: 'object',
      properties: {
        success: { type: 'boolean', example: true },
        message: { type: 'string', example: 'Reset code verified successfully.' }
      }
    }
  })
  @ApiResponse({ status: 400, description: 'Invalid or expired reset code' })
  @ApiResponse({ status: 404, description: 'User not found' })
  async verifyResetCode(@Body() dto: VerifyResetCodeDto) {
    return this.authService.verifyResetCode(dto);
  }

  @Post('password/reset')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ 
    summary: 'Reset password',
    description: 'Resets the user\'s password using a verified reset code. The reset code must be valid and not expired.'
  })
  @ApiBody({ type: ResetPasswordDto })
  @ApiResponse({ 
    status: 200, 
    description: 'Password reset successfully',
    schema: {
      type: 'object',
      properties: {
        success: { type: 'boolean', example: true },
        message: { type: 'string', example: 'Password reset successfully.' }
      }
    }
  })
  @ApiResponse({ status: 400, description: 'Invalid or expired reset code' })
  @ApiResponse({ status: 404, description: 'User not found' })
  async resetPassword(@Body() dto: ResetPasswordDto) {
    return this.authService.resetPassword(dto);
  }
}

