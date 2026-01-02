'use client';

import { useState, useEffect } from 'react';
import { useRouter, useSearchParams } from 'next/navigation';
import { MerchantPortalAPI } from '@/src/lib/api';
import { toast } from '@/app/components/Toaster';
import { Button, Select, Breadcrumbs, StatusBadge, DataTable, Pagination } from '@/app/components';
import PageSkeleton from '@/app/components/PageSkeleton';
import Icon, { faReceipt } from '@/app/components/Icon';
import Link from 'next/link';

export default function OrdersPage() {
  const router = useRouter();
  const searchParams = useSearchParams();
  const businessId = searchParams.get('businessId') || '';
  const listingId = searchParams.get('listingId') || '';
  const [orders, setOrders] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);
  const [page, setPage] = useState(1);
  const [pageSize, setPageSize] = useState(20);
  const [total, setTotal] = useState(0);
  const [statusFilter, setStatusFilter] = useState<string>('all');
  const [fulfillmentFilter, setFulfillmentFilter] = useState<string>('all');

  useEffect(() => {
    if (businessId) {
      fetchOrders();
    }
  }, [businessId, listingId, page, pageSize, statusFilter, fulfillmentFilter]);

  const fetchOrders = async () => {
    if (!businessId) return;
    setLoading(true);
    try {
      const params: any = {
        page,
        limit: pageSize,
      };
      if (listingId) params.listingId = listingId;
      if (statusFilter !== 'all') params.status = statusFilter;
      if (fulfillmentFilter !== 'all') params.fulfillmentType = fulfillmentFilter;

      const response = await MerchantPortalAPI.getOrders(businessId, params);
      setOrders(response.data || []);
      setTotal(response.meta?.total || 0);
    } catch (error: any) {
      console.error('Failed to fetch orders:', error);
      toast.error(error?.response?.data?.message || error?.message || 'Failed to load orders');
    } finally {
      setLoading(false);
    }
  };

  const columns = [
    {
      key: 'orderNumber',
      label: 'Order #',
      sortable: false,
      render: (_: any, row: any) => (
        <Link
          href={`/dashboard/my-orders/${row.id}?businessId=${businessId}`}
          className="text-[#0e1a30] hover:underline font-medium"
        >
          {row.orderNumber}
        </Link>
      ),
    },
    {
      key: 'listing',
      label: 'Listing',
      sortable: false,
      render: (_: any, row: any) => (
        <div>
          <p className="font-medium text-gray-900">{row.listing?.name || 'N/A'}</p>
        </div>
      ),
    },
    {
      key: 'customer',
      label: 'Customer',
      sortable: false,
      render: (_: any, row: any) => (
        <div>
          <p className="text-sm text-gray-900">{row.customerName}</p>
          <p className="text-xs text-gray-500">{row.customerPhone}</p>
        </div>
      ),
    },
    {
      key: 'items',
      label: 'Items',
      sortable: false,
      render: (_: any, row: any) => (
        <div>
          <p className="text-sm text-gray-900">{row.items?.length || 0} item(s)</p>
        </div>
      ),
    },
    {
      key: 'total',
      label: 'Total',
      sortable: false,
      render: (_: any, row: any) => (
        <div>
          <p className="font-medium text-gray-900">
            {row.totalAmount?.toLocaleString()} {row.currency || 'RWF'}
          </p>
        </div>
      ),
    },
    {
      key: 'fulfillment',
      label: 'Fulfillment',
      sortable: false,
      render: (_: any, row: any) => (
        <div>
          <p className="text-sm text-gray-900 capitalize">
            {row.fulfillmentType?.replace('_', ' ') || 'N/A'}
          </p>
        </div>
      ),
    },
    {
      key: 'status',
      label: 'Status',
      sortable: false,
      render: (_: any, row: any) => (
        <StatusBadge
          status={
            row.status === 'confirmed' || row.status === 'processing' ? 'active' :
            row.status === 'pending' ? 'pending' :
            row.status === 'delivered' ? 'active' :
            row.status === 'cancelled' ? 'inactive' : 'pending'
          }
        />
      ),
    },
    {
      key: 'date',
      label: 'Date',
      sortable: false,
      render: (_: any, row: any) => (
        <div>
          <p className="text-sm text-gray-900">
            {new Date(row.createdAt).toLocaleDateString()}
          </p>
          <p className="text-xs text-gray-500">
            {new Date(row.createdAt).toLocaleTimeString()}
          </p>
        </div>
      ),
    },
  ];

  if (loading && orders.length === 0) {
    return <PageSkeleton />;
  }

  return (
    <div className="space-y-6">
      <Breadcrumbs items={[
        { label: 'Dashboard', href: '/dashboard/my-dashboard' },
        { label: 'Orders' }
      ]} />

      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-bold text-gray-900">Orders</h1>
          <p className="text-gray-600 mt-1">Manage shop orders for your listings</p>
        </div>
      </div>

      {/* Filters */}
      <div className="bg-white border border-gray-200 rounded-sm p-4">
        <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
          <Select
            label="Status"
            value={statusFilter}
            onChange={(e) => {
              setStatusFilter(e.target.value);
              setPage(1);
            }}
            options={[
              { value: 'all', label: 'All Statuses' },
              { value: 'pending', label: 'Pending' },
              { value: 'confirmed', label: 'Confirmed' },
              { value: 'processing', label: 'Processing' },
              { value: 'shipped', label: 'Shipped' },
              { value: 'delivered', label: 'Delivered' },
              { value: 'cancelled', label: 'Cancelled' },
            ]}
          />
          <Select
            label="Fulfillment Type"
            value={fulfillmentFilter}
            onChange={(e) => {
              setFulfillmentFilter(e.target.value);
              setPage(1);
            }}
            options={[
              { value: 'all', label: 'All Types' },
              { value: 'delivery', label: 'Delivery' },
              { value: 'pickup', label: 'Pickup' },
              { value: 'dine_in', label: 'Dine In' },
            ]}
          />
        </div>
      </div>

      <div className="bg-white border border-gray-200 rounded-sm">
        <DataTable
          data={orders}
          columns={columns}
          loading={loading}
        />
        {total > pageSize && (
          <div className="p-4 border-t border-gray-200">
            <Pagination
              currentPage={page}
              totalPages={Math.ceil(total / pageSize)}
              onPageChange={setPage}
            />
          </div>
        )}
      </div>
    </div>
  );
}

