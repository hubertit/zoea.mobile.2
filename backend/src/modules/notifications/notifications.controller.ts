import { Controller, Get, Post, Delete, Param, Query, UseGuards, Request } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth, ApiQuery, ApiParam, ApiResponse } from '@nestjs/swagger';
import { NotificationsService } from './notifications.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';

@ApiTags('Notifications')
@Controller('notifications')
@UseGuards(JwtAuthGuard)
@ApiBearerAuth()
export class NotificationsController {
  constructor(private notificationsService: NotificationsService) {}

  @Get()
  @ApiOperation({ 
    summary: 'Get notifications',
    description: 'Retrieves paginated notifications for the authenticated user. Notifications include booking confirmations, payment updates, review responses, and system announcements. Can filter to show only unread notifications.'
  })
  @ApiQuery({ name: 'page', required: false, type: Number, example: 1, description: 'Page number (default: 1)' })
  @ApiQuery({ name: 'limit', required: false, type: Number, example: 20, description: 'Items per page (default: 20)' })
  @ApiQuery({ name: 'unreadOnly', required: false, type: Boolean, description: 'Filter to show only unread notifications', example: false })
  @ApiResponse({ 
    status: 200, 
    description: 'Notifications retrieved successfully',
    schema: {
      type: 'object',
      properties: {
        data: { 
          type: 'array',
          items: {
            type: 'object',
            properties: {
              id: { type: 'string' },
              title: { type: 'string', example: 'Booking Confirmed' },
              message: { type: 'string', example: 'Your booking at Grand Hotel has been confirmed' },
              type: { type: 'string', enum: ['booking', 'payment', 'review', 'system'], example: 'booking' },
              isRead: { type: 'boolean', example: false },
              createdAt: { type: 'string' }
            }
          }
        },
        total: { type: 'number', example: 45 },
        unreadCount: { type: 'number', example: 5 },
        page: { type: 'number', example: 1 },
        limit: { type: 'number', example: 20 }
      }
    }
  })
  @ApiResponse({ status: 401, description: 'Unauthorized - Invalid or missing token' })
  async findAll(
    @Request() req,
    @Query('page') page?: string,
    @Query('limit') limit?: string,
    @Query('unreadOnly') unreadOnly?: string,
  ) {
    return this.notificationsService.findAll(req.user.id, {
      page: page ? +page : 1,
      limit: limit ? +limit : 20,
      unreadOnly: unreadOnly === 'true',
    });
  }

  @Get('unread-count')
  @ApiOperation({ 
    summary: 'Get unread notification count',
    description: 'Returns the count of unread notifications for the authenticated user. Useful for displaying a badge or indicator in the UI.'
  })
  @ApiResponse({ 
    status: 200, 
    description: 'Unread count retrieved successfully',
    schema: {
      type: 'object',
      properties: {
        count: { type: 'number', example: 5, description: 'Number of unread notifications' }
      }
    }
  })
  @ApiResponse({ status: 401, description: 'Unauthorized - Invalid or missing token' })
  async getUnreadCount(@Request() req) {
    return this.notificationsService.getUnreadCount(req.user.id);
  }

  @Post(':id/read')
  @ApiOperation({ 
    summary: 'Mark notification as read',
    description: 'Marks a specific notification as read. The notification will no longer appear in unread counts.'
  })
  @ApiParam({ name: 'id', type: String, description: 'Notification UUID', example: '123e4567-e89b-12d3-a456-426614174000' })
  @ApiResponse({ 
    status: 200, 
    description: 'Notification marked as read successfully',
    schema: {
      type: 'object',
      properties: {
        success: { type: 'boolean', example: true },
        message: { type: 'string', example: 'Notification marked as read' }
      }
    }
  })
  @ApiResponse({ status: 401, description: 'Unauthorized - Invalid or missing token' })
  @ApiResponse({ status: 403, description: 'Forbidden - Not authorized to mark this notification' })
  @ApiResponse({ status: 404, description: 'Notification not found' })
  async markAsRead(@Param('id') id: string, @Request() req) {
    return this.notificationsService.markAsRead(id, req.user.id);
  }

  @Post('read-all')
  @ApiOperation({ 
    summary: 'Mark all notifications as read',
    description: 'Marks all notifications for the authenticated user as read. Useful for "Mark all as read" functionality.'
  })
  @ApiResponse({ 
    status: 200, 
    description: 'All notifications marked as read successfully',
    schema: {
      type: 'object',
      properties: {
        success: { type: 'boolean', example: true },
        message: { type: 'string', example: 'All notifications marked as read' },
        updatedCount: { type: 'number', example: 10, description: 'Number of notifications marked as read' }
      }
    }
  })
  @ApiResponse({ status: 401, description: 'Unauthorized - Invalid or missing token' })
  async markAllAsRead(@Request() req) {
    return this.notificationsService.markAllAsRead(req.user.id);
  }

  @Delete(':id')
  @ApiOperation({ 
    summary: 'Delete a notification',
    description: 'Deletes a specific notification. This action cannot be undone.'
  })
  @ApiParam({ name: 'id', type: String, description: 'Notification UUID', example: '123e4567-e89b-12d3-a456-426614174000' })
  @ApiResponse({ 
    status: 200, 
    description: 'Notification deleted successfully',
    schema: {
      type: 'object',
      properties: {
        success: { type: 'boolean', example: true },
        message: { type: 'string', example: 'Notification deleted successfully' }
      }
    }
  })
  @ApiResponse({ status: 401, description: 'Unauthorized - Invalid or missing token' })
  @ApiResponse({ status: 403, description: 'Forbidden - Not authorized to delete this notification' })
  @ApiResponse({ status: 404, description: 'Notification not found' })
  async delete(@Param('id') id: string, @Request() req) {
    return this.notificationsService.delete(id, req.user.id);
  }

  @Delete()
  @ApiOperation({ 
    summary: 'Delete all notifications',
    description: 'Deletes all notifications for the authenticated user. This action cannot be undone. Useful for clearing notification history.'
  })
  @ApiResponse({ 
    status: 200, 
    description: 'All notifications deleted successfully',
    schema: {
      type: 'object',
      properties: {
        success: { type: 'boolean', example: true },
        message: { type: 'string', example: 'All notifications deleted successfully' },
        deletedCount: { type: 'number', example: 25, description: 'Number of notifications deleted' }
      }
    }
  })
  @ApiResponse({ status: 401, description: 'Unauthorized - Invalid or missing token' })
  async deleteAll(@Request() req) {
    return this.notificationsService.deleteAll(req.user.id);
  }
}
