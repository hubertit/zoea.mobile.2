'use client';

import { useState, useEffect } from 'react';
import { useRouter } from 'next/navigation';
import { BookingsAPI, type Booking, type BookingStatus, type PaymentStatus } from '@/src/lib/api';
import Icon, { faSearch, faTimes } from '@/app/components/Icon';
import { toast } from '@/app/components/Toaster';
import { DataTable, Pagination } from '@/app/components';
import PageSkeleton from '@/app/components/PageSkeleton';

const STATUSES: { value: BookingStatus | ''; label: string }[] = [
  { value: '', label: 'All Status' },
  { value: 'pending', label: 'Pending' },
  { value: 'confirmed', label: 'Confirmed' },
  { value: 'checked_in', label: 'Checked In' },
  { value: 'completed', label: 'Completed' },
  { value: 'cancelled', label: 'Cancelled' },
  { value: 'no_show', label: 'No Show' },
  { value: 'refunded', label: 'Refunded' },
];

const PAYMENT_STATUSES: { value: PaymentStatus | ''; label: string }[] = [
  { value: '', label: 'All Payment Status' },
  { value: 'pending', label: 'Pending' },
  { value: 'processing', label: 'Processing' },
  { value: 'completed', label: 'Completed' },
  { value: 'failed', label: 'Failed' },
  { value: 'refunded', label: 'Refunded' },
  { value: 'partially_refunded', label: 'Partially Refunded' },
];

const getStatusBadgeColor = (status: BookingStatus) => {
  switch (status) {
    case 'completed':
    case 'confirmed':
      return 'bg-green-100 text-green-800';
    case 'pending':
    case 'checked_in':
      return 'bg-yellow-100 text-yellow-800';
    case 'cancelled':
    case 'no_show':
    case 'refunded':
      return 'bg-red-100 text-red-800';
    default:
      return 'bg-gray-100 text-gray-800';
  }
};

const getPaymentStatusBadgeColor = (status: PaymentStatus) => {
  switch (status) {
    case 'completed':
      return 'bg-green-100 text-green-800';
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

export default function ListingBookingsPage() {
  const router = useRouter();
  const [bookings, setBookings] = useState<Booking[]>([]);
  const [loading, setLoading] = useState(true);
  const [page, setPage] = useState(1);
  const [pageSize, setPageSize] = useState(10);
  const [total, setTotal] = useState(0);
  const [search, setSearch] = useState('');
  const [statusFilter, setStatusFilter] = useState<BookingStatus | ''>('');
  const [paymentStatusFilter, setPaymentStatusFilter] = useState<PaymentStatus | ''>('');

  useEffect(() => {
    const fetchBookings = async () => {
      setLoading(true);
      try {
        const params: any = {
          page,
          limit: pageSize,
        };

        if (statusFilter) {
          params.status = statusFilter;
        }

        if (paymentStatusFilter) {
          params.paymentStatus = paymentStatusFilter;
        }

        // Filter for listing bookings only (listingId is not null)
        const response = await BookingsAPI.listBookings(params);
        
        // Client-side filtering for listing bookings and search
        let filteredData = response.data.filter((booking) => booking.listingId !== null && booking.listingId !== undefined);
        
        if (search.trim()) {
          const searchLower = search.toLowerCase();
          filteredData = filteredData.filter((booking) => {
            const bookingNumber = booking.bookingNumber?.toLowerCase() || '';
            const userName = booking.user?.fullName?.toLowerCase() || '';
            const userEmail = booking.user?.email?.toLowerCase() || '';
            const listingName = booking.listing?.name?.toLowerCase() || '';
            
            return bookingNumber.includes(searchLower) ||
                   userName.includes(searchLower) ||
                   userEmail.includes(searchLower) ||
                   listingName.includes(searchLower);
          });
        }
        
        setBookings(filteredData);
        setTotal(response.meta?.total || 0);
      } catch (error: any) {
        console.error('Failed to fetch bookings:', error);
        toast.error(error?.message || 'Failed to load bookings');
      } finally {
        setLoading(false);
      }
    };

    fetchBookings();
  }, [page, pageSize, statusFilter, paymentStatusFilter, search]);

  const totalPages = Math.ceil(total / pageSize);

  const columns = [
    {
      key: 'booking',
      label: 'Booking',
      sortable: false,
      render: (_: any, row: Booking) => (
        <div>
          <p className="text-sm font-medium text-gray-900">#{row.bookingNumber}</p>
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
      key: 'user',
      label: 'User',
      sortable: false,
      render: (_: any, row: Booking) => (
        <div>
          <p className="text-sm text-gray-900">{row.user?.fullName || 'N/A'}</p>
          <p className="text-xs text-gray-500">{row.user?.email || ''}</p>
        </div>
      ),
    },
    {
      key: 'listing',
      label: 'Listing',
      sortable: false,
      render: (_: any, row: Booking) => (
        <span className="text-sm text-gray-900">{row.listing?.name || 'N/A'}</span>
      ),
    },
    {
      key: 'amount',
      label: 'Amount',
      sortable: false,
      render: (_: any, row: Booking) => (
        <p className="text-sm font-medium text-gray-900">
          {row.currency || 'RWF'} {row.totalAmount?.toLocaleString() || '0'}
        </p>
      ),
    },
    {
      key: 'status',
      label: 'Status',
      sortable: false,
      render: (_: any, row: Booking) => (
        <div className="flex flex-col gap-1">
          <span className={`inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium w-fit ${getStatusBadgeColor(row.status || 'pending')}`}>
            {row.status?.replace(/_/g, ' ') || '-'}
          </span>
          <span className={`inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium w-fit ${getPaymentStatusBadgeColor(row.paymentStatus || 'pending')}`}>
            {row.paymentStatus?.replace(/_/g, ' ') || '-'}
          </span>
        </div>
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
          <h1 className="text-2xl font-bold text-gray-900">Listing Bookings</h1>
          <p className="text-gray-600 mt-1">Manage listing bookings</p>
        </div>
      </div>

      {/* Filters */}
      <div className="bg-white border border-gray-200 rounded-sm p-4">
        <div className="grid grid-cols-1 md:grid-cols-4 gap-4">
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
                placeholder="Search by booking number, user, listing..."
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
                setStatusFilter(e.target.value as BookingStatus | '');
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

          {/* Payment Status Filter */}
          <div>
            <select
              value={paymentStatusFilter}
              onChange={(e) => {
                setPaymentStatusFilter(e.target.value as PaymentStatus | '');
                setPage(1);
              }}
              className="w-full px-3 py-2 border border-gray-200 rounded-sm focus:outline-none focus:ring-1 focus:ring-[#0e1a30] focus:border-[#0e1a30] text-sm"
            >
              {PAYMENT_STATUSES.map((status) => (
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
        data={bookings}
        loading={loading}
        onRowClick={(row) => router.push(`/dashboard/bookings/${row.id}`)}
        emptyMessage="No listing bookings found"
        showNumbering={true}
        numberingStart={(page - 1) * pageSize + 1}
      />

      {/* Pagination */}
      {totalPages > 1 && (
        <Pagination
          currentPage={page}
          totalPages={totalPages}
          onPageChange={setPage}
          pageSize={pageSize}
          onPageSizeChange={(size) => {
            setPageSize(size);
            setPage(1);
          }}
          totalItems={total}
        />
      )}
    </div>
  );
}

