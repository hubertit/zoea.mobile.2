'use client';

import { useState, useEffect } from 'react';
import { useRouter } from 'next/navigation';
import { BookingsAPI, UsersAPI, ListingsAPI, EventsAPI, type Booking, type BookingStatus, type PaymentStatus, type CreateBookingParams, type User, type Listing, type Event, type BookingType } from '@/src/lib/api';
import Icon, { faSearch, faPlus, faTimes, faClipboardList, faChevronDown, faChevronUp } from '@/app/components/Icon';
import { toast } from '@/app/components/Toaster';
import { DataTable, Pagination, Button, Modal, Input, Select } from '@/app/components';
import PageSkeleton from '@/app/components/PageSkeleton';
import { useDebounce } from '@/src/hooks/useDebounce';

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
  { value: '', label: 'All Payment' },
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

export default function BookingsPage() {
  const router = useRouter();
  const [bookings, setBookings] = useState<Booking[]>([]);
  const [loading, setLoading] = useState(true);
  const [page, setPage] = useState(1);
  const [pageSize, setPageSize] = useState(10);
  const [total, setTotal] = useState(0);
  const [search, setSearch] = useState('');
  const debouncedSearch = useDebounce(search, 500);
  const [statusFilter, setStatusFilter] = useState<BookingStatus | ''>('');
  const [paymentStatusFilter, setPaymentStatusFilter] = useState<PaymentStatus | ''>('');
  const [showCreateModal, setShowCreateModal] = useState(false);
  const [creating, setCreating] = useState(false);
  const [showAdvancedFilters, setShowAdvancedFilters] = useState(false);
  const [dateFrom, setDateFrom] = useState('');
  const [dateTo, setDateTo] = useState('');
  const [minAmount, setMinAmount] = useState('');
  const [maxAmount, setMaxAmount] = useState('');
  const [users, setUsers] = useState<User[]>([]);
  const [listings, setListings] = useState<Listing[]>([]);
  const [events, setEvents] = useState<Event[]>([]);
  const [formData, setFormData] = useState<Partial<CreateBookingParams>>({
    userId: '',
    bookingType: 'hotel',
    listingId: '',
    eventId: '',
    checkInDate: '',
    checkOutDate: '',
    bookingDate: '',
    bookingTime: '',
    guestCount: undefined,
    adults: undefined,
    children: undefined,
    specialRequests: '',
  });

  useEffect(() => {
    const fetchBookings = async () => {
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
          params.status = statusFilter;
        }

        if (paymentStatusFilter) {
          params.paymentStatus = paymentStatusFilter;
        }

        const response = await BookingsAPI.listBookings(params);
        
        // Client-side filtering for date and amount
        let filteredData = response.data || [];
        
        if (dateFrom || dateTo) {
          filteredData = filteredData.filter((booking: Booking) => {
            const bookingDate = booking.bookingDate || booking.createdAt;
            if (!bookingDate) return false;
            const date = new Date(bookingDate);
            if (dateFrom && date < new Date(dateFrom)) return false;
            if (dateTo) {
              const toDate = new Date(dateTo);
              toDate.setHours(23, 59, 59, 999);
              if (date > toDate) return false;
            }
            return true;
          });
        }
        
        if (minAmount || maxAmount) {
          filteredData = filteredData.filter((booking: Booking) => {
            const amount = booking.totalAmount || 0;
            if (minAmount && amount < parseFloat(minAmount)) return false;
            if (maxAmount && amount > parseFloat(maxAmount)) return false;
            return true;
          });
        }
        
        setBookings(filteredData);
        setTotal(filteredData.length);
      } catch (error: any) {
        console.error('Failed to fetch bookings:', error);
        toast.error(error?.message || 'Failed to load bookings');
      } finally {
        setLoading(false);
      }
    };

    fetchBookings();
  }, [page, pageSize, debouncedSearch, statusFilter, paymentStatusFilter, dateFrom, dateTo, minAmount, maxAmount]);

  // Fetch users, listings, events for create modal
  useEffect(() => {
    if (showCreateModal) {
      const fetchData = async () => {
        try {
          const [usersRes, listingsRes, eventsRes] = await Promise.all([
            UsersAPI.listUsers({ limit: 100, page: 1 }),
            ListingsAPI.listListings({ limit: 100, page: 1 }),
            EventsAPI.listEvents({ limit: 100, page: 1 }),
          ]);
          setUsers(usersRes.data || []);
          setListings(listingsRes.data || []);
          setEvents(eventsRes.data || []);
        } catch (error: any) {
          console.error('Failed to fetch data:', error);
        }
      };
      fetchData();
    }
  }, [showCreateModal]);

  const totalPages = Math.ceil(total / pageSize);

  const columns = [
    {
      key: 'bookingNumber',
      label: 'Booking #',
      sortable: false,
      render: (_: any, row: Booking) => (
        <div className="flex items-center gap-3">
          <div className="w-10 h-10 bg-[#0e1a30]/10 rounded-full flex items-center justify-center">
            <Icon icon={faClipboardList} className="text-[#0e1a30]" size="sm" />
          </div>
          <div>
            <p className="text-sm font-medium text-gray-900">{row?.bookingNumber || '-'}</p>
            {row?.user && (
              <p className="text-xs text-gray-500">{row.user.fullName || row.user.email}</p>
            )}
          </div>
        </div>
      ),
    },
    {
      key: 'listing',
      label: 'Listing/Event',
      sortable: false,
      render: (_: any, row: Booking) => (
        <span className="text-sm text-gray-900">{row?.listing?.name || '-'}</span>
      ),
    },
    {
      key: 'merchant',
      label: 'Merchant',
      sortable: false,
      render: (_: any, row: Booking) => (
        <span className="text-sm text-gray-900">{row?.merchant?.businessName || '-'}</span>
      ),
    },
    {
      key: 'amount',
      label: 'Amount',
      sortable: false,
      render: (_: any, row: Booking) => (
        <div>
          <p className="text-sm font-medium text-gray-900">
            {row?.totalAmount ? `${row.currency || 'RWF'} ${row.totalAmount.toLocaleString()}` : '-'}
          </p>
        </div>
      ),
    },
    {
      key: 'status',
      label: 'Status',
      sortable: false,
      render: (_: any, row: Booking) => (
        <div className="flex flex-col gap-1">
          <span className={`inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium ${getStatusBadgeColor(row?.status || 'pending')}`}>
            {row?.status?.replace(/_/g, ' ') || '-'}
          </span>
          <span className={`inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium ${getPaymentStatusBadgeColor(row?.paymentStatus || 'pending')}`}>
            {row?.paymentStatus?.replace(/_/g, ' ') || '-'}
          </span>
        </div>
      ),
    },
    {
      key: 'date',
      label: 'Booking Date',
      sortable: false,
      render: (_: any, row: Booking) => (
        <div>
          {row?.bookingDate && (
            <p className="text-sm text-gray-900">
              {new Date(row.bookingDate).toLocaleDateString('en-US', {
                month: 'short',
                day: 'numeric',
                year: 'numeric',
              })}
            </p>
          )}
          {row?.checkInDate && (
            <p className="text-xs text-gray-500">
              Check-in: {new Date(row.checkInDate).toLocaleDateString('en-US', {
                month: 'short',
                day: 'numeric',
              })}
            </p>
          )}
          {!row?.bookingDate && !row?.checkInDate && (
            <span className="text-sm text-gray-400">-</span>
          )}
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
          <h1 className="text-2xl font-bold text-gray-900">Bookings</h1>
          <p className="text-gray-600 mt-1">Manage all bookings and reservations</p>
        </div>
        <Button variant="primary" size="md" icon={faPlus} onClick={() => setShowCreateModal(true)}>
          Create Booking
        </Button>
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
                placeholder="Search by booking number, user email/phone..."
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

          {/* Advanced Filters Toggle */}
          <div>
            <Button
              variant="outline"
              size="sm"
              onClick={() => setShowAdvancedFilters(!showAdvancedFilters)}
              className="w-full"
              icon={showAdvancedFilters ? faChevronUp : faChevronDown}
            >
              {showAdvancedFilters ? 'Hide' : 'Show'} Advanced Filters
            </Button>
          </div>
        </div>

        {/* Advanced Filters */}
        {showAdvancedFilters && (
          <div className="mt-4 p-4 bg-gray-50 rounded-sm border border-gray-200">
            <div className="grid grid-cols-1 md:grid-cols-4 gap-4">
              {/* Booking Date From */}
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  Booking Date From
                </label>
                <input
                  type="date"
                  value={dateFrom}
                  onChange={(e) => {
                    setDateFrom(e.target.value);
                    setPage(1);
                  }}
                  className="w-full px-3 py-2 border border-gray-200 rounded-sm focus:outline-none focus:ring-1 focus:ring-[#0e1a30] focus:border-[#0e1a30] text-sm"
                />
              </div>

              {/* Booking Date To */}
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  Booking Date To
                </label>
                <input
                  type="date"
                  value={dateTo}
                  onChange={(e) => {
                    setDateTo(e.target.value);
                    setPage(1);
                  }}
                  className="w-full px-3 py-2 border border-gray-200 rounded-sm focus:outline-none focus:ring-1 focus:ring-[#0e1a30] focus:border-[#0e1a30] text-sm"
                />
              </div>

              {/* Min Amount */}
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  Min Amount
                </label>
                <input
                  type="number"
                  value={minAmount}
                  onChange={(e) => {
                    setMinAmount(e.target.value);
                    setPage(1);
                  }}
                  placeholder="0"
                  min="0"
                  step="0.01"
                  className="w-full px-3 py-2 border border-gray-200 rounded-sm focus:outline-none focus:ring-1 focus:ring-[#0e1a30] focus:border-[#0e1a30] text-sm"
                />
              </div>

              {/* Max Amount */}
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  Max Amount
                </label>
                <input
                  type="number"
                  value={maxAmount}
                  onChange={(e) => {
                    setMaxAmount(e.target.value);
                    setPage(1);
                  }}
                  placeholder="Any"
                  min="0"
                  step="0.01"
                  className="w-full px-3 py-2 border border-gray-200 rounded-sm focus:outline-none focus:ring-1 focus:ring-[#0e1a30] focus:border-[#0e1a30] text-sm"
                />
              </div>
            </div>

            {/* Clear Filters */}
            {(dateFrom || dateTo || minAmount || maxAmount) && (
              <div className="mt-4 flex justify-end">
                <Button
                  variant="ghost"
                  size="sm"
                  onClick={() => {
                    setDateFrom('');
                    setDateTo('');
                    setMinAmount('');
                    setMaxAmount('');
                    setPage(1);
                  }}
                >
                  Clear Advanced Filters
                </Button>
              </div>
            )}
          </div>
        )}
      </div>

      {/* Table */}
      <DataTable
        columns={columns}
        data={bookings}
        loading={loading}
        onRowClick={(row) => router.push(`/dashboard/bookings/${row.id}`)}
        emptyMessage="No bookings found"
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

      {/* Create Booking Modal */}
      <Modal
        isOpen={showCreateModal}
        onClose={() => {
          setShowCreateModal(false);
          setFormData({
            userId: '',
            bookingType: 'hotel',
            listingId: '',
            eventId: '',
            checkInDate: '',
            checkOutDate: '',
            bookingDate: '',
            bookingTime: '',
            guestCount: undefined,
            adults: undefined,
            children: undefined,
            specialRequests: '',
          });
        }}
        title="Create New Booking"
        size="lg"
      >
        <div className="space-y-4 max-h-[70vh] overflow-y-auto">
          <div className="grid grid-cols-2 gap-4">
            <div className="col-span-2">
              <label className="block text-sm font-medium text-gray-700 mb-1">
                User <span className="text-red-500">*</span>
              </label>
              <Select
                value={formData.userId || ''}
                onChange={(e) => setFormData({ ...formData, userId: e.target.value })}
                options={[
                  { value: '', label: 'Select user' },
                  ...users.map(u => ({ value: u.id, label: `${u.fullName || u.email || u.phoneNumber} (${u.email || u.phoneNumber})` })),
                ]}
              />
            </div>

            <div className="col-span-2">
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Booking Type <span className="text-red-500">*</span>
              </label>
              <Select
                value={formData.bookingType || 'hotel'}
                onChange={(e) => setFormData({ ...formData, bookingType: e.target.value as BookingType, listingId: '', eventId: '' })}
                options={[
                  { value: 'hotel', label: 'Hotel' },
                  { value: 'restaurant', label: 'Restaurant' },
                  { value: 'event', label: 'Event' },
                  { value: 'tour', label: 'Tour' },
                  { value: 'experience', label: 'Experience' },
                ]}
              />
            </div>

            {(formData.bookingType === 'hotel' || formData.bookingType === 'restaurant') && (
              <div className="col-span-2">
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  Listing <span className="text-red-500">*</span>
                </label>
                <Select
                  value={formData.listingId || ''}
                  onChange={(e) => setFormData({ ...formData, listingId: e.target.value || undefined })}
                  options={[
                    { value: '', label: 'Select listing' },
                    ...listings.map(l => ({ value: l.id, label: l.name })),
                  ]}
                />
              </div>
            )}

            {formData.bookingType === 'event' && (
              <div className="col-span-2">
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  Event <span className="text-red-500">*</span>
                </label>
                <Select
                  value={formData.eventId || ''}
                  onChange={(e) => setFormData({ ...formData, eventId: e.target.value || undefined })}
                  options={[
                    { value: '', label: 'Select event' },
                    ...events.map(e => ({ value: e.id, label: e.name })),
                  ]}
                />
              </div>
            )}

            {formData.bookingType === 'hotel' && (
              <>
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">
                    Check-in Date <span className="text-red-500">*</span>
                  </label>
                  <Input
                    type="date"
                    value={formData.checkInDate || ''}
                    onChange={(e) => setFormData({ ...formData, checkInDate: e.target.value || undefined })}
                  />
                </div>
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">
                    Check-out Date <span className="text-red-500">*</span>
                  </label>
                  <Input
                    type="date"
                    value={formData.checkOutDate || ''}
                    onChange={(e) => setFormData({ ...formData, checkOutDate: e.target.value || undefined })}
                  />
                </div>
              </>
            )}

            {formData.bookingType === 'restaurant' && (
              <div className="col-span-2">
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  Booking Date <span className="text-red-500">*</span>
                </label>
                <Input
                  type="datetime-local"
                  value={formData.bookingDate || ''}
                  onChange={(e) => setFormData({ ...formData, bookingDate: e.target.value || undefined })}
                />
              </div>
            )}

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Guest Count
              </label>
              <Input
                type="number"
                value={formData.guestCount || ''}
                onChange={(e) => setFormData({ ...formData, guestCount: e.target.value ? parseInt(e.target.value) : undefined })}
                placeholder="0"
              />
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Adults
              </label>
              <Input
                type="number"
                value={formData.adults || ''}
                onChange={(e) => setFormData({ ...formData, adults: e.target.value ? parseInt(e.target.value) : undefined })}
                placeholder="0"
              />
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Children
              </label>
              <Input
                type="number"
                value={formData.children || ''}
                onChange={(e) => setFormData({ ...formData, children: e.target.value ? parseInt(e.target.value) : undefined })}
                placeholder="0"
              />
            </div>

            <div className="col-span-2">
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Special Requests
              </label>
              <Input
                value={formData.specialRequests || ''}
                onChange={(e) => setFormData({ ...formData, specialRequests: e.target.value || undefined })}
                placeholder="Enter special requests"
              />
            </div>
          </div>

          <div className="flex justify-end gap-3 pt-4 border-t border-gray-200">
            <Button
              variant="outline"
              onClick={() => {
                setShowCreateModal(false);
                setFormData({
                  userId: '',
                  bookingType: 'hotel',
                  listingId: '',
                  eventId: '',
                  checkInDate: '',
                  checkOutDate: '',
                  bookingDate: '',
                  bookingTime: '',
                  guestCount: undefined,
                  adults: undefined,
                  children: undefined,
                  specialRequests: '',
                });
              }}
            >
              Cancel
            </Button>
            <Button
              variant="primary"
              onClick={async () => {
                if (!formData.userId || !formData.bookingType) {
                  toast.error('Please provide user and booking type');
                  return;
                }
                if ((formData.bookingType === 'hotel' || formData.bookingType === 'restaurant') && !formData.listingId) {
                  toast.error('Please select a listing');
                  return;
                }
                if (formData.bookingType === 'event' && !formData.eventId) {
                  toast.error('Please select an event');
                  return;
                }
                
                setCreating(true);
                try {
                  await BookingsAPI.createBooking(formData as CreateBookingParams);
                  toast.success('Booking created successfully');
                  setShowCreateModal(false);
                  setFormData({
                    userId: '',
                    bookingType: 'hotel',
                    listingId: '',
                    eventId: '',
                    checkInDate: '',
                    checkOutDate: '',
                    bookingDate: '',
                    bookingTime: '',
                    guestCount: undefined,
                    adults: undefined,
                    children: undefined,
                    specialRequests: '',
                  });
                  // Refresh bookings
                  const response = await BookingsAPI.listBookings({ page, limit: pageSize });
                  setBookings(response.data || []);
                  setTotal(response.meta?.total || 0);
                } catch (error: any) {
                  console.error('Failed to create booking:', error);
                  toast.error(error?.response?.data?.message || error?.message || 'Failed to create booking');
                } finally {
                  setCreating(false);
                }
              }}
              loading={creating}
            >
              Create Booking
            </Button>
          </div>
        </div>
      </Modal>
    </div>
  );
}

