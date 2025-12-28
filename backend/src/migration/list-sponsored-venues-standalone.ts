/**
 * List V1 Sponsored Venues (Standalone)
 * 
 * This script queries the V1 database to list all venues where sponsored > 0
 * so you can review them before migrating to V2 featured listings.
 * 
 * Run: ts-node src/migration/list-sponsored-venues-standalone.ts
 */

import * as mysql from 'mysql2/promise';

async function bootstrap() {
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
    console.log('🔍 Querying V1 database for sponsored venues...');
    console.log(`Connecting to: ${v1Config.host}:${v1Config.port}/${v1Config.database}\n`);

    // Connect to V1 database
    v1Connection = await mysql.createConnection({
      host: v1Config.host,
      port: v1Config.port,
      user: v1Config.user,
      password: v1Config.password,
      database: v1Config.database,
    });

    console.log('✅ Connected to V1 database\n');

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

    console.log(`📊 Found ${sponsoredVenues.length} sponsored venues in V1\n`);

    if (sponsoredVenues.length === 0) {
      console.log('⚠️  No sponsored venues found in V1 database');
      await v1Connection.end();
      process.exit(0);
    }

    // Display sponsored venues in a formatted table
    console.log('═══════════════════════════════════════════════════════════════════════════════');
    console.log('📋 SPONSORED VENUES FROM V1 DATABASE');
    console.log('═══════════════════════════════════════════════════════════════════════════════\n');

    sponsoredVenues.forEach((venue: any, index: number) => {
      console.log(`${index + 1}. Venue ID: ${venue.venue_id}`);
      console.log(`   Name: ${venue.venue_name || 'N/A'}`);
      console.log(`   Sponsored Level: ${venue.sponsored}`);
      console.log(`   Status: ${venue.venue_status || 'N/A'}`);
      console.log(`   Category ID: ${venue.category_id || 'N/A'}`);
      console.log(`   Location ID: ${venue.location_id || 'N/A'}`);
      console.log(`   Rating: ${venue.venue_rating || 'N/A'}`);
      console.log(`   Reviews: ${venue.venue_reviews || 0}`);
      console.log(`   Added: ${venue.time_added ? new Date(venue.time_added).toLocaleDateString() : 'N/A'}`);
      console.log('');
    });

    console.log('═══════════════════════════════════════════════════════════════════════════════');
    console.log(`\n📈 Summary:`);
    console.log(`   Total sponsored venues: ${sponsoredVenues.length}`);
    
    // Group by sponsored level
    const byLevel: { [key: number]: number } = {};
    sponsoredVenues.forEach((venue: any) => {
      const level = venue.sponsored || 0;
      byLevel[level] = (byLevel[level] || 0) + 1;
    });
    
    console.log(`\n   Sponsored by level:`);
    Object.entries(byLevel)
      .sort(([a], [b]) => {
        const numA = parseInt(a as string, 10);
        const numB = parseInt(b as string, 10);
        return numB - numA;
      })
      .forEach(([level, count]) => {
        console.log(`     Level ${level}: ${count} venue(s)`);
      });

    // Group by status
    const byStatus: { [key: string]: number } = {};
    sponsoredVenues.forEach((venue: any) => {
      const status = venue.venue_status || 'unknown';
      byStatus[status] = (byStatus[status] || 0) + 1;
    });
    
    console.log(`\n   By status:`);
    Object.entries(byStatus)
      .sort(([, countA], [, countB]) => (countB as number) - (countA as number))
      .forEach(([status, count]) => {
        console.log(`     ${status}: ${count} venue(s)`);
      });

    console.log('\n═══════════════════════════════════════════════════════════════════════════════');
    console.log('✅ Review complete. If these look correct, run migrate-sponsored-to-featured.ts');
    console.log('═══════════════════════════════════════════════════════════════════════════════\n');

    await v1Connection.end();
    process.exit(0);
  } catch (error: any) {
    console.error('❌ Failed to list sponsored venues:', error.message);
    if (v1Connection) {
      await v1Connection.end();
    }
    process.exit(1);
  }
}

bootstrap();

