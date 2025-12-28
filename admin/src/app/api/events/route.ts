import { NextResponse } from 'next/server';
import { query } from '@/lib/db';
import { Application } from '@/types';

export async function GET() {
  try {
    const applications = await query<Application[]>(
      'SELECT id, event, title, first_name, last_name, organization, work_title, phone, email, status, updated_date FROM application ORDER BY updated_date DESC LIMIT 100'
    );

    return NextResponse.json(applications);
  } catch (error) {
    console.error('Error fetching events:', error);
    return NextResponse.json(
      { error: 'Failed to fetch events' },
      { status: 500 }
    );
  }
}

