import { NextResponse } from 'next/server';
import { query } from '@/lib/db';
import { Venue } from '@/types';

export async function GET() {
  try {
    const venues = await query<Venue[]>(
      'SELECT venue_id, user_id, category_id, venue_name, venue_about, venue_rating, venue_reviews, venue_status, venue_price, venue_address, venue_coordinates FROM venues ORDER BY venue_id DESC LIMIT 100'
    );

    return NextResponse.json(venues);
  } catch (error) {
    console.error('Error fetching venues:', error);
    return NextResponse.json(
      { error: 'Failed to fetch venues' },
      { status: 500 }
    );
  }
}

