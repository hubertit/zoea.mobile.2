import { Body, Controller, Delete, Get, Param, Patch, Post, Put, Query, UseGuards } from '@nestjs/common';
import { ApiBearerAuth, ApiOperation, ApiTags } from '@nestjs/swagger';
import { Roles } from '../../../common/decorators/roles.decorator';
import { RolesGuard } from '../../../common/guards/roles.guard';
import { JwtAuthGuard } from '../../auth/guards/jwt-auth.guard';
import { AdminEventsService } from './admin-events.service';
import { AdminListEventsDto } from './dto/list-events.dto';
import { AdminUpdateEventStatusDto } from './dto/update-event-status.dto';
import { AdminCreateEventDto, AdminUpdateEventDto } from './dto/create-event.dto';

@ApiTags('Admin - Events')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard, RolesGuard)
@Roles('admin', 'super_admin')
@Controller('admin/events')
export class AdminEventsController {
  constructor(private readonly adminEventsService: AdminEventsService) {}

  @Get()
  @ApiOperation({ summary: 'List events' })
  async list(@Query() query: AdminListEventsDto) {
    return this.adminEventsService.listEvents(query);
  }

  @Get(':id')
  @ApiOperation({ summary: 'Get event detail' })
  async get(@Param('id') id: string) {
    return this.adminEventsService.getEvent(id);
  }

  @Post()
  @ApiOperation({ summary: 'Create event on behalf of organizer' })
  async create(@Body() dto: AdminCreateEventDto) {
    return this.adminEventsService.createEvent(dto);
  }

  @Put(':id')
  @ApiOperation({ summary: 'Update event content' })
  async updateEvent(@Param('id') id: string, @Body() dto: AdminUpdateEventDto) {
    return this.adminEventsService.updateEvent(id, dto);
  }

  @Patch(':id/status')
  @ApiOperation({ summary: 'Update event moderation state' })
  async updateStatus(@Param('id') id: string, @Body() dto: AdminUpdateEventStatusDto) {
    return this.adminEventsService.updateEventStatus(id, dto);
  }

  @Delete(':id')
  @ApiOperation({ summary: 'Soft delete event' })
  async delete(@Param('id') id: string) {
    return this.adminEventsService.deleteEvent(id);
  }

  @Patch(':id/restore')
  @ApiOperation({ summary: 'Restore soft-deleted event' })
  async restore(@Param('id') id: string) {
    return this.adminEventsService.restoreEvent(id);
  }
}


