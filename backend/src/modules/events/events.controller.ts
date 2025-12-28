import { Controller, Get, Post, Param, Query, Body, UseGuards, Request } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth, ApiQuery } from '@nestjs/swagger';
import { EventsService } from './events.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { CreateEventCommentDto } from './dto/event.dto';

@ApiTags('Events')
@Controller('events')
export class EventsController {
  constructor(private eventsService: EventsService) {}

  @Get()
  @ApiOperation({ summary: 'Get all events (explore-events compatible)' })
  @ApiQuery({ name: 'page', required: false })
  @ApiQuery({ name: 'limit', required: false })
  @ApiQuery({ name: 'status', required: false })
  @ApiQuery({ name: 'cityId', required: false })
  @ApiQuery({ name: 'countryId', required: false })
  @ApiQuery({ name: 'category', required: false, description: 'Event context ID' })
  @ApiQuery({ name: 'startDate', required: false })
  @ApiQuery({ name: 'endDate', required: false })
  @ApiQuery({ name: 'search', required: false })
  @ApiQuery({ name: 'sort', required: false })
  async findAll(
    @Query('page') page?: string,
    @Query('limit') limit?: string,
    @Query('status') status?: string,
    @Query('cityId') cityId?: string,
    @Query('countryId') countryId?: string,
    @Query('category') category?: string,
    @Query('startDate') startDate?: string,
    @Query('endDate') endDate?: string,
    @Query('search') search?: string,
  ) {
    return this.eventsService.findAll({
      page: page ? +page : 1,
      limit: limit ? +limit : 25,
      status: status || 'published',
      cityId,
      countryId,
      contextId: category,
      startDate: startDate ? new Date(startDate) : undefined,
      endDate: endDate ? new Date(endDate) : undefined,
      search,
    });
  }

  @Get('explore-events')
  @ApiOperation({ summary: 'Get events for explore (SINC API compatible)' })
  async exploreEvents(
    @Query('page') page?: string,
    @Query('limit') limit?: string,
    @Query('category') category?: string,
    @Query('location') location?: string,
    @Query('startDate') startDate?: string,
    @Query('endDate') endDate?: string,
    @Query('search') search?: string,
    @Query('sort') sort?: string,
  ) {
    return this.eventsService.findAll({
      page: page ? +page : 1,
      limit: limit ? +limit : 25,
      status: 'published',
      contextId: category,
      startDate: startDate ? new Date(startDate) : new Date(),
      endDate: endDate ? new Date(endDate) : undefined,
      search,
    });
  }

  @Get('upcoming')
  @ApiOperation({ summary: 'Get upcoming events' })
  @ApiQuery({ name: 'limit', required: false })
  @ApiQuery({ name: 'cityId', required: false })
  async getUpcoming(@Query('limit') limit?: string, @Query('cityId') cityId?: string) {
    return this.eventsService.getUpcoming(limit ? +limit : 10, cityId);
  }

  @Get('this-week')
  @ApiOperation({ summary: 'Get events happening this week' })
  @ApiQuery({ name: 'limit', required: false })
  @ApiQuery({ name: 'cityId', required: false })
  async getThisWeek(@Query('limit') limit?: string, @Query('cityId') cityId?: string) {
    return this.eventsService.getThisWeek(limit ? +limit : 25, cityId);
  }

  @Get('slug/:slug')
  @ApiOperation({ summary: 'Get event by slug' })
  async findBySlug(@Param('slug') slug: string) {
    return this.eventsService.findBySlug(slug);
  }

  @Get(':id')
  @ApiOperation({ summary: 'Get event by ID' })
  async findOne(@Param('id') id: string) {
    return this.eventsService.findOne(id);
  }

  @Post(':id/like')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Like/unlike an event' })
  async likeEvent(@Param('id') id: string, @Request() req) {
    return this.eventsService.likeEvent(id, req.user.id);
  }

  @Get(':id/comments')
  @ApiOperation({ summary: 'Get event comments' })
  @ApiQuery({ name: 'page', required: false })
  @ApiQuery({ name: 'limit', required: false })
  async getComments(
    @Param('id') id: string,
    @Query('page') page?: string,
    @Query('limit') limit?: string,
  ) {
    return this.eventsService.getComments(id, page ? +page : 1, limit ? +limit : 20);
  }

  @Post(':id/comments')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Add a comment to an event' })
  async addComment(
    @Param('id') id: string,
    @Request() req,
    @Body() data: CreateEventCommentDto,
  ) {
    return this.eventsService.addComment(id, req.user.id, data.content, data.parentId);
  }
}
