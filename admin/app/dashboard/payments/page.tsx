'use client';

import { useState, useEffect } from 'react';
import { useRouter } from 'next/navigation';
import { PaymentsAPI, type Transaction, type Payout, type TransactionType, type TransactionStatus, type PaymentStatus } from '@/src/lib/api';
import Icon, { faSearch, faTimes, faCreditCard, faMoneyBill } from '@/app/components/Icon';
import { toast } from '@/app/components/Toaster';
import { DataTable, Pagination, Button } from '@/app/components';
import PageSkeleton from '@/app/components/PageSkeleton';
import Card, { CardHeader, CardBody } from '@/app/components/Card';
import { useDebounce } from '@/src/hooks/useDebounce';

const TRANSACTION_TYPES: { value: TransactionType | ''; label: string }[] = [
  { value: '', label: 'All Types' },
  { value: 'deposit', label: 'Deposit' },
  { value: 'withdrawal', label: 'Withdrawal' },
  { value: 'payment', label: 'Payment' },
  { value: 'refund', label: 'Refund' },
  { value: 'commission', label: 'Commission' },
  { value: 'bonus', label: 'Bonus' },
  { value: 'payout', label: 'Payout' },
  { value: 'subscription', label: 'Subscription' },
];

const TRANSACTION_STATUSES: { value: TransactionStatus | ''; label: string }[] = [
  { value: '', label: 'All Status' },
  { value: 'pending', label: 'Pending' },
  { value: 'completed', label: 'Completed' },
  { value: 'failed', label: 'Failed' },
  { value: 'cancelled', label: 'Cancelled' },
];

const PAYOUT_STATUSES: { value: PaymentStatus | ''; label: string }[] = [
  { value: '', label: 'All Status' },
  { value: 'pending', label: 'Pending' },
  { value: 'processing', label: 'Processing' },
  { value: 'completed', label: 'Completed' },
  { value: 'failed', label: 'Failed' },
  { value: 'refunded', label: 'Refunded' },
];

const getStatusBadgeColor = (status: TransactionStatus | PaymentStatus) => {
  switch (status) {
    case 'completed':
      return 'bg-green-100 text-green-800';
    case 'pending':
    case 'processing':
      return 'bg-yellow-100 text-yellow-800';
    case 'failed':
    case 'cancelled':
      return 'bg-red-100 text-red-800';
    default:
      return 'bg-gray-100 text-gray-800';
  }
};

