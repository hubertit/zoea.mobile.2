'use client';

import { useState } from 'react';
import Icon, { faDownload, faUserShield, faHome, faDollarSign, faChartLine, faArrowLeft } from '../../../../components/Icon';
import Link from 'next/link';
import ChartWrapper from '../../../../components/ChartWrapper';
import BarChart from '../../../../components/charts/BarChart';
import PieChart from '../../../../components/charts/PieChart';
import DataTable from '../../../../components/DataTable';
import { mockProperties } from '@/lib/mockData';

export default function AgentPerformanceReportPage() {
  const [dateRange, setDateRange] = useState({
    start: '2025-01-01',
    end: '2025-12-31',
  });

  const totalAgents = 25;
  const activeAgents = 18;
  const totalSales = 42;
  const totalCommission = 12500000;

  const columns = [
    { key: 'agent_name', label: 'Agent', sortable: true },
    { key: 'properties', label: 'Properties', sortable: true },
    { key: 'sales', label: 'Sales', sortable: true },
    { key: 'revenue', label: 'Revenue', sortable: true, render: (value: number) => `RWF ${value.toLocaleString()}` },
    { key: 'commission', label: 'Commission', sortable: true, render: (value: number) => `RWF ${value.toLocaleString()}` },
  ];

  const agentData = [
    { agent_name: 'John Doe', properties: 12, sales: 8, revenue: 3500000, commission: 175000 },
    { agent_name: 'Jane Smith', properties: 10, sales: 6, revenue: 2800000, commission: 140000 },
    { agent_name: 'Mike Johnson', properties: 8, sales: 5, revenue: 2200000, commission: 110000 },
    { agent_name: 'Sarah Williams', properties: 9, sales: 4, revenue: 1900000, commission: 95000 },
    { agent_name: 'David Brown', properties: 7, sales: 3, revenue: 1500000, commission: 75000 },
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
              <h1 className="text-3xl font-bold text-gray-900 mb-2">Agent Performance Report</h1>
              <p className="text-gray-600">Real estate agent performance and analytics</p>
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
            <Icon icon={faUserShield} className="text-primary" />
            <p className="text-sm text-gray-500">Total Agents</p>
          </div>
          <p className="text-2xl font-bold text-gray-900">{totalAgents}</p>
        </div>
        <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-6">
          <div className="flex items-center gap-3 mb-2">
            <Icon icon={faUserShield} className="text-green-600" />
            <p className="text-sm text-gray-500">Active Agents</p>
          </div>
          <p className="text-2xl font-bold text-gray-900">{activeAgents}</p>
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
            <p className="text-sm text-gray-500">Total Commission</p>
          </div>
          <p className="text-2xl font-bold text-gray-900">RWF {totalCommission.toLocaleString()}</p>
        </div>
      </div>

      {/* Charts */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6 mb-6">
        <ChartWrapper title="Top Agents by Sales">
          <BarChart
            data={agentData}
            dataKey="agent_name"
            bars={[{ key: 'sales', name: 'Sales', color: '#181E29' }]}
            height={300}
          />
        </ChartWrapper>

        <ChartWrapper title="Agent Performance Distribution">
          <PieChart
            data={[
              { name: 'Top Performers', value: 8 },
              { name: 'Average', value: 10 },
              { name: 'Below Average', value: 7 },
            ]}
            height={300}
          />
        </ChartWrapper>
      </div>

      {/* Data Table */}
      <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-6">
        <h2 className="text-lg font-semibold text-gray-900 mb-4">Agent Performance Details</h2>
        <DataTable
          columns={columns}
          data={agentData}
          loading={false}
        />
      </div>
    </div>
  );
}

