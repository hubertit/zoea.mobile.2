import { NextResponse } from 'next/server';
import { query } from '@/lib/db';
import { Order } from '@/types';

export async function GET() {
  try {
    const orders = await query<Order[]>(
      'SELECT id, order_no, customer_id, seller_id, total_amount, currency, status, order_date FROM orders ORDER BY order_date DESC LIMIT 100'
    );

    return NextResponse.json(orders);
  } catch (error) {
    console.error('Error fetching orders:', error);
    return NextResponse.json(
      { error: 'Failed to fetch orders' },
      { status: 500 }
    );
  }
}

