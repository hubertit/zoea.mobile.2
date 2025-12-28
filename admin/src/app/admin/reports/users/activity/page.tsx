'use client';

import { useState } from 'react';
import Icon, { faDownload, faUsers, faClock, faChartLine, faArrowLeft } from '../../../../components/Icon';
import Link from 'next/link';
import ChartWrapper from '../../../../components/ChartWrapper';
import LineChart from '../../../../components/charts/LineChart';
import BarChart from '../../../../components/charts/BarChart';
import { mockChartData, mockDashboardStats } from '@/lib/mockData';

export default function UserActivityReportPage() {
  const [dateRange, setDateRange] = useState({
    start: '2025-01-01',
    end: '2025-12-31',
  });

  return (
    <div>
      <div className="mb-8">
        <div className="flex items-center justify-between mb-4">
          <div className="flex items-center gap-4">
            <Link
              href="/admin/reports"
              className="p-2 hover:bg-gray-100 rounded-lg transition-colors"
            >
              <Icon icon={faArrowLeft} />
            </Link>
            <div>
              <h1 className="text-3xl font-bold text-gray-900 mb-2">User Activity Report</h1>
              <p className="text-gray-600">User engagement and activity metrics</p>
            </div>
          </div>
          <button className="flex items-center gap-2 bg-primary text-white px-4 py-2 rounded-lg hover:bg-primary-600 transition-colors">
            <Icon icon={faDownload} />
            <span>Export</span>
          </button>
        </div>
      </div>

      {/* Filters */}
      <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-6 mb-6">
        <h2 className="text-lg font-semibold text-gray-900 mb-4">Filters</h2>
        <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">Start Date</label>
            <input
              type="date"
              value={dateRange.start}
              onChange={(e) => setDateRange({ ...dateRange, start: e.target.value })}
              className="w-full px-4 py-2 border border-gray-200 rounded-lg focus:outline-none focus:border-primary"
            />
          </div>
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">End Date</label>
            <input
              type="date"
              value={dateRange.end}
              onChange={(e) => setDateRange({ ...dateRange, end: e.target.value })}
              className="w-full px-4 py-2 border border-gray-200 rounded-lg focus:outline-none focus:border-primary"
            />
          </div>
          <div className="flex items-end">
            <button className="w-full bg-primary text-white px-4 py-2 rounded-lg hover:bg-primary-600 transition-colors">
              Apply Filters
            </button>
          </div>
        </div>
      </div>

      {/* Summary Stats */}
      <div className="grid grid-cols-1 md:grid-cols-4 gap-6 mb-6">
        <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-6">
          <div className="flex items-center gap-3 mb-2">
            <Icon icon={faUsers} className="text-primary" />
            <p className="text-sm text-gray-500">Active Users</p>
          </div>
          <p className="text-2xl font-bold text-gray-900">{mockDashboardStats.activeUsers.toLocaleString()}</p>
        </div>
        <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-6">
          <div className="flex items-center gap-3 mb-2">
            <Icon icon={faClock} className="text-primary" />
            <p className="text-sm text-gray-500">Daily Active</p>
          </div>
          <p className="text-2xl font-bold text-gray-900">342</p>
        </div>
        <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-6">
          <div className="flex items-center gap-3 mb-2">
            <Icon icon={faChartLine} className="text-primary" />
            <p className="text-sm text-gray-500">Weekly Active</p>
          </div>
          <p className="text-2xl font-bold text-gray-900">1,245</p>
        </div>
        <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-6">
          <div className="flex items-center gap-3 mb-2">
            <Icon icon={faUsers} className="text-primary" />
            <p className="text-sm text-gray-500">Monthly Active</p>
          </div>
          <p className="text-2xl font-bold text-gray-900">{mockDashboardStats.totalUsers.toLocaleString()}</p>
        </div>
      </div>

      {/* Charts */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6 mb-6">
        <ChartWrapper title="Daily Active Users">
          <BarChart
            data={mockChartData.userGrowth}
            dataKey="date"
            bars={[{ key: 'users', name: 'Active Users', color: '#1a74e8' }]}
            height={300}
          />
        </ChartWrapper>

        <ChartWrapper title="User Activity Trend">
          <LineChart
            data={mockChartData.userGrowth}
            dataKey="date"
            lines={[
              { key: 'users', name: 'Active Users', color: '#1a74e8' },
            ]}
            height={300}
          />
        </ChartWrapper>
      </div>
    </div>
  );
}

