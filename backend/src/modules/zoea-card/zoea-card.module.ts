import { Module } from '@nestjs/common';
import { ZoeaCardController } from './zoea-card.controller';
import { ZoeaCardService } from './zoea-card.service';

@Module({
  controllers: [ZoeaCardController],
  providers: [ZoeaCardService],
  exports: [ZoeaCardService],
})
export class ZoeaCardModule {}

