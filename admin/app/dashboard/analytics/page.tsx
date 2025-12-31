'use client';

import { useState, useEffect } from 'react';
import Card, { CardHeader, CardBody } from '@/app/components/Card';
import LineChart from '@/app/components/charts/LineChart';
import BarChart from '@/app/components/charts/BarChart';
import DonutChart from '@/app/components/charts/DonutChart';
import AreaChart from '@/app/components/charts/AreaChart';
import Icon, { faUsers, faClipboardList, faCalendar, faDollarSign, faChartLine } from '@/app/components/Icon';
import { getDashboardStats } from '@/src/lib/api/dashboard';
import { UsersAPI, BookingsAPI, EventsAPI, PaymentsAPI } from '@/src/lib/api';
import { toast } from '@/app/components/Toaster';
import PageSkeleton from '@/app/components/PageSkeleton';

interface AnalyticsData {
  userGrowth: { date: string; count: number }[];
  bookingTrends: { date: string; count: number; revenue: number }[];
  userDistribution: { role: string; count: number }[];
  bookingStatusDistribution: { status: string; count: number }[];
  revenueBySource: { source: string; amount: number }[];
}

export default function AnalyticsPage() {
  const [loading, setLoading] = useState(true);
  const [analyticsData, setAnalyticsData] = useState<AnalyticsData | null>(null);
  const [dateRange, setDateRange] = useState<'7d' | '30d' | '90d' | '1y'>('30d');

  useEffect(() => {
    const fetchAnalytics = async () => {
      setLoading(true);
      try {
        // Fetch dashboard stats
        const stats = await getDashboardStats();

        // Fetch users for growth chart
        const usersRes = await UsersAPI.listUsers({ limit: 1000, page: 1 });
        const users = usersRes.data || [];

        // Fetch bookings for trends
        const bookingsRes = await BookingsAPI.listBookings({ limit: 1000, page: 1 });
        const bookings = bookingsRes.data || [];

        // Fetch events
        const eventsRes = await EventsAPI.listEvents({ limit: 1000, page: 1 });
        const events = eventsRes.data || [];

        // Fetch transactions for revenue
        let transactions: any[] = [];
        try {
          const transactionsRes = await PaymentsAPI.listTransactions({ limit: 1000, page: 1 });
          transactions = transactionsRes.data || [];
        } catch (e) {
          console.warn('Could not fetch transactions:', e);
        }

        // Calculate date range
        const now = new Date();
        const daysBack = dateRange === '7d' ? 7 : dateRange === '30d' ? 30 : dateRange === '90d' ? 90 : 365;
        const startDate = new Date(now);
        startDate.setDate(startDate.getDate() - daysBack);

        // User growth chart data (last 30 days by default)
        const userGrowthMap = new Map<string, number>();
        users.forEach((user: any) => {
          const date = new Date(user.createdAt);
          if (date >= startDate) {
            const dateKey = date.toISOString().split('T')[0];
            userGrowthMap.set(dateKey, (userGrowthMap.get(dateKey) || 0) + 1);
          }
        });
        const userGrowth = Array.from(userGrowthMap.entries())
          .map(([date, count]) => ({ date, count }))
          .sort((a, b) => a.date.localeCompare(b.date));

        // Booking trends chart data
        const bookingTrendsMap = new Map<string, { count: number; revenue: number }>();
        bookings.forEach((booking: any) => {
          const date = new Date(booking.createdAt || booking.bookingDate);
          if (date >= startDate) {
            const dateKey = date.toISOString().split('T')[0];
            const existing = bookingTrendsMap.get(dateKey) || { count: 0, revenue: 0 };
            bookingTrendsMap.set(dateKey, {
              count: existing.count + 1,
              revenue: existing.revenue + (booking.totalAmount || 0),
            });
          }
        });
        const bookingTrends = Array.from(bookingTrendsMap.entries())
          .map(([date, data]) => ({ date, ...data }))
          .sort((a, b) => a.date.localeCompare(b.date));

        // User distribution by role
        const roleCounts = new Map<string, number>();
        users.forEach((user: any) => {
          const roles = user.roles || [];
          roles.forEach((role: any) => {
            const roleName = typeof role === 'string' ? role : (role.code || role.name || 'unknown');
            roleCounts.set(roleName, (roleCounts.get(roleName) || 0) + 1);
          });
        });
        const userDistribution = Array.from(roleCounts.entries())
          .map(([role, count]) => ({ role: role.replace(/_/g, ' '), count }))
          .sort((a, b) => b.count - a.count);

        // Booking status distribution
        const statusCounts = new Map<string, number>();
        bookings.forEach((booking: any) => {
          const status = booking.status || 'unknown';
          statusCounts.set(status, (statusCounts.get(status) || 0) + 1);
        });
        const bookingStatusDistribution = Array.from(statusCounts.entries())
          .map(([status, count]) => ({ status: status.replace(/_/g, ' '), count }))
          .sort((a, b) => b.count - a.count);

        // Revenue by source (from transactions)
        const revenueBySource = new Map<string, number>();
        transactions.forEach((tx: any) => {
          if (tx.status === 'completed' && tx.amount) {
            const source = tx.type || 'other';
            revenueBySource.set(source, (revenueBySource.get(source) || 0) + tx.amount);
          }
        });
        const revenueBySourceArray = Array.from(revenueBySource.entries())
          .map(([source, amount]) => ({ source: source.replace(/_/g, ' '), amount }))
          .sort((a, b) => b.amount - a.amount);

        setAnalyticsData({
          userGrowth,
          bookingTrends,
          userDistribution,
          bookingStatusDistribution,
          revenueBySource: revenueBySourceArray,
        });
      } catch (error: any) {
        console.error('Failed to fetch analytics:', error);
        toast.error(error?.message || 'Failed to load analytics data');
      } finally {
        setLoading(false);
      }
    };

    fetchAnalytics();
  }, [dateRange]);

  if (loading) {
    return <PageSkeleton />;
  }

  if (!analyticsData) {
    return (
      <div className="flex items-center justify-center min-h-[400px]">
        <Card>
          <CardBody className="text-center">
            <p className="text-gray-600">No analytics data available</p>
          </CardBody>
        </Card>
      </div>
    );
  }

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex items-center justify-between flex-wrap gap-4">
        <div>
          <h1 className="text-2xl font-bold text-gray-900">Analytics</h1>
          <p className="text-gray-600 mt-1">Platform analytics and insights</p>
        </div>
        <div>
          <select
            value={dateRange}
            onChange={(e) => setDateRange(e.target.value as '7d' | '30d' | '90d' | '1y')}
            className="px-3 py-2 border border-gray-200 rounded-sm focus:outline-none focus:ring-1 focus:ring-[#0e1a30] focus:border-[#0e1a30] text-sm"
          >
            <option value="7d">Last 7 days</option>
            <option value="30d">Last 30 days</option>
            <option value="90d">Last 90 days</option>
            <option value="1y">Last year</option>
          </select>
        </div>
      </div>

      {/* Charts Grid */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        {/* User Growth Chart */}
        <Card>
          <CardHeader>
            <div className="flex items-center gap-2">
              <Icon icon={faUsers} className="text-[#0e1a30]" size="sm" />
              <h2 className="text-lg font-semibold text-gray-900">User Growth</h2>
            </div>
          </CardHeader>
          <CardBody>
            {analyticsData.userGrowth.length > 0 ? (
              <LineChart
                data={analyticsData.userGrowth.map((d) => ({
                  x: new Date(d.date).toLocaleDateString('en-US', { month: 'short', day: 'numeric' }),
                  y: d.count,
                }))}
                title="New Users"
              />
            ) : (
              <p className="text-sm text-gray-500 text-center py-8">No user growth data available</p>
            )}
          </CardBody>
        </Card>

        {/* Booking Trends Chart */}
        <Card>
          <CardHeader>
            <div className="flex items-center gap-2">
              <Icon icon={faClipboardList} className="text-[#0e1a30]" size="sm" />
              <h2 className="text-lg font-semibold text-gray-900">Booking Trends</h2>
            </div>
          </CardHeader>
          <CardBody>
            {analyticsData.bookingTrends.length > 0 ? (
              <AreaChart
                data={analyticsData.bookingTrends.map((d) => ({
                  x: new Date(d.date).toLocaleDateString('en-US', { month: 'short', day: 'numeric' }),
                  y: d.count,
                }))}
                title="Bookings Over Time"
              />
            ) : (
              <p className="text-sm text-gray-500 text-center py-8">No booking trends data available</p>
            )}
          </CardBody>
        </Card>

        {/* User Distribution by Role */}
        <Card>
          <CardHeader>
            <div className="flex items-center gap-2">
              <Icon icon={faUsers} className="text-[#0e1a30]" size="sm" />
              <h2 className="text-lg font-semibold text-gray-900">Users by Role</h2>
            </div>
          </CardHeader>
          <CardBody>
            {analyticsData.userDistribution.length > 0 ? (
              <DonutChart
                data={analyticsData.userDistribution.map((d) => ({
                  label: d.role,
                  value: d.count,
                }))}
                title="User Distribution"
                colors={['#0e1a30', '#1a2d4a', '#264a6e', '#326792', '#3e84b6', '#4aa1da']}
              />
            ) : (
              <p className="text-sm text-gray-500 text-center py-8">No user distribution data available</p>
            )}
          </CardBody>
        </Card>

        {/* Booking Status Distribution */}
        <Card>
          <CardHeader>
            <div className="flex items-center gap-2">
              <Icon icon={faClipboardList} className="text-[#0e1a30]" size="sm" />
              <h2 className="text-lg font-semibold text-gray-900">Bookings by Status</h2>
            </div>
          </CardHeader>
          <CardBody>
            {analyticsData.bookingStatusDistribution.length > 0 ? (
              <BarChart
                data={analyticsData.bookingStatusDistribution.map((d) => ({
                  x: d.status,
                  y: d.count,
                }))}
                title="Booking Status"
              />
            ) : (
              <p className="text-sm text-gray-500 text-center py-8">No booking status data available</p>
            )}
          </CardBody>
        </Card>

        {/* Revenue by Source */}
        {analyticsData.revenueBySource.length > 0 && (
          <Card className="lg:col-span-2">
            <CardHeader>
              <div className="flex items-center gap-2">
                <Icon icon={faDollarSign} className="text-[#0e1a30]" size="sm" />
                <h2 className="text-lg font-semibold text-gray-900">Revenue by Source</h2>
              </div>
            </CardHeader>
            <CardBody>
              <BarChart
                data={analyticsData.revenueBySource.map((d) => ({
                  x: d.source,
                  y: d.amount,
                }))}
                title="Revenue Breakdown"
              />
            </CardBody>
          </Card>
        )}
      </div>
    </div>
  );
}
