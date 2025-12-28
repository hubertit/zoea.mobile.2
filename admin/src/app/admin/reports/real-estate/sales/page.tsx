'use client';

import { useState } from 'react';
import Icon, { faDownload, faDollarSign, faHome, faChartLine, faCheck, faArrowLeft } from '../../../../components/Icon';
import Link from 'next/link';
import ChartWrapper from '../../../../components/ChartWrapper';
import LineChart from '../../../../components/charts/LineChart';
import BarChart from '../../../../components/charts/BarChart';
import DataTable from '../../../../components/DataTable';
import { mockProperties, mockChartData } from '@/lib/mockData';

export default function RealEstateSalesReportPage() {
  const [dateRange, setDateRange] = useState({
    start: '2025-01-01',
    end: '2025-12-31',
  });

  const totalSales = 42;
  const totalRevenue = mockProperties.filter(p => p.property_type === 'sale').reduce((sum, p) => sum + p.price, 0);
  const avgSalePrice = totalSales > 0 ? totalRevenue / totalSales : 0;
  const pendingSales = 8;

  const columns = [
    { key: 'title', label: 'Property', sortable: true },
    { key: 'category', label: 'Category', sortable: true },
    { key: 'price', label: 'Sale Price', sortable: true, render: (value: number) => `RWF ${value.toLocaleString()}` },
    { key: 'property_type', label: 'Type', sortable: true },
    { key: 'status', label: 'Status', sortable: true },
  ];

  const salesData = mockProperties.filter(p => p.property_type === 'sale');

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
              <h1 className="text-3xl font-bold text-gray-900 mb-2">Real Estate Sales Report</h1>
              <p className="text-gray-600">Property sales and revenue analytics</p>
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
            <p className="text-sm text-gray-500">Total Sales</p>
          </div>
          <p className="text-2xl font-bold text-gray-900">{totalSales}</p>
        </div>
        <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-6">
          <div className="flex items-center gap-3 mb-2">
            <Icon icon={faDollarSign} className="text-primary" />
            <p className="text-sm text-gray-500">Total Revenue</p>
          </div>
          <p className="text-2xl font-bold text-gray-900">RWF {totalRevenue.toLocaleString()}</p>
        </div>
        <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-6">
          <div className="flex items-center gap-3 mb-2">
            <Icon icon={faChartLine} className="text-primary" />
            <p className="text-sm text-gray-500">Avg Sale Price</p>
          </div>
          <p className="text-2xl font-bold text-gray-900">RWF {Math.round(avgSalePrice).toLocaleString()}</p>
        </div>
        <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-6">
          <div className="flex items-center gap-3 mb-2">
            <Icon icon={faCheck} className="text-yellow-600" />
            <p className="text-sm text-gray-500">Pending Sales</p>
          </div>
          <p className="text-2xl font-bold text-gray-900">{pendingSales}</p>
        </div>
      </div>

      {/* Charts */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6 mb-6">
        <ChartWrapper title="Sales Revenue Trend">
          <LineChart
            data={mockChartData.revenue.map(item => ({
              date: item.date,
              revenue: item.revenue * 2.5,
            }))}
            dataKey="date"
            lines={[
              { key: 'revenue', name: 'Sales Revenue', color: '#181E29' },
            ]}
            height={300}
          />
        </ChartWrapper>

        <ChartWrapper title="Sales by Category">
          <BarChart
            data={[
              { category: 'House', sales: 18 },
              { category: 'Apartment', sales: 15 },
              { category: 'Commercial', sales: 7 },
              { category: 'Land', sales: 2 },
            ]}
            dataKey="category"
            bars={[{ key: 'sales', name: 'Sales', color: '#181E29' }]}
            height={300}
          />
        </ChartWrapper>
      </div>

      {/* Data Table */}
      <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-6">
        <h2 className="text-lg font-semibold text-gray-900 mb-4">Sales Properties</h2>
        <DataTable
          columns={columns}
          data={salesData}
          loading={false}
        />
      </div>
    </div>
  );
}

