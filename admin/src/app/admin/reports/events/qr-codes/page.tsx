'use client';

import { useState } from 'react';
import Icon, { faDownload, faQrcode, faBarcode, faCheck, faArrowLeft } from '../../../../components/Icon';
import Link from 'next/link';
import ChartWrapper from '../../../../components/ChartWrapper';
import BarChart from '../../../../components/charts/BarChart';
import LineChart from '../../../../components/charts/LineChart';
import { mockChartData } from '@/lib/mockData';

export default function QRCodeUsageReportPage() {
  const [dateRange, setDateRange] = useState({
    start: '2025-01-01',
    end: '2025-12-31',
  });

  const totalScans = 3456;
  const uniqueScans = 2890;
  const successfulScans = 3320;
  const failedScans = 136;

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
              <h1 className="text-3xl font-bold text-gray-900 mb-2">QR Code Usage Report</h1>
              <p className="text-gray-600">QR code scan analytics and usage statistics</p>
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
            <Icon icon={faQrcode} className="text-primary" />
            <p className="text-sm text-gray-500">Total Scans</p>
          </div>
          <p className="text-2xl font-bold text-gray-900">{totalScans.toLocaleString()}</p>
        </div>
        <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-6">
          <div className="flex items-center gap-3 mb-2">
            <Icon icon={faBarcode} className="text-primary" />
            <p className="text-sm text-gray-500">Unique Scans</p>
          </div>
          <p className="text-2xl font-bold text-gray-900">{uniqueScans.toLocaleString()}</p>
        </div>
        <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-6">
          <div className="flex items-center gap-3 mb-2">
            <Icon icon={faCheck} className="text-green-600" />
            <p className="text-sm text-gray-500">Successful</p>
          </div>
          <p className="text-2xl font-bold text-gray-900">{successfulScans.toLocaleString()}</p>
        </div>
        <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-6">
          <div className="flex items-center gap-3 mb-2">
            <Icon icon={faQrcode} className="text-red-600" />
            <p className="text-sm text-gray-500">Failed</p>
          </div>
          <p className="text-2xl font-bold text-gray-900">{failedScans}</p>
        </div>
      </div>

      {/* Charts */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6 mb-6">
        <ChartWrapper title="QR Code Scans (Last 7 Days)">
          <BarChart
            data={mockChartData.userGrowth.map((item, idx) => ({
              date: item.date,
              scans: item.users * 12 + Math.floor(Math.random() * 50),
            }))}
            dataKey="date"
            bars={[{ key: 'scans', name: 'Scans', color: '#181E29' }]}
            height={300}
          />
        </ChartWrapper>

        <ChartWrapper title="Scan Trend">
          <LineChart
            data={mockChartData.userGrowth.map((item, idx) => ({
              date: item.date,
              scans: item.users * 12 + Math.floor(Math.random() * 50),
            }))}
            dataKey="date"
            lines={[
              { key: 'scans', name: 'Total Scans', color: '#181E29' },
            ]}
            height={300}
          />
        </ChartWrapper>
      </div>
    </div>
  );
}

