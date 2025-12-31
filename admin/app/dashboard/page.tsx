'use client';

import Card, { CardHeader, CardBody } from '../components/Card';
import StatCard from '../components/StatCard';
import Icon, { faUsers, faBox, faCalendar, faClipboardList, faExclamationTriangle, faPlus, faChartLine, faDollarSign } from '../components/Icon';
import DashboardSkeleton from '../components/DashboardSkeleton';
import { useState, useEffect } from 'react';
import { getDashboardStats, DashboardStats } from '@/src/lib/api/dashboard';
import { toast } from '../components/Toaster';
import { useAuthStore } from '@/src/store/auth';
import { LineChart, AreaChart } from '../components';
import { UsersAPI, BookingsAPI, PaymentsAPI } from '@/src/lib/api';
import { useRouter } from 'next/navigation';
import { Button } from '../components';

export default function DashboardPage() {
  const router = useRouter();
  const [loading, setLoading] = useState(true);
  const [stats, setStats] = useState<DashboardStats | null>(null);
  const { user } = useAuthStore();
  const [dateRange, setDateRange] = useState<'7d' | '30d' | '90d' | '1y'>('30d');
  const [userGrowth, setUserGrowth] = useState<{ date: string; count: number }[]>([]);
  const [bookingTrends, setBookingTrends] = useState<{ date: string; count: number; revenue: number }[]>([]);
  const [recentActivity, setRecentActivity] = useState<any[]>([]);

  // Helper to fetch all paginated data
  const fetchAllPaginated = async (
    fetchFn: (params: any) => Promise<any>,
    params: any = {}
  ): Promise<any[]> => {
    const allData: any[] = [];
    let page = 1;
    const limit = 100;
    let hasMore = true;

    while (hasMore) {
      const response = await fetchFn({ ...params, page, limit });
      const data = response.data || [];
      allData.push(...data);
      
      const total = response.meta?.total || 0;
      hasMore = allData.length < total && data.length === limit;
      page++;
    }

    return allData;
  };

  useEffect(() => {
    async function fetchDashboardData() {
      try {
        setLoading(true);
        
        // Fetch basic stats
        const data = await getDashboardStats();
        setStats(data);

        // Calculate date range
        const now = new Date();
        const daysBack = dateRange === '7d' ? 7 : dateRange === '30d' ? 30 : dateRange === '90d' ? 90 : 365;
        const startDate = new Date(now);
        startDate.setDate(startDate.getDate() - daysBack);

        // Fetch users for growth chart
        try {
          const allUsers = await fetchAllPaginated(UsersAPI.listUsers);
          const usersByDate = allUsers
            .filter((u: any) => new Date(u.createdAt) >= startDate)
            .reduce((acc: any, user: any) => {
              const date = new Date(user.createdAt).toISOString().split('T')[0];
              acc[date] = (acc[date] || 0) + 1;
              return acc;
            }, {});

          const userGrowthData = Object.entries(usersByDate)
            .map(([date, count]) => ({ date, count: count as number }))
            .sort((a, b) => a.date.localeCompare(b.date));
          setUserGrowth(userGrowthData);
        } catch (error) {
          console.error('Failed to fetch user growth:', error);
        }

        // Fetch bookings for trends chart
        try {
          const allBookings = await fetchAllPaginated(BookingsAPI.listBookings);
          const bookingsByDate = allBookings
            .filter((b: any) => new Date(b.createdAt || b.bookingDate) >= startDate)
            .reduce((acc: any, booking: any) => {
              const date = new Date(booking.createdAt || booking.bookingDate).toISOString().split('T')[0];
              if (!acc[date]) {
                acc[date] = { count: 0, revenue: 0 };
              }
              acc[date].count += 1;
              acc[date].revenue += booking.totalAmount || 0;
              return acc;
            }, {});

          const bookingTrendsData = Object.entries(bookingsByDate)
            .map(([date, data]: [string, any]) => ({ date, count: data.count, revenue: data.revenue }))
            .sort((a, b) => a.date.localeCompare(b.date));
          setBookingTrends(bookingTrendsData);
        } catch (error) {
          console.error('Failed to fetch booking trends:', error);
        }

        // Fetch recent activity (recent bookings, users, etc.)
        try {
          const [recentBookings, recentUsers] = await Promise.all([
            BookingsAPI.listBookings({ limit: 5, page: 1 }),
            UsersAPI.listUsers({ limit: 5, page: 1 }),
          ]);

          const activities = [
            ...(recentBookings.data || []).map((b: any) => ({
              type: 'booking',
              message: `New booking #${b.bookingNumber} by ${b.user?.fullName || 'User'}`,
              date: b.createdAt,
              link: `/dashboard/bookings/${b.id}`,
            })),
            ...(recentUsers.data || []).map((u: any) => ({
              type: 'user',
              message: `New user registered: ${u.fullName || u.email || u.phoneNumber}`,
              date: u.createdAt,
              link: `/dashboard/users/${u.id}`,
            })),
          ]
            .sort((a, b) => new Date(b.date).getTime() - new Date(a.date).getTime())
            .slice(0, 10);

          setRecentActivity(activities);
        } catch (error) {
          console.error('Failed to fetch recent activity:', error);
        }
      } catch (error: any) {
        console.error('Error fetching dashboard stats:', error);
        
        // Check if it's a 403 error (access denied)
        if (error?.status === 403) {
          const hasAdminRole = user?.roles?.some(
            (role: any) => {
              const roleValue = typeof role === 'string' ? role : role.code;
              return roleValue === 'admin' || roleValue === 'super_admin';
            }
          );
          
          if (!hasAdminRole) {
            toast.error('Access denied. You need admin or super_admin role to access this page.');
          } else {
            toast.error(error?.message || 'Access denied. Please contact your administrator.');
          }
        } else {
          toast.error(error?.message || 'Failed to load dashboard statistics');
        }
      } finally {
        setLoading(false);
      }
    }

    fetchDashboardData();
  }, [user, dateRange]);

  // Check if user has admin role
  // Roles can be either strings (from backend) or objects with code property
  const hasAdminRole = user?.roles?.some(
    (role: any) => {
      const roleValue = typeof role === 'string' ? role : role.code;
      return roleValue === 'admin' || roleValue === 'super_admin';
    }
  );

  if (loading) {
    return <DashboardSkeleton />;
  }

  // Show access denied message if user doesn't have admin role
  if (!hasAdminRole) {
    return (
      <div className="flex items-center justify-center min-h-[400px]">
        <Card className="max-w-md">
          <CardBody className="text-center">
            <div className="w-16 h-16 bg-red-100 rounded-full flex items-center justify-center mx-auto mb-4">
              <Icon icon={faExclamationTriangle} className="text-red-600" size="2x" />
            </div>
            <h2 className="text-xl font-bold text-gray-900 mb-2">Access Denied</h2>
            <p className="text-sm text-gray-600 mb-4">
              You need admin or super_admin role to access the dashboard.
            </p>
            <p className="text-xs text-gray-500">
              Please contact your administrator to get the required permissions.
            </p>
          </CardBody>
        </Card>
      </div>
    );
  }

  const formatNumber = (num: number) => {
    return new Intl.NumberFormat('en-US').format(num);
  };

  return (
    <div className="space-y-6">
      {/* Page Header */}
      <div className="flex items-center justify-between flex-wrap gap-4">
        <div>
          <h1 className="text-2xl font-bold text-gray-900">Dashboard</h1>
          <p className="mt-1 text-sm text-gray-600">Welcome to the Zoea Admin Portal</p>
        </div>
        
        {/* Date Range Filter */}
        <div className="flex items-center gap-2">
          <label className="text-sm text-gray-700">Date Range:</label>
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

      {/* Stat Cards */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
        <StatCard
          title="Total Users"
          value={formatNumber(stats?.users.total || 0)}
          icon={faUsers}
          href="/dashboard/users"
          trend={
            stats?.users.newThisMonth
              ? {
                  value: stats.users.newThisMonth,
                  label: 'new this month',
                }
              : undefined
          }
        />
        <StatCard
          title="Total Listings"
          value={formatNumber(stats?.listings.total || 0)}
          icon={faBox}
          href="/dashboard/listings"
          subtitle={stats?.listings.pending ? `${formatNumber(stats.listings.pending)} pending review` : undefined}
        />
        <StatCard
          title="Total Events"
          value={formatNumber(stats?.events.total || 0)}
          icon={faCalendar}
          href="/dashboard/events"
          subtitle={stats?.events.upcoming ? `${formatNumber(stats.events.upcoming)} upcoming` : undefined}
        />
        <StatCard
          title="Total Bookings"
          value={formatNumber(stats?.bookings.total || 0)}
          icon={faClipboardList}
          href="/dashboard/bookings"
          trend={
            stats?.bookings.thisMonth
              ? {
                  value: stats.bookings.thisMonth,
                  label: 'this month',
                }
              : undefined
          }
        />
      </div>

      {/* Additional Stats */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
        <Card>
          <CardBody>
            <div className="flex items-center justify-between">
              <div>
                <p className="text-sm text-gray-600">Active Users</p>
                <p className="text-2xl font-bold text-gray-900 mt-1">
                  {formatNumber(stats?.users.active || 0)}
                </p>
              </div>
              <div className="w-12 h-12 bg-green-100 rounded-full flex items-center justify-center">
                <Icon icon={faUsers} className="text-green-600" size="md" />
              </div>
            </div>
          </CardBody>
        </Card>
        <Card>
          <CardBody>
            <div className="flex items-center justify-between">
              <div>
                <p className="text-sm text-gray-600">Active Listings</p>
                <p className="text-2xl font-bold text-gray-900 mt-1">
                  {formatNumber(stats?.listings.active || 0)}
                </p>
              </div>
              <div className="w-12 h-12 bg-blue-100 rounded-full flex items-center justify-center">
                <Icon icon={faBox} className="text-blue-600" size="md" />
              </div>
            </div>
          </CardBody>
        </Card>
        <Card>
          <CardBody>
            <div className="flex items-center justify-between">
              <div>
                <p className="text-sm text-gray-600">Pending Bookings</p>
                <p className="text-2xl font-bold text-gray-900 mt-1">
                  {formatNumber(stats?.bookings.pending || 0)}
                </p>
              </div>
              <div className="w-12 h-12 bg-yellow-100 rounded-full flex items-center justify-center">
                <Icon icon={faClipboardList} className="text-yellow-600" size="md" />
              </div>
            </div>
          </CardBody>
        </Card>
        <Card>
          <CardBody>
            <div className="flex items-center justify-between">
              <div>
                <p className="text-sm text-gray-600">Completed Bookings</p>
                <p className="text-2xl font-bold text-gray-900 mt-1">
                  {formatNumber(stats?.bookings.completed || 0)}
                </p>
              </div>
              <div className="w-12 h-12 bg-green-100 rounded-full flex items-center justify-center">
                <Icon icon={faClipboardList} className="text-green-600" size="md" />
              </div>
            </div>
          </CardBody>
        </Card>
      </div>

      {/* Charts */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        <Card>
          <CardHeader>
            <h2 className="text-lg font-semibold text-gray-900">User Growth</h2>
          </CardHeader>
          <CardBody>
            {userGrowth.length > 0 ? (
              <LineChart
                title="New Users"
                data={userGrowth.map((item) => ({
                  x: new Date(item.date).toLocaleDateString('en-US', { month: 'short', day: 'numeric' }),
                  y: item.count,
                }))}
                height={300}
                showLegend={false}
              />
            ) : (
              <p className="text-sm text-gray-600 text-center py-8">No data available</p>
            )}
          </CardBody>
        </Card>

        <Card>
          <CardHeader>
            <h2 className="text-lg font-semibold text-gray-900">Booking Trends</h2>
          </CardHeader>
          <CardBody>
            {bookingTrends.length > 0 ? (
              <AreaChart
                title="Bookings & Revenue"
                data={bookingTrends.map((item) => ({
                  x: new Date(item.date).toLocaleDateString('en-US', { month: 'short', day: 'numeric' }),
                  y: item.count,
                }))}
                height={300}
                showLegend={false}
              />
            ) : (
              <p className="text-sm text-gray-600 text-center py-8">No data available</p>
            )}
          </CardBody>
        </Card>
      </div>

      {/* Recent Activity & Quick Actions */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        <Card>
          <CardHeader>
            <h2 className="text-lg font-semibold text-gray-900">Recent Activity</h2>
          </CardHeader>
          <CardBody>
            {recentActivity.length > 0 ? (
              <div className="space-y-3">
                {recentActivity.map((activity, index) => (
                  <div
                    key={index}
                    className="flex items-start gap-3 p-3 border border-gray-200 rounded-sm hover:bg-gray-50 transition-colors cursor-pointer"
                    onClick={() => activity.link && router.push(activity.link)}
                  >
                    <div className="flex-shrink-0 w-2 h-2 bg-[#0e1a30] rounded-full mt-2"></div>
                    <div className="flex-1 min-w-0">
                      <p className="text-sm text-gray-900">{activity.message}</p>
                      <p className="text-xs text-gray-500 mt-1">
                        {new Date(activity.date).toLocaleString()}
                      </p>
                    </div>
                  </div>
                ))}
              </div>
            ) : (
              <p className="text-sm text-gray-600 text-center py-8">No recent activity</p>
            )}
          </CardBody>
        </Card>

        <Card>
          <CardHeader>
            <h2 className="text-lg font-semibold text-gray-900">Quick Actions</h2>
          </CardHeader>
          <CardBody>
            <div className="grid grid-cols-2 gap-3">
              <Button
                variant="outline"
                onClick={() => router.push('/dashboard/users')}
                className="flex flex-col items-center gap-2 h-auto py-4"
              >
                <Icon icon={faUsers} size="lg" />
                <span className="text-sm">Manage Users</span>
              </Button>
              <Button
                variant="outline"
                onClick={() => router.push('/dashboard/listings')}
                className="flex flex-col items-center gap-2 h-auto py-4"
              >
                <Icon icon={faBox} size="lg" />
                <span className="text-sm">Manage Listings</span>
              </Button>
              <Button
                variant="outline"
                onClick={() => router.push('/dashboard/events')}
                className="flex flex-col items-center gap-2 h-auto py-4"
              >
                <Icon icon={faCalendar} size="lg" />
                <span className="text-sm">Manage Events</span>
              </Button>
              <Button
                variant="outline"
                onClick={() => router.push('/dashboard/bookings')}
                className="flex flex-col items-center gap-2 h-auto py-4"
              >
                <Icon icon={faClipboardList} size="lg" />
                <span className="text-sm">View Bookings</span>
              </Button>
              <Button
                variant="outline"
                onClick={() => router.push('/dashboard/reports')}
                className="flex flex-col items-center gap-2 h-auto py-4"
              >
                <Icon icon={faChartLine} size="lg" />
                <span className="text-sm">Generate Reports</span>
              </Button>
              <Button
                variant="outline"
                onClick={() => router.push('/dashboard/settings')}
                className="flex flex-col items-center gap-2 h-auto py-4"
              >
                <Icon icon={faExclamationTriangle} size="lg" />
                <span className="text-sm">Settings</span>
              </Button>
            </div>
          </CardBody>
        </Card>
      </div>
    </div>
  );
}

