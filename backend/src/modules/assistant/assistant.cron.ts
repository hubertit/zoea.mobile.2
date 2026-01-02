import { Injectable, Logger } from '@nestjs/common';
import { Cron, CronExpression } from '@nestjs/schedule';
import { AssistantService } from './assistant.service';

@Injectable()
export class AssistantCronService {
  private readonly logger = new Logger(AssistantCronService.name);

  constructor(private assistantService: AssistantService) {}

  /**
   * Clean up conversations older than 90 days
   * Runs daily at 2 AM
   */
  @Cron(CronExpression.EVERY_DAY_AT_2AM)
  async cleanupOldConversations() {
    this.logger.log('Starting cleanup of old assistant conversations...');
    
    try {
      const result = await this.assistantService.cleanupOldConversations();
      this.logger.log(`Cleaned up ${result.deleted} old conversations`);
    } catch (error) {
      this.logger.error('Failed to cleanup old conversations', error);
    }
  }
}

