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
  @ApiOperation({ summary: 'Register a new user' })
  async register(@Body() dto: RegisterDto) {
    return this.authService.register(dto);
  }

  @Post('login')
  @ApiOperation({ summary: 'Login user' })
  async login(@Body() dto: LoginDto) {
    return this.authService.login(dto);
  }

  @Post('refresh')
  @ApiOperation({ summary: 'Refresh access token' })
  async refresh(@Body() dto: RefreshTokenDto) {
    return this.authService.refreshToken(dto.refreshToken);
  }

  @Get('profile')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Get current user profile' })
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

