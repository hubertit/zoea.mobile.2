'use client';

import { useState } from 'react';
import Icon, { faDownload, faStore, faDollarSign, faShoppingCart, faChartLine, faArrowLeft } from '../../../../components/Icon';
import Link from 'next/link';
import ChartWrapper from '../../../../components/ChartWrapper';
import BarChart from '../../../../components/charts/BarChart';
import PieChart from '../../../../components/charts/PieChart';
import DataTable from '../../../../components/DataTable';
import { mockChartData } from '@/lib/mockData';

export default function MerchantPerformanceReportPage() {
  const [dateRange, setDateRange] = useState({
    start: '2025-01-01',
    end: '2025-12-31',
  });

  const totalMerchants = 45;
  const activeMerchants = 38;
  const totalRevenue = 12500000;
  const avgRevenue = totalRevenue / activeMerchants;

  const columns = [
    { key: 'merchant_name', label: 'Merchant', sortable: true },
    { key: 'orders', label: 'Orders', sortable: true },
    { key: 'revenue', label: 'Revenue', sortable: true, render: (value: number) => `RWF ${value.toLocaleString()}` },
    { key: 'status', label: 'Status', sortable: true },
  ];

  const merchantData = [
    { merchant_name: 'Tech Store', orders: 125, revenue: 3500000, status: 'active' },
    { merchant_name: 'Fashion Boutique', orders: 98, revenue: 2800000, status: 'active' },
    { merchant_name: 'Electronics Hub', orders: 87, revenue: 2200000, status: 'active' },
    { merchant_name: 'Home Decor', orders: 65, revenue: 1900000, status: 'active' },
    { merchant_name: 'Sports Gear', orders: 52, revenue: 1500000, status: 'active' },
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
              <h1 className="text-3xl font-bold text-gray-900 mb-2">Merchant Performance Report</h1>
              <p className="text-gray-600">Merchant sales and performance analytics</p>
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
            <Icon icon={faStore} className="text-primary" />
            <p className="text-sm text-gray-500">Total Merchants</p>
          </div>
          <p className="text-2xl font-bold text-gray-900">{totalMerchants}</p>
        </div>
        <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-6">
          <div className="flex items-center gap-3 mb-2">
            <Icon icon={faStore} className="text-green-600" />
            <p className="text-sm text-gray-500">Active Merchants</p>
          </div>
          <p className="text-2xl font-bold text-gray-900">{activeMerchants}</p>
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
            <p className="text-sm text-gray-500">Avg Revenue</p>
          </div>
          <p className="text-2xl font-bold text-gray-900">RWF {Math.round(avgRevenue).toLocaleString()}</p>
        </div>
      </div>

      {/* Charts */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6 mb-6">
        <ChartWrapper title="Top Merchants by Revenue">
          <BarChart
            data={merchantData}
            dataKey="merchant_name"
            bars={[{ key: 'revenue', name: 'Revenue', color: '#181E29' }]}
            height={300}
          />
        </ChartWrapper>

        <ChartWrapper title="Merchant Status Distribution">
          <PieChart
            data={[
              { name: 'Active', value: activeMerchants },
              { name: 'Inactive', value: totalMerchants - activeMerchants },
            ]}
            height={300}
          />
        </ChartWrapper>
      </div>

      {/* Data Table */}
      <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-6">
        <h2 className="text-lg font-semibold text-gray-900 mb-4">Merchant Performance Details</h2>
        <DataTable
          columns={columns}
          data={merchantData}
          loading={false}
        />
      </div>
    </div>
  );
}

