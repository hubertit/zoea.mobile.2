import { Module } from '@nestjs/common';
import { ScheduleModule } from '@nestjs/schedule';
import { AssistantController } from './assistant.controller';
import { AssistantService } from './assistant.service';
import { ContentSearchService } from './content-search.service';
import { OpenAIService } from './openai.service';
import { AssistantCronService } from './assistant.cron';
import { PrismaModule } from '../../prisma/prisma.module';
import { IntegrationsModule } from '../integrations/integrations.module';
import { ListingsModule } from '../listings/listings.module';
import { ToursModule } from '../tours/tours.module';
import { ProductsModule } from '../products/products.module';
import { ServicesModule } from '../services/services.module';
import { CategoriesModule } from '../categories/categories.module';

@Module({
  imports: [
    ScheduleModule.forRoot(),
    PrismaModule,
    IntegrationsModule,
    ListingsModule,
    ToursModule,
    ProductsModule,
    ServicesModule,
    CategoriesModule,
  ],
  controllers: [AssistantController],
  providers: [AssistantService, ContentSearchService, OpenAIService, AssistantCronService],
  exports: [AssistantService],
})
export class AssistantModule {}

