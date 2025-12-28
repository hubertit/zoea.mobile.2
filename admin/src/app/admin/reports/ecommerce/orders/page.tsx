'use client';

import { useState } from 'react';
import Icon, { faDownload, faShoppingCart, faCheck, faClock, faTimes, faArrowLeft } from '../../../../components/Icon';
import Link from 'next/link';
import ChartWrapper from '../../../../components/ChartWrapper';
import PieChart from '../../../../components/charts/PieChart';
import BarChart from '../../../../components/charts/BarChart';
import DataTable from '../../../../components/DataTable';
import { mockOrders, mockChartData } from '@/lib/mockData';

export default function EcommerceOrdersReportPage() {
  const [dateRange, setDateRange] = useState({
    start: '2025-01-01',
    end: '2025-12-31',
  });

  const statusCounts = {
    pending: mockOrders.filter(o => (o.status as string) === 'pending').length,
    confirmed: mockOrders.filter(o => (o.status as string) === 'confirmed').length,
    processing: mockOrders.filter(o => (o.status as string) === 'processing').length,
    shipped: mockOrders.filter(o => (o.status as string) === 'shipped').length,
    delivered: mockOrders.filter(o => (o.status as string) === 'delivered').length,
    cancelled: mockOrders.filter(o => (o.status as string) === 'cancelled').length,
  };

  const columns = [
    { key: 'order_no', label: 'Order #', sortable: true },
    { key: 'customer_id', label: 'Customer ID', sortable: true },
    { key: 'total_amount', label: 'Amount', sortable: true, render: (value: number, row: any) => `${value.toLocaleString()} ${row.currency}` },
    { key: 'status', label: 'Status', sortable: true },
    { key: 'order_date', label: 'Date', sortable: true, render: (value: string) => new Date(value).toLocaleDateString() },
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
              <h1 className="text-3xl font-bold text-gray-900 mb-2">Order Status Report</h1>
              <p className="text-gray-600">Order status distribution and analytics</p>
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
      <div className="grid grid-cols-1 md:grid-cols-6 gap-6 mb-6">
        <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-6">
          <div className="flex items-center gap-3 mb-2">
            <Icon icon={faShoppingCart} className="text-primary" />
            <p className="text-sm text-gray-500">Total</p>
          </div>
          <p className="text-2xl font-bold text-gray-900">{mockOrders.length}</p>
        </div>
        <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-6">
          <div className="flex items-center gap-3 mb-2">
            <Icon icon={faClock} className="text-yellow-600" />
            <p className="text-sm text-gray-500">Pending</p>
          </div>
          <p className="text-2xl font-bold text-gray-900">{statusCounts.pending}</p>
        </div>
        <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-6">
          <div className="flex items-center gap-3 mb-2">
            <Icon icon={faCheck} className="text-blue-600" />
            <p className="text-sm text-gray-500">Confirmed</p>
          </div>
          <p className="text-2xl font-bold text-gray-900">{statusCounts.confirmed}</p>
        </div>
        <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-6">
          <div className="flex items-center gap-3 mb-2">
            <Icon icon={faClock} className="text-purple-600" />
            <p className="text-sm text-gray-500">Processing</p>
          </div>
          <p className="text-2xl font-bold text-gray-900">{statusCounts.processing}</p>
        </div>
        <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-6">
          <div className="flex items-center gap-3 mb-2">
            <Icon icon={faCheck} className="text-green-600" />
            <p className="text-sm text-gray-500">Delivered</p>
          </div>
          <p className="text-2xl font-bold text-gray-900">{statusCounts.delivered}</p>
        </div>
        <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-6">
          <div className="flex items-center gap-3 mb-2">
            <Icon icon={faTimes} className="text-red-600" />
            <p className="text-sm text-gray-500">Cancelled</p>
          </div>
          <p className="text-2xl font-bold text-gray-900">{statusCounts.cancelled}</p>
        </div>
      </div>

      {/* Charts */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6 mb-6">
        <ChartWrapper title="Orders by Status">
          <PieChart
            data={mockChartData.ordersByStatus}
            height={300}
          />
        </ChartWrapper>

        <ChartWrapper title="Order Status Distribution">
          <BarChart
            data={[
              { status: 'Delivered', count: statusCounts.delivered },
              { status: 'Processing', count: statusCounts.processing },
              { status: 'Confirmed', count: statusCounts.confirmed },
              { status: 'Pending', count: statusCounts.pending },
              { status: 'Cancelled', count: statusCounts.cancelled },
            ]}
            dataKey="status"
            bars={[{ key: 'count', name: 'Orders', color: '#181E29' }]}
            height={300}
          />
        </ChartWrapper>
      </div>

      {/* Data Table */}
      <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-6">
        <h2 className="text-lg font-semibold text-gray-900 mb-4">All Orders</h2>
        <DataTable
          columns={columns}
          data={mockOrders}
          loading={false}
        />
      </div>
    </div>
  );
}

