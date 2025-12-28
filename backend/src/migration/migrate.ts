/**
 * Migration Script Entry Point
 * 
 * Run: npm run migrate
 */

import { NestFactory } from '@nestjs/core';
import { AppModule } from '../app.module';
import { MigrationService } from './migration.service';

async function bootstrap() {
  const app = await NestFactory.createApplicationContext(AppModule);
  const migrationService = app.get(MigrationService);

  // V1 Database Configuration
  // TODO: Update these with actual V1 database credentials
  const v1Config = {
    host: process.env.V1_DB_HOST || 'localhost',
    port: parseInt(process.env.V1_DB_PORT || '3306', 10),
    user: process.env.V1_DB_USER || 'root',
    password: process.env.V1_DB_PASSWORD || '',
    database: process.env.V1_DB_NAME || 'devsvknl_tarama',
  };

  console.log('🚀 Starting V1 → V2 Migration...');
  console.log('V1 Database:', v1Config.host, v1Config.database);

  try {
    const results = await migrationService.runMigration(v1Config);

    console.log('\n✅ Migration Results:');
    console.log(`Countries: ${results.countries.success} success, ${results.countries.failed} failed`);
    console.log(`Cities: ${results.cities.success} success, ${results.cities.failed} failed`);
    console.log(`Users: ${results.users.success} success, ${results.users.failed} failed`);
    console.log(`Venues: ${results.venues.success} success, ${results.venues.failed} failed`);
    console.log(`Bookings: ${results.bookings.success} success, ${results.bookings.failed} failed`);
    console.log(`Reviews: ${results.reviews.success} success, ${results.reviews.failed} failed`);
    console.log(`Favorites: ${results.favorites.success} success, ${results.favorites.failed} failed`);

    await app.close();
    process.exit(0);
  } catch (error) {
    console.error('❌ Migration failed:', error);
    await app.close();
    process.exit(1);
  }
}

bootstrap();

