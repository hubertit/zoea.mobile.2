'use client';

import { useState } from 'react';
import Icon, { faDownload, faHome, faDollarSign, faBed, faBath, faArrowLeft } from '../../../../components/Icon';
import Link from 'next/link';
import ChartWrapper from '../../../../components/ChartWrapper';
import PieChart from '../../../../components/charts/PieChart';
import BarChart from '../../../../components/charts/BarChart';
import DataTable from '../../../../components/DataTable';
import { mockProperties, mockChartData, mockDashboardStats } from '@/lib/mockData';

export default function RealEstateListingsReportPage() {
  const [dateRange, setDateRange] = useState({
    start: '2025-01-01',
    end: '2025-12-31',
  });

  const columns = [
    { key: 'title', label: 'Property', sortable: true },
    { key: 'category', label: 'Category', sortable: true },
    { key: 'bedrooms', label: 'Bedrooms', sortable: true, render: (value: number) => value || '-' },
    { key: 'bathrooms', label: 'Bathrooms', sortable: true, render: (value: number) => value || '-' },
    { key: 'price', label: 'Price', sortable: true, render: (value: number) => `RWF ${value.toLocaleString()}` },
    { key: 'property_type', label: 'Type', sortable: true },
    { key: 'status', label: 'Status', sortable: true },
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
              <h1 className="text-3xl font-bold text-gray-900 mb-2">Property Listing Report</h1>
              <p className="text-gray-600">Property listings and inventory analytics</p>
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
            <Icon icon={faHome} className="text-primary" />
            <p className="text-sm text-gray-500">Total Properties</p>
          </div>
          <p className="text-2xl font-bold text-gray-900">{mockDashboardStats.totalProperties}</p>
        </div>
        <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-6">
          <div className="flex items-center gap-3 mb-2">
            <Icon icon={faHome} className="text-green-600" />
            <p className="text-sm text-gray-500">Available</p>
          </div>
          <p className="text-2xl font-bold text-gray-900">{mockProperties.filter(p => p.status === 'available').length}</p>
        </div>
        <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-6">
          <div className="flex items-center gap-3 mb-2">
            <Icon icon={faDollarSign} className="text-primary" />
            <p className="text-sm text-gray-500">Avg Price</p>
          </div>
          <p className="text-2xl font-bold text-gray-900">
            RWF {Math.round(mockProperties.reduce((sum, p) => sum + p.price, 0) / mockProperties.length).toLocaleString()}
          </p>
        </div>
        <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-6">
          <div className="flex items-center gap-3 mb-2">
            <Icon icon={faBed} className="text-primary" />
            <p className="text-sm text-gray-500">Total Bedrooms</p>
          </div>
          <p className="text-2xl font-bold text-gray-900">
            {mockProperties.reduce((sum, p) => sum + (p.bedrooms || 0), 0)}
          </p>
        </div>
      </div>

      {/* Charts */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6 mb-6">
        <ChartWrapper title="Properties by Category">
          <PieChart
            data={mockChartData.propertiesByCategory}
            height={300}
          />
        </ChartWrapper>

        <ChartWrapper title="Properties by Type">
          <BarChart
            data={[
              { type: 'Rent', count: mockProperties.filter(p => p.property_type === 'rent').length },
              { type: 'Sale', count: mockProperties.filter(p => p.property_type === 'sale').length },
            ]}
            dataKey="type"
            bars={[{ key: 'count', name: 'Properties', color: '#181E29' }]}
            height={300}
          />
        </ChartWrapper>
      </div>

      {/* Data Table */}
      <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-6">
        <h2 className="text-lg font-semibold text-gray-900 mb-4">All Properties</h2>
        <DataTable
          columns={columns}
          data={mockProperties}
          loading={false}
        />
      </div>
    </div>
  );
}

