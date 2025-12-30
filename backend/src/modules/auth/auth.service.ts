import { Injectable, UnauthorizedException, ConflictException, BadRequestException, NotFoundException } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { ConfigService } from '@nestjs/config';
import * as bcrypt from 'bcrypt';
import { PrismaService } from '../../prisma/prisma.service';
import { RegisterDto, LoginDto, RequestPasswordResetDto, VerifyResetCodeDto, ResetPasswordDto } from './dto/auth.dto';

@Injectable()
export class AuthService {
  constructor(
    private prisma: PrismaService,
    private jwtService: JwtService,
    private configService: ConfigService,
  ) {}

  async register(dto: RegisterDto) {
    try {
      // Check if user exists
      const orConditions = [];
      if (dto.email) orConditions.push({ email: dto.email });
      if (dto.phoneNumber) orConditions.push({ phoneNumber: dto.phoneNumber });

      if (orConditions.length > 0) {
        const existingUser = await this.prisma.user.findFirst({
          where: { OR: orConditions },
        });

        if (existingUser) {
          throw new ConflictException('User with this email or phone already exists');
        }
      }

      // Hash password
      const passwordHash = await bcrypt.hash(dto.password, 10);

      // Create user
      const user = await this.prisma.user.create({
        data: {
          email: dto.email || null,
          phoneNumber: dto.phoneNumber || null,
          passwordHash,
          fullName: dto.fullName || null,
        },
        select: {
          id: true,
          email: true,
          phoneNumber: true,
          fullName: true,
          roles: true,
          createdAt: true,
        },
      });

      // Generate tokens
      const tokens = await this.generateTokens(user.id, user.email);

      return {
        user,
        ...tokens,
      };
    } catch (error) {
      console.error('Register error:', error);
      throw error;
    }
  }

  async login(dto: LoginDto) {
    // Find user
    const user = await this.prisma.user.findFirst({
      where: {
        OR: [
          { email: dto.identifier },
          { phoneNumber: dto.identifier },
        ],
      },
    });

    if (!user || !user.passwordHash) {
      throw new UnauthorizedException('Invalid credentials');
    }

    // Verify password
    const isPasswordValid = await bcrypt.compare(dto.password, user.passwordHash);
    if (!isPasswordValid) {
      throw new UnauthorizedException('Invalid credentials');
    }

    // Update last login
    await this.prisma.user.update({
      where: { id: user.id },
      data: { lastLoginAt: new Date() },
    });

    // Generate tokens
    const tokens = await this.generateTokens(user.id, user.email);

    return {
      user: {
        id: user.id,
        email: user.email,
        phoneNumber: user.phoneNumber,
        fullName: user.fullName,
        roles: user.roles,
      },
      ...tokens,
    };
  }

  async refreshToken(refreshToken: string) {
    try {
      const payload = this.jwtService.verify(refreshToken, {
        secret: this.configService.get('JWT_REFRESH_SECRET'),
      });

      const user = await this.prisma.user.findUnique({
        where: { id: payload.sub },
      });

      if (!user) {
        throw new UnauthorizedException('User not found');
      }

      return this.generateTokens(user.id, user.email);
    } catch {
      throw new UnauthorizedException('Invalid refresh token');
    }
  }

  async getProfile(userId: string) {
    const user = await this.prisma.user.findUnique({
      where: { id: userId },
      select: {
        id: true,
        email: true,
        phoneNumber: true,
        username: true,
        fullName: true,
        bio: true,
        gender: true,
        roles: true,
        accountType: true,
        isVerified: true,
        preferredCurrency: true,
        preferredLanguage: true,
        createdAt: true,
      },
    });

    if (!user) {
      throw new UnauthorizedException('User not found');
    }

    return user;
  }

  async requestPasswordReset(dto: RequestPasswordResetDto) {
    // Find user by email or phone
    const user = await this.prisma.user.findFirst({
      where: {
        OR: [
          { email: dto.identifier },
          { phoneNumber: dto.identifier },
        ],
      },
    });

    if (!user) {
      // Don't reveal if user exists for security
      return { success: true, message: 'If the account exists, a reset code has been sent.' };
    }

    // Generate reset code (placeholder: "0000")
    const resetCode = '0000';

    // Expire in 15 minutes
    const expiresAt = new Date();
    expiresAt.setMinutes(expiresAt.getMinutes() + 15);

    // Invalidate any existing reset tokens for this user
    await this.prisma.password_reset_tokens.updateMany({
      where: {
        user_id: user.id,
        used_at: null,
      },
      data: {
        used_at: new Date(), // Mark as used
      },
    });

    // Create new reset token
    await this.prisma.password_reset_tokens.create({
      data: {
        user_id: user.id,
        token: resetCode,
        expires_at: expiresAt,
      },
    });

    // TODO: Send SMS and email with reset code
    // For now, we just return success (code is "0000" as placeholder)

    return { 
      success: true, 
      message: 'If the account exists, a reset code has been sent.',
      // In development, we can return the code for testing
      // Remove this in production
      code: process.env.NODE_ENV === 'development' ? resetCode : undefined,
    };
  }

  async verifyResetCode(dto: VerifyResetCodeDto) {
    // Find user by email or phone
    const user = await this.prisma.user.findFirst({
      where: {
        OR: [
          { email: dto.identifier },
          { phoneNumber: dto.identifier },
        ],
      },
    });

    if (!user) {
      throw new NotFoundException('User not found');
    }

    // Find valid reset token
    const resetToken = await this.prisma.password_reset_tokens.findFirst({
      where: {
        user_id: user.id,
        token: dto.code,
        used_at: null,
        expires_at: {
          gte: new Date(), // Not expired
        },
      },
      orderBy: {
        created_at: 'desc', // Get most recent
      },
    });

    if (!resetToken) {
      throw new BadRequestException('Invalid or expired reset code');
    }

    return { 
      success: true, 
      message: 'Reset code verified successfully.',
    };
  }

  async resetPassword(dto: ResetPasswordDto) {
    // Find user by email or phone
    const user = await this.prisma.user.findFirst({
      where: {
        OR: [
          { email: dto.identifier },
          { phoneNumber: dto.identifier },
        ],
      },
    });

    if (!user) {
      throw new NotFoundException('User not found');
    }

    // Find valid reset token
    const resetToken = await this.prisma.password_reset_tokens.findFirst({
      where: {
        user_id: user.id,
        token: dto.code,
        used_at: null,
        expires_at: {
          gte: new Date(), // Not expired
        },
      },
      orderBy: {
        created_at: 'desc', // Get most recent
      },
    });

    if (!resetToken) {
      throw new BadRequestException('Invalid or expired reset code');
    }

    // Hash new password
    const passwordHash = await bcrypt.hash(dto.newPassword, 10);

    // Update user password
    await this.prisma.user.update({
      where: { id: user.id },
      data: { passwordHash },
    });

    // Mark reset token as used
    await this.prisma.password_reset_tokens.update({
      where: { id: resetToken.id },
      data: { used_at: new Date() },
    });

    return { 
      success: true, 
      message: 'Password reset successfully.',
    };
  }

  private async generateTokens(userId: string, email: string) {
    const payload = { sub: userId, email };

    const [accessToken, refreshToken] = await Promise.all([
      this.jwtService.signAsync(payload),
      this.jwtService.signAsync(payload, {
        secret: this.configService.get('JWT_REFRESH_SECRET'),
        expiresIn: this.configService.get('JWT_REFRESH_EXPIRATION') || '7d',
      }),
    ]);

    return {
      accessToken,
      refreshToken,
    };
  }
}

