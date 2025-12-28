'use client';

import { useState } from 'react';
import Icon, { faDownload, faDollarSign, faShoppingCart, faArrowLeft, faChartLine } from '../../../../components/Icon';
import Link from 'next/link';
import ChartWrapper from '../../../../components/ChartWrapper';
import LineChart from '../../../../components/charts/LineChart';
import PieChart from '../../../../components/charts/PieChart';
import BarChart from '../../../../components/charts/BarChart';
import DataTable from '../../../../components/DataTable';
import { mockOrders, mockChartData } from '@/lib/mockData';

export default function EcommerceSalesReportPage() {
  const [dateRange, setDateRange] = useState({
    start: '2025-01-01',
    end: '2025-12-31',
  });

  const totalRevenue = mockOrders.reduce((sum, order) => sum + order.total_amount, 0);
  const totalOrders = mockOrders.length;
  const avgOrderValue = totalOrders > 0 ? totalRevenue / totalOrders : 0;
  const deliveredOrders = mockOrders.filter(o => o.status === 'delivered').length;

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
              <h1 className="text-3xl font-bold text-gray-900 mb-2">E-commerce Sales Report</h1>
              <p className="text-gray-600">Sales performance and revenue analytics</p>
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
            <Icon icon={faDollarSign} className="text-primary" />
            <p className="text-sm text-gray-500">Total Revenue</p>
          </div>
          <p className="text-2xl font-bold text-gray-900">RWF {totalRevenue.toLocaleString()}</p>
        </div>
        <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-6">
          <div className="flex items-center gap-3 mb-2">
            <Icon icon={faShoppingCart} className="text-primary" />
            <p className="text-sm text-gray-500">Total Orders</p>
          </div>
          <p className="text-2xl font-bold text-gray-900">{totalOrders}</p>
        </div>
        <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-6">
          <div className="flex items-center gap-3 mb-2">
            <Icon icon={faChartLine} className="text-primary" />
            <p className="text-sm text-gray-500">Avg Order Value</p>
          </div>
          <p className="text-2xl font-bold text-gray-900">RWF {Math.round(avgOrderValue).toLocaleString()}</p>
        </div>
        <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-6">
          <div className="flex items-center gap-3 mb-2">
            <Icon icon={faShoppingCart} className="text-green-600" />
            <p className="text-sm text-gray-500">Delivered</p>
          </div>
          <p className="text-2xl font-bold text-gray-900">{deliveredOrders}</p>
        </div>
      </div>

      {/* Charts */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6 mb-6">
        <ChartWrapper title="Revenue Trend (Last 7 Days)">
          <LineChart
            data={mockChartData.revenue}
            dataKey="date"
            lines={[
              { key: 'revenue', name: 'Revenue', color: '#181E29' },
            ]}
            height={300}
          />
        </ChartWrapper>

        <ChartWrapper title="Orders by Status">
          <PieChart
            data={mockChartData.ordersByStatus}
            height={300}
          />
        </ChartWrapper>
      </div>

      {/* Data Table */}
      <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-6">
        <h2 className="text-lg font-semibold text-gray-900 mb-4">Recent Orders</h2>
        <DataTable
          columns={columns}
          data={mockOrders}
          loading={false}
        />
      </div>
    </div>
  );
}

