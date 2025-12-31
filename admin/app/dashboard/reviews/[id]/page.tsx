'use client';

import { useState, useEffect } from 'react';
import { useParams, useRouter } from 'next/navigation';
import Link from 'next/link';
import { ReviewsAPI, type Review, type ReviewStatus } from '@/src/lib/api';
import Icon, { 
  faArrowLeft, 
  faEdit, 
  faStar,
  faUser,
  faCalendar,
} from '@/app/components/Icon';
import { toast } from '@/app/components/Toaster';
import { Button, Modal } from '@/app/components';
import Card, { CardHeader, CardBody } from '@/app/components/Card';
import Select from '@/app/components/Select';

const STATUSES: { value: ReviewStatus; label: string }[] = [
  { value: 'pending', label: 'Pending' },
  { value: 'approved', label: 'Approved' },
  { value: 'rejected', label: 'Rejected' },
];

const getStatusBadgeColor = (status: ReviewStatus) => {
  switch (status) {
    case 'approved':
      return 'bg-green-100 text-green-800';
    case 'pending':
      return 'bg-yellow-100 text-yellow-800';
    case 'rejected':
      return 'bg-red-100 text-red-800';
    default:
      return 'bg-gray-100 text-gray-800';
  }
};

export default function ReviewDetailPage() {
  const params = useParams();
  const router = useRouter();
  const reviewId = params?.id as string | undefined;

  const [review, setReview] = useState<Review | null>(null);
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);
  const [statusModalOpen, setStatusModalOpen] = useState(false);

  const [formData, setFormData] = useState({
    status: 'pending' as ReviewStatus,
  });

  useEffect(() => {
    if (!reviewId) {
      setLoading(false);
      return;
    }

    const fetchReview = async () => {
      setLoading(true);
      try {
        const reviewData = await ReviewsAPI.getReviewById(reviewId);
        setReview(reviewData);
        setFormData({
          status: reviewData.status || 'pending',
        });
      } catch (error: any) {
        console.error('Failed to fetch review:', error);
        toast.error(error?.message || 'Failed to load review');
        router.push('/dashboard/reviews');
      } finally {
        setLoading(false);
      }
    };

    fetchReview();
  }, [reviewId, router]);

  const handleSaveStatus = async () => {
    if (!reviewId) return;

    setSaving(true);
    try {
      await ReviewsAPI.updateReviewStatus(reviewId, {
        status: formData.status,
      });
      
      // Refresh review data
      const updatedReview = await ReviewsAPI.getReviewById(reviewId);
      setReview(updatedReview);
      setStatusModalOpen(false);
      toast.success('Review status updated successfully');
    } catch (error: any) {
      console.error('Failed to update review status:', error);
      toast.error(error?.message || 'Failed to update review status');
    } finally {
      setSaving(false);
    }
  };

  if (loading) {
    return (
      <div className="flex items-center justify-center min-h-[400px]">
        <div className="text-center">
          <div className="inline-block animate-spin rounded-full h-12 w-12 border-b-2 border-[#0e1a30] mb-4"></div>
          <p className="text-gray-600">Loading review...</p>
        </div>
      </div>
    );
  }

  if (!review) {
    return null;
  }

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex items-center justify-between flex-wrap gap-4">
        <div className="flex items-center gap-4">
          <Link href="/dashboard/reviews">
            <Button variant="ghost" size="sm" icon={faArrowLeft}>
              Back
            </Button>
          </Link>
          <div>
            <h1 className="text-2xl font-bold text-gray-900">Review Details</h1>
            <p className="text-gray-600 mt-1">
              {review.user?.fullName || 'N/A'} • {review.listing?.name || review.event?.name || review.tour?.name || 'N/A'}
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

      {/* Review Information */}
      <Card>
        <CardHeader>
          <h2 className="text-lg font-semibold text-gray-900">Review Information</h2>
        </CardHeader>
        <CardBody>
          <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">Rating</label>
              <div className="flex items-center gap-2">
                <div className="flex items-center">
                  {[...Array(5)].map((_, i) => (
                    <Icon
                      key={i}
                      icon={faStar}
                      className={i < (review.rating || 0) ? 'text-yellow-400' : 'text-gray-300'}
                      size="sm"
                    />
                  ))}
                </div>
                <span className="text-sm font-medium text-gray-900">{review.rating}/5</span>
              </div>
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">Status</label>
              <span className={`inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium ${getStatusBadgeColor(review.status || 'pending')}`}>
                {review.status?.replace(/_/g, ' ') || 'N/A'}
              </span>
            </div>

            {review.title && (
              <div className="md:col-span-2">
                <label className="block text-sm font-medium text-gray-700 mb-1">Title</label>
                <p className="text-sm font-medium text-gray-900">{review.title}</p>
              </div>
            )}

            {(review.comment || review.content) && (
              <div className="md:col-span-2">
                <label className="block text-sm font-medium text-gray-700 mb-1">Comment</label>
                <p className="text-sm text-gray-900 whitespace-pre-wrap">{review.comment || review.content || 'N/A'}</p>
              </div>
            )}

            {review.pros && review.pros.length > 0 && (
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">Pros</label>
                <ul className="list-disc list-inside text-sm text-gray-900 space-y-1">
                  {review.pros.map((pro, index) => (
                    <li key={index}>{pro}</li>
                  ))}
                </ul>
              </div>
            )}

            {review.cons && review.cons.length > 0 && (
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">Cons</label>
                <ul className="list-disc list-inside text-sm text-gray-900 space-y-1">
                  {review.cons.map((con, index) => (
                    <li key={index}>{con}</li>
                  ))}
                </ul>
              </div>
            )}

            {review.helpfulCount !== null && review.helpfulCount !== undefined && (
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">Helpful Count</label>
                <p className="text-sm text-gray-900">{review.helpfulCount}</p>
              </div>
            )}

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                <Icon icon={faCalendar} className="inline mr-1 text-gray-400" size="sm" />
                Created At
              </label>
              <p className="text-sm text-gray-900">
                {review.createdAt ? new Date(review.createdAt).toLocaleString('en-US', {
                  month: 'long',
                  day: 'numeric',
                  year: 'numeric',
                  hour: '2-digit',
                  minute: '2-digit',
                }) : 'N/A'}
              </p>
            </div>
          </div>
        </CardBody>
      </Card>

      {/* User Information */}
      {review.user && (
        <Card>
          <CardHeader>
            <h2 className="text-lg font-semibold text-gray-900">User</h2>
          </CardHeader>
          <CardBody>
            <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  <Icon icon={faUser} className="inline mr-1 text-gray-400" size="sm" />
                  Name
                </label>
                <Link href={`/dashboard/users/${review.user.id}`} className="text-sm text-[#0e1a30] hover:underline">
                  {review.user.fullName || 'N/A'}
                </Link>
              </div>
            </div>
          </CardBody>
        </Card>
      )}

      {/* Item Information */}
      {(review.listing || review.event || review.tour) && (
        <Card>
          <CardHeader>
            <h2 className="text-lg font-semibold text-gray-900">Reviewed Item</h2>
          </CardHeader>
          <CardBody>
            <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
              {review.listing && (
                <>
                  <div>
                    <label className="block text-sm font-medium text-gray-700 mb-1">Listing</label>
                    <Link href={`/dashboard/listings/${review.listing.id}`} className="text-sm text-[#0e1a30] hover:underline">
                      {review.listing.name}
                    </Link>
                  </div>
                  {review.listing.category && (
                    <div>
                      <label className="block text-sm font-medium text-gray-700 mb-1">Category</label>
                      <p className="text-sm text-gray-900">{review.listing.category.name}</p>
                    </div>
                  )}
                </>
              )}
              {review.event && (
                <>
                  <div>
                    <label className="block text-sm font-medium text-gray-700 mb-1">Event</label>
                    <Link href={`/dashboard/events/${review.event.id}`} className="text-sm text-[#0e1a30] hover:underline">
                      {review.event.name}
                    </Link>
                  </div>
                  {review.event.eventContext && (
                    <div>
                      <label className="block text-sm font-medium text-gray-700 mb-1">Context</label>
                      <p className="text-sm text-gray-900">{review.event.eventContext.name}</p>
                    </div>
                  )}
                </>
              )}
              {review.tour && (
                <>
                  <div>
                    <label className="block text-sm font-medium text-gray-700 mb-1">Tour</label>
                    <span className="text-sm text-gray-900">{review.tour.name}</span>
                  </div>
                  {review.tour.category && (
                    <div>
                      <label className="block text-sm font-medium text-gray-700 mb-1">Category</label>
                      <p className="text-sm text-gray-900">{review.tour.category.name}</p>
                    </div>
                  )}
                </>
              )}
            </div>
          </CardBody>
        </Card>
      )}

      {/* Booking Information */}
      {review.booking && (
        <Card>
          <CardHeader>
            <h2 className="text-lg font-semibold text-gray-900">Booking</h2>
          </CardHeader>
          <CardBody>
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">Booking Number</label>
              <Link href={`/dashboard/bookings/${review.booking.id}`} className="text-sm text-[#0e1a30] hover:underline">
                #{review.booking.bookingNumber}
              </Link>
            </div>
          </CardBody>
        </Card>
      )}

      {/* Status Update Modal */}
      <Modal
        isOpen={statusModalOpen}
        onClose={() => {
          setStatusModalOpen(false);
          setFormData({
            status: review.status || 'pending',
          });
        }}
        title="Update Review Status"
        size="md"
      >
        <div className="space-y-4">
          <Select
            label="Status"
            value={formData.status}
            onChange={(e) => setFormData({ ...formData, status: e.target.value as ReviewStatus })}
            options={STATUSES.map((s) => ({ value: s.value, label: s.label }))}
          />

          <div className="flex items-center gap-2 justify-end pt-4 border-t border-gray-200">
            <Button
              variant="secondary"
              size="md"
              onClick={() => {
                setStatusModalOpen(false);
                setFormData({
                  status: review.status || 'pending',
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

