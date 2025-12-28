/**
 * Targeted migration script for User 1's venues
 * This fixes the issue where user 1's 335 venues failed to migrate
 */

import { NestFactory } from '@nestjs/core';
import { AppModule } from '../app.module';
import { MigrationService } from './migration.service';
import * as mysql from 'mysql2/promise';

async function bootstrap() {
  const app = await NestFactory.createApplicationContext(AppModule);
  const migrationService = app.get(MigrationService);

  const v1Config = {
    host: process.env.V1_DB_HOST || 'localhost',
    port: parseInt(process.env.V1_DB_PORT || '3306', 10),
    user: process.env.V1_DB_USER || 'root',
    password: process.env.V1_DB_PASSWORD || 'mysql',
    database: process.env.V1_DB_NAME || 'zoea',
  };

  console.log('🎯 Migrating User 1 Venues...');
  console.log('V1 Database:', v1Config.host, v1Config.database);

  try {
    // Connect to V1 database
    const v1Connection = await mysql.createConnection(v1Config);
    console.log('✅ Connected to V1 database');

    // Get user 1's venues
    const [venuesRows] = await v1Connection.execute(
      'SELECT * FROM venues WHERE user_id = 1 ORDER BY venue_id'
    ) as [any[], any];
    const venues = venuesRows;
    console.log(`📊 Found ${venues.length} venues for user_id = 1`);

    // Get user 1 from V2
    const user1V2 = await migrationService['prisma'].user.findUnique({
      where: { legacyId: 1 },
    });

    if (!user1V2) {
      console.error('❌ User 1 not found in V2! Cannot migrate venues.');
      await v1Connection.end();
      await app.close();
      process.exit(1);
    }

    console.log(`✅ User 1 found in V2: ${user1V2.id} (${user1V2.fullName})`);

    // Create merchant profiles for user 1's venues
    const { batchCreateMerchantProfilesForUser } = await import('./utils/merchant-profile-mapper');
    
    const merchantMap = await batchCreateMerchantProfilesForUser(
      user1V2.id,
      venues.map((v: any) => ({
        venue_id: v.venue_id,
        venue_name: v.venue_name,
        category_id: v.category_id,
        venue_email: v.venue_email,
        venue_phone: v.venue_phone,
        venue_website: v.venue_website,
        country_id: v.country_id,
        location_id: v.location_id,
      })),
      { type: 'one_per_venue' },
      migrationService['prisma']
    );

    console.log(`✅ Created ${merchantMap.size} merchant profiles`);

    // Migrate each venue
    let success = 0;
    let failed = 0;
    const errors: Array<{ venue_id: number; error: string }> = [];

    for (const venue of venues) {
      try {
        // Check if already migrated
        const existing = await migrationService['prisma'].listing.findFirst({
          where: { legacyId: venue.venue_id },
        });

        if (existing) {
          console.log(`⏭️  Venue ${venue.venue_id} already migrated, skipping`);
          success++;
          continue;
        }

        // Migrate venue
        await migrationService['migrateVenueToListing'](
          venue,
          merchantMap.get(venue.venue_id),
          false // Don't force inactive
        );

        console.log(`✅ Migrated venue ${venue.venue_id}: ${venue.venue_name}`);
        success++;
      } catch (error: any) {
        console.error(`❌ Failed to migrate venue ${venue.venue_id}:`, error.message);
        errors.push({ venue_id: venue.venue_id, error: error.message });
        failed++;
      }
    }

    await v1Connection.end();

    console.log('\n📊 Migration Results:');
    console.log(`✅ Success: ${success}`);
    console.log(`❌ Failed: ${failed}`);

    if (errors.length > 0) {
      console.log('\n❌ Errors:');
      errors.slice(0, 10).forEach(e => {
        console.log(`  Venue ${e.venue_id}: ${e.error}`);
      });
      if (errors.length > 10) {
        console.log(`  ... and ${errors.length - 10} more errors`);
      }
    }

    await app.close();
    process.exit(failed > 0 ? 1 : 0);
  } catch (error) {
    console.error('❌ Migration failed:', error);
    await app.close();
    process.exit(1);
  }
}

bootstrap();

