'use client';

import { useState, useEffect } from 'react';
import Icon, { faHome, faDollarSign, faChartLine, faUsers } from '../../../components/Icon';
import ChartWrapper from '../../../components/ChartWrapper';
import LineChart from '../../../components/charts/LineChart';
import BarChart from '../../../components/charts/BarChart';
import PieChart from '../../../components/charts/PieChart';
import { mockProperties, mockChartData, mockDashboardStats } from '@/lib/mockData';

export default function RealEstateAnalyticsPage() {
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    setLoading(false);
  }, []);

  const avgPrice = mockProperties.reduce((sum, p) => sum + p.price, 0) / mockProperties.length;

  return (
    <div>
      <div className="mb-8">
        <h1 className="text-3xl font-bold text-gray-900 mb-2">Market Analytics</h1>
        <p className="text-gray-600">Real estate market trends and performance metrics</p>
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
          <p className="text-2xl font-bold text-gray-900">
            {mockProperties.filter(p => p.status === 'available').length}
          </p>
        </div>
        <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-6">
          <div className="flex items-center gap-3 mb-2">
            <Icon icon={faDollarSign} className="text-primary" />
            <p className="text-sm text-gray-500">Avg Price</p>
          </div>
          <p className="text-2xl font-bold text-gray-900">RWF {Math.round(avgPrice).toLocaleString()}</p>
        </div>
        <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-6">
          <div className="flex items-center gap-3 mb-2">
            <Icon icon={faUsers} className="text-primary" />
            <p className="text-sm text-gray-500">Active Agents</p>
          </div>
          <p className="text-2xl font-bold text-gray-900">18</p>
        </div>
      </div>

      {/* Charts */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6 mb-6">
        <ChartWrapper title="Properties by Category" loading={loading}>
          <PieChart
            data={mockChartData.propertiesByCategory}
            height={300}
          />
        </ChartWrapper>

        <ChartWrapper title="Properties by Type" loading={loading}>
          <BarChart
            data={[
              { type: 'Rent', count: mockProperties.filter(p => p.property_type === 'rent').length },
              { type: 'Sale', count: mockProperties.filter(p => p.property_type === 'sale').length },
            ]}
            dataKey="type"
            bars={[{ key: 'count', name: 'Properties', color: '#1a74e8' }]}
            height={300}
          />
        </ChartWrapper>

        <ChartWrapper title="Price Trend" loading={loading}>
          <LineChart
            data={mockChartData.revenue.map(item => ({
              date: item.date,
              price: item.revenue * 2.5,
            }))}
            dataKey="date"
            lines={[
              { key: 'price', name: 'Avg Price', color: '#1a74e8' },
            ]}
            height={300}
          />
        </ChartWrapper>

        <ChartWrapper title="Sales Performance" loading={loading}>
          <BarChart
            data={[
              { category: 'House', sales: 18, revenue: 6300000 },
              { category: 'Apartment', sales: 15, revenue: 4500000 },
              { category: 'Commercial', sales: 7, revenue: 2800000 },
            ]}
            dataKey="category"
            bars={[
              { key: 'sales', name: 'Sales', color: '#181E29' },
              { key: 'revenue', name: 'Revenue', color: '#1a74e8' },
            ]}
            height={300}
          />
        </ChartWrapper>
      </div>
    </div>
  );
}

