import { Controller, Post, Body, UseGuards, Request, HttpCode, HttpStatus } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth, ApiBody } from '@nestjs/swagger';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { AnalyticsService } from './analytics.service';
import { BatchAnalyticsEventsDto, RecordContentViewDto } from './dto/analytics.dto';

@ApiTags('Analytics')
@Controller('analytics')
export class AnalyticsController {
  constructor(private analyticsService: AnalyticsService) {}

  @Post('events')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ 
    summary: 'Receive batched analytics events from mobile app',
    description: 'Processes multiple analytics events in a single request. Tracks views, searches, and interactions.'
  })
  @ApiBody({ type: BatchAnalyticsEventsDto })
  async receiveBatchEvents(@Request() req, @Body() dto: BatchAnalyticsEventsDto) {
    return this.analyticsService.processBatchEvents(req.user.id, dto, req);
  }

  @Post('content-view')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @HttpCode(HttpStatus.CREATED)
  @ApiOperation({ 
    summary: 'Record a content view',
    description: 'Records a view of a listing or event with detailed tracking information.'
  })
  @ApiBody({ type: RecordContentViewDto })
  async recordContentView(@Request() req, @Body() dto: RecordContentViewDto) {
    await this.analyticsService.recordContentView(req.user.id, dto, req);
    return { message: 'Content view recorded successfully' };
  }
}

