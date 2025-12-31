'use client';

import Card, { CardHeader, CardBody } from '../components/Card';
import StatCard from '../components/StatCard';
import Icon, { faUsers, faBox, faCalendar, faClipboardList, faExclamationTriangle } from '../components/Icon';
import DashboardSkeleton from '../components/DashboardSkeleton';
import { useState, useEffect } from 'react';
import { getDashboardStats, DashboardStats } from '@/src/lib/api/dashboard';
import { toast } from '../components/Toaster';
import { useAuthStore } from '@/src/store/auth';

export default function DashboardPage() {
  const [loading, setLoading] = useState(true);
  const [stats, setStats] = useState<DashboardStats | null>(null);
  const { user } = useAuthStore();

  useEffect(() => {
    async function fetchStats() {
      try {
        setLoading(true);
        const data = await getDashboardStats();
        setStats(data);
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

    fetchStats();
  }, [user]);

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
      <div>
        <h1 className="text-2xl font-bold text-gray-900">Dashboard</h1>
        <p className="mt-1 text-sm text-gray-600">Welcome to the Zoea Admin Portal</p>
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

      {/* Placeholder Content */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        <Card>
          <CardHeader>
            <h2 className="text-lg font-semibold text-gray-900">Recent Activity</h2>
          </CardHeader>
          <CardBody>
            <p className="text-sm text-gray-600">Activity feed will be displayed here</p>
          </CardBody>
        </Card>
        <Card>
          <CardHeader>
            <h2 className="text-lg font-semibold text-gray-900">Quick Actions</h2>
          </CardHeader>
          <CardBody>
            <p className="text-sm text-gray-600">Quick actions will be displayed here</p>
          </CardBody>
        </Card>
      </div>
    </div>
  );
}

