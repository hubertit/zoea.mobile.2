import { NextResponse } from 'next/server';
import { query } from '@/lib/db';
import { Property } from '@/types';

export async function GET() {
  try {
    const properties = await query<Property[]>(
      'SELECT property_id, location_id, agent_id, category, bedrooms, bathrooms, size, price, property_type, status, title, address FROM properties ORDER BY property_id DESC LIMIT 100'
    );

    return NextResponse.json(properties);
  } catch (error) {
    console.error('Error fetching properties:', error);
    return NextResponse.json(
      { error: 'Failed to fetch properties' },
      { status: 500 }
    );
  }
}

