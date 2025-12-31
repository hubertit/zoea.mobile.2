'use client';

import { useState, useEffect } from 'react';
import { useParams, useRouter } from 'next/navigation';
import Link from 'next/link';
import { BookingsAPI, type Booking, type BookingStatus, type PaymentStatus } from '@/src/lib/api';
import Icon, { 
  faArrowLeft, 
  faEdit, 
  faCalendar,
  faUsers,
  faDollarSign,
  faCheckCircle,
  faTimesCircle,
} from '@/app/components/Icon';
import { toast } from '@/app/components/Toaster';
import { Button, Modal } from '@/app/components';
import Card, { CardHeader, CardBody } from '@/app/components/Card';
import Select from '@/app/components/Select';
import Textarea from '@/app/components/Textarea';

const BOOKING_STATUSES: { value: BookingStatus; label: string }[] = [
  { value: 'pending', label: 'Pending' },
  { value: 'confirmed', label: 'Confirmed' },
  { value: 'checked_in', label: 'Checked In' },
  { value: 'completed', label: 'Completed' },
  { value: 'cancelled', label: 'Cancelled' },
  { value: 'no_show', label: 'No Show' },
  { value: 'refunded', label: 'Refunded' },
];

const PAYMENT_STATUSES: { value: PaymentStatus; label: string }[] = [
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

export default function BookingDetailPage() {
  const params = useParams();
  const router = useRouter();
  const bookingId = params?.id as string | undefined;

  const [booking, setBooking] = useState<Booking | null>(null);
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);
  const [statusModalOpen, setStatusModalOpen] = useState(false);

  const [formData, setFormData] = useState({
    status: 'pending' as BookingStatus,
    paymentStatus: 'pending' as PaymentStatus,
    specialRequests: '',
  });

  useEffect(() => {
    if (!bookingId) {
      setLoading(false);
      return;
    }

    const fetchBooking = async () => {
      setLoading(true);
      try {
        const bookingData = await BookingsAPI.getBookingById(bookingId);
        setBooking(bookingData);
        setFormData({
          status: bookingData.status || 'pending',
          paymentStatus: bookingData.paymentStatus || 'pending',
          specialRequests: bookingData.specialRequests || '',
        });
      } catch (error: any) {
        console.error('Failed to fetch booking:', error);
        toast.error(error?.message || 'Failed to load booking');
        router.push('/dashboard/bookings');
      } finally {
        setLoading(false);
      }
    };

    fetchBooking();
  }, [bookingId, router]);

  const handleSaveStatus = async () => {
    if (!bookingId) return;

    setSaving(true);
    try {
      await BookingsAPI.updateBookingStatus(bookingId, {
        status: formData.status,
        paymentStatus: formData.paymentStatus,
      });
      
      // Refresh booking data
      const updatedBooking = await BookingsAPI.getBookingById(bookingId);
      setBooking(updatedBooking);
      setStatusModalOpen(false);
      toast.success('Booking status updated successfully');
    } catch (error: any) {
      console.error('Failed to update booking status:', error);
      toast.error(error?.message || 'Failed to update booking status');
    } finally {
      setSaving(false);
    }
  };

  if (loading) {
    return (
      <div className="flex items-center justify-center min-h-[400px]">
        <div className="text-center">
          <div className="inline-block animate-spin rounded-full h-12 w-12 border-b-2 border-[#0e1a30] mb-4"></div>
          <p className="text-gray-600">Loading booking...</p>
        </div>
      </div>
    );
  }

  if (!booking) {
    return null;
  }

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex items-center justify-between flex-wrap gap-4">
        <div className="flex items-center gap-4">
          <Link href="/dashboard/bookings">
            <Button variant="ghost" size="sm" icon={faArrowLeft}>
              Back
            </Button>
          </Link>
          <div>
            <h1 className="text-2xl font-bold text-gray-900">Booking #{booking.bookingNumber}</h1>
            <p className="text-gray-600 mt-1">
              {booking.user?.fullName || booking.user?.email || 'N/A'} • {booking.listing?.name || booking.eventId ? 'Event' : 'N/A'}
            </p>
          </div>
        </div>
        <div className="flex items-center gap-2">
          <Button
            onClick={() => {
              setStatusModalOpen(true);
            }}
            variant="primary"
            size="sm"
            icon={faEdit}
          >
            Update Status
          </Button>
        </div>
      </div>

      {/* Booking Information */}
      <Card>
        <CardHeader>
          <h2 className="text-lg font-semibold text-gray-900">Booking Information</h2>
        </CardHeader>
        <CardBody>
          <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">Booking Number</label>
              <p className="text-sm font-medium text-gray-900">{booking.bookingNumber || 'N/A'}</p>
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">Status</label>
              <div className="flex flex-col gap-1">
                <span className={`inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium w-fit ${getStatusBadgeColor(booking.status || 'pending')}`}>
                  {booking.status?.replace(/_/g, ' ') || 'N/A'}
                </span>
                <span className={`inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium w-fit ${getPaymentStatusBadgeColor(booking.paymentStatus || 'pending')}`}>
                  Payment: {booking.paymentStatus?.replace(/_/g, ' ') || 'N/A'}
                </span>
              </div>
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                <Icon icon={faDollarSign} className="inline mr-1 text-gray-400" size="sm" />
                Total Amount
              </label>
              <p className="text-sm font-medium text-gray-900">
                {booking.currency || 'RWF'} {booking.totalAmount?.toLocaleString() || '0'}
              </p>
            </div>

            {booking.bookingDate && (
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  <Icon icon={faCalendar} className="inline mr-1 text-gray-400" size="sm" />
                  Booking Date
                </label>
                <p className="text-sm text-gray-900">
                  {new Date(booking.bookingDate).toLocaleDateString('en-US', {
                    month: 'long',
                    day: 'numeric',
                    year: 'numeric',
                  })}
                </p>
              </div>
            )}

            {booking.checkInDate && (
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">Check-In Date</label>
                <p className="text-sm text-gray-900">
                  {new Date(booking.checkInDate).toLocaleDateString('en-US', {
                    month: 'long',
                    day: 'numeric',
                    year: 'numeric',
                  })}
                </p>
              </div>
            )}

            {booking.checkOutDate && (
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">Check-Out Date</label>
                <p className="text-sm text-gray-900">
                  {new Date(booking.checkOutDate).toLocaleDateString('en-US', {
                    month: 'long',
                    day: 'numeric',
                    year: 'numeric',
                  })}
                </p>
              </div>
            )}

            {(booking.guestCount || booking.adults || booking.children) && (
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  <Icon icon={faUsers} className="inline mr-1 text-gray-400" size="sm" />
                  Guests
                </label>
                <p className="text-sm text-gray-900">
                  {booking.guestCount ? `${booking.guestCount} total` : ''}
                  {booking.adults && booking.children ? ` (${booking.adults} adults, ${booking.children} children)` : ''}
                  {booking.adults && !booking.children ? ` (${booking.adults} adults)` : ''}
                  {!booking.guestCount && !booking.adults && !booking.children && 'N/A'}
                </p>
              </div>
            )}
          </div>
        </CardBody>
      </Card>

      {/* User Information */}
      {booking.user && (
        <Card>
          <CardHeader>
            <h2 className="text-lg font-semibold text-gray-900">User</h2>
          </CardHeader>
          <CardBody>
            <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">Name</label>
                <p className="text-sm text-gray-900">{booking.user.fullName || 'N/A'}</p>
              </div>
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">Email</label>
                <p className="text-sm text-gray-900">{booking.user.email || 'N/A'}</p>
              </div>
            </div>
          </CardBody>
        </Card>
      )}

      {/* Listing/Event Information */}
      {(booking.listing || booking.merchant) && (
        <Card>
          <CardHeader>
            <h2 className="text-lg font-semibold text-gray-900">Listing/Merchant</h2>
          </CardHeader>
          <CardBody>
            <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
              {booking.listing && (
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">Listing</label>
                  <p className="text-sm text-gray-900">{booking.listing.name || 'N/A'}</p>
                </div>
              )}
              {booking.merchant && (
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">Merchant</label>
                  <p className="text-sm text-gray-900">{booking.merchant.businessName || 'N/A'}</p>
                </div>
              )}
            </div>
          </CardBody>
        </Card>
      )}

      {/* Special Requests */}
      {booking.specialRequests && (
        <Card>
          <CardHeader>
            <h2 className="text-lg font-semibold text-gray-900">Special Requests</h2>
          </CardHeader>
          <CardBody>
            <p className="text-sm text-gray-900 whitespace-pre-wrap">{booking.specialRequests}</p>
          </CardBody>
        </Card>
      )}

      {/* Status Update Modal */}
      <Modal
        isOpen={statusModalOpen}
        onClose={() => {
          setStatusModalOpen(false);
          setFormData({
            status: booking.status || 'pending',
            paymentStatus: booking.paymentStatus || 'pending',
            specialRequests: booking.specialRequests || '',
          });
        }}
        title="Update Booking Status"
        size="md"
      >
        <div className="space-y-4">
          <Select
            label="Booking Status"
            value={formData.status}
            onChange={(e) => setFormData({ ...formData, status: e.target.value as BookingStatus })}
            options={BOOKING_STATUSES.map((s) => ({ value: s.value, label: s.label }))}
          />

          <Select
            label="Payment Status"
            value={formData.paymentStatus}
            onChange={(e) => setFormData({ ...formData, paymentStatus: e.target.value as PaymentStatus })}
            options={PAYMENT_STATUSES.map((s) => ({ value: s.value, label: s.label }))}
          />

          <div className="flex items-center gap-2 justify-end pt-4 border-t border-gray-200">
            <Button
              variant="secondary"
              size="md"
              onClick={() => {
                setStatusModalOpen(false);
                setFormData({
                  status: booking.status || 'pending',
                  paymentStatus: booking.paymentStatus || 'pending',
                  specialRequests: booking.specialRequests || '',
                });
              }}
              disabled={saving}
            >
              Cancel
            </Button>
            <Button
              variant="primary"
              size="md"
              onClick={handleSaveStatus}
              loading={saving}
            >
              Save Changes
            </Button>
          </div>
        </div>
      </Modal>
    </div>
  );
}

