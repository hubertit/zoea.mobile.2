'use client';

import { useState } from 'react';
import Icon, { faDownload, faUsers, faCalendar, faCheck, faArrowLeft } from '../../../../components/Icon';
import Link from 'next/link';
import ChartWrapper from '../../../../components/ChartWrapper';
import BarChart from '../../../../components/charts/BarChart';
import LineChart from '../../../../components/charts/LineChart';
import DataTable from '../../../../components/DataTable';
import { mockEvents, mockChartData } from '@/lib/mockData';

export default function EventAttendanceReportPage() {
  const [dateRange, setDateRange] = useState({
    start: '2025-01-01',
    end: '2025-12-31',
  });

  const totalAttendees = 1245;
  const confirmedAttendees = 1120;
  const checkedIn = 980;
  const noShow = 140;

  const columns = [
    { key: 'event', label: 'Event', sortable: true },
    { key: 'confirmed', label: 'Confirmed', sortable: true },
    { key: 'checked_in', label: 'Checked In', sortable: true },
    { key: 'attendance_rate', label: 'Attendance Rate', sortable: true, render: (value: number) => `${value}%` },
  ];

  const attendanceData = [
    { event: 'Tech Summit 2025', confirmed: 450, checked_in: 420, attendance_rate: 93 },
    { event: 'Music Festival', confirmed: 320, checked_in: 290, attendance_rate: 91 },
    { event: 'Business Conference', confirmed: 280, checked_in: 250, attendance_rate: 89 },
    { event: 'Art Exhibition', confirmed: 70, checked_in: 60, attendance_rate: 86 },
  ];

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
              <h1 className="text-3xl font-bold text-gray-900 mb-2">Event Attendance Report</h1>
              <p className="text-gray-600">Event attendance and check-in analytics</p>
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
            <p className="text-sm text-gray-500">Total Attendees</p>
          </div>
          <p className="text-2xl font-bold text-gray-900">{totalAttendees.toLocaleString()}</p>
        </div>
        <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-6">
          <div className="flex items-center gap-3 mb-2">
            <Icon icon={faCheck} className="text-green-600" />
            <p className="text-sm text-gray-500">Confirmed</p>
          </div>
          <p className="text-2xl font-bold text-gray-900">{confirmedAttendees.toLocaleString()}</p>
        </div>
        <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-6">
          <div className="flex items-center gap-3 mb-2">
            <Icon icon={faCalendar} className="text-primary" />
            <p className="text-sm text-gray-500">Checked In</p>
          </div>
          <p className="text-2xl font-bold text-gray-900">{checkedIn.toLocaleString()}</p>
        </div>
        <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-6">
          <div className="flex items-center gap-3 mb-2">
            <Icon icon={faUsers} className="text-red-600" />
            <p className="text-sm text-gray-500">No Show</p>
          </div>
          <p className="text-2xl font-bold text-gray-900">{noShow}</p>
        </div>
      </div>

      {/* Charts */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6 mb-6">
        <ChartWrapper title="Attendance by Event">
          <BarChart
            data={attendanceData}
            dataKey="event"
            bars={[
              { key: 'checked_in', name: 'Checked In', color: '#181E29' },
              { key: 'confirmed', name: 'Confirmed', color: '#1a74e8' },
            ]}
            height={300}
          />
        </ChartWrapper>

        <ChartWrapper title="Attendance Rate Trend">
          <LineChart
            data={mockChartData.userGrowth.map((item, idx) => ({
              date: item.date,
              rate: 85 + Math.floor(Math.random() * 10),
            }))}
            dataKey="date"
            lines={[
              { key: 'rate', name: 'Attendance Rate %', color: '#181E29' },
            ]}
            height={300}
          />
        </ChartWrapper>
      </div>

      {/* Data Table */}
      <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-6">
        <h2 className="text-lg font-semibold text-gray-900 mb-4">Event Attendance Details</h2>
        <DataTable
          columns={columns}
          data={attendanceData}
          loading={false}
        />
      </div>
    </div>
  );
}

