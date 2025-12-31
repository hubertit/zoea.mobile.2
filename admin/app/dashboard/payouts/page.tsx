'use client';

import { useState, useEffect } from 'react';
import { useRouter } from 'next/navigation';
import Link from 'next/link';
import { PaymentsAPI, type Payout, type PaymentStatus } from '@/src/lib/api';
import Icon, { faSearch, faTimes } from '@/app/components/Icon';
import { toast } from '@/app/components/Toaster';
import { DataTable, Pagination } from '@/app/components';
import PageSkeleton from '@/app/components/PageSkeleton';

const STATUSES: { value: PaymentStatus | ''; label: string }[] = [
  { value: '', label: 'All Status' },
  { value: 'pending', label: 'Pending' },
  { value: 'processing', label: 'Processing' },
  { value: 'completed', label: 'Completed' },
  { value: 'failed', label: 'Failed' },
  { value: 'refunded', label: 'Refunded' },
  { value: 'partially_refunded', label: 'Partially Refunded' },
];

const getStatusBadgeColor = (status: PaymentStatus) => {
  switch (status) {
    case 'completed':
      return 'bg-green-100 text-green-800';
    case 'pending':
    case 'processing':
      return 'bg-yellow-100 text-yellow-800';
    case 'failed':
      return 'bg-red-100 text-red-800';
    case 'refunded':
    case 'partially_refunded':
      return 'bg-orange-100 text-orange-800';
    default:
      return 'bg-gray-100 text-gray-800';
  }
};

export default function PayoutsPage() {
  const router = useRouter();
  const [payouts, setPayouts] = useState<Payout[]>([]);
  const [loading, setLoading] = useState(true);
  const [page, setPage] = useState(1);
  const [pageSize, setPageSize] = useState(10);
  const [total, setTotal] = useState(0);
  const [search, setSearch] = useState('');
  const [statusFilter, setStatusFilter] = useState<PaymentStatus | ''>('');

  useEffect(() => {
    const fetchPayouts = async () => {
      setLoading(true);
      try {
        const params: any = {
          page,
          limit: pageSize,
        };

        if (statusFilter) {
          params.status = statusFilter;
        }

        const response = await PaymentsAPI.listPayouts(params);
        
        // Client-side search filtering
        let filteredData = response.data || [];
        if (search.trim()) {
          const searchLower = search.toLowerCase();
          filteredData = filteredData.filter((payout) => {
            const reference = payout.reference?.toLowerCase() || '';
            const merchantName = payout.merchant?.businessName?.toLowerCase() || '';
            
            return reference.includes(searchLower) ||
                   merchantName.includes(searchLower);
          });
        }
        
        setPayouts(filteredData);
        setTotal(response.meta?.total || 0);
      } catch (error: any) {
        console.error('Failed to fetch payouts:', error);
        toast.error(error?.message || 'Failed to load payouts');
      } finally {
        setLoading(false);
      }
    };

    fetchPayouts();
  }, [page, pageSize, statusFilter, search]);

  const totalPages = Math.ceil(total / pageSize);

  const columns = [
    {
      key: 'reference',
      label: 'Reference',
      sortable: false,
      render: (_: any, row: Payout) => (
        <div>
          <Link href={`/dashboard/payments/payouts/${row.id}`} className="text-sm font-medium text-[#0e1a30] hover:underline">
            {row.reference || row.id.substring(0, 8)}
          </Link>
          <p className="text-xs text-gray-500">
            {row.createdAt ? new Date(row.createdAt).toLocaleDateString('en-US', {
              month: 'short',
              day: 'numeric',
              year: 'numeric',
            }) : '-'}
          </p>
        </div>
      ),
    },
    {
      key: 'merchant',
      label: 'Merchant',
      sortable: false,
      render: (_: any, row: Payout) => (
        <div>
          {row.merchant ? (
            <Link href={`/dashboard/merchants/${row.merchant.id}`} className="text-sm text-[#0e1a30] hover:underline">
              {row.merchant.businessName || 'N/A'}
            </Link>
          ) : (
            <span className="text-sm text-gray-400">-</span>
          )}
        </div>
      ),
    },
    {
      key: 'amount',
      label: 'Amount',
      sortable: false,
      render: (_: any, row: Payout) => (
        <p className="text-sm font-medium text-gray-900">
          {row.currency || 'RWF'} {row.amount?.toLocaleString() || '0'}
        </p>
      ),
    },
    {
      key: 'status',
      label: 'Status',
      sortable: false,
      render: (_: any, row: Payout) => (
        <span className={`inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium ${getStatusBadgeColor(row.status || 'pending')}`}>
          {row.status?.replace(/_/g, ' ') || '-'}
        </span>
      ),
    },
    {
      key: 'processed',
      label: 'Processed At',
      sortable: false,
      render: (_: any, row: Payout) => (
        <p className="text-sm text-gray-900">
          {row.processedAt ? new Date(row.processedAt).toLocaleDateString('en-US', {
            month: 'short',
            day: 'numeric',
            year: 'numeric',
          }) : '-'}
        </p>
      ),
    },
  ];

  if (loading) {
    return <PageSkeleton />;
  }

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex items-center justify-between flex-wrap gap-4">
        <div>
          <h1 className="text-2xl font-bold text-gray-900">Payouts</h1>
          <p className="text-gray-600 mt-1">Manage merchant payouts</p>
        </div>
        <Link href="/dashboard/payments">
          <span className="text-sm text-[#0e1a30] hover:underline">View Payments Dashboard</span>
        </Link>
      </div>

      {/* Filters */}
      <div className="bg-white border border-gray-200 rounded-sm p-4">
        <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
          {/* Search */}
          <div className="md:col-span-2">
            <div className="relative">
              <Icon
                icon={faSearch}
                className="absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400"
                size="sm"
              />
              <input
                type="text"
                placeholder="Search by reference, merchant..."
                value={search}
                onChange={(e) => {
                  setSearch(e.target.value);
                  setPage(1);
                }}
                className="w-full pl-10 pr-4 py-2 border border-gray-200 rounded-sm focus:outline-none focus:ring-1 focus:ring-[#0e1a30] focus:border-[#0e1a30] text-sm"
              />
              {search && (
                <button
                  onClick={() => {
                    setSearch('');
                    setPage(1);
                  }}
                  className="absolute right-3 top-1/2 transform -translate-y-1/2 text-gray-400 hover:text-gray-600"
                >
                  <Icon icon={faTimes} size="xs" />
                </button>
              )}
            </div>
          </div>

          {/* Status Filter */}
          <div>
            <select
              value={statusFilter}
              onChange={(e) => {
                setStatusFilter(e.target.value as PaymentStatus | '');
                setPage(1);
              }}
              className="w-full px-3 py-2 border border-gray-200 rounded-sm focus:outline-none focus:ring-1 focus:ring-[#0e1a30] focus:border-[#0e1a30] text-sm"
            >
              {STATUSES.map((status) => (
                <option key={status.value} value={status.value}>
                  {status.label}
                </option>
              ))}
            </select>
          </div>
        </div>
      </div>

      {/* Table */}
      <DataTable
        columns={columns}
        data={payouts}
        loading={loading}
        onRowClick={(row) => router.push(`/dashboard/payments/payouts/${row.id}`)}
        emptyMessage="No payouts found"
        showNumbering={true}
        numberingStart={(page - 1) * pageSize + 1}
      />

      {/* Pagination */}
      {totalPages > 1 && (
        <Pagination
          currentPage={page}
          totalPages={totalPages}
          onPageChange={setPage}
        />
      )}
    </div>
  );
}

