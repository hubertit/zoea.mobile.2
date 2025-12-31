'use client';

import { useState, useEffect } from 'react';
import { useRouter, useSearchParams } from 'next/navigation';
import { MerchantPortalAPI, type Business, type MerchantBooking, type MerchantPortalBookingStatus } from '@/src/lib/api';
import { toast } from '@/app/components/Toaster';
import { DataTable, Pagination, Button, Breadcrumbs, StatusBadge } from '@/app/components';
import PageSkeleton from '@/app/components/PageSkeleton';
import { useDebounce } from '@/src/hooks/useDebounce';
import Icon, { faSearch, faClipboardList, faEye, faEdit } from '@/app/components/Icon';

const STATUSES: { value: MerchantPortalBookingStatus | ''; label: string }[] = [
  { value: '', label: 'All Status' },
  { value: 'pending', label: 'Pending' },
  { value: 'confirmed', label: 'Confirmed' },
  { value: 'checked_in', label: 'Checked In' },
  { value: 'completed', label: 'Completed' },
  { value: 'cancelled', label: 'Cancelled' },
  { value: 'no_show', label: 'No Show' },
  { value: 'refunded', label: 'Refunded' },
];

export default function MyBookingsPage() {
  const router = useRouter();
  const searchParams = useSearchParams();
  const [businesses, setBusinesses] = useState<Business[]>([]);
  const [selectedBusinessId, setSelectedBusinessId] = useState<string | null>(null);
  const [bookings, setBookings] = useState<MerchantBooking[]>([]);
  const [loading, setLoading] = useState(true);
  const [page, setPage] = useState(1);
  const [pageSize, setPageSize] = useState(10);
  const [total, setTotal] = useState(0);
  const [search, setSearch] = useState('');
  const debouncedSearch = useDebounce(search, 500);
  const [statusFilter, setStatusFilter] = useState<MerchantPortalBookingStatus | ''>('');
  const [dateFrom, setDateFrom] = useState('');
  const [dateTo, setDateTo] = useState('');

  // Fetch businesses
  useEffect(() => {
    const fetchBusinesses = async () => {
      try {
        const data = await MerchantPortalAPI.getMyBusinesses();
        setBusinesses(data);
        const businessId = searchParams.get('businessId');
        if (businessId && data.find(b => b.id === businessId)) {
          setSelectedBusinessId(businessId);
        } else if (data.length > 0) {
          setSelectedBusinessId(data[0].id);
        }
      } catch (error: any) {
        console.error('Failed to fetch businesses:', error);
        toast.error(error?.response?.data?.message || error?.message || 'Failed to load businesses');
      }
    };
    fetchBusinesses();
  }, []);

  // Fetch bookings
  useEffect(() => {
    if (!selectedBusinessId) return;

    const fetchBookings = async () => {
      setLoading(true);
      try {
        const response = await MerchantPortalAPI.getBookings(selectedBusinessId, {
          page,
          limit: pageSize,
          status: statusFilter || undefined,
          startDate: dateFrom || undefined,
          endDate: dateTo || undefined,
        });
        // Filter by search term client-side
        let filteredBookings = response.data || [];
        if (debouncedSearch) {
          filteredBookings = filteredBookings.filter(b =>
            b.bookingNumber.toLowerCase().includes(debouncedSearch.toLowerCase()) ||
            b.user?.fullName?.toLowerCase().includes(debouncedSearch.toLowerCase()) ||
            b.listing?.name?.toLowerCase().includes(debouncedSearch.toLowerCase())
          );
        }
        setBookings(filteredBookings);
        setTotal(response.meta?.total || 0);
      } catch (error: any) {
        console.error('Failed to fetch bookings:', error);
        toast.error(error?.response?.data?.message || error?.message || 'Failed to load bookings');
      } finally {
        setLoading(false);
      }
    };

    fetchBookings();
  }, [page, pageSize, statusFilter, selectedBusinessId, dateFrom, dateTo, debouncedSearch]);

  const totalPages = Math.ceil(total / pageSize);

  const columns = [
    {
      key: 'bookingNumber',
      label: 'Booking #',
      sortable: true,
      render: (value: string, row: MerchantBooking) => (
        <div>
          <div className="font-medium text-gray-900">{value}</div>
          <div className="text-xs text-gray-500">
            {new Date(row.createdAt).toLocaleDateString()}
          </div>
        </div>
      ),
    },
    {
      key: 'user',
      label: 'Customer',
      render: (value: any, row: MerchantBooking) => (
        <div>
          <div className="font-medium text-gray-900">{row.user?.fullName || 'Guest'}</div>
          {row.user?.email && (
            <div className="text-xs text-gray-500">{row.user.email}</div>
          )}
        </div>
      ),
    },
    {
      key: 'listing',
      label: 'Listing',
      render: (value: any, row: MerchantBooking) => (
        <span className="text-sm text-gray-700">{row.listing?.name || 'N/A'}</span>
      ),
    },
    {
      key: 'status',
      label: 'Status',
      sortable: true,
      render: (value: MerchantPortalBookingStatus) => (
        <StatusBadge status={value === 'confirmed' || value === 'checked_in' || value === 'completed' ? 'active' : value === 'pending' ? 'pending' : 'inactive'} />
      ),
    },
    {
      key: 'totalAmount',
      label: 'Amount',
      sortable: true,
      render: (value: number, row: MerchantBooking) => (
        <span className="font-medium text-gray-900">
          {value.toLocaleString()} {row.currency}
        </span>
      ),
    },
    {
      key: 'actions',
      label: 'Actions',
      render: (_: any, row: MerchantBooking) => (
        <div className="flex items-center gap-2">
          <Button
            variant="ghost"
            size="sm"
            icon={faEye}
            onClick={() => router.push(`/dashboard/my-bookings/${row.id}?businessId=${selectedBusinessId}`)}
          >
            View
          </Button>
        </div>
      ),
    },
  ];

  if (businesses.length === 0) {
    return (
      <div className="space-y-6">
        <Breadcrumbs items={[
          { label: 'Dashboard', href: '/dashboard/my-dashboard' },
          { label: 'My Bookings' }
        ]} />
        <div className="flex items-center justify-center min-h-[400px]">
          <div className="text-center">
            <p className="text-gray-600">No businesses found. Create a business first.</p>
          </div>
        </div>
      </div>
    );
  }

  if (!selectedBusinessId) {
    return <PageSkeleton />;
  }

  return (
    <div className="space-y-6">
      <Breadcrumbs items={[
        { label: 'Dashboard', href: '/dashboard/my-dashboard' },
        { label: 'My Bookings' }
      ]} />

      {/* Business Selector */}
      <div className="bg-white border border-gray-200 rounded-sm p-4">
        <div className="flex items-center justify-between flex-wrap gap-4">
          <div className="flex-1 min-w-0">
            <label className="block text-sm font-medium text-gray-700 mb-2">
              Select Business
            </label>
            <select
              value={selectedBusinessId}
              onChange={(e) => {
                setSelectedBusinessId(e.target.value);
                setPage(1);
              }}
              className="w-full md:w-auto px-3 py-2 border border-gray-200 rounded-sm focus:outline-none focus:ring-1 focus:ring-[#0e1a30] focus:border-[#0e1a30] text-sm"
            >
              {businesses.map((business) => (
                <option key={business.id} value={business.id}>
                  {business.businessName}
                </option>
              ))}
            </select>
          </div>
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
                placeholder="Search bookings..."
                value={search}
                onChange={(e) => {
                  setSearch(e.target.value);
                  setPage(1);
                }}
                className="w-full pl-10 pr-4 py-2 border border-gray-200 rounded-sm focus:outline-none focus:ring-1 focus:ring-[#0e1a30] focus:border-[#0e1a30] text-sm"
              />
            </div>
          </div>

          {/* Status Filter */}
          <div>
            <select
              value={statusFilter}
              onChange={(e) => {
                setStatusFilter(e.target.value as MerchantPortalBookingStatus | '');
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

          {/* Date Range */}
          <div className="flex gap-2">
            <input
              type="date"
              value={dateFrom}
              onChange={(e) => {
                setDateFrom(e.target.value);
                setPage(1);
              }}
              className="flex-1 px-3 py-2 border border-gray-200 rounded-sm focus:outline-none focus:ring-1 focus:ring-[#0e1a30] focus:border-[#0e1a30] text-sm"
              placeholder="From"
            />
            <input
              type="date"
              value={dateTo}
              onChange={(e) => {
                setDateTo(e.target.value);
                setPage(1);
              }}
              className="flex-1 px-3 py-2 border border-gray-200 rounded-sm focus:outline-none focus:ring-1 focus:ring-[#0e1a30] focus:border-[#0e1a30] text-sm"
              placeholder="To"
            />
          </div>
        </div>
      </div>

      {/* Table */}
      <DataTable
        columns={columns}
        data={bookings}
        loading={loading}
        onRowClick={(row) => router.push(`/dashboard/my-bookings/${row.id}?businessId=${selectedBusinessId}`)}
        emptyMessage="No bookings found."
        showNumbering={true}
        numberingStart={(page - 1) * pageSize + 1}
        enableClientSort={true}
        enableColumnVisibility={true}
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

