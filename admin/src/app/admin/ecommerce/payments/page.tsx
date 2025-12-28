'use client';

import { useState, useEffect } from 'react';
import Icon, { faCreditCard, faDollarSign, faCheck, faTimes } from '../../../components/Icon';
import DataTable from '../../../components/DataTable';
import ChartWrapper from '../../../components/ChartWrapper';
import PieChart from '../../../components/charts/PieChart';
import LineChart from '../../../components/charts/LineChart';
import { mockOrders, mockChartData } from '@/lib/mockData';

export default function EcommercePaymentsPage() {
  const [loading, setLoading] = useState(true);
  const [payments, setPayments] = useState<any[]>([]);

  useEffect(() => {
    setTimeout(() => {
      setPayments([
        {
          id: 1,
          order_no: 'ORD-2025-001',
          customer_name: 'John Doe',
          amount: 125000,
          payment_method: 'Card',
          status: 'successful',
          date: '2025-01-15',
        },
        {
          id: 2,
          order_no: 'ORD-2025-002',
          customer_name: 'Jane Smith',
          amount: 75000,
          payment_method: 'Mobile Money',
          status: 'successful',
          date: '2025-01-16',
        },
        {
          id: 3,
          order_no: 'ORD-2025-003',
          customer_name: 'Mike Johnson',
          amount: 95000,
          payment_method: 'Card',
          status: 'failed',
          date: '2025-01-17',
        },
      ]);
      setLoading(false);
    }, 500);
  }, []);

  const columns = [
    { key: 'order_no', label: 'Order #', sortable: true },
    { key: 'customer_name', label: 'Customer', sortable: true },
    { key: 'amount', label: 'Amount', sortable: true, render: (value: number) => `RWF ${value.toLocaleString()}` },
    { key: 'payment_method', label: 'Method', sortable: true },
    {
      key: 'status',
      label: 'Status',
      sortable: true,
      render: (value: string) => {
        const colors: Record<string, string> = {
          successful: 'bg-green-100 text-green-800',
          failed: 'bg-red-100 text-red-800',
          pending: 'bg-yellow-100 text-yellow-800',
        };
        const color = colors[value] || 'bg-gray-100 text-gray-800';
        return (
          <span className={`px-2 py-1 rounded-full text-xs font-medium ${color}`}>
            {value}
          </span>
        );
      },
    },
    { key: 'date', label: 'Date', sortable: true, render: (value: string) => new Date(value).toLocaleDateString() },
  ];

  const totalPayments = payments.length;
  const successfulPayments = payments.filter(p => p.status === 'successful').length;
  const failedPayments = payments.filter(p => p.status === 'failed').length;
  const totalAmount = payments.reduce((sum, p) => sum + p.amount, 0);

  return (
    <div>
      <div className="mb-8">
        <h1 className="text-3xl font-bold text-gray-900 mb-2">Payments</h1>
        <p className="text-gray-600">View and manage all payment transactions</p>
      </div>

      {/* Summary Stats */}
      <div className="grid grid-cols-1 md:grid-cols-4 gap-6 mb-6">
        <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-6">
          <div className="flex items-center gap-3 mb-2">
            <Icon icon={faCreditCard} className="text-primary" />
            <p className="text-sm text-gray-500">Total Payments</p>
          </div>
          <p className="text-2xl font-bold text-gray-900">{totalPayments}</p>
        </div>
        <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-6">
          <div className="flex items-center gap-3 mb-2">
            <Icon icon={faCheck} className="text-green-600" />
            <p className="text-sm text-gray-500">Successful</p>
          </div>
          <p className="text-2xl font-bold text-gray-900">{successfulPayments}</p>
        </div>
        <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-6">
          <div className="flex items-center gap-3 mb-2">
            <Icon icon={faTimes} className="text-red-600" />
            <p className="text-sm text-gray-500">Failed</p>
          </div>
          <p className="text-2xl font-bold text-gray-900">{failedPayments}</p>
        </div>
        <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-6">
          <div className="flex items-center gap-3 mb-2">
            <Icon icon={faDollarSign} className="text-primary" />
            <p className="text-sm text-gray-500">Total Amount</p>
          </div>
          <p className="text-2xl font-bold text-gray-900">RWF {totalAmount.toLocaleString()}</p>
        </div>
      </div>

      {/* Charts */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6 mb-6">
        <ChartWrapper title="Payment Status" loading={loading}>
          <PieChart
            data={[
              { name: 'Successful', value: successfulPayments },
              { name: 'Failed', value: failedPayments },
            ]}
            height={300}
          />
        </ChartWrapper>

        <ChartWrapper title="Payment Trend" loading={loading}>
          <LineChart
            data={mockChartData.revenue.map(item => ({
              date: item.date,
              payments: item.orders * 1.2,
            }))}
            dataKey="date"
            lines={[
              { key: 'payments', name: 'Payments', color: '#181E29' },
            ]}
            height={300}
          />
        </ChartWrapper>
      </div>

      {/* Data Table */}
      <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-6">
        <h2 className="text-lg font-semibold text-gray-900 mb-4">All Payments</h2>
        <DataTable
          columns={columns}
          data={payments}
          loading={loading}
        />
      </div>
    </div>
  );
}

