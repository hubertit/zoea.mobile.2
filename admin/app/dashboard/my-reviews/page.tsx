'use client';

import { useState, useEffect } from 'react';
import { useRouter, useSearchParams } from 'next/navigation';
import { MerchantPortalAPI, type Business, type MerchantReview } from '@/src/lib/api';
import { toast } from '@/app/components/Toaster';
import { DataTable, Pagination, Button, Modal, Textarea, Breadcrumbs } from '@/app/components';
import PageSkeleton from '@/app/components/PageSkeleton';
import { useDebounce } from '@/src/hooks/useDebounce';
import Icon, { faSearch, faStar, faEdit } from '@/app/components/Icon';

export default function MyReviewsPage() {
  const router = useRouter();
  const searchParams = useSearchParams();
  const [businesses, setBusinesses] = useState<Business[]>([]);
  const [selectedBusinessId, setSelectedBusinessId] = useState<string | null>(null);
  const [reviews, setReviews] = useState<MerchantReview[]>([]);
  const [loading, setLoading] = useState(true);
  const [page, setPage] = useState(1);
  const [pageSize, setPageSize] = useState(10);
  const [total, setTotal] = useState(0);
  const [search, setSearch] = useState('');
  const debouncedSearch = useDebounce(search, 500);
  const [selectedReview, setSelectedReview] = useState<MerchantReview | null>(null);
  const [showResponseModal, setShowResponseModal] = useState(false);
  const [responding, setResponding] = useState(false);
  const [responseText, setResponseText] = useState('');

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

  // Fetch reviews
  useEffect(() => {
    if (!selectedBusinessId) return;

    const fetchReviews = async () => {
      setLoading(true);
      try {
        const response = await MerchantPortalAPI.getReviews(selectedBusinessId, {
          page,
          limit: pageSize,
        });
        // Filter by search term client-side
        let filteredReviews = response.data || [];
        if (debouncedSearch) {
          filteredReviews = filteredReviews.filter(r =>
            r.user?.fullName?.toLowerCase().includes(debouncedSearch.toLowerCase()) ||
            r.listing?.name?.toLowerCase().includes(debouncedSearch.toLowerCase()) ||
            r.comment?.toLowerCase().includes(debouncedSearch.toLowerCase())
          );
        }
        setReviews(filteredReviews);
        setTotal(response.meta?.total || 0);
      } catch (error: any) {
        console.error('Failed to fetch reviews:', error);
        toast.error(error?.response?.data?.message || error?.message || 'Failed to load reviews');
      } finally {
        setLoading(false);
      }
    };

    fetchReviews();
  }, [page, pageSize, selectedBusinessId, debouncedSearch]);

  const handleRespond = (review: MerchantReview) => {
    setSelectedReview(review);
    setResponseText(review.response || '');
    setShowResponseModal(true);
  };

  const handleSubmitResponse = async () => {
    if (!selectedReview || !selectedBusinessId) return;
    setResponding(true);
    try {
      await MerchantPortalAPI.respondToReview(selectedBusinessId, selectedReview.id, responseText);
      toast.success('Response submitted successfully');
      setShowResponseModal(false);
      setSelectedReview(null);
      setResponseText('');
      // Refresh reviews
      const response = await MerchantPortalAPI.getReviews(selectedBusinessId, {
        page,
        limit: pageSize,
      });
      setReviews(response.data || []);
      setTotal(response.meta?.total || 0);
    } catch (error: any) {
      console.error('Failed to submit response:', error);
      toast.error(error?.response?.data?.message || error?.message || 'Failed to submit response');
    } finally {
      setResponding(false);
    }
  };

  const totalPages = Math.ceil(total / pageSize);

  const columns = [
    {
      key: 'user',
      label: 'Customer',
      render: (value: any, row: MerchantReview) => (
        <div>
          <div className="font-medium text-gray-900">{row.user?.fullName || 'Guest'}</div>
        </div>
      ),
    },
    {
      key: 'listing',
      label: 'Listing',
      render: (value: any, row: MerchantReview) => (
        <span className="text-sm text-gray-700">{row.listing?.name || 'N/A'}</span>
      ),
    },
    {
      key: 'rating',
      label: 'Rating',
      sortable: true,
      render: (value: number) => (
        <div className="flex items-center gap-1">
          <Icon icon={faStar} className="text-yellow-400" size="sm" />
          <span className="text-sm font-medium text-gray-900">{value}</span>
        </div>
      ),
    },
    {
      key: 'comment',
      label: 'Review',
      render: (value: string | null) => (
        <div className="max-w-md">
          <p className="text-sm text-gray-700 line-clamp-2">{value || 'No comment'}</p>
        </div>
      ),
    },
    {
      key: 'response',
      label: 'Response',
      render: (value: string | null) => (
        <div className="max-w-md">
          {value ? (
            <p className="text-sm text-gray-700 line-clamp-2">{value}</p>
          ) : (
            <span className="text-sm text-gray-500">No response</span>
          )}
        </div>
      ),
    },
    {
      key: 'createdAt',
      label: 'Date',
      sortable: true,
      render: (value: string) => (
        <span className="text-sm text-gray-700">
          {new Date(value).toLocaleDateString()}
        </span>
      ),
    },
    {
      key: 'actions',
      label: 'Actions',
      render: (_: any, row: MerchantReview) => (
        <Button
          variant="ghost"
          size="sm"
          icon={faEdit}
          onClick={() => handleRespond(row)}
        >
          {row.response ? 'Edit' : 'Respond'}
        </Button>
      ),
    },
  ];

  if (businesses.length === 0) {
    return (
      <div className="space-y-6">
        <Breadcrumbs items={[
          { label: 'Dashboard', href: '/dashboard/my-dashboard' },
          { label: 'My Reviews' }
        ]} />
        <div className="flex items-center justify-center min-h-[400px]">
          <div className="text-center">
            <p className="text-gray-600">No businesses found.</p>
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
        { label: 'My Reviews' }
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
        <div className="relative">
          <Icon
            icon={faSearch}
            className="absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400"
            size="sm"
          />
          <input
            type="text"
            placeholder="Search reviews..."
            value={search}
            onChange={(e) => {
              setSearch(e.target.value);
              setPage(1);
            }}
            className="w-full pl-10 pr-4 py-2 border border-gray-200 rounded-sm focus:outline-none focus:ring-1 focus:ring-[#0e1a30] focus:border-[#0e1a30] text-sm"
          />
        </div>
      </div>

      {/* Table */}
      <DataTable
        columns={columns}
        data={reviews}
        loading={loading}
        emptyMessage="No reviews found."
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

      {/* Response Modal */}
      <Modal
        isOpen={showResponseModal}
        onClose={() => {
          setShowResponseModal(false);
          setSelectedReview(null);
          setResponseText('');
        }}
        title={selectedReview?.response ? 'Edit Response' : 'Respond to Review'}
        size="md"
      >
        {selectedReview && (
          <div className="space-y-4">
            <div className="bg-gray-50 p-4 rounded-sm">
              <div className="flex items-center gap-2 mb-2">
                <Icon icon={faStar} className="text-yellow-400" size="sm" />
                <span className="font-medium text-gray-900">{selectedReview.rating} / 5</span>
              </div>
              <p className="text-sm text-gray-700 mb-2">
                <strong>{selectedReview.user?.fullName || 'Guest'}</strong> reviewed{' '}
                <strong>{selectedReview.listing?.name || 'listing'}</strong>
              </p>
              {selectedReview.comment && (
                <p className="text-sm text-gray-600">{selectedReview.comment}</p>
              )}
            </div>
            <Textarea
              label="Your Response"
              value={responseText}
              onChange={(e) => setResponseText(e.target.value)}
              rows={5}
              placeholder="Write your response to this review..."
            />
            <div className="flex justify-end gap-3 mt-6">
              <Button
                variant="ghost"
                onClick={() => {
                  setShowResponseModal(false);
                  setSelectedReview(null);
                  setResponseText('');
                }}
              >
                Cancel
              </Button>
              <Button
                variant="primary"
                onClick={handleSubmitResponse}
                loading={responding}
              >
                {selectedReview?.response ? 'Update Response' : 'Submit Response'}
              </Button>
            </div>
          </div>
        )}
      </Modal>
    </div>
  );
}

