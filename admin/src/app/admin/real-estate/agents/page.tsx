'use client';

import { useState, useEffect } from 'react';
import Icon, { faUserShield, faHome, faDollarSign, faChartLine } from '../../../components/Icon';
import DataTable from '../../../components/DataTable';
import ChartWrapper from '../../../components/ChartWrapper';
import BarChart from '../../../components/charts/BarChart';
import { mockProperties } from '@/lib/mockData';

export default function RealEstateAgentsPage() {
  const [loading, setLoading] = useState(true);
  const [agents, setAgents] = useState<any[]>([]);

  useEffect(() => {
    setTimeout(() => {
      setAgents([
        {
          id: 1,
          name: 'John Doe',
          email: 'john@example.com',
          phone: '+250788123456',
          properties: 12,
          sales: 8,
          revenue: 3500000,
          commission: 175000,
          status: 'active',
        },
        {
          id: 2,
          name: 'Jane Smith',
          email: 'jane@example.com',
          phone: '+250788234567',
          properties: 10,
          sales: 6,
          revenue: 2800000,
          commission: 140000,
          status: 'active',
        },
        {
          id: 3,
          name: 'Mike Johnson',
          email: 'mike@example.com',
          phone: '+250788345678',
          properties: 8,
          sales: 5,
          revenue: 2200000,
          commission: 110000,
          status: 'active',
        },
      ]);
      setLoading(false);
    }, 500);
  }, []);

  const columns = [
    { key: 'name', label: 'Name', sortable: true },
    { key: 'email', label: 'Email', sortable: true },
    { key: 'phone', label: 'Phone', sortable: true },
    { key: 'properties', label: 'Properties', sortable: true },
    { key: 'sales', label: 'Sales', sortable: true },
    { key: 'revenue', label: 'Revenue', sortable: true, render: (value: number) => `RWF ${value.toLocaleString()}` },
    { key: 'commission', label: 'Commission', sortable: true, render: (value: number) => `RWF ${value.toLocaleString()}` },
    {
      key: 'status',
      label: 'Status',
      sortable: true,
      render: (value: string) => (
        <span className={`px-2 py-1 rounded-full text-xs font-medium ${
          value === 'active' ? 'bg-green-100 text-green-800' : 'bg-gray-100 text-gray-800'
        }`}>
          {value}
        </span>
      ),
    },
  ];

  const totalAgents = agents.length;
  const totalSales = agents.reduce((sum, a) => sum + a.sales, 0);
  const totalRevenue = agents.reduce((sum, a) => sum + a.revenue, 0);
  const totalCommission = agents.reduce((sum, a) => sum + a.commission, 0);

  return (
    <div>
      <div className="mb-8">
        <h1 className="text-3xl font-bold text-gray-900 mb-2">Real Estate Agents</h1>
        <p className="text-gray-600">Manage and view all real estate agents</p>
      </div>

      {/* Summary Stats */}
      <div className="grid grid-cols-1 md:grid-cols-4 gap-6 mb-6">
        <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-6">
          <div className="flex items-center gap-3 mb-2">
            <Icon icon={faUserShield} className="text-primary" />
            <p className="text-sm text-gray-500">Total Agents</p>
          </div>
          <p className="text-2xl font-bold text-gray-900">{totalAgents}</p>
        </div>
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
            <p className="text-sm text-gray-500">Total Commission</p>
          </div>
          <p className="text-2xl font-bold text-gray-900">RWF {totalCommission.toLocaleString()}</p>
        </div>
      </div>

      {/* Charts */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6 mb-6">
        <ChartWrapper title="Top Agents by Sales" loading={loading}>
          <BarChart
            data={agents}
            dataKey="name"
            bars={[{ key: 'sales', name: 'Sales', color: '#181E29' }]}
            height={300}
          />
        </ChartWrapper>

        <ChartWrapper title="Agents by Revenue" loading={loading}>
          <BarChart
            data={agents}
            dataKey="name"
            bars={[{ key: 'revenue', name: 'Revenue', color: '#181E29' }]}
            height={300}
          />
        </ChartWrapper>
      </div>

      {/* Data Table */}
      <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-6">
        <h2 className="text-lg font-semibold text-gray-900 mb-4">All Agents</h2>
        <DataTable
          columns={columns}
          data={agents}
          loading={loading}
        />
      </div>
    </div>
  );
}

