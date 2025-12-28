import { Body, Controller, Get, Param, Patch, Query, UseGuards } from '@nestjs/common';
import { ApiBearerAuth, ApiOperation, ApiTags } from '@nestjs/swagger';
import { Roles } from '../../../common/decorators/roles.decorator';
import { RolesGuard } from '../../../common/guards/roles.guard';
import { JwtAuthGuard } from '../../auth/guards/jwt-auth.guard';
import { AdminUsersService } from './admin-users.service';
import { AdminListUsersDto } from './dto/list-users.dto';
import { AdminUpdateUserStatusDto } from './dto/update-user-status.dto';
import { AdminUpdateUserRolesDto } from './dto/update-user-roles.dto';

@ApiTags('Admin - Users')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard, RolesGuard)
@Roles('admin', 'super_admin')
@Controller('admin/users')
export class AdminUsersController {
  constructor(private readonly adminUsersService: AdminUsersService) {}

  @Get()
  @ApiOperation({ summary: 'List users with filters and pagination' })
  async listUsers(@Query() query: AdminListUsersDto) {
    return this.adminUsersService.listUsers(query);
  }

  @Get(':id')
  @ApiOperation({ summary: 'Get detailed user profile' })
  async getUser(@Param('id') id: string) {
    return this.adminUsersService.getUserById(id);
  }

  @Patch(':id/status')
  @ApiOperation({ summary: 'Update user status, verification or blocking' })
  async updateStatus(@Param('id') id: string, @Body() dto: AdminUpdateUserStatusDto) {
    return this.adminUsersService.updateUserStatus(id, dto);
  }

  @Patch(':id/roles')
  @ApiOperation({ summary: 'Update user roles' })
  async updateRoles(@Param('id') id: string, @Body() dto: AdminUpdateUserRolesDto) {
    return this.adminUsersService.updateUserRoles(id, dto);
  }
}


