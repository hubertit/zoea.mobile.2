/**
 * List V1 Sponsored Venues from SQL Dump
 * 
 * This script parses the V1 SQL dump file to extract all venues where sponsored > 0
 * so you can review them before migrating to V2 featured listings.
 * 
 * Run: ts-node src/migration/list-sponsored-from-sql.ts
 */

import * as fs from 'fs';
import * as path from 'path';

interface Venue {
  venue_id: number;
  venue_name: string;
  sponsored: number;
  venue_status: string;
  category_id: number;
  location_id: number;
  venue_rating: number;
  venue_reviews: number;
  time_added: string;
}

function parseSQLDump(filePath: string): Venue[] {
  const sqlContent = fs.readFileSync(filePath, 'utf-8');
  const venues: Venue[] = [];

  // Find the INSERT INTO venues statement
  const insertMatch = sqlContent.match(/INSERT INTO `venues`[^;]+;/gs);
  
  if (!insertMatch) {
    console.error('❌ No INSERT INTO venues statement found in SQL file');
    return [];
  }

  // Parse each INSERT statement
  for (const insertStatement of insertMatch) {
    // Extract VALUES part
    const valuesMatch = insertStatement.match(/VALUES\s+(.+);/s);
    if (!valuesMatch) continue;

    const valuesString = valuesMatch[1];
    
    // Split by rows (each row is in parentheses)
    // Match rows that might span multiple lines
    const rowRegex = /\(([^)]*(?:\([^)]*\)[^)]*)*)\)/g;
    let rowMatch;
    
    while ((rowMatch = rowRegex.exec(valuesString)) !== null) {
      const row = rowMatch[1];
      
      // Parse the row values - handle escaped quotes and commas
      const values: string[] = [];
      let current = '';
      let inQuotes = false;
      let quoteChar = '';
      
      for (let i = 0; i < row.length; i++) {
        const char = row[i];
        const nextChar = row[i + 1];
        
        if (!inQuotes && (char === '"' || char === "'")) {
          inQuotes = true;
          quoteChar = char;
          current += char;
        } else if (inQuotes && char === quoteChar && nextChar !== quoteChar) {
          inQuotes = false;
          quoteChar = '';
          current += char;
        } else if (inQuotes && char === quoteChar && nextChar === quoteChar) {
          // Escaped quote
          current += char + nextChar;
          i++; // Skip next char
        } else if (!inQuotes && char === ',') {
          values.push(current.trim());
          current = '';
        } else {
          current += char;
        }
      }
      
      if (current.trim()) {
        values.push(current.trim());
      }

      // Extract fields based on the INSERT column order
      // venue_id, user_id, category_id, country_id, location_id, venue_code, venue_name, venue_about, 
      // facilities, venue_policy, cancellation_policy, checkin_policy, checkout_policy, venue_price, 
      // breakfast_included, venue_phone, venue_email, venue_website, vubaVuba_link, venue_image, 
      // banner_url, venue_rating, venue_reviews, venue_address, venue_coordinates, services, wallet, 
      // working_hours, time_added, venue_status, sponsored, sort_order
      
      if (values.length >= 31) {
        const venue: Venue = {
          venue_id: parseInt(values[0]) || 0,
          venue_name: values[6]?.replace(/^['"]|['"]$/g, '') || '',
          sponsored: parseInt(values[29]) || 0,
          venue_status: values[28]?.replace(/^['"]|['"]$/g, '') || '',
          category_id: parseInt(values[2]) || 0,
          location_id: parseInt(values[4]) || 0,
          venue_rating: parseInt(values[21]) || 0,
          venue_reviews: parseInt(values[22]) || 0,
          time_added: values[27]?.replace(/^['"]|['"]$/g, '') || '',
        };

        // Only include venues where sponsored > 0
        if (venue.sponsored > 0) {
          venues.push(venue);
        }
      }
    }
  }

  return venues;
}

async function bootstrap() {
  const sqlFilePath = process.env.V1_SQL_FILE || '/Applications/AMPPS/www/zoea1/zoea.sql';

  try {
    console.log('🔍 Parsing V1 SQL dump file for sponsored venues...');
    console.log(`File: ${sqlFilePath}\n`);

    if (!fs.existsSync(sqlFilePath)) {
      console.error(`❌ SQL file not found: ${sqlFilePath}`);
      process.exit(1);
    }

    const sponsoredVenues = parseSQLDump(sqlFilePath);

    console.log(`📊 Found ${sponsoredVenues.length} sponsored venues in V1\n`);

    if (sponsoredVenues.length === 0) {
      console.log('⚠️  No sponsored venues found in V1 SQL file');
      process.exit(0);
    }

    // Sort by sponsored level (descending)
    sponsoredVenues.sort((a, b) => b.sponsored - a.sponsored);

    // Display sponsored venues in a formatted table
    console.log('═══════════════════════════════════════════════════════════════════════════════');
    console.log('📋 SPONSORED VENUES FROM V1 SQL DUMP');
    console.log('═══════════════════════════════════════════════════════════════════════════════\n');

    sponsoredVenues.forEach((venue, index) => {
      console.log(`${index + 1}. Venue ID: ${venue.venue_id}`);
      console.log(`   Name: ${venue.venue_name || 'N/A'}`);
      console.log(`   Sponsored Level: ${venue.sponsored}`);
      console.log(`   Status: ${venue.venue_status || 'N/A'}`);
      console.log(`   Category ID: ${venue.category_id || 'N/A'}`);
      console.log(`   Location ID: ${venue.location_id || 'N/A'}`);
      console.log(`   Rating: ${venue.venue_rating || 'N/A'}`);
      console.log(`   Reviews: ${venue.venue_reviews || 0}`);
      console.log(`   Added: ${venue.time_added || 'N/A'}`);
      console.log('');
    });

    console.log('═══════════════════════════════════════════════════════════════════════════════');
    console.log(`\n📈 Summary:`);
    console.log(`   Total sponsored venues: ${sponsoredVenues.length}`);
    
    // Group by sponsored level
    const byLevel: { [key: number]: number } = {};
    sponsoredVenues.forEach((venue) => {
      byLevel[venue.sponsored] = (byLevel[venue.sponsored] || 0) + 1;
    });
    
    console.log(`\n   Sponsored by level:`);
    Object.entries(byLevel)
      .sort(([a], [b]) => parseInt(b) - parseInt(a))
      .forEach(([level, count]) => {
        console.log(`     Level ${level}: ${count} venue(s)`);
      });

    // Group by status
    const byStatus: { [key: string]: number } = {};
    sponsoredVenues.forEach((venue) => {
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

    process.exit(0);
  } catch (error: any) {
    console.error('❌ Failed to parse SQL file:', error.message);
    console.error(error.stack);
    process.exit(1);
  }
}

bootstrap();

