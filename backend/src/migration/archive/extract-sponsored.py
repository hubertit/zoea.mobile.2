#!/usr/bin/env python3
import re
import sys

sql_file = '/Applications/AMPPS/www/zoea1/zoea.sql'

try:
    with open(sql_file, 'r', encoding='utf-8', errors='ignore') as f:
        content = f.read()
    
    # Find all INSERT INTO venues statements
    matches = re.findall(r'INSERT INTO `venues`[^;]+;', content, re.DOTALL)
    
    sponsored_venues = []
    for match in matches:
        # Extract all value rows
        values_match = re.search(r'VALUES\s+(.+);', match, re.DOTALL)
        if not values_match:
            continue
        
        values_str = values_match.group(1)
        # Split by rows - each row starts with (
        rows = re.findall(r'\(([^)]*(?:\([^)]*\)[^)]*)*)\)', values_str)
        
        for row in rows:
            # Simple split by comma, handling quoted strings
            values = []
            current = ''
            in_quotes = False
            quote_char = None
            
            i = 0
            while i < len(row):
                char = row[i]
                if not in_quotes and (char == "'" or char == '"'):
                    in_quotes = True
                    quote_char = char
                    current += char
                elif in_quotes and char == quote_char:
                    if i + 1 < len(row) and row[i+1] == quote_char:
                        current += char + char
                        i += 1
                    else:
                        in_quotes = False
                        quote_char = None
                        current += char
                elif not in_quotes and char == ',':
                    values.append(current.strip())
                    current = ''
                else:
                    current += char
                i += 1
            
            if current.strip():
                values.append(current.strip())
            
            # Check if we have enough values and if sponsored (index 29) > 0
            if len(values) >= 30:
                try:
                    sponsored = int(values[29].strip())
                    if sponsored > 0:
                        venue_id = int(values[0].strip())
                        venue_name = values[6].strip().strip("'").strip('"')
                        venue_status = values[28].strip().strip("'").strip('"')
                        category_id = int(values[2].strip()) if values[2].strip().isdigit() else 0
                        location_id = int(values[4].strip()) if values[4].strip().isdigit() else 0
                        rating = int(values[21].strip()) if values[21].strip().isdigit() else 0
                        reviews = int(values[22].strip()) if values[22].strip().isdigit() else 0
                        time_added = values[27].strip().strip("'").strip('"')
                        
                        sponsored_venues.append({
                            'venue_id': venue_id,
                            'venue_name': venue_name,
                            'sponsored': sponsored,
                            'venue_status': venue_status,
                            'category_id': category_id,
                            'location_id': location_id,
                            'venue_rating': rating,
                            'venue_reviews': reviews,
                            'time_added': time_added
                        })
                except (ValueError, IndexError) as e:
                    pass
    
    # Sort by sponsored level
    sponsored_venues.sort(key=lambda x: x['sponsored'], reverse=True)
    
    print(f'Found {len(sponsored_venues)} sponsored venues:\n')
    for i, venue in enumerate(sponsored_venues, 1):
        print(f"{i}. Venue ID: {venue['venue_id']}")
        print(f"   Name: {venue['venue_name']}")
        print(f"   Sponsored Level: {venue['sponsored']}")
        print(f"   Status: {venue['venue_status']}")
        print(f"   Category ID: {venue['category_id']}")
        print(f"   Location ID: {venue['location_id']}")
        print(f"   Rating: {venue['venue_rating']}")
        print(f"   Reviews: {venue['venue_reviews']}")
        print(f"   Added: {venue['time_added']}")
        print()
    
    if len(sponsored_venues) == 0:
        print("No sponsored venues found (all have sponsored = 0)")
        sys.exit(0)
    
except Exception as e:
    print(f"Error: {e}", file=sys.stderr)
    import traceback
    traceback.print_exc()
    sys.exit(1)

