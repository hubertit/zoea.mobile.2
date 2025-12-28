'use client';

import { useState, useEffect } from 'react';
import Icon, { faCalendar, faUsers, faCheck, faChartLine } from '../../../components/Icon';
import ChartWrapper from '../../../components/ChartWrapper';
import LineChart from '../../../components/charts/LineChart';
import BarChart from '../../../components/charts/BarChart';
import PieChart from '../../../components/charts/PieChart';
import { mockChartData, mockDashboardStats } from '@/lib/mockData';

export default function EventAnalyticsPage() {
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    setLoading(false);
  }, []);

  return (
    <div>
      <div className="mb-8">
        <h1 className="text-3xl font-bold text-gray-900 mb-2">Event Analytics</h1>
        <p className="text-gray-600">Comprehensive event performance metrics and insights</p>
      </div>

      {/* Summary Stats */}
      <div className="grid grid-cols-1 md:grid-cols-4 gap-6 mb-6">
        <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-6">
          <div className="flex items-center gap-3 mb-2">
            <Icon icon={faCalendar} className="text-primary" />
            <p className="text-sm text-gray-500">Total Events</p>
          </div>
          <p className="text-2xl font-bold text-gray-900">{mockDashboardStats.totalEvents}</p>
        </div>
        <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-6">
          <div className="flex items-center gap-3 mb-2">
            <Icon icon={faUsers} className="text-primary" />
            <p className="text-sm text-gray-500">Total Applications</p>
          </div>
          <p className="text-2xl font-bold text-gray-900">{mockDashboardStats.totalApplications}</p>
        </div>
        <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-6">
          <div className="flex items-center gap-3 mb-2">
            <Icon icon={faCheck} className="text-green-600" />
            <p className="text-sm text-gray-500">Approved</p>
          </div>
          <p className="text-2xl font-bold text-gray-900">
            {mockDashboardStats.totalApplications - mockDashboardStats.pendingApplications}
          </p>
        </div>
        <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-6">
          <div className="flex items-center gap-3 mb-2">
            <Icon icon={faChartLine} className="text-primary" />
            <p className="text-sm text-gray-500">Pending</p>
          </div>
          <p className="text-2xl font-bold text-gray-900">{mockDashboardStats.pendingApplications}</p>
        </div>
      </div>

      {/* Charts */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6 mb-6">
        <ChartWrapper title="Applications Trend (Last 7 Days)" loading={loading}>
          <LineChart
            data={mockChartData.userGrowth.map((item, idx) => ({
              date: item.date,
              applications: item.users * 3 + Math.floor(Math.random() * 10),
            }))}
            dataKey="date"
            lines={[
              { key: 'applications', name: 'Applications', color: '#1a74e8' },
            ]}
            height={300}
          />
        </ChartWrapper>

        <ChartWrapper title="Applications by Status" loading={loading}>
          <PieChart
            data={mockChartData.applicationsByStatus}
            height={300}
          />
        </ChartWrapper>

        <ChartWrapper title="Event Applications" loading={loading}>
          <BarChart
            data={[
              { event: 'Tech Summit', applications: 45 },
              { event: 'Music Festival', applications: 32 },
              { event: 'Business Conference', applications: 28 },
              { event: 'Art Exhibition', applications: 15 },
            ]}
            dataKey="event"
            bars={[{ key: 'applications', name: 'Applications', color: '#1a74e8' }]}
            height={300}
          />
        </ChartWrapper>

        <ChartWrapper title="Event Performance" loading={loading}>
          <BarChart
            data={[
              { event: 'Tech Summit', attendance: 420, capacity: 500 },
              { event: 'Music Festival', attendance: 290, capacity: 350 },
              { event: 'Business Conference', attendance: 250, capacity: 300 },
            ]}
            dataKey="event"
            bars={[
              { key: 'attendance', name: 'Attendance', color: '#181E29' },
              { key: 'capacity', name: 'Capacity', color: '#1a74e8' },
            ]}
            height={300}
          />
        </ChartWrapper>
      </div>
    </div>
  );
}

