import { Module } from '@nestjs/common';
import { RolesGuard } from '../../common/guards/roles.guard';
import { PrismaModule } from '../../prisma/prisma.module';
import { AdminUsersService } from './users/admin-users.service';
import { AdminUsersController } from './users/admin-users.controller';
import { AdminMerchantsService } from './merchants/admin-merchants.service';
import { AdminMerchantsController } from './merchants/admin-merchants.controller';
import { AdminListingsService } from './listings/admin-listings.service';
import { AdminListingsController } from './listings/admin-listings.controller';
import { AdminBookingsService } from './bookings/admin-bookings.service';
import { AdminBookingsController } from './bookings/admin-bookings.controller';
import { AdminPaymentsService } from './payments/admin-payments.service';
import { AdminPaymentsController } from './payments/admin-payments.controller';
import { AdminEventsService } from './events/admin-events.service';
import { AdminEventsController } from './events/admin-events.controller';
import { AdminNotificationsService } from './notifications/admin-notifications.service';
import { AdminNotificationsController } from './notifications/admin-notifications.controller';
import { AdminReviewsService } from './reviews/admin-reviews.service';
import { AdminReviewsController } from './reviews/admin-reviews.controller';
import { ReviewsModule } from '../reviews/reviews.module';

@Module({
  imports: [PrismaModule, ReviewsModule],
  controllers: [
    AdminUsersController,
    AdminMerchantsController,
    AdminListingsController,
    AdminBookingsController,
    AdminPaymentsController,
    AdminEventsController,
    AdminNotificationsController,
    AdminReviewsController,
  ],
  providers: [
    AdminUsersService,
    AdminMerchantsService,
    AdminListingsService,
    AdminBookingsService,
    AdminPaymentsService,
    AdminEventsService,
    AdminNotificationsService,
    AdminReviewsService,
    RolesGuard,
  ],
})
export class AdminModule {}


