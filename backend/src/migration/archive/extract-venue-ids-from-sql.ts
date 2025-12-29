/**
 * Extract Venue IDs from Exported SQL File
 * 
 * This script reads the exported venues.sql file and extracts venue IDs
 * to use for migrating sponsored listings to V2 featured.
 */

import * as fs from 'fs';
import * as path from 'path';

function extractVenueIds(sqlFilePath: string): number[] {
  const content = fs.readFileSync(sqlFilePath, 'utf-8');
  const venueIds: number[] = [];

  // Find INSERT INTO venues statement
  const insertMatch = content.match(/INSERT INTO `venues`[^;]+;/s);
  
  if (!insertMatch) {
    console.error('❌ No INSERT INTO venues statement found');
    return [];
  }

  // Extract VALUES part
  const valuesMatch = insertMatch[0].match(/VALUES\s+(.+);/s);
  if (!valuesMatch) {
    console.error('❌ No VALUES found in INSERT statement');
    return [];
  }

  const valuesString = valuesMatch[1];
  
  // Match all rows (each row is in parentheses)
  const rowRegex = /\(([^)]+)\)/g;
  let rowMatch;
  
  while ((rowMatch = rowRegex.exec(valuesString)) !== null) {
    const row = rowMatch[1];
    
    // Split by comma, but handle quoted strings
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

    // First value is venue_id
    if (values.length > 0) {
      const venueId = parseInt(values[0].trim());
      if (!isNaN(venueId)) {
        venueIds.push(venueId);
      }
    }
  }

  return venueIds;
}

async function bootstrap() {
  const sqlFilePath = process.env.VENUES_SQL_FILE || path.join(process.env.HOME || '', 'Desktop', 'venues.sql');

  try {
    console.log('🔍 Extracting venue IDs from exported SQL file...');
    console.log(`File: ${sqlFilePath}\n`);

    if (!fs.existsSync(sqlFilePath)) {
      console.error(`❌ SQL file not found: ${sqlFilePath}`);
      process.exit(1);
    }

    const venueIds = extractVenueIds(sqlFilePath);

    console.log(`📊 Found ${venueIds.length} venue IDs:\n`);
    console.log('Venue IDs:', venueIds.join(', '));
    console.log(`\n✅ Extracted ${venueIds.length} venue IDs`);
    console.log('\nYou can now use these IDs to migrate them to V2 featured listings.');

    process.exit(0);
  } catch (error: any) {
    console.error('❌ Failed to extract venue IDs:', error.message);
    console.error(error.stack);
    process.exit(1);
  }
}

bootstrap();

