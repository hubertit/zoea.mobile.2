'use client';

import { useState, useEffect } from 'react';
import Icon, { faShoppingCart, faDollarSign, faChartLine, faCheck } from '../../../components/Icon';
import ChartWrapper from '../../../components/ChartWrapper';
import LineChart from '../../../components/charts/LineChart';
import BarChart from '../../../components/charts/BarChart';
import PieChart from '../../../components/charts/PieChart';
import { mockOrders, mockChartData } from '@/lib/mockData';

export default function EcommerceAnalyticsPage() {
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    setLoading(false);
  }, []);

  const totalRevenue = mockOrders.reduce((sum, o) => sum + o.total_amount, 0);
  const totalOrders = mockOrders.length;
  const avgOrderValue = totalOrders > 0 ? totalRevenue / totalOrders : 0;

  return (
    <div>
      <div className="mb-8">
        <h1 className="text-3xl font-bold text-gray-900 mb-2">Sales Analytics</h1>
        <p className="text-gray-600">E-commerce sales performance and revenue insights</p>
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
            <Icon icon={faCheck} className="text-green-600" />
            <p className="text-sm text-gray-500">Delivered</p>
          </div>
          <p className="text-2xl font-bold text-gray-900">
            {mockOrders.filter(o => (o.status as string) === 'delivered').length}
          </p>
        </div>
      </div>

      {/* Charts */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6 mb-6">
        <ChartWrapper title="Revenue Trend (Last 7 Days)" loading={loading}>
          <LineChart
            data={mockChartData.revenue}
            dataKey="date"
            lines={[
              { key: 'revenue', name: 'Revenue', color: '#181E29' },
              { key: 'orders', name: 'Orders', color: '#1a74e8' },
            ]}
            height={300}
          />
        </ChartWrapper>

        <ChartWrapper title="Orders by Status" loading={loading}>
          <PieChart
            data={mockChartData.ordersByStatus}
            height={300}
          />
        </ChartWrapper>

        <ChartWrapper title="Daily Orders" loading={loading}>
          <BarChart
            data={mockChartData.revenue}
            dataKey="date"
            bars={[{ key: 'orders', name: 'Orders', color: '#181E29' }]}
            height={300}
          />
        </ChartWrapper>

        <ChartWrapper title="Revenue by Day" loading={loading}>
          <BarChart
            data={mockChartData.revenue}
            dataKey="date"
            bars={[{ key: 'revenue', name: 'Revenue', color: '#181E29' }]}
            height={300}
          />
        </ChartWrapper>
      </div>
    </div>
  );
}

