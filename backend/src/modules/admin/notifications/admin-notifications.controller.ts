import { Body, Controller, Get, Param, Patch, Post, Query, Request, UseGuards } from '@nestjs/common';
import { ApiBearerAuth, ApiOperation, ApiTags } from '@nestjs/swagger';
import { Roles } from '../../../common/decorators/roles.decorator';
import { RolesGuard } from '../../../common/guards/roles.guard';
import { JwtAuthGuard } from '../../auth/guards/jwt-auth.guard';
import { AdminNotificationsService } from './admin-notifications.service';
import { AdminListNotificationRequestsDto } from './dto/list-notification-requests.dto';
import { AdminUpdateNotificationRequestDto } from './dto/update-notification-request.dto';
import { AdminCreateBroadcastDto } from './dto/create-broadcast.dto';

@ApiTags('Admin - Notifications')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard, RolesGuard)
@Roles('admin', 'super_admin')
@Controller('admin/notifications')
export class AdminNotificationsController {
  constructor(private readonly adminNotificationsService: AdminNotificationsService) {}

  @Get('requests')
  @ApiOperation({ summary: 'List notification/broadcast requests' })
  async listRequests(@Query() query: AdminListNotificationRequestsDto) {
    return this.adminNotificationsService.listRequests(query);
  }

  @Patch('requests/:id/status')
  @ApiOperation({ summary: 'Approve or reject notification request' })
  async updateRequest(
    @Param('id') id: string,
    @Request() req,
    @Body() dto: AdminUpdateNotificationRequestDto,
  ) {
    return this.adminNotificationsService.updateRequest(id, req.user.id, dto);
  }

  @Post('broadcast')
  @ApiOperation({ summary: 'Create immediate/scheduled broadcast message' })
  async createBroadcast(@Request() req, @Body() dto: AdminCreateBroadcastDto) {
    return this.adminNotificationsService.createBroadcast(req.user.id, dto);
  }
}


