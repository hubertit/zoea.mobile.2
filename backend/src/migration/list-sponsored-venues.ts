/**
 * List V1 Sponsored Venues
 * 
 * This script queries the V1 database to list all venues where sponsored > 0
 * so you can review them before migrating to V2 featured listings.
 * 
 * Run: ts-node src/migration/list-sponsored-venues.ts
 */

import { NestFactory } from '@nestjs/core';
import { AppModule } from '../app.module';
import { Logger } from '@nestjs/common';
import * as mysql from 'mysql2/promise';

async function bootstrap() {
  const app = await NestFactory.createApplicationContext(AppModule);
  const logger = new Logger('ListSponsoredVenues');

  // V1 Database Configuration
  const v1Config = {
    host: process.env.V1_DB_HOST || '172.16.40.61',
    port: parseInt(process.env.V1_DB_PORT || '3306', 10),
    user: process.env.V1_DB_USER || 'devsvknl_tarama',
    password: process.env.V1_DB_PASSWORD || 'Tarama@2024',
    database: process.env.V1_DB_NAME || 'devsvknl_tarama',
  };

  let v1Connection: mysql.Connection | null = null;

  try {
    logger.log('🔍 Querying V1 database for sponsored venues...');
    logger.log(`Connecting to: ${v1Config.host}:${v1Config.port}/${v1Config.database}`);

    // Connect to V1 database
    v1Connection = await mysql.createConnection({
      host: v1Config.host,
      port: v1Config.port,
      user: v1Config.user,
      password: v1Config.password,
      database: v1Config.database,
    });

    logger.log('✅ Connected to V1 database');

    // Query V1 venues where sponsored > 0
    const [sponsoredVenues] = await v1Connection.execute(
      `SELECT 
        venue_id, 
        venue_name, 
        sponsored, 
        venue_status,
        category_id,
        location_id,
        venue_rating,
        venue_reviews,
        time_added
      FROM venues 
      WHERE sponsored > 0 
      ORDER BY sponsored DESC, venue_id`
    ) as [any[], any];

    logger.log(`\n📊 Found ${sponsoredVenues.length} sponsored venues in V1\n`);

    if (sponsoredVenues.length === 0) {
      logger.warn('⚠️  No sponsored venues found in V1 database');
      await v1Connection.end();
      await app.close();
      process.exit(0);
    }

    // Display sponsored venues in a formatted table
    logger.log('═══════════════════════════════════════════════════════════════════════════════');
    logger.log('📋 SPONSORED VENUES FROM V1 DATABASE');
    logger.log('═══════════════════════════════════════════════════════════════════════════════\n');

    sponsoredVenues.forEach((venue: any, index: number) => {
      logger.log(`${index + 1}. Venue ID: ${venue.venue_id}`);
      logger.log(`   Name: ${venue.venue_name || 'N/A'}`);
      logger.log(`   Sponsored Level: ${venue.sponsored}`);
      logger.log(`   Status: ${venue.venue_status || 'N/A'}`);
      logger.log(`   Category ID: ${venue.category_id || 'N/A'}`);
      logger.log(`   Location ID: ${venue.location_id || 'N/A'}`);
      logger.log(`   Rating: ${venue.venue_rating || 'N/A'}`);
      logger.log(`   Reviews: ${venue.venue_reviews || 0}`);
      logger.log(`   Added: ${venue.time_added ? new Date(venue.time_added).toLocaleDateString() : 'N/A'}`);
      logger.log('');
    });

    logger.log('═══════════════════════════════════════════════════════════════════════════════');
    logger.log(`\n📈 Summary:`);
    logger.log(`   Total sponsored venues: ${sponsoredVenues.length}`);
    
    // Group by sponsored level
    const byLevel: { [key: number]: number } = {};
    sponsoredVenues.forEach((venue: any) => {
      const level = venue.sponsored || 0;
      byLevel[level] = (byLevel[level] || 0) + 1;
    });
    
    logger.log(`\n   Sponsored by level:`);
    Object.entries(byLevel)
      .sort(([a], [b]) => {
        const numA = parseInt(a as string, 10);
        const numB = parseInt(b as string, 10);
        return numB - numA;
      })
      .forEach(([level, count]) => {
        logger.log(`     Level ${level}: ${count} venue(s)`);
      });

    // Group by status
    const byStatus: { [key: string]: number } = {};
    sponsoredVenues.forEach((venue: any) => {
      const status = venue.venue_status || 'unknown';
      byStatus[status] = (byStatus[status] || 0) + 1;
    });
    
    logger.log(`\n   By status:`);
    Object.entries(byStatus)
      .sort(([, countA], [, countB]) => (countB as number) - (countA as number))
      .forEach(([status, count]) => {
        logger.log(`     ${status}: ${count} venue(s)`);
      });

    logger.log('\n═══════════════════════════════════════════════════════════════════════════════');
    logger.log('✅ Review complete. If these look correct, run migrate-sponsored-to-featured.ts');
    logger.log('═══════════════════════════════════════════════════════════════════════════════\n');

    await v1Connection.end();
    await app.close();
    process.exit(0);
  } catch (error: any) {
    logger.error('❌ Failed to list sponsored venues:', error);
    if (v1Connection) {
      await v1Connection.end();
    }
    await app.close();
    process.exit(1);
  }
}

bootstrap();

