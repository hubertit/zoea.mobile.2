import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { ThrottlerModule } from '@nestjs/throttler';
import { PrismaModule } from './prisma/prisma.module';
import { AuthModule } from './modules/auth/auth.module';
import { UsersModule } from './modules/users/users.module';
import { ListingsModule } from './modules/listings/listings.module';
import { EventsModule } from './modules/events/events.module';
import { ToursModule } from './modules/tours/tours.module';
import { BookingsModule } from './modules/bookings/bookings.module';
import { ReviewsModule } from './modules/reviews/reviews.module';
import { FavoritesModule } from './modules/favorites/favorites.module';
import { NotificationsModule } from './modules/notifications/notifications.module';
import { ZoeaCardModule } from './modules/zoea-card/zoea-card.module';
import { CategoriesModule } from './modules/categories/categories.module';
import { CountriesModule } from './modules/countries/countries.module';
import { SearchModule } from './modules/search/search.module';
import { MerchantsModule } from './modules/merchants/merchants.module';
import { MediaModule } from './modules/media/media.module';
import { AdminModule } from './modules/admin/admin.module';
import { AnalyticsModule } from './modules/analytics/analytics.module';
import { HealthModule } from './modules/health/health.module';

@Module({
  imports: [
    ConfigModule.forRoot({
      isGlobal: true,
    }),
    ThrottlerModule.forRoot([
      {
        ttl: 60000,
        limit: 100,
      },
    ]),
    PrismaModule,
    AuthModule,
    UsersModule,
    ListingsModule,
    EventsModule,
    ToursModule,
    BookingsModule,
    ReviewsModule,
    FavoritesModule,
    NotificationsModule,
    ZoeaCardModule,
    CategoriesModule,
    CountriesModule,
    SearchModule,
    MerchantsModule,
    MediaModule,
    AdminModule,
    AnalyticsModule,
    HealthModule,
  ],
})
export class AppModule {}
