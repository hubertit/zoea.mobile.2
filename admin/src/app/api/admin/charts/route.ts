import { NextResponse } from 'next/server';
import { query } from '@/lib/db';

export async function GET() {
  try {
    // Revenue over time (last 7 days)
    const revenueData = await query<Array<{ date: string; revenue: number; orders: number }>>(
      `SELECT 
        DATE(order_date) as date,
        COALESCE(SUM(total_amount), 0) as revenue,
        COUNT(*) as orders
      FROM orders 
      WHERE status != 'cancelled' 
        AND order_date >= DATE_SUB(CURDATE(), INTERVAL 7 DAY)
      GROUP BY DATE(order_date)
      ORDER BY date ASC`
    );

    // Orders by status
    const ordersByStatus = await query<Array<{ status: string; count: number }>>(
      `SELECT status, COUNT(*) as count 
       FROM orders 
       GROUP BY status`
    );

    // User registrations over time (last 7 days)
    const userGrowth = await query<Array<{ date: string; users: number }>>(
      `SELECT 
        DATE(user_reg_date) as date,
        COUNT(*) as users
      FROM users 
      WHERE user_reg_date >= DATE_SUB(CURDATE(), INTERVAL 7 DAY)
      GROUP BY DATE(user_reg_date)
      ORDER BY date ASC`
    );

    // Applications by status
    const applicationsByStatus = await query<Array<{ status: string; count: number }>>(
      `SELECT status, COUNT(*) as count 
       FROM application 
       GROUP BY status`
    );

    // Properties by category
    const propertiesByCategory = await query<Array<{ category: string; count: number }>>(
      `SELECT category, COUNT(*) as count 
       FROM properties 
       WHERE status = 'available'
       GROUP BY category`
    );

    // Generate last 7 days dates for revenue chart
    const last7Days = Array.from({ length: 7 }, (_, i) => {
      const date = new Date();
      date.setDate(date.getDate() - (6 - i));
      return date.toISOString().split('T')[0];
    });

    const revenueMap = new Map(
      revenueData.map(item => [item.date.toString().split('T')[0], item])
    );

    const revenueChartData = last7Days.map(date => {
      const data = revenueMap.get(date);
      return {
        date: new Date(date).toLocaleDateString('en-US', { month: 'short', day: 'numeric' }),
        revenue: data ? Number(data.revenue) || 0 : 0,
        orders: data ? Number(data.orders) || 0 : 0,
      };
    });

    // Generate last 7 days dates for user growth chart
    const userGrowthMap = new Map(
      userGrowth.map(item => [item.date.toString().split('T')[0], item])
    );

    const userGrowthChartData = last7Days.map(date => {
      const data = userGrowthMap.get(date);
      return {
        date: new Date(date).toLocaleDateString('en-US', { month: 'short', day: 'numeric' }),
        users: data ? Number(data.users) || 0 : 0,
      };
    });

    return NextResponse.json({
      revenue: revenueChartData,
      ordersByStatus: ordersByStatus.length > 0 
        ? ordersByStatus.map(item => ({
            name: item.status.charAt(0).toUpperCase() + item.status.slice(1),
            value: Number(item.count) || 0,
          }))
        : [{ name: 'No Data', value: 0 }],
      userGrowth: userGrowthChartData,
      applicationsByStatus: applicationsByStatus.length > 0
        ? applicationsByStatus.map(item => ({
            name: item.status.charAt(0).toUpperCase() + item.status.slice(1),
            value: Number(item.count) || 0,
          }))
        : [{ name: 'No Data', value: 0 }],
      propertiesByCategory: propertiesByCategory.length > 0
        ? propertiesByCategory.map(item => ({
            name: item.category || 'Unknown',
            value: Number(item.count) || 0,
          }))
        : [{ name: 'No Data', value: 0 }],
    });
  } catch (error) {
    console.error('Error fetching chart data:', error);
    return NextResponse.json(
      { error: 'Failed to fetch chart data' },
      { status: 500 }
    );
  }
}

