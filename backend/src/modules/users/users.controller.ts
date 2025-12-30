import { Controller, Get, Post, Put, Delete, Param, Body, Query, UseGuards, Request } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth, ApiQuery, ApiBody } from '@nestjs/swagger';
import { UsersService } from './users.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import {
  UpdateUserDto,
  UpdateEmailDto,
  UpdatePhoneDto,
  ChangePasswordDto,
  UpdatePreferencesDto,
  CreateMerchantProfileDto,
  CreateOrganizerProfileDto,
  CreateTourOperatorProfileDto,
  UpdateMerchantProfileDto,
  UpdateOrganizerProfileDto,
  UpdateTourOperatorProfileDto,
} from './dto/user.dto';

@ApiTags('Users')
@Controller('users')
export class UsersController {
  constructor(private usersService: UsersService) {}

  @Get('me')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Get current user profile' })
  async getMe(@Request() req) {
    return this.usersService.findOne(req.user.id);
  }

  @Put('me')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Update current user profile' })
  async updateMe(@Request() req, @Body() data: UpdateUserDto) {
    return this.usersService.update(req.user.id, data);
  }

  @Put('me/email')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Update email address' })
  async updateEmail(@Request() req, @Body() data: UpdateEmailDto) {
    return this.usersService.updateEmail(req.user.id, data.email, data.password);
  }

  @Put('me/phone')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Update phone number' })
  async updatePhone(@Request() req, @Body() data: UpdatePhoneDto) {
    return this.usersService.updatePhone(req.user.id, data.phoneNumber, data.password);
  }

  @Put('me/password')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Change password' })
  async changePassword(@Request() req, @Body() data: ChangePasswordDto) {
    return this.usersService.changePassword(req.user.id, data.currentPassword, data.newPassword);
  }

  @Put('me/profile-image')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Update profile image' })
  @ApiBody({ schema: { properties: { mediaId: { type: 'string', format: 'uuid' } } } })
  async updateProfileImage(@Request() req, @Body('mediaId') mediaId: string) {
    return this.usersService.updateProfileImage(req.user.id, mediaId);
  }

  @Put('me/background-image')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Update background image' })
  @ApiBody({ schema: { properties: { mediaId: { type: 'string', format: 'uuid' } } } })
  async updateBackgroundImage(@Request() req, @Body('mediaId') mediaId: string) {
    return this.usersService.updateBackgroundImage(req.user.id, mediaId);
  }

  @Get('me/preferences')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Get user preferences' })
  async getPreferences(@Request() req) {
    return this.usersService.getPreferences(req.user.id);
  }

  @Get('me/preferences/completion-status')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Get data collection completion status' })
  async getCompletionStatus(@Request() req) {
    return this.usersService.getCompletionStatus(req.user.id);
  }

  @Put('me/preferences')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Update user preferences' })
  async updatePreferences(@Request() req, @Body() data: UpdatePreferencesDto) {
    return this.usersService.updatePreferences(req.user.id, data);
  }

  @Get('me/profile/completion')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Get profile completion percentage' })
  async getProfileCompletion(@Request() req) {
    return this.usersService.getProfileCompletion(req.user.id);
  }

  @Get('me/stats')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Get user statistics' })
  async getStats(@Request() req) {
    return this.usersService.getStats(req.user.id);
  }

  @Get('me/visited-places')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Get visited places' })
  @ApiQuery({ name: 'page', required: false, type: Number })
  @ApiQuery({ name: 'limit', required: false, type: Number })
  async getVisitedPlaces(@Request() req, @Query('page') page?: string, @Query('limit') limit?: string) {
    return this.usersService.getVisitedPlaces(req.user.id, page ? +page : 1, limit ? +limit : 20);
  }

  // ============ MERCHANT PROFILES ============
  @Get('me/businesses')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Get all my businesses (merchant profiles)' })
  async getMyBusinesses(@Request() req) {
    return this.usersService.getMerchantProfiles(req.user.id);
  }

