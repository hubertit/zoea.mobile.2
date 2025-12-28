import { NextResponse } from 'next/server';
import { query } from '@/lib/db';

export async function GET() {
  try {
    // Get total users
    const totalUsersResult = await query<{ count: number }[]>(
      'SELECT COUNT(*) as count FROM users'
    );
    const totalUsers = totalUsersResult[0]?.count || 0;

    // Get active users
    const activeUsersResult = await query<{ count: number }[]>(
      'SELECT COUNT(*) as count FROM users WHERE user_status = ?',
      ['active']
    );
    const activeUsers = activeUsersResult[0]?.count || 0;

    // Get total venues
    const venuesResult = await query<{ count: number }[]>(
      'SELECT COUNT(*) as count FROM venues WHERE venue_status = ?',
      ['active']
    );
    const activeVenues = venuesResult[0]?.count || 0;

    // Get total properties
    const propertiesResult = await query<{ count: number }[]>(
      'SELECT COUNT(*) as count FROM properties WHERE status = ?',
      ['available']
    );
    const totalProperties = propertiesResult[0]?.count || 0;

    // Get total events
    const eventsResult = await query<{ count: number }[]>(
      'SELECT COUNT(*) as count FROM events'
    );
    const totalEvents = eventsResult[0]?.count || 0;

    // Get total orders
    const ordersResult = await query<{ count: number }[]>(
      'SELECT COUNT(*) as count FROM orders'
    );
    const totalOrders = ordersResult[0]?.count || 0;

    // Get total revenue
    const revenueResult = await query<{ total: number }[]>(
      'SELECT COALESCE(SUM(total_amount), 0) as total FROM orders WHERE status != ?',
      ['cancelled']
    );
    const totalRevenue = revenueResult[0]?.total || 0;

    // Get inactive users
    const inactiveUsersResult = await query<{ count: number }[]>(
      'SELECT COUNT(*) as count FROM users WHERE user_status = ?',
      ['inactive']
    );
    const inactiveUsers = inactiveUsersResult[0]?.count || 0;

    // Get pending venues
    const pendingVenuesResult = await query<{ count: number }[]>(
      'SELECT COUNT(*) as count FROM venues WHERE venue_status = ?',
      ['pending']
    );
    const pendingVenues = pendingVenuesResult[0]?.count || 0;

    // Get total applications
    const applicationsResult = await query<{ count: number }[]>(
      'SELECT COUNT(*) as count FROM application'
    );
    const totalApplications = applicationsResult[0]?.count || 0;

    // Get pending applications
    const pendingApplicationsResult = await query<{ count: number }[]>(
      'SELECT COUNT(*) as count FROM application WHERE status = ?',
      ['pending']
    );
    const pendingApplications = pendingApplicationsResult[0]?.count || 0;

    // Get total venues (all statuses)
    const totalVenuesResult = await query<{ count: number }[]>(
      'SELECT COUNT(*) as count FROM venues'
    );
    const totalVenues = totalVenuesResult[0]?.count || 0;

    return NextResponse.json({
      totalUsers,
      activeUsers,
      inactiveUsers,
      totalVenues,
      activeVenues,
      pendingVenues,
      totalProperties,
      totalEvents,
      totalOrders,
      totalRevenue,
      totalApplications,
      pendingApplications,
    });
  } catch (error) {
    console.error('Error fetching dashboard stats:', error);
    return NextResponse.json(
      { error: 'Failed to fetch dashboard statistics' },
      { status: 500 }
    );
  }
}

