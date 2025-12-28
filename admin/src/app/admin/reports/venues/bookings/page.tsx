'use client';

import { useState } from 'react';
import Icon, { faDownload, faCalendar, faStore, faUsers, faDollarSign, faArrowLeft, faCheck, faClock, faTimes } from '../../../../components/Icon';
import Link from 'next/link';
import ChartWrapper from '../../../../components/ChartWrapper';
import BarChart from '../../../../components/charts/BarChart';
import LineChart from '../../../../components/charts/LineChart';
import { mockVenues, mockChartData } from '@/lib/mockData';

export default function VenueBookingsReportPage() {
  const [dateRange, setDateRange] = useState({
    start: '2025-01-01',
    end: '2025-12-31',
  });

  const totalBookings = 245;
  const confirmedBookings = 198;
  const pendingBookings = 32;
  const cancelledBookings = 15;

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
              <h1 className="text-3xl font-bold text-gray-900 mb-2">Booking Analytics Report</h1>
              <p className="text-gray-600">Venue booking trends and analytics</p>
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
            <Icon icon={faCalendar} className="text-primary" />
            <p className="text-sm text-gray-500">Total Bookings</p>
          </div>
          <p className="text-2xl font-bold text-gray-900">{totalBookings}</p>
        </div>
        <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-6">
          <div className="flex items-center gap-3 mb-2">
            <Icon icon={faCheck} className="text-green-600" />
            <p className="text-sm text-gray-500">Confirmed</p>
          </div>
          <p className="text-2xl font-bold text-gray-900">{confirmedBookings}</p>
        </div>
        <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-6">
          <div className="flex items-center gap-3 mb-2">
            <Icon icon={faClock} className="text-yellow-600" />
            <p className="text-sm text-gray-500">Pending</p>
          </div>
          <p className="text-2xl font-bold text-gray-900">{pendingBookings}</p>
        </div>
        <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-6">
          <div className="flex items-center gap-3 mb-2">
            <Icon icon={faTimes} className="text-red-600" />
            <p className="text-sm text-gray-500">Cancelled</p>
          </div>
          <p className="text-2xl font-bold text-gray-900">{cancelledBookings}</p>
        </div>
      </div>

      {/* Charts */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6 mb-6">
        <ChartWrapper title="Bookings by Venue">
          <BarChart
            data={mockVenues.map(v => ({ name: v.venue_name, bookings: Math.floor(Math.random() * 50) + 10 }))}
            dataKey="name"
            bars={[{ key: 'bookings', name: 'Bookings', color: '#181E29' }]}
            height={300}
          />
        </ChartWrapper>

        <ChartWrapper title="Booking Trend (Last 7 Days)">
          <LineChart
            data={mockChartData.revenue.map(item => ({ date: item.date, bookings: Math.floor(item.orders * 1.5) }))}
            dataKey="date"
            lines={[
              { key: 'bookings', name: 'Bookings', color: '#181E29' },
            ]}
            height={300}
          />
        </ChartWrapper>
      </div>
    </div>
  );
}

