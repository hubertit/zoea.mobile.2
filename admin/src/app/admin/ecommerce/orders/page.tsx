'use client';

import { useEffect, useState } from 'react';
import DataTable from '../../../components/DataTable';
import Icon, { faEye, faEdit } from '../../../components/Icon';
import Link from 'next/link';
import { Order } from '@/types';
import { mockOrders } from '@/lib/mockData';

export default function OrdersPage() {
  const [orders, setOrders] = useState<Order[]>(mockOrders);
  const [loading, setLoading] = useState(false);
  const [sortKey, setSortKey] = useState<string>('');
  const [sortDirection, setSortDirection] = useState<'asc' | 'desc'>('desc');

  // Using mock data - no API call needed

  const handleSort = (key: string, direction: 'asc' | 'desc') => {
    setSortKey(key);
    setSortDirection(direction);
    
    const sorted = [...orders].sort((a, b) => {
      const aVal = a[key as keyof Order];
      const bVal = b[key as keyof Order];
      
      if (aVal === undefined || aVal === null) return 1;
      if (bVal === undefined || bVal === null) return -1;
      
      if (direction === 'asc') {
        return aVal > bVal ? 1 : -1;
      } else {
        return aVal < bVal ? 1 : -1;
      }
    });
    
    setOrders(sorted);
  };

  const getStatusBadge = (status: string) => {
    const statusColors: Record<string, string> = {
      'pending': 'bg-yellow-100 text-yellow-800',
      'confirmed': 'bg-blue-100 text-blue-800',
      'processing': 'bg-purple-100 text-purple-800',
      'shipped': 'bg-indigo-100 text-indigo-800',
      'delivered': 'bg-green-100 text-green-800',
      'cancelled': 'bg-red-100 text-red-800',
    };
    
    const color = statusColors[status.toLowerCase()] || 'bg-gray-100 text-gray-800';
    
    return (
      <span className={`px-2 py-1 rounded-full text-xs font-medium ${color}`}>
        {status}
      </span>
    );
  };

  const columns = [
    {
      key: 'order_no',
      label: 'Order #',
      sortable: true,
      render: (value: string) => (
        <span className="font-mono text-sm font-medium">{value}</span>
      ),
    },
    {
      key: 'customer_id',
      label: 'Customer ID',
      sortable: true,
    },
    {
      key: 'seller_id',
      label: 'Merchant ID',
      sortable: true,
    },
    {
      key: 'total_amount',
      label: 'Amount',
      sortable: true,
      render: (value: number, row: Order) => (
        <div>
          <div className="font-medium">{value.toLocaleString()} {row.currency}</div>
        </div>
      ),
    },
    {
      key: 'status',
      label: 'Status',
      sortable: true,
      render: (value: string) => getStatusBadge(value),
    },
    {
      key: 'order_date',
      label: 'Date',
      sortable: true,
      render: (value: string) => {
        const date = new Date(value);
        return date.toLocaleDateString();
      },
    },
    {
      key: 'actions',
      label: 'Actions',
      render: (_: any, row: Order) => (
        <div className="flex items-center gap-2">
          <Link
            href={`/admin/ecommerce/orders/${row.id}`}
            className="p-2 text-primary hover:bg-primary/10 rounded-sm transition-colors"
            title="View"
          >
            <Icon icon={faEye} size="sm" />
          </Link>
          <Link
            href={`/admin/ecommerce/orders/${row.id}/edit`}
            className="p-2 text-blue-600 hover:bg-blue-50 rounded-sm transition-colors"
            title="Edit"
          >
            <Icon icon={faEdit} size="sm" />
          </Link>
        </div>
      ),
    },
  ];

  return (
    <div>
      <div className="mb-8">
        <h1 className="text-3xl font-bold text-gray-900 mb-2">Orders</h1>
        <p className="text-gray-600">Manage and track e-commerce orders</p>
      </div>

      <DataTable
        columns={columns}
        data={orders}
        loading={loading}
        onSort={handleSort}
        sortKey={sortKey}
        sortDirection={sortDirection}
      />
    </div>
  );
}

