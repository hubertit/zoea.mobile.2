'use client';

import { useState, useEffect } from 'react';
import { useRouter, useSearchParams } from 'next/navigation';
import { MerchantPortalAPI, type Business } from '@/src/lib/api';
import { toast } from '@/app/components/Toaster';
import { Button, Breadcrumbs } from '@/app/components';
import PageSkeleton from '@/app/components/PageSkeleton';
import Icon, { faChartLine, faDollarSign, faClipboardList } from '@/app/components/Icon';
import { LineChart, AreaChart, BarChart } from '@/app/components';
import dynamic from 'next/dynamic';

// Dynamically import charts to avoid SSR issues
const LineChartDynamic = dynamic(() => import('@/app/components/charts/LineChart').then(mod => ({ default: mod.default })), { ssr: false });
const AreaChartDynamic = dynamic(() => import('@/app/components/charts/AreaChart').then(mod => ({ default: mod.default })), { ssr: false });
const BarChartDynamic = dynamic(() => import('@/app/components/charts/BarChart').then(mod => ({ default: mod.default })), { ssr: false });

export default function MyAnalyticsPage() {
  const router = useRouter();
  const searchParams = useSearchParams();
  const [businesses, setBusinesses] = useState<Business[]>([]);
  const [selectedBusinessId, setSelectedBusinessId] = useState<string | null>(null);
  const [loading, setLoading] = useState(true);
  const [revenueData, setRevenueData] = useState<any>(null);
  const [bookingData, setBookingData] = useState<any>(null);
  const [dateRange, setDateRange] = useState({
    startDate: new Date(new Date().setMonth(new Date().getMonth() - 1)).toISOString().split('T')[0],
    endDate: new Date().toISOString().split('T')[0],
  });
  const [groupBy, setGroupBy] = useState<'day' | 'week' | 'month' | 'year'>('month');

  // Fetch businesses
  useEffect(() => {
    const fetchBusinesses = async () => {
      try {
        const data = await MerchantPortalAPI.getMyBusinesses();
        setBusinesses(data);
        const businessId = searchParams.get('businessId');
        if (businessId && data.find(b => b.id === businessId)) {
          setSelectedBusinessId(businessId);
        } else if (data.length > 0) {
          setSelectedBusinessId(data[0].id);
        }
      } catch (error: any) {
        console.error('Failed to fetch businesses:', error);
        toast.error(error?.response?.data?.message || error?.message || 'Failed to load businesses');
      } finally {
        setLoading(false);
      }
    };
    fetchBusinesses();
  }, []);

  // Fetch analytics
  useEffect(() => {
    if (!selectedBusinessId) return;

    const fetchAnalytics = async () => {
      try {
        const [revenue, bookings] = await Promise.all([
          MerchantPortalAPI.getRevenueAnalytics(selectedBusinessId, {
            startDate: dateRange.startDate,
            endDate: dateRange.endDate,
            groupBy,
          }),
          MerchantPortalAPI.getBookingAnalytics(selectedBusinessId, {
            startDate: dateRange.startDate,
            endDate: dateRange.endDate,
          }),
        ]);
        setRevenueData(revenue);
        setBookingData(bookings);
      } catch (error: any) {
        console.error('Failed to fetch analytics:', error);
        toast.error(error?.response?.data?.message || error?.message || 'Failed to load analytics');
      }
    };

    fetchAnalytics();
  }, [selectedBusinessId, dateRange, groupBy]);

  if (loading) {
    return <PageSkeleton />;
  }

  if (businesses.length === 0) {
    return (
      <div className="space-y-6">
        <Breadcrumbs items={[
          { label: 'Dashboard', href: '/dashboard/my-dashboard' },
          { label: 'Analytics' }
        ]} />
        <div className="flex items-center justify-center min-h-[400px]">
          <div className="text-center">
            <p className="text-gray-600">No businesses found.</p>
          </div>
        </div>
      </div>
    );
  }

  if (!selectedBusinessId) {
    return <PageSkeleton />;
  }

  const revenueChartData = revenueData?.periodData ? revenueData.periodData.map((item: any) => ({
    x: item.period,
    y: item.revenue,
  })) : [];

  const bookingChartData = bookingData?.periodData ? bookingData.periodData.map((item: any) => ({
    x: item.period,
    y: item.count || 0,
  })) : [];

  return (
    <div className="space-y-6">
      <Breadcrumbs items={[
        { label: 'Dashboard', href: '/dashboard/my-dashboard' },
        { label: 'Analytics' }
      ]} />

      {/* Business Selector */}
      <div className="bg-white border border-gray-200 rounded-sm p-4">
        <div className="flex items-center justify-between flex-wrap gap-4">
          <div className="flex-1 min-w-0">
            <label className="block text-sm font-medium text-gray-700 mb-2">
              Select Business
            </label>
            <select
              value={selectedBusinessId}
              onChange={(e) => setSelectedBusinessId(e.target.value)}
              className="w-full md:w-auto px-3 py-2 border border-gray-200 rounded-sm focus:outline-none focus:ring-1 focus:ring-[#0e1a30] focus:border-[#0e1a30] text-sm"
            >
              {businesses.map((business) => (
                <option key={business.id} value={business.id}>
                  {business.businessName}
                </option>
              ))}
            </select>
          </div>
        </div>
      </div>

      {/* Filters */}
      <div className="bg-white border border-gray-200 rounded-sm p-4">
        <div className="grid grid-cols-1 md:grid-cols-4 gap-4">
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">Start Date</label>
            <input
              type="date"
              value={dateRange.startDate}
              onChange={(e) => setDateRange({ ...dateRange, startDate: e.target.value })}
              className="w-full px-3 py-2 border border-gray-200 rounded-sm focus:outline-none focus:ring-1 focus:ring-[#0e1a30] focus:border-[#0e1a30] text-sm"
            />
          </div>
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">End Date</label>
            <input
              type="date"
              value={dateRange.endDate}
              onChange={(e) => setDateRange({ ...dateRange, endDate: e.target.value })}
              className="w-full px-3 py-2 border border-gray-200 rounded-sm focus:outline-none focus:ring-1 focus:ring-[#0e1a30] focus:border-[#0e1a30] text-sm"
            />
          </div>
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">Group By</label>
            <select
              value={groupBy}
              onChange={(e) => setGroupBy(e.target.value as 'day' | 'week' | 'month' | 'year')}
              className="w-full px-3 py-2 border border-gray-200 rounded-sm focus:outline-none focus:ring-1 focus:ring-[#0e1a30] focus:border-[#0e1a30] text-sm"
            >
              <option value="day">Day</option>
              <option value="week">Week</option>
              <option value="month">Month</option>
              <option value="year">Year</option>
            </select>
          </div>
          <div className="flex items-end">
            <Button
              variant="primary"
              onClick={() => {
                setDateRange({
                  startDate: new Date(new Date().setMonth(new Date().getMonth() - 1)).toISOString().split('T')[0],
                  endDate: new Date().toISOString().split('T')[0],
                });
              }}
            >
              Reset
            </Button>
          </div>
        </div>
      </div>

      {/* Revenue Analytics */}
      <div className="bg-white border border-gray-200 rounded-sm p-6">
        <div className="flex items-center justify-between mb-4">
          <h2 className="text-lg font-semibold text-gray-900">Revenue Analytics</h2>
          {revenueData && (
            <div className="text-right">
              <p className="text-sm text-gray-600">Total Revenue</p>
              <p className="text-2xl font-bold text-gray-900">
                {revenueData.totalRevenue?.toLocaleString() || 0} RWF
              </p>
            </div>
          )}
        </div>
        {revenueChartData.length > 0 ? (
          <div className="h-80">
            <AreaChartDynamic
              data={revenueChartData}
              title="Revenue Over Time"
              height={320}
            />
          </div>
        ) : (
          <div className="h-80 flex items-center justify-center text-gray-500">
            No revenue data available for the selected period
          </div>
        )}
      </div>

      {/* Booking Analytics */}
      <div className="bg-white border border-gray-200 rounded-sm p-6">
        <h2 className="text-lg font-semibold text-gray-900 mb-4">Booking Analytics</h2>
        {bookingChartData.length > 0 ? (
          <div className="h-80">
            <BarChartDynamic
              data={bookingChartData}
              title="Bookings Over Time"
              height={320}
            />
          </div>
        ) : (
          <div className="h-80 flex items-center justify-center text-gray-500">
            No booking data available for the selected period
          </div>
        )}
      </div>
    </div>
  );
}

