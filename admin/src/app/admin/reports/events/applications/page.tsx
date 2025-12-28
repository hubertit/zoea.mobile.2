'use client';

import { useState } from 'react';
import Icon, { faDownload, faCalendar, faFileAlt, faArrowLeft } from '../../../../components/Icon';
import Link from 'next/link';
import DataTable from '../../../../components/DataTable';
import ChartWrapper from '../../../../components/ChartWrapper';
import PieChart from '../../../../components/charts/PieChart';
import BarChart from '../../../../components/charts/BarChart';
import { mockEvents } from '@/lib/mockData';

export default function EventApplicationsReportPage() {
  const [dateRange, setDateRange] = useState({
    start: '2025-01-01',
    end: '2025-12-31',
  });

  const columns = [
    { key: 'id', label: 'ID', sortable: true },
    {
      key: 'first_name',
      label: 'Applicant',
      render: (value: string, row: any) => (
        <div>
          <div className="font-medium">{row.title} {row.first_name} {row.last_name}</div>
          <div className="text-xs text-gray-500">{row.email}</div>
        </div>
      ),
    },
    { key: 'event', label: 'Event', sortable: true },
    { key: 'organization', label: 'Organization', sortable: true },
    {
      key: 'status',
      label: 'Status',
      render: (value: string) => {
        const colors: Record<string, string> = {
          'approved': 'bg-green-100 text-green-800',
          'pending': 'bg-yellow-100 text-yellow-800',
          'rejected': 'bg-red-100 text-red-800',
        };
        const color = colors[value.toLowerCase()] || 'bg-gray-100 text-gray-800';
        return (
          <span className={`px-2 py-1 rounded-full text-xs font-medium ${color}`}>
            {value}
          </span>
        );
      },
    },
    {
      key: 'updated_date',
      label: 'Date',
      render: (value: string) => new Date(value).toLocaleDateString(),
    },
  ];

  return (
    <div>
      <div className="mb-8">
        <div className="flex items-center justify-between mb-4">
          <div className="flex items-center gap-4">
            <Link
              href="/admin/reports"
              className="p-2 hover:bg-gray-100 rounded-sm transition-colors"
            >
              <Icon icon={faArrowLeft} />
            </Link>
            <div>
              <h1 className="text-3xl font-bold text-gray-900 mb-2">Event Applications Report</h1>
              <p className="text-gray-600">View and analyze event applications</p>
            </div>
          </div>
          <button className="flex items-center gap-2 bg-primary text-white px-4 py-2 rounded-sm hover:bg-primary-600 transition-colors">
            <Icon icon={faDownload} />
            <span>Export</span>
          </button>
        </div>
      </div>

      {/* Filters */}
      <div className="bg-white rounded-sm shadow-sm border border-gray-200 p-6 mb-6">
        <h2 className="text-lg font-semibold text-gray-900 mb-4">Filters</h2>
        <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">Start Date</label>
            <input
              type="date"
              value={dateRange.start}
              onChange={(e) => setDateRange({ ...dateRange, start: e.target.value })}
              className="w-full px-4 py-2 border border-gray-200 rounded-sm focus:outline-none focus:border-primary"
            />
          </div>
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">End Date</label>
            <input
              type="date"
              value={dateRange.end}
              onChange={(e) => setDateRange({ ...dateRange, end: e.target.value })}
              className="w-full px-4 py-2 border border-gray-200 rounded-sm focus:outline-none focus:border-primary"
            />
          </div>
          <div className="flex items-end">
            <button className="w-full bg-primary text-white px-4 py-2 rounded-sm hover:bg-primary-600 transition-colors">
              Apply Filters
            </button>
          </div>
        </div>
      </div>

      {/* Summary Stats */}
      <div className="grid grid-cols-1 md:grid-cols-4 gap-6 mb-6">
        <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-6">
          <div className="flex items-center gap-3 mb-2">
            <Icon icon={faFileAlt} className="text-primary" />
            <p className="text-sm text-gray-500">Total Applications</p>
          </div>
          <p className="text-2xl font-bold text-gray-900">{mockEvents.length}</p>
        </div>
        <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-6">
          <div className="flex items-center gap-3 mb-2">
            <Icon icon={faCalendar} className="text-green-600" />
            <p className="text-sm text-gray-500">Approved</p>
          </div>
          <p className="text-2xl font-bold text-gray-900">
            {mockEvents.filter(e => e.status === 'approved').length}
          </p>
        </div>
        <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-6">
          <div className="flex items-center gap-3 mb-2">
            <Icon icon={faCalendar} className="text-yellow-600" />
            <p className="text-sm text-gray-500">Pending</p>
          </div>
          <p className="text-2xl font-bold text-gray-900">
            {mockEvents.filter(e => e.status === 'pending').length}
          </p>
        </div>
        <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-6">
          <div className="flex items-center gap-3 mb-2">
            <Icon icon={faCalendar} className="text-red-600" />
            <p className="text-sm text-gray-500">Rejected</p>
          </div>
          <p className="text-2xl font-bold text-gray-900">
            {mockEvents.filter(e => e.status === 'rejected').length}
          </p>
        </div>
      </div>

      {/* Charts */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6 mb-6">
        <ChartWrapper title="Applications by Status">
          <PieChart
            data={[
              { name: 'Approved', value: mockEvents.filter(e => e.status === 'approved').length },
              { name: 'Pending', value: mockEvents.filter(e => e.status === 'pending').length },
              { name: 'Rejected', value: mockEvents.filter(e => e.status === 'rejected').length },
            ]}
            height={300}
          />
        </ChartWrapper>

        <ChartWrapper title="Applications by Event">
          <BarChart
            data={[
              { event: 'Tech Summit 2025', count: 45 },
              { event: 'Music Festival', count: 32 },
              { event: 'Business Conference', count: 28 },
              { event: 'Art Exhibition', count: 15 },
            ]}
            dataKey="event"
            bars={[{ key: 'count', name: 'Applications', color: '#181E29' }]}
            height={300}
          />
        </ChartWrapper>
      </div>

      {/* Data Table */}
      <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-6">
        <h2 className="text-lg font-semibold text-gray-900 mb-4">All Applications</h2>
        <DataTable
          columns={columns}
          data={mockEvents}
          loading={false}
        />
      </div>
    </div>
  );
}

