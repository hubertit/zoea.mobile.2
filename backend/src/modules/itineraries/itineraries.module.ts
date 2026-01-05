import { Module } from '@nestjs/common';
import { ItinerariesController, PublicItinerariesController } from './itineraries.controller';
import { ItinerariesService } from './itineraries.service';

@Module({
  controllers: [ItinerariesController, PublicItinerariesController],
  providers: [ItinerariesService],
  exports: [ItinerariesService],
})
export class ItinerariesModule {}

