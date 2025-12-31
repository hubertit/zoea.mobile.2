import { Controller, Get, Post, Put, Delete, Param, Body, Query, UseGuards, Request, HttpCode, HttpStatus } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth, ApiQuery, ApiBody, ApiParam, ApiResponse } from '@nestjs/swagger';
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
  @ApiOperation({ 
    summary: 'Get current user profile',
    description: 'Retrieves the authenticated user\'s complete profile including preferences, demographics, and statistics. Age range is automatically calculated from dateOfBirth if available.'
  })
  @ApiResponse({ status: 200, description: 'User profile retrieved successfully' })
  @ApiResponse({ status: 401, description: 'Unauthorized - Invalid or missing token' })
  @ApiResponse({ status: 404, description: 'User not found' })
  async getMe(@Request() req) {
    return this.usersService.findOne(req.user.id);
  }

  @Put('me')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ 
    summary: 'Update current user profile',
    description: 'Updates the authenticated user\'s profile information. All fields are optional. If dateOfBirth is provided, ageRange will be automatically calculated and ageRangeUpdatedAt will be set.'
  })
  @ApiResponse({ status: 200, description: 'Profile updated successfully' })
  @ApiResponse({ status: 401, description: 'Unauthorized - Invalid or missing token' })
  @ApiResponse({ status: 400, description: 'Bad request - Invalid input data' })
  async updateMe(@Request() req, @Body() data: UpdateUserDto) {
    return this.usersService.update(req.user.id, data);
  }

  @Put('me/email')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ 
    summary: 'Update email address',
    description: 'Updates the user\'s email address. Requires current password for verification. Email verification status will be reset after update.'
  })
  @ApiResponse({ status: 200, description: 'Email updated successfully' })
  @ApiResponse({ status: 400, description: 'Bad request - Email already in use or invalid password' })
  @ApiResponse({ status: 401, description: 'Unauthorized - Invalid or missing token' })
  async updateEmail(@Request() req, @Body() data: UpdateEmailDto) {
    return this.usersService.updateEmail(req.user.id, data.email, data.password);
  }

  @Put('me/phone')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ 
    summary: 'Update phone number',
    description: 'Updates the user\'s phone number. Requires current password for verification. Phone verification status will be reset after update.'
  })
  @ApiResponse({ status: 200, description: 'Phone number updated successfully' })
  @ApiResponse({ status: 400, description: 'Bad request - Phone number already in use or invalid password' })
  @ApiResponse({ status: 401, description: 'Unauthorized - Invalid or missing token' })
  async updatePhone(@Request() req, @Body() data: UpdatePhoneDto) {
    return this.usersService.updatePhone(req.user.id, data.phoneNumber, data.password);
  }

  @Put('me/password')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ 
    summary: 'Change password',
    description: 'Changes the user\'s password. Requires current password for verification. New password must be at least 6 characters long.'
  })
  @ApiResponse({ status: 200, description: 'Password changed successfully', schema: { type: 'object', properties: { success: { type: 'boolean', example: true } } } })
  @ApiResponse({ status: 400, description: 'Bad request - Current password is incorrect' })
  @ApiResponse({ status: 401, description: 'Unauthorized - Invalid or missing token' })
  async changePassword(@Request() req, @Body() data: ChangePasswordDto) {
    return this.usersService.changePassword(req.user.id, data.currentPassword, data.newPassword);
  }

  @Put('me/profile-image')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ 
    summary: 'Update profile image',
    description: 'Updates the user\'s profile image. Requires a mediaId from a previously uploaded image. The media must exist in the system.'
  })
  @ApiBody({ 
    schema: { 
      type: 'object',
      properties: { 
        mediaId: { 
          type: 'string', 
          format: 'uuid',
          example: '123e4567-e89b-12d3-a456-426614174000',
          description: 'UUID of the media file uploaded via /api/media endpoint'
        } 
      },
      required: ['mediaId']
    } 
  })
  @ApiResponse({ status: 200, description: 'Profile image updated successfully' })
  @ApiResponse({ status: 400, description: 'Bad request - Invalid mediaId' })
  @ApiResponse({ status: 401, description: 'Unauthorized - Invalid or missing token' })
  @ApiResponse({ status: 404, description: 'Media not found' })
  async updateProfileImage(@Request() req, @Body('mediaId') mediaId: string) {
    return this.usersService.updateProfileImage(req.user.id, mediaId);
  }

  @Put('me/background-image')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ 
    summary: 'Update background image',
    description: 'Updates the user\'s profile background image. Requires a mediaId from a previously uploaded image. The media must exist in the system.'
  })
  @ApiBody({ 
    schema: { 
      type: 'object',
      properties: { 
        mediaId: { 
          type: 'string', 
          format: 'uuid',
          example: '123e4567-e89b-12d3-a456-426614174000',
          description: 'UUID of the media file uploaded via /api/media endpoint'
        } 
      },
      required: ['mediaId']
    } 
  })
  @ApiResponse({ status: 200, description: 'Background image updated successfully' })
  @ApiResponse({ status: 400, description: 'Bad request - Invalid mediaId' })
  @ApiResponse({ status: 401, description: 'Unauthorized - Invalid or missing token' })
  @ApiResponse({ status: 404, description: 'Media not found' })
  async updateBackgroundImage(@Request() req, @Body('mediaId') mediaId: string) {
    return this.usersService.updateBackgroundImage(req.user.id, mediaId);
  }

  @Get('me/preferences')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ 
    summary: 'Get user preferences',
    description: 'Retrieves all user preferences including UX-first data collection fields. If dateOfBirth exists, ageRange is automatically calculated and returned as calculatedAgeRange. The response includes ageRangeSource indicating whether the age range is calculated from dateOfBirth or user-selected.'
  })
  @ApiResponse({ 
    status: 200, 
    description: 'Preferences retrieved successfully',
    schema: {
      type: 'object',
      properties: {
        preferredCurrency: { type: 'string', example: 'RWF' },
        preferredLanguage: { type: 'string', example: 'en' },
        countryOfOrigin: { type: 'string', example: 'RW' },
        userType: { type: 'string', example: 'resident' },
        ageRange: { type: 'string', example: '26-35' },
        calculatedAgeRange: { type: 'string', example: '26-35' },
        ageRangeSource: { type: 'string', enum: ['calculated', 'user-selected'] }
      }
    }
  })
  @ApiResponse({ status: 401, description: 'Unauthorized - Invalid or missing token' })
  @ApiResponse({ status: 404, description: 'User not found' })
  async getPreferences(@Request() req) {
    return this.usersService.getPreferences(req.user.id);
  }

  @Get('me/preferences/completion-status')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ 
    summary: 'Get data collection completion status',
    description: 'Returns the completion status of mandatory and optional user data collection fields. Useful for determining which data still needs to be collected from the user.'
  })
  @ApiResponse({ 
    status: 200, 
    description: 'Completion status retrieved successfully',
    schema: {
      type: 'object',
      properties: {
        mandatory: {
          type: 'object',
          properties: {
            completed: { type: 'boolean', example: true },
            missing: { type: 'array', items: { type: 'string' }, example: ['visitPurpose'] }
          }
        },
        optional: {
          type: 'object',
          properties: {
            completed: { type: 'boolean', example: false },
            missing: { type: 'array', items: { type: 'string' }, example: ['ageRange', 'gender'] }
          }
        }
      }
    }
  })
  @ApiResponse({ status: 401, description: 'Unauthorized - Invalid or missing token' })
  async getCompletionStatus(@Request() req) {
    return this.usersService.getCompletionStatus(req.user.id);
  }

  @Put('me/preferences')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ 
    summary: 'Update user preferences',
    description: 'Updates user preferences including all UX-first data collection fields. All fields are optional. If ageRange is provided, ageRangeUpdatedAt will be automatically set. If dataCollectionCompletedAt is provided, it will be converted to a DateTime. Note: lengthOfStay should only be set for visitors, not residents.'
  })
  @ApiResponse({ 
    status: 200, 
    description: 'Preferences updated successfully',
    schema: {
      type: 'object',
      properties: {
        calculatedAgeRange: { type: 'string', example: '26-35' },
        ageRangeSource: { type: 'string', enum: ['calculated', 'user-selected'] }
      }
    }
  })
  @ApiResponse({ status: 400, description: 'Bad request - Invalid input data or validation failed' })
  @ApiResponse({ status: 401, description: 'Unauthorized - Invalid or missing token' })
  async updatePreferences(@Request() req, @Body() data: UpdatePreferencesDto) {
    return this.usersService.updatePreferences(req.user.id, data);
  }

  @Get('me/profile/completion')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ 
    summary: 'Get profile completion percentage',
    description: 'Returns the overall profile completion percentage and list of missing fields. Completion is calculated based on mandatory and optional fields. For visitors, lengthOfStay is included in the calculation; for residents, it is excluded.'
  })
  @ApiResponse({ 
    status: 200, 
    description: 'Profile completion retrieved successfully',
    schema: {
      type: 'object',
      properties: {
        percentage: { type: 'number', example: 75, description: 'Completion percentage (0-100)' },
        missingFields: { 
          type: 'array', 
          items: { type: 'string' }, 
          example: ['ageRange', 'gender', 'interests'],
          description: 'List of missing optional fields'
        }
      }
    }
  })
  @ApiResponse({ status: 401, description: 'Unauthorized - Invalid or missing token' })
  async getProfileCompletion(@Request() req) {
    return this.usersService.getProfileCompletion(req.user.id);
  }

  @Get('me/stats')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ 
    summary: 'Get user statistics',
    description: 'Retrieves aggregated statistics for the authenticated user including booking count, review count, favorites count, and visited places count.'
  })
  @ApiResponse({ 
    status: 200, 
    description: 'Statistics retrieved successfully',
    schema: {
      type: 'object',
      properties: {
        bookings: { type: 'number', example: 12, description: 'Number of completed bookings' },
        reviews: { type: 'number', example: 5, description: 'Number of reviews written' },
        favorites: { type: 'number', example: 23, description: 'Number of favorited items' },
        visitedPlaces: { type: 'number', example: 12, description: 'Number of visited places (same as bookings)' }
      }
    }
  })
  @ApiResponse({ status: 401, description: 'Unauthorized - Invalid or missing token' })
  async getStats(@Request() req) {
    return this.usersService.getStats(req.user.id);
  }

  @Get('me/visited-places')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ 
    summary: 'Get visited places',
    description: 'Retrieves a paginated list of places the user has visited (based on completed bookings). Results are ordered by most recent first.'
  })
  @ApiQuery({ name: 'page', required: false, type: Number, example: 1, description: 'Page number (default: 1)' })
  @ApiQuery({ name: 'limit', required: false, type: Number, example: 20, description: 'Items per page (default: 20, max: 100)' })
  @ApiResponse({ 
    status: 200, 
    description: 'Visited places retrieved successfully',
    schema: {
      type: 'object',
      properties: {
        data: { type: 'array', items: { type: 'object' } },
        meta: {
          type: 'object',
          properties: {
            total: { type: 'number', example: 45 },
            page: { type: 'number', example: 1 },
            limit: { type: 'number', example: 20 },
            totalPages: { type: 'number', example: 3 }
          }
        }
      }
    }
  })
  @ApiResponse({ status: 401, description: 'Unauthorized - Invalid or missing token' })
  async getVisitedPlaces(@Request() req, @Query('page') page?: string, @Query('limit') limit?: string) {
    return this.usersService.getVisitedPlaces(req.user.id, page ? +page : 1, limit ? +limit : 20);
  }

  // ============ MERCHANT PROFILES ============
  @Get('me/businesses')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ 
    summary: 'Get all my businesses (merchant profiles)',
    description: 'Retrieves all merchant profiles (businesses) associated with the authenticated user. Returns an array of business profiles with details like business name, type, registration info, and contact details.'
  })
  @ApiResponse({ status: 200, description: 'Businesses retrieved successfully', schema: { type: 'array', items: { type: 'object' } } })
  @ApiResponse({ status: 401, description: 'Unauthorized - Invalid or missing token' })
  async getMyBusinesses(@Request() req) {
    return this.usersService.getMerchantProfiles(req.user.id);
  }

  @Get('me/businesses/:id')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Get specific business by ID' })
  @ApiParam({ name: 'id', type: 'string', example: '123e4567-e89b-12d3-a456-426614174000', description: 'Business (merchant profile) UUID' })
  @ApiResponse({ status: 200, description: 'Business retrieved successfully' })
  @ApiResponse({ status: 401, description: 'Unauthorized - Invalid or missing token' })
  @ApiResponse({ status: 404, description: 'Business not found or does not belong to user' })
  async getMyBusiness(@Request() req, @Param('id') id: string) {
    return this.usersService.getMerchantProfile(req.user.id, id);
  }

  @Post('me/businesses')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @HttpCode(HttpStatus.CREATED)
  @ApiOperation({ 
    summary: 'Create a new business (merchant profile)',
    description: 'Creates a new merchant profile (business) for the authenticated user. Required fields: businessName and businessType. Optional fields include registration number, tax ID, contact info, and location.'
  })
  @ApiResponse({ status: 201, description: 'Business created successfully' })
  @ApiResponse({ status: 400, description: 'Bad request - Invalid input data or missing required fields' })
  @ApiResponse({ status: 401, description: 'Unauthorized - Invalid or missing token' })
  async createBusiness(@Request() req, @Body() data: CreateMerchantProfileDto) {
    return this.usersService.createMerchantProfile(req.user.id, data);
  }

  @Put('me/businesses/:id')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ 
    summary: 'Update a business',
    description: 'Updates an existing merchant profile (business). All fields are optional. Only fields provided will be updated. The business must belong to the authenticated user.'
  })
  @ApiParam({ name: 'id', type: 'string', example: '123e4567-e89b-12d3-a456-426614174000', description: 'Business (merchant profile) UUID' })
  @ApiResponse({ status: 200, description: 'Business updated successfully' })
  @ApiResponse({ status: 400, description: 'Bad request - Invalid input data' })
  @ApiResponse({ status: 401, description: 'Unauthorized - Invalid or missing token' })
  @ApiResponse({ status: 404, description: 'Business not found or does not belong to user' })
  async updateBusiness(@Request() req, @Param('id') id: string, @Body() data: UpdateMerchantProfileDto) {
    return this.usersService.updateMerchantProfile(req.user.id, id, data);
  }

  @Delete('me/businesses/:id')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ 
    summary: 'Delete a business',
    description: 'Deletes a merchant profile (business). The business must belong to the authenticated user. This is a permanent deletion.'
  })
  @ApiParam({ name: 'id', type: 'string', example: '123e4567-e89b-12d3-a456-426614174000', description: 'Business (merchant profile) UUID' })
  @ApiResponse({ status: 200, description: 'Business deleted successfully' })
  @ApiResponse({ status: 401, description: 'Unauthorized - Invalid or missing token' })
  @ApiResponse({ status: 404, description: 'Business not found or does not belong to user' })
  async deleteBusiness(@Request() req, @Param('id') id: string) {
    return this.usersService.deleteMerchantProfile(req.user.id, id);
  }

  // ============ ORGANIZER PROFILES ============
  @Get('me/organizer-profiles')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ 
    summary: 'Get all my organizer profiles',
    description: 'Retrieves all event organizer profiles associated with the authenticated user. Returns an array of organizer profiles with organization details and contact information.'
  })
  @ApiResponse({ status: 200, description: 'Organizer profiles retrieved successfully', schema: { type: 'array', items: { type: 'object' } } })
  @ApiResponse({ status: 401, description: 'Unauthorized - Invalid or missing token' })
  async getMyOrganizerProfiles(@Request() req) {
    return this.usersService.getOrganizerProfiles(req.user.id);
  }

  @Get('me/organizer-profiles/:id')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ 
    summary: 'Get specific organizer profile',
    description: 'Retrieves a specific event organizer profile by ID. The profile must belong to the authenticated user.'
  })
  @ApiParam({ name: 'id', type: 'string', example: '123e4567-e89b-12d3-a456-426614174000', description: 'Organizer profile UUID' })
  @ApiResponse({ status: 200, description: 'Organizer profile retrieved successfully' })
  @ApiResponse({ status: 401, description: 'Unauthorized - Invalid or missing token' })
  @ApiResponse({ status: 404, description: 'Organizer profile not found or does not belong to user' })
  async getMyOrganizerProfile(@Request() req, @Param('id') id: string) {
    return this.usersService.getOrganizerProfile(req.user.id, id);
  }

  @Post('me/organizer-profiles')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @HttpCode(HttpStatus.CREATED)
  @ApiOperation({ 
    summary: 'Create organizer profile',
    description: 'Creates a new event organizer profile for the authenticated user. Required field: organizationName. Optional fields include organization type, description, contact info, and location.'
  })
  @ApiResponse({ status: 201, description: 'Organizer profile created successfully' })
  @ApiResponse({ status: 400, description: 'Bad request - Invalid input data or missing required fields' })
  @ApiResponse({ status: 401, description: 'Unauthorized - Invalid or missing token' })
  async createOrganizerProfile(@Request() req, @Body() data: CreateOrganizerProfileDto) {
    return this.usersService.createOrganizerProfile(req.user.id, data);
  }

  @Put('me/organizer-profiles/:id')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ 
    summary: 'Update organizer profile',
    description: 'Updates an existing event organizer profile. All fields are optional. Only fields provided will be updated. The profile must belong to the authenticated user.'
  })
  @ApiParam({ name: 'id', type: 'string', example: '123e4567-e89b-12d3-a456-426614174000', description: 'Organizer profile UUID' })
  @ApiResponse({ status: 200, description: 'Organizer profile updated successfully' })
  @ApiResponse({ status: 400, description: 'Bad request - Invalid input data' })
  @ApiResponse({ status: 401, description: 'Unauthorized - Invalid or missing token' })
  @ApiResponse({ status: 404, description: 'Organizer profile not found or does not belong to user' })
  async updateOrganizerProfile(@Request() req, @Param('id') id: string, @Body() data: UpdateOrganizerProfileDto) {
    return this.usersService.updateOrganizerProfile(req.user.id, id, data);
  }

  @Delete('me/organizer-profiles/:id')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ 
    summary: 'Delete organizer profile',
    description: 'Deletes an event organizer profile. The profile must belong to the authenticated user. This is a permanent deletion.'
  })
  @ApiParam({ name: 'id', type: 'string', example: '123e4567-e89b-12d3-a456-426614174000', description: 'Organizer profile UUID' })
  @ApiResponse({ status: 200, description: 'Organizer profile deleted successfully' })
  @ApiResponse({ status: 401, description: 'Unauthorized - Invalid or missing token' })
  @ApiResponse({ status: 404, description: 'Organizer profile not found or does not belong to user' })
  async deleteOrganizerProfile(@Request() req, @Param('id') id: string) {
    return this.usersService.deleteOrganizerProfile(req.user.id, id);
  }

  // ============ TOUR OPERATOR PROFILES ============
  @Get('me/tour-operator-profiles')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ 
    summary: 'Get all my tour operator profiles',
    description: 'Retrieves all tour operator profiles associated with the authenticated user. Returns an array of tour operator profiles with company details, specializations, and operating regions.'
  })
  @ApiResponse({ status: 200, description: 'Tour operator profiles retrieved successfully', schema: { type: 'array', items: { type: 'object' } } })
  @ApiResponse({ status: 401, description: 'Unauthorized - Invalid or missing token' })
  async getMyTourOperatorProfiles(@Request() req) {
    return this.usersService.getTourOperatorProfiles(req.user.id);
  }

  @Get('me/tour-operator-profiles/:id')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ 
    summary: 'Get specific tour operator profile',
    description: 'Retrieves a specific tour operator profile by ID. The profile must belong to the authenticated user.'
  })
  @ApiParam({ name: 'id', type: 'string', example: '123e4567-e89b-12d3-a456-426614174000', description: 'Tour operator profile UUID' })
  @ApiResponse({ status: 200, description: 'Tour operator profile retrieved successfully' })
  @ApiResponse({ status: 401, description: 'Unauthorized - Invalid or missing token' })
  @ApiResponse({ status: 404, description: 'Tour operator profile not found or does not belong to user' })
  async getMyTourOperatorProfile(@Request() req, @Param('id') id: string) {
    return this.usersService.getTourOperatorProfile(req.user.id, id);
  }

  @Post('me/tour-operator-profiles')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @HttpCode(HttpStatus.CREATED)
  @ApiOperation({ 
    summary: 'Create tour operator profile',
    description: 'Creates a new tour operator profile for the authenticated user. Required field: companyName. Optional fields include license number, specializations, languages offered, contact info, and operating regions.'
  })
  @ApiResponse({ status: 201, description: 'Tour operator profile created successfully' })
  @ApiResponse({ status: 400, description: 'Bad request - Invalid input data or missing required fields' })
  @ApiResponse({ status: 401, description: 'Unauthorized - Invalid or missing token' })
  async createTourOperatorProfile(@Request() req, @Body() data: CreateTourOperatorProfileDto) {
    return this.usersService.createTourOperatorProfile(req.user.id, data);
  }

  @Put('me/tour-operator-profiles/:id')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ 
    summary: 'Update tour operator profile',
    description: 'Updates an existing tour operator profile. All fields are optional. Only fields provided will be updated. The profile must belong to the authenticated user.'
  })
  @ApiParam({ name: 'id', type: 'string', example: '123e4567-e89b-12d3-a456-426614174000', description: 'Tour operator profile UUID' })
  @ApiResponse({ status: 200, description: 'Tour operator profile updated successfully' })
  @ApiResponse({ status: 400, description: 'Bad request - Invalid input data' })
  @ApiResponse({ status: 401, description: 'Unauthorized - Invalid or missing token' })
  @ApiResponse({ status: 404, description: 'Tour operator profile not found or does not belong to user' })
  async updateTourOperatorProfile(@Request() req, @Param('id') id: string, @Body() data: UpdateTourOperatorProfileDto) {
    return this.usersService.updateTourOperatorProfile(req.user.id, id, data);
  }

  @Delete('me/tour-operator-profiles/:id')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ 
    summary: 'Delete tour operator profile',
    description: 'Deletes a tour operator profile. The profile must belong to the authenticated user. This is a permanent deletion.'
  })
  @ApiParam({ name: 'id', type: 'string', example: '123e4567-e89b-12d3-a456-426614174000', description: 'Tour operator profile UUID' })
  @ApiResponse({ status: 200, description: 'Tour operator profile deleted successfully' })
  @ApiResponse({ status: 401, description: 'Unauthorized - Invalid or missing token' })
  @ApiResponse({ status: 404, description: 'Tour operator profile not found or does not belong to user' })
  async deleteTourOperatorProfile(@Request() req, @Param('id') id: string) {
    return this.usersService.deleteTourOperatorProfile(req.user.id, id);
  }

  // ============ ACCOUNT ============
  @Delete('me')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ 
    summary: 'Delete account (soft delete)',
    description: 'Soft deletes the authenticated user\'s account. The account is marked as deleted (deletedAt is set) but data is retained for historical purposes. The user will not be able to log in after deletion.'
  })
  @ApiResponse({ status: 200, description: 'Account deleted successfully' })
  @ApiResponse({ status: 401, description: 'Unauthorized - Invalid or missing token' })
  async deleteAccount(@Request() req) {
    return this.usersService.deleteAccount(req.user.id);
  }

  // ============ PUBLIC PROFILES ============
  @Get('username/:username')
  @ApiOperation({ 
    summary: 'Get user by username (public profile)',
    description: 'Retrieves a user\'s public profile by username. This endpoint does not require authentication and returns only public information.'
  })
  @ApiParam({ name: 'username', type: 'string', example: 'johndoe', description: 'User\'s username' })
  @ApiResponse({ status: 200, description: 'User profile retrieved successfully' })
  @ApiResponse({ status: 404, description: 'User not found' })
  async getByUsername(@Param('username') username: string) {
    return this.usersService.findByUsername(username);
  }

  @Get(':id')
  @ApiOperation({ 
    summary: 'Get user by ID (public profile)',
    description: 'Retrieves a user\'s public profile by UUID. This endpoint does not require authentication and returns only public information.'
  })
  @ApiParam({ name: 'id', type: 'string', example: '123e4567-e89b-12d3-a456-426614174000', description: 'User UUID' })
  @ApiResponse({ status: 200, description: 'User profile retrieved successfully' })
  @ApiResponse({ status: 404, description: 'User not found' })
  async findOne(@Param('id') id: string) {
    return this.usersService.findOne(id);
  }
}
