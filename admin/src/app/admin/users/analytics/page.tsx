'use client';

import { useState, useEffect } from 'react';
import Icon, { faUsers, faUserPlus, faChartLine, faUserShield, faArrowRight } from '../../../components/Icon';
import ChartWrapper from '../../../components/ChartWrapper';
import LineChart from '../../../components/charts/LineChart';
import BarChart from '../../../components/charts/BarChart';
import PieChart from '../../../components/charts/PieChart';
import DataTable from '../../../components/DataTable';
import { mockChartData, mockDashboardStats, mockAnalyticsData } from '@/lib/mockData';

export default function UserAnalyticsPage() {
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    setLoading(false);
  }, []);

  return (
    <div>
      <div className="mb-8">
        <h1 className="text-3xl font-bold text-gray-900 mb-2">User Analytics</h1>
        <p className="text-gray-600">User growth, activity, and engagement metrics</p>
      </div>

      {/* Summary Stats */}
      <div className="grid grid-cols-1 md:grid-cols-4 gap-6 mb-6">
        <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-6">
          <div className="flex items-center gap-3 mb-2">
            <Icon icon={faUsers} className="text-primary" />
            <p className="text-sm text-gray-500">Total Users</p>
          </div>
          <p className="text-2xl font-bold text-gray-900">{mockDashboardStats.totalUsers.toLocaleString()}</p>
        </div>
        <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-6">
          <div className="flex items-center gap-3 mb-2">
            <Icon icon={faChartLine} className="text-primary" />
            <p className="text-sm text-gray-500">New This Week</p>
          </div>
          <p className="text-2xl font-bold text-gray-900">142</p>
        </div>
        <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-6">
          <div className="flex items-center gap-3 mb-2">
            <Icon icon={faUserShield} className="text-primary" />
            <p className="text-sm text-gray-500">Inactive Users</p>
          </div>
          <p className="text-2xl font-bold text-gray-900">{mockDashboardStats.inactiveUsers.toLocaleString()}</p>
        </div>
        <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-6">
          <div className="flex items-center gap-3 mb-2">
            <Icon icon={faUsers} className="text-primary" />
            <p className="text-sm text-gray-500">Returning Users</p>
          </div>
          <p className="text-2xl font-bold text-gray-900">1,850</p>
        </div>
      </div>

      {/* KPIs Section */}
      <div className="grid grid-cols-1 md:grid-cols-4 gap-6 mb-6">
        <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-6">
          <div className="flex items-center gap-3 mb-2">
            <Icon icon={faUsers} className="text-primary" />
            <p className="text-sm text-gray-500">Active Users</p>
          </div>
          <p className="text-2xl font-bold text-gray-900">1.6K</p>
          <p className="text-xs text-green-600 mt-1">+356.7%</p>
        </div>
        <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-6">
          <div className="flex items-center gap-3 mb-2">
            <Icon icon={faChartLine} className="text-primary" />
            <p className="text-sm text-gray-500">Event Count</p>
          </div>
          <p className="text-2xl font-bold text-gray-900">6.8K</p>
          <p className="text-xs text-green-600 mt-1">+284.5%</p>
        </div>
        <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-6">
          <div className="flex items-center gap-3 mb-2">
            <Icon icon={faChartLine} className="text-primary" />
            <p className="text-sm text-gray-500">Key Events</p>
          </div>
          <p className="text-2xl font-bold text-gray-900">0</p>
          <p className="text-xs text-gray-500 mt-1">-</p>
        </div>
        <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-6">
          <div className="flex items-center gap-3 mb-2">
            <Icon icon={faUserPlus} className="text-primary" />
            <p className="text-sm text-gray-500">New Users</p>
          </div>
          <p className="text-2xl font-bold text-gray-900">1.6K</p>
          <p className="text-xs text-green-600 mt-1">+367.5%</p>
        </div>
      </div>

      {/* Time Series Chart */}
      <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-6 mb-6">
        <div className="flex items-center justify-between mb-4">
          <h2 className="text-lg font-semibold text-gray-900">User & Event Activity (Last 30 days)</h2>
          <select className="text-sm border border-gray-200 rounded-lg px-3 py-1">
            <option>Last 30 days</option>
            <option>Last 7 days</option>
            <option>Last 90 days</option>
          </select>
        </div>
        <ChartWrapper title="" loading={loading}>
          <LineChart
            data={mockAnalyticsData.timeSeriesData}
            dataKey="date"
            lines={[
              { key: 'users', name: 'Last 30 days', color: '#181E29' },
              { key: 'previousUsers', name: 'Previous period', color: '#1a74e8' },
            ]}
            height={350}
          />
        </ChartWrapper>
      </div>

      {/* Charts Grid */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6 mb-6">
        <ChartWrapper title="User Growth (Last 7 Days)" loading={loading}>
          <BarChart
            data={mockChartData.userGrowth}
            dataKey="date"
            bars={[{ key: 'users', name: 'New Users', color: '#181E29' }]}
            height={300}
          />
        </ChartWrapper>

        <ChartWrapper title="Users by Account Type" loading={loading}>
          <PieChart
            data={[
              { name: 'Customers', value: 850 },
              { name: 'Merchants', value: 400 },
            ]}
            height={300}
          />
        </ChartWrapper>
      </div>

      {/* Active Users by Country */}
      <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-6 mb-6">
        <div className="flex items-center justify-between mb-4">
          <h2 className="text-lg font-semibold text-gray-900">Active users by Country ID</h2>
          <span className="text-sm text-gray-500">This year (Jan - Today)</span>
        </div>
        <DataTable
          columns={[
            { key: 'country', label: 'Country', sortable: true },
            { 
              key: 'users', 
              label: 'Active users', 
              sortable: true,
              render: (value: number) => value.toLocaleString(),
            },
            {
              key: 'change',
              label: 'Change',
              sortable: true,
              render: (value: number, row: any) => {
                const isPositive = row.changeType === 'increase';
                const color = isPositive ? 'text-green-600' : 'text-red-600';
                const sign = isPositive ? '+' : '';
                return (
                  <span className={color}>
                    {sign}{value.toFixed(1)}%
                  </span>
                );
              },
            },
          ]}
          data={mockAnalyticsData.usersByCountry}
          loading={loading}
        />
        <div className="mt-4">
          <a href="#" className="text-sm text-primary hover:underline flex items-center gap-1">
            View countries <Icon icon={faArrowRight} size="xs" />
          </a>
        </div>
      </div>

      {/* Page Views */}
      <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-6 mb-6">
        <div className="flex items-center justify-between mb-4">
          <h2 className="text-lg font-semibold text-gray-900">Views by Page title and screen</h2>
          <span className="text-sm text-gray-500">Last 7 days</span>
        </div>
        <DataTable
          columns={[
            { key: 'page', label: 'Page', sortable: true },
            { 
              key: 'views', 
              label: 'Views', 
              sortable: true,
            },
            {
              key: 'change',
              label: 'Change',
              sortable: true,
              render: (value: number, row: any) => {
                if (value === 0) return <span className="text-gray-500">-</span>;
                const isPositive = row.changeType === 'increase';
                const color = isPositive ? 'text-green-600' : 'text-red-600';
                const sign = isPositive ? '+' : '';
                return (
                  <span className={color}>
                    {sign}{value.toFixed(1)}%
                  </span>
                );
              },
            },
          ]}
          data={mockAnalyticsData.pageViews}
          loading={loading}
        />
        <div className="mt-4">
          <a href="#" className="text-sm text-primary hover:underline flex items-center gap-1">
            View pages and screens <Icon icon={faArrowRight} size="xs" />
          </a>
        </div>
      </div>

      {/* Sessions by Channel */}
      <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-6 mb-6">
        <div className="flex items-center justify-between mb-4">
          <h2 className="text-lg font-semibold text-gray-900">Sessions by Session primary channel</h2>
          <span className="text-sm text-gray-500">Last 7 days</span>
        </div>
        <DataTable
          columns={[
            { key: 'channel', label: 'Channel', sortable: true },
            { 
              key: 'sessions', 
              label: 'Sessions', 
              sortable: true,
            },
            {
              key: 'change',
              label: 'Change',
              sortable: true,
              render: (value: number, row: any) => {
                if (value === 0) return <span className="text-gray-500">-</span>;
                const isPositive = row.changeType === 'increase';
                const color = isPositive ? 'text-green-600' : 'text-red-600';
                const sign = isPositive ? '+' : '';
                return (
                  <span className={color}>
                    {sign}{value.toFixed(1)}%
                  </span>
                );
              },
            },
          ]}
          data={mockAnalyticsData.sessionsByChannel}
          loading={loading}
        />
        <div className="mt-4">
          <a href="#" className="text-sm text-primary hover:underline flex items-center gap-1">
            View traffic acquisition <Icon icon={faArrowRight} size="xs" />
          </a>
        </div>
      </div>
    </div>
  );
}