export default function PaymentsPage() {
  const router = useRouter();
  const [activeTab, setActiveTab] = useState<'transactions' | 'payouts'>('transactions');
  const [transactions, setTransactions] = useState<Transaction[]>([]);
  const [payouts, setPayouts] = useState<Payout[]>([]);
  const [loading, setLoading] = useState(true);
  const [page, setPage] = useState(1);
  const [pageSize, setPageSize] = useState(10);
  const [total, setTotal] = useState(0);
  const [search, setSearch] = useState('');
  const debouncedSearch = useDebounce(search, 500);
  const [typeFilter, setTypeFilter] = useState<TransactionType | ''>('');
  const [statusFilter, setStatusFilter] = useState<TransactionStatus | PaymentStatus | ''>('');

  // Fetch transactions
  useEffect(() => {
    if (activeTab === 'transactions') {
      const fetchTransactions = async () => {
        setLoading(true);
        try {
          const params: any = {
            page,
            limit: pageSize,
          };

          if (debouncedSearch.trim()) {
            params.search = debouncedSearch.trim();
          }

          if (typeFilter) {
            params.type = typeFilter;
          }

          if (statusFilter) {
            params.status = statusFilter as TransactionStatus;
          }

          const response = await PaymentsAPI.listTransactions(params);
          setTransactions(response.data || []);
          setTotal(response.meta?.total || 0);
        } catch (error: any) {
          console.error('Failed to fetch transactions:', error);
          toast.error(error?.message || 'Failed to load transactions');
        } finally {
          setLoading(false);
        }
      };

      fetchTransactions();
    }
  }, [activeTab, page, pageSize, debouncedSearch, typeFilter, statusFilter]);

  // Fetch payouts
  useEffect(() => {
    if (activeTab === 'payouts') {
      const fetchPayouts = async () => {
        setLoading(true);
        try {
          const params: any = {
            page,
            limit: pageSize,
          };

          if (debouncedSearch.trim()) {
            params.search = debouncedSearch.trim();
          }

          if (statusFilter) {
            params.status = statusFilter as PaymentStatus;
          }

          const response = await PaymentsAPI.listPayouts(params);
          setPayouts(response.data || []);
          setTotal(response.meta?.total || 0);
        } catch (error: any) {
          console.error('Failed to fetch payouts:', error);
          toast.error(error?.message || 'Failed to load payouts');
        } finally {
          setLoading(false);
        }
      };

      fetchPayouts();
    }
  }, [activeTab, page, pageSize, debouncedSearch, statusFilter]);

  const totalPages = Math.ceil(total / pageSize);

  const transactionColumns = [
    {
      key: 'reference',
      label: 'Transaction',
      sortable: false,
      render: (_: any, row: Transaction) => (
        <div className="flex items-center gap-3">
          <div className="w-10 h-10 bg-[#0e1a30]/10 rounded-full flex items-center justify-center">
            <Icon icon={faCreditCard} className="text-[#0e1a30]" size="sm" />
          </div>
          <div>
            <p className="text-sm font-medium text-gray-900">{row?.reference || row?.id?.substring(0, 8) || '-'}</p>
            <p className="text-xs text-gray-500">{row?.type?.replace(/_/g, ' ') || '-'}</p>
          </div>
        </div>
      ),
    },
    {
      key: 'user',
      label: 'User/Merchant',
      sortable: false,
      render: (_: any, row: Transaction) => (
        <span className="text-sm text-gray-900">
          {row?.user?.fullName || row?.merchant?.businessName || '-'}
        </span>
      ),
    },
    {
      key: 'amount',
      label: 'Amount',
      sortable: false,
      render: (_: any, row: Transaction) => (
        <p className="text-sm font-medium text-gray-900">
          {row?.amount ? `${row.currency || 'RWF'} ${row.amount.toLocaleString()}` : '-'}
        </p>
      ),
    },
    {
      key: 'status',
      label: 'Status',
      sortable: false,
      render: (_: any, row: Transaction) => (
        <span className={`inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium ${getStatusBadgeColor(row?.status || 'pending')}`}>
          {row?.status?.replace(/_/g, ' ') || '-'}
        </span>
      ),
    },
    {
      key: 'date',
      label: 'Date',
      sortable: false,
      render: (_: any, row: Transaction) => (
        <p className="text-sm text-gray-900">
          {row?.createdAt ? new Date(row.createdAt).toLocaleDateString('en-US', {
            month: 'short',
            day: 'numeric',
            year: 'numeric',
          }) : '-'}
        </p>
      ),
    },
  ];

  const payoutColumns = [
    {
      key: 'reference',
      label: 'Payout',
      sortable: false,
      render: (_: any, row: Payout) => (
        <div className="flex items-center gap-3">
          <div className="w-10 h-10 bg-[#0e1a30]/10 rounded-full flex items-center justify-center">
            <Icon icon={faMoneyBill} className="text-[#0e1a30]" size="sm" />
          </div>
          <div>
            <p className="text-sm font-medium text-gray-900">{row?.reference || row?.id?.substring(0, 8) || '-'}</p>
            {row?.merchant && (
              <p className="text-xs text-gray-500">{row.merchant.businessName}</p>
            )}
          </div>
        </div>
      ),
    },
    {
      key: 'merchant',
      label: 'Merchant',
      sortable: false,
      render: (_: any, row: Payout) => (
        <span className="text-sm text-gray-900">{row?.merchant?.businessName || '-'}</span>
      ),
    },
    {
      key: 'amount',
      label: 'Amount',
      sortable: false,
      render: (_: any, row: Payout) => (
        <p className="text-sm font-medium text-gray-900">
          {row?.amount ? `${row.currency || 'RWF'} ${row.amount.toLocaleString()}` : '-'}
        </p>
      ),
    },
    {
      key: 'status',
      label: 'Status',
      sortable: false,
      render: (_: any, row: Payout) => (
        <span className={`inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium ${getStatusBadgeColor(row?.status || 'pending')}`}>
          {row?.status?.replace(/_/g, ' ') || '-'}
        </span>
      ),
    },
    {
      key: 'date',
      label: 'Date',
      sortable: false,
      render: (_: any, row: Payout) => (
        <p className="text-sm text-gray-900">
          {row?.createdAt ? new Date(row.createdAt).toLocaleDateString('en-US', {
            month: 'short',
            day: 'numeric',
            year: 'numeric',
          }) : '-'}
        </p>
      ),
    },
  ];

  if (loading && transactions.length === 0 && payouts.length === 0) {
    return <PageSkeleton />;
  }

  return (
    <div className="space-y-6">
      {/* Header */}
      <div>
        <h1 className="text-2xl font-bold text-gray-900">Payments</h1>
        <p className="text-gray-600 mt-1">Manage transactions and payouts</p>
      </div>

      {/* Tabs */}
      <div className="border-b border-gray-200">
        <nav className="-mb-px flex space-x-8">
          <button
            onClick={() => {
              setActiveTab('transactions');
              setPage(1);
              setTypeFilter('');
              setStatusFilter('');
            }}
            className={`py-4 px-1 border-b-2 font-medium text-sm ${
              activeTab === 'transactions'
                ? 'border-[#0e1a30] text-[#0e1a30]'
                : 'border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300'
            }`}
          >
            Transactions
          </button>
          <button
            onClick={() => {
              setActiveTab('payouts');
              setPage(1);
              setTypeFilter('');
              setStatusFilter('');
            }}
            className={`py-4 px-1 border-b-2 font-medium text-sm ${
              activeTab === 'payouts'
                ? 'border-[#0e1a30] text-[#0e1a30]'
                : 'border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300'
            }`}
          >
            Payouts
          </button>
        </nav>
      </div>

      {/* Filters */}
      <div className="bg-white border border-gray-200 rounded-sm p-4">
        <div className={`grid grid-cols-1 gap-4 ${activeTab === 'transactions' ? 'md:grid-cols-4' : 'md:grid-cols-3'}`}>
          {/* Search */}
          <div className={activeTab === 'transactions' ? 'md:col-span-2' : 'md:col-span-2'}>
            <div className="relative">
              <Icon
                icon={faSearch}
                className="absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400"
                size="sm"
              />
              <input
                type="text"
                placeholder={activeTab === 'transactions' ? 'Search by reference/description...' : 'Search payout number/reference...'}
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

          {/* Type Filter (only for transactions) */}
          {activeTab === 'transactions' && (
            <div>
              <select
                value={typeFilter}
                onChange={(e) => {
                  setTypeFilter(e.target.value as TransactionType | '');
                  setPage(1);
                }}
                className="w-full px-3 py-2 border border-gray-200 rounded-sm focus:outline-none focus:ring-1 focus:ring-[#0e1a30] focus:border-[#0e1a30] text-sm"
              >
                {TRANSACTION_TYPES.map((type) => (
                  <option key={type.value} value={type.value}>
                    {type.label}
                  </option>
                ))}
              </select>
            </div>
          )}

          {/* Status Filter */}
          <div>
            <select
              value={statusFilter}
              onChange={(e) => {
                setStatusFilter(e.target.value as TransactionStatus | PaymentStatus | '');
                setPage(1);
              }}
              className="w-full px-3 py-2 border border-gray-200 rounded-sm focus:outline-none focus:ring-1 focus:ring-[#0e1a30] focus:border-[#0e1a30] text-sm"
            >
              {(activeTab === 'transactions' ? TRANSACTION_STATUSES : PAYOUT_STATUSES).map((status) => (
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
        columns={activeTab === 'transactions' ? transactionColumns : payoutColumns}
        data={activeTab === 'transactions' ? transactions : payouts}
        loading={loading}
        onRowClick={(row) => {
          if (activeTab === 'transactions') {
            router.push(`/dashboard/payments/transactions/${row.id}`);
          } else {
            router.push(`/dashboard/payments/payouts/${row.id}`);
          }
        }}
        emptyMessage={`No ${activeTab} found`}
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

