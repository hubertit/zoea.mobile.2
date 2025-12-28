'use client';

import { useState, useEffect } from 'react';
import Icon, { faStore, faUsers, faShoppingCart, faDollarSign } from '../../../components/Icon';
import DataTable from '../../../components/DataTable';
import ChartWrapper from '../../../components/ChartWrapper';
import BarChart from '../../../components/charts/BarChart';
import PieChart from '../../../components/charts/PieChart';

export default function UserMerchantsPage() {
  const [loading, setLoading] = useState(true);
  const [merchants, setMerchants] = useState<any[]>([]);

  useEffect(() => {
    setTimeout(() => {
      setMerchants([
        {
          id: 1,
          name: 'Tech Store Owner',
          email: 'tech@example.com',
          phone: '+250788123456',
          store_name: 'Tech Store',
          orders: 125,
          revenue: 3500000,
          status: 'active',
        },
        {
          id: 2,
          name: 'Fashion Boutique Owner',
          email: 'fashion@example.com',
          phone: '+250788234567',
          store_name: 'Fashion Boutique',
          orders: 98,
          revenue: 2800000,
          status: 'active',
        },
        {
          id: 3,
          name: 'Electronics Hub Owner',
          email: 'electronics@example.com',
          phone: '+250788345678',
          store_name: 'Electronics Hub',
          orders: 87,
          revenue: 2200000,
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
    { key: 'store_name', label: 'Store', sortable: true },
    { key: 'orders', label: 'Orders', sortable: true },
    { key: 'revenue', label: 'Revenue', sortable: true, render: (value: number) => `RWF ${value.toLocaleString()}` },
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

  const totalMerchants = merchants.length;
  const activeMerchants = merchants.filter(m => m.status === 'active').length;
  const totalRevenue = merchants.reduce((sum, m) => sum + m.revenue, 0);
  const totalOrders = merchants.reduce((sum, m) => sum + m.orders, 0);

  return (
    <div>
      <div className="mb-8">
        <h1 className="text-3xl font-bold text-gray-900 mb-2">Merchants</h1>
        <p className="text-gray-600">Manage and view all merchant users</p>
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
            <Icon icon={faUsers} className="text-green-600" />
            <p className="text-sm text-gray-500">Active Merchants</p>
          </div>
          <p className="text-2xl font-bold text-gray-900">{activeMerchants}</p>
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
            <Icon icon={faDollarSign} className="text-primary" />
            <p className="text-sm text-gray-500">Total Revenue</p>
          </div>
          <p className="text-2xl font-bold text-gray-900">RWF {totalRevenue.toLocaleString()}</p>
        </div>
      </div>

      {/* Charts */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6 mb-6">
        <ChartWrapper title="Top Merchants by Revenue" loading={loading}>
          <BarChart
            data={merchants}
            dataKey="name"
            bars={[{ key: 'revenue', name: 'Revenue', color: '#181E29' }]}
            height={300}
          />
        </ChartWrapper>

        <ChartWrapper title="Merchant Status" loading={loading}>
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
        <h2 className="text-lg font-semibold text-gray-900 mb-4">All Merchants</h2>
        <DataTable
          columns={columns}
          data={merchants}
          loading={loading}
        />
      </div>
    </div>
  );
}

