'use client';

import { useState, useEffect } from 'react';
import { useRouter, useParams, useSearchParams } from 'next/navigation';
import { MerchantPortalAPI, type MerchantBooking, type MerchantPortalBookingStatus } from '@/src/lib/api';
import { toast } from '@/app/components/Toaster';
import { Button, Modal, Select, Textarea, Breadcrumbs, StatusBadge } from '@/app/components';
import PageSkeleton from '@/app/components/PageSkeleton';
import Icon, { faArrowLeft, faEdit, faClipboardList } from '@/app/components/Icon';

const STATUS_OPTIONS: { value: MerchantPortalBookingStatus; label: string }[] = [
  { value: 'pending', label: 'Pending' },
  { value: 'confirmed', label: 'Confirmed' },
  { value: 'checked_in', label: 'Checked In' },
  { value: 'completed', label: 'Completed' },
  { value: 'cancelled', label: 'Cancelled' },
  { value: 'no_show', label: 'No Show' },
  { value: 'refunded', label: 'Refunded' },
];

export default function BookingDetailPage() {
  const router = useRouter();
  const params = useParams();
  const searchParams = useSearchParams();
  const bookingId = params.id as string;
  const businessId = searchParams.get('businessId') || '';
  const [booking, setBooking] = useState<MerchantBooking | null>(null);
  const [loading, setLoading] = useState(true);
  const [showStatusModal, setShowStatusModal] = useState(false);
  const [updating, setUpdating] = useState(false);
  const [statusForm, setStatusForm] = useState({
    status: 'pending' as MerchantPortalBookingStatus,
    notes: '',
    cancellationReason: '',
  });

  useEffect(() => {
    if (businessId) {
      fetchBooking();
    }
  }, [businessId, bookingId]);

  const fetchBooking = async () => {
    if (!businessId) return;
    setLoading(true);
    try {
      const data = await MerchantPortalAPI.getBooking(businessId, bookingId);
      setBooking(data);
      setStatusForm({
        status: data.status,
        notes: '',
        cancellationReason: '',
      });
    } catch (error: any) {
      console.error('Failed to fetch booking:', error);
      toast.error(error?.response?.data?.message || error?.message || 'Failed to load booking');
    } finally {
      setLoading(false);
    }
  };

  const handleStatusUpdate = async () => {
    if (!businessId) return;
    setUpdating(true);
    try {
      await MerchantPortalAPI.updateBookingStatus(businessId, bookingId, {
        status: statusForm.status,
        notes: statusForm.notes || undefined,
        cancellationReason: statusForm.cancellationReason || undefined,
      });
      toast.success('Booking status updated successfully');
      setShowStatusModal(false);
      fetchBooking();
    } catch (error: any) {
      console.error('Failed to update booking status:', error);
      toast.error(error?.response?.data?.message || error?.message || 'Failed to update booking status');
    } finally {
      setUpdating(false);
    }
  };

  if (loading) {
    return <PageSkeleton />;
  }

  if (!booking || !businessId) {
    return (
      <div className="space-y-6">
        <Breadcrumbs items={[
          { label: 'Dashboard', href: '/dashboard/my-dashboard' },
          { label: 'My Bookings', href: '/dashboard/my-bookings' },
          { label: 'Booking Details' }
        ]} />
        <div className="text-center py-12">
          <p className="text-gray-600">Booking not found</p>
        </div>
      </div>
    );
  }

  return (
    <div className="space-y-6">
      <Breadcrumbs items={[
        { label: 'Dashboard', href: '/dashboard/my-dashboard' },
        { label: 'My Bookings', href: '/dashboard/my-bookings' },
        { label: booking.bookingNumber }
      ]} />

      {/* Header */}
      <div className="flex items-center justify-between flex-wrap gap-4">
        <div className="flex items-center gap-4">
          <Button
            variant="ghost"
            size="sm"
            icon={faArrowLeft}
            onClick={() => router.push(`/dashboard/my-bookings?businessId=${businessId}`)}
          >
            Back
          </Button>
          <div>
            <h1 className="text-2xl font-bold text-gray-900">Booking #{booking.bookingNumber}</h1>
            <p className="text-gray-600 mt-1">{booking.listing?.name || 'Listing'}</p>
          </div>
        </div>
        <Button
          variant="primary"
          size="sm"
          icon={faEdit}
          onClick={() => setShowStatusModal(true)}
        >
          Update Status
        </Button>
      </div>

      {/* Booking Info */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        {/* Left Column */}
        <div className="space-y-6">
          <div className="bg-white border border-gray-200 rounded-sm p-6">
            <h2 className="text-lg font-semibold text-gray-900 mb-4">Customer Information</h2>
            <div className="space-y-3">
              <div>
                <p className="text-sm text-gray-600">Name</p>
                <p className="text-gray-900 font-medium">{booking.user?.fullName || 'Guest'}</p>
              </div>
              {booking.user?.email && (
                <div>
                  <p className="text-sm text-gray-600">Email</p>
                  <p className="text-gray-900">{booking.user.email}</p>
                </div>
              )}
              {booking.user?.phoneNumber && (
                <div>
                  <p className="text-sm text-gray-600">Phone</p>
                  <p className="text-gray-900">{booking.user.phoneNumber}</p>
                </div>
              )}
            </div>
          </div>

          <div className="bg-white border border-gray-200 rounded-sm p-6">
            <h2 className="text-lg font-semibold text-gray-900 mb-4">Booking Details</h2>
            <div className="space-y-3">
              <div>
                <p className="text-sm text-gray-600">Booking Number</p>
                <p className="text-gray-900 font-medium">{booking.bookingNumber}</p>
              </div>
              <div>
                <p className="text-sm text-gray-600">Listing</p>
                <p className="text-gray-900">{booking.listing?.name || 'N/A'}</p>
              </div>
              <div>
                <p className="text-sm text-gray-600">Type</p>
                <p className="text-gray-900 capitalize">{booking.bookingType || 'N/A'}</p>
              </div>
              {booking.checkInDate && (
                <div>
                  <p className="text-sm text-gray-600">Check In</p>
                  <p className="text-gray-900">{new Date(booking.checkInDate).toLocaleDateString()}</p>
                </div>
              )}
              {booking.checkOutDate && (
                <div>
                  <p className="text-sm text-gray-600">Check Out</p>
                  <p className="text-gray-900">{new Date(booking.checkOutDate).toLocaleDateString()}</p>
                </div>
              )}
              {booking.bookingDate && (
                <div>
                  <p className="text-sm text-gray-600">Booking Date</p>
                  <p className="text-gray-900">{new Date(booking.bookingDate).toLocaleDateString()}</p>
                </div>
              )}
              {booking.bookingTime && (
                <div>
                  <p className="text-sm text-gray-600">Booking Time</p>
                  <p className="text-gray-900">{booking.bookingTime}</p>
                </div>
              )}
              {booking.partySize && (
                <div>
                  <p className="text-sm text-gray-600">Party Size</p>
                  <p className="text-gray-900">{booking.partySize} {booking.partySize === 1 ? 'person' : 'people'}</p>
                </div>
              )}
            </div>
          </div>
        </div>

        {/* Right Column */}
        <div className="space-y-6">
          <div className="bg-white border border-gray-200 rounded-sm p-6">
            <h2 className="text-lg font-semibold text-gray-900 mb-4">Status & Payment</h2>
            <div className="space-y-3">
              <div>
                <p className="text-sm text-gray-600">Status</p>
                <div className="mt-1">
                  <StatusBadge status={booking.status === 'confirmed' || booking.status === 'checked_in' || booking.status === 'completed' ? 'active' : booking.status === 'pending' ? 'pending' : 'inactive'} />
                </div>
              </div>
              <div>
                <p className="text-sm text-gray-600">Total Amount</p>
                <p className="text-2xl font-bold text-gray-900">
                  {booking.totalAmount.toLocaleString()} {booking.currency}
                </p>
              </div>
              <div>
                <p className="text-sm text-gray-600">Created</p>
                <p className="text-gray-900">{new Date(booking.createdAt).toLocaleString()}</p>
              </div>
              <div>
                <p className="text-sm text-gray-600">Last Updated</p>
                <p className="text-gray-900">{new Date(booking.updatedAt).toLocaleString()}</p>
              </div>
            </div>
          </div>

          {booking.notes && (
            <div className="bg-white border border-gray-200 rounded-sm p-6">
              <h2 className="text-lg font-semibold text-gray-900 mb-4">Notes</h2>
              <p className="text-gray-900">{booking.notes}</p>
            </div>
          )}
        </div>
      </div>

      {/* Status Update Modal */}
      <Modal
        isOpen={showStatusModal}
        onClose={() => {
          setShowStatusModal(false);
          setStatusForm({
            status: booking.status,
            notes: '',
            cancellationReason: '',
          });
        }}
        title="Update Booking Status"
        size="md"
      >
        <div className="space-y-4">
          <Select
            label="Status"
            value={statusForm.status}
            onChange={(e) => setStatusForm({ ...statusForm, status: e.target.value as MerchantPortalBookingStatus })}
            options={STATUS_OPTIONS.map(s => ({ value: s.value, label: s.label }))}
            required
          />
          {statusForm.status === 'cancelled' && (
            <Textarea
              label="Cancellation Reason"
              value={statusForm.cancellationReason}
              onChange={(e) => setStatusForm({ ...statusForm, cancellationReason: e.target.value })}
              rows={3}
              placeholder="Enter reason for cancellation"
            />
          )}
          <Textarea
            label="Internal Notes (Optional)"
            value={statusForm.notes}
            onChange={(e) => setStatusForm({ ...statusForm, notes: e.target.value })}
            rows={3}
            placeholder="Add any internal notes about this booking"
          />
          <div className="flex justify-end gap-3 mt-6">
            <Button
              variant="ghost"
              onClick={() => {
                setShowStatusModal(false);
                setStatusForm({
                  status: booking.status,
                  notes: '',
                  cancellationReason: '',
                });
              }}
            >
              Cancel
            </Button>
            <Button
              variant="primary"
              onClick={handleStatusUpdate}
              loading={updating}
            >
              Update Status
            </Button>
          </div>
        </div>
      </Modal>
    </div>
  );
}