  @Get('me/businesses/:id')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Get specific business by ID' })
  async getMyBusiness(@Request() req, @Param('id') id: string) {
    return this.usersService.getMerchantProfile(req.user.id, id);
  }

  @Post('me/businesses')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Create a new business (merchant profile)' })
  async createBusiness(@Request() req, @Body() data: CreateMerchantProfileDto) {
    return this.usersService.createMerchantProfile(req.user.id, data);
  }

  @Put('me/businesses/:id')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Update a business' })
  async updateBusiness(@Request() req, @Param('id') id: string, @Body() data: UpdateMerchantProfileDto) {
    return this.usersService.updateMerchantProfile(req.user.id, id, data);
  }

  @Delete('me/businesses/:id')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Delete a business' })
  async deleteBusiness(@Request() req, @Param('id') id: string) {
    return this.usersService.deleteMerchantProfile(req.user.id, id);
  }

  // ============ ORGANIZER PROFILES ============
  @Get('me/organizer-profiles')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Get all my organizer profiles' })
  async getMyOrganizerProfiles(@Request() req) {
    return this.usersService.getOrganizerProfiles(req.user.id);
  }

  @Get('me/organizer-profiles/:id')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Get specific organizer profile' })
  async getMyOrganizerProfile(@Request() req, @Param('id') id: string) {
    return this.usersService.getOrganizerProfile(req.user.id, id);
  }

  @Post('me/organizer-profiles')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Create organizer profile' })
  async createOrganizerProfile(@Request() req, @Body() data: CreateOrganizerProfileDto) {
    return this.usersService.createOrganizerProfile(req.user.id, data);
  }

  @Put('me/organizer-profiles/:id')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Update organizer profile' })
  async updateOrganizerProfile(@Request() req, @Param('id') id: string, @Body() data: UpdateOrganizerProfileDto) {
    return this.usersService.updateOrganizerProfile(req.user.id, id, data);
  }

  @Delete('me/organizer-profiles/:id')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Delete organizer profile' })
  async deleteOrganizerProfile(@Request() req, @Param('id') id: string) {
    return this.usersService.deleteOrganizerProfile(req.user.id, id);
  }

  // ============ TOUR OPERATOR PROFILES ============
  @Get('me/tour-operator-profiles')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Get all my tour operator profiles' })
  async getMyTourOperatorProfiles(@Request() req) {
    return this.usersService.getTourOperatorProfiles(req.user.id);
  }

  @Get('me/tour-operator-profiles/:id')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Get specific tour operator profile' })
  async getMyTourOperatorProfile(@Request() req, @Param('id') id: string) {
    return this.usersService.getTourOperatorProfile(req.user.id, id);
  }

  @Post('me/tour-operator-profiles')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Create tour operator profile' })
  async createTourOperatorProfile(@Request() req, @Body() data: CreateTourOperatorProfileDto) {
    return this.usersService.createTourOperatorProfile(req.user.id, data);
  }

  @Put('me/tour-operator-profiles/:id')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Update tour operator profile' })
  async updateTourOperatorProfile(@Request() req, @Param('id') id: string, @Body() data: UpdateTourOperatorProfileDto) {
    return this.usersService.updateTourOperatorProfile(req.user.id, id, data);
  }

  @Delete('me/tour-operator-profiles/:id')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Delete tour operator profile' })
  async deleteTourOperatorProfile(@Request() req, @Param('id') id: string) {
    return this.usersService.deleteTourOperatorProfile(req.user.id, id);
  }

  // ============ ACCOUNT ============
  @Delete('me')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Delete account (soft delete)' })
  async deleteAccount(@Request() req) {
    return this.usersService.deleteAccount(req.user.id);
  }

  // ============ PUBLIC PROFILES ============
  @Get('username/:username')
  @ApiOperation({ summary: 'Get user by username (public profile)' })
  async getByUsername(@Param('username') username: string) {
    return this.usersService.findByUsername(username);
  }

  @Get(':id')
  @ApiOperation({ summary: 'Get user by ID (public profile)' })
  async findOne(@Param('id') id: string) {
    return this.usersService.findOne(id);
  }
}
