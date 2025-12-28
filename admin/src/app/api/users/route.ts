import { NextResponse } from 'next/server';
import { query } from '@/lib/db';
import { User } from '@/types';

export async function GET() {
  try {
    const users = await query<User[]>(
      'SELECT user_id, venue_id, account_type, user_fname, user_lname, user_email, user_phone, user_status, user_reg_date FROM users ORDER BY user_reg_date DESC LIMIT 100'
    );

    return NextResponse.json(users);
  } catch (error) {
    console.error('Error fetching users:', error);
    return NextResponse.json(
      { error: 'Failed to fetch users' },
      { status: 500 }
    );
  }
}

