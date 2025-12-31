'use client';

import { useState, useEffect } from 'react';
import { useRouter } from 'next/navigation';
import Link from 'next/link';
import { ReviewsAPI, type Review, type ReviewStatus } from '@/src/lib/api';
import Icon, { faSearch, faTimes, faStar } from '@/app/components/Icon';
import { toast } from '@/app/components/Toaster';
import { DataTable, Pagination, Button } from '@/app/components';
import PageSkeleton from '@/app/components/PageSkeleton';
import { useDebounce } from '@/src/hooks/useDebounce';

const STATUSES: { value: ReviewStatus | ''; label: string }[] = [
  { value: '', label: 'All Status' },
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

export default function ReviewsPage() {
  const router = useRouter();
  const [reviews, setReviews] = useState<Review[]>([]);
  const [loading, setLoading] = useState(true);
  const [page, setPage] = useState(1);
  const [pageSize, setPageSize] = useState(10);
  const [total, setTotal] = useState(0);
  const [search, setSearch] = useState('');
  const [statusFilter, setStatusFilter] = useState<ReviewStatus | ''>('');
  const debouncedSearch = useDebounce(search, 500);

  useEffect(() => {
    const fetchReviews = async () => {
      setLoading(true);
      try {
        const params: any = {
          page,
          limit: pageSize,
        };

        if (statusFilter) {
          params.status = statusFilter;
        }

        if (debouncedSearch.trim()) {
          params.search = debouncedSearch.trim();
        }

        // Admin endpoint returns all reviews including unapproved
        const response = await ReviewsAPI.listReviews(params);
        
        setReviews(response.data || []);
        setTotal(response.meta?.total || 0);
      } catch (error: any) {
        console.error('Failed to fetch reviews:', error);
        toast.error(error?.message || 'Failed to load reviews');
      } finally {
        setLoading(false);
      }
    };

    fetchReviews();
  }, [page, pageSize, statusFilter, debouncedSearch]);

  const totalPages = Math.ceil(total / pageSize);

  const columns = [
    {
      key: 'review',
      label: 'Review',
      sortable: false,
      render: (_: any, row: Review) => (
        <div className="flex items-center gap-3">
          <div className="w-10 h-10 bg-[#0e1a30]/10 rounded-full flex items-center justify-center">
            <Icon icon={faStar} className="text-yellow-500" size="sm" />
          </div>
          <div>
            <div className="flex items-center gap-2 mb-1">
              <div className="flex items-center">
                {[...Array(5)].map((_, i) => (
                  <Icon
                    key={i}
                    icon={faStar}
                    className={i < (row.rating || 0) ? 'text-yellow-400' : 'text-gray-300'}
                    size="xs"
                  />
                ))}
              </div>
              {row.title && (
                <p className="text-sm font-medium text-gray-900">{row.title}</p>
              )}
            </div>
            <p className="text-xs text-gray-500 line-clamp-1">
              {row.comment || row.content || 'No comment'}
            </p>
          </div>
        </div>
      ),
    },
    {
      key: 'user',
      label: 'User',
      sortable: false,
      render: (_: any, row: Review) => (
        <span className="text-sm text-gray-900">{row.user?.fullName || 'N/A'}</span>
      ),
    },
    {
      key: 'item',
      label: 'Item',
      sortable: false,
      render: (_: any, row: Review) => (
        <div>
          {row.listing && (
            <Link href={`/dashboard/listings/${row.listing.id}`} className="text-sm text-[#0e1a30] hover:underline">
              {row.listing.name}
            </Link>
          )}
          {row.event && (
            <Link href={`/dashboard/events/${row.event.id}`} className="text-sm text-[#0e1a30] hover:underline">
              {row.event.name}
            </Link>
          )}
          {row.tour && (
            <span className="text-sm text-gray-900">{row.tour.name}</span>
          )}
          {!row.listing && !row.event && !row.tour && (
            <span className="text-sm text-gray-400">-</span>
          )}
        </div>
      ),
    },
    {
      key: 'status',
      label: 'Status',
      sortable: false,
      render: (_: any, row: Review) => (
        <span className={`inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium ${getStatusBadgeColor(row.status || 'pending')}`}>
          {row.status?.replace(/_/g, ' ') || '-'}
        </span>
      ),
    },
    {
      key: 'date',
      label: 'Date',
      sortable: false,
      render: (_: any, row: Review) => (
        <p className="text-sm text-gray-900">
          {row.createdAt ? new Date(row.createdAt).toLocaleDateString('en-US', {
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
          <h1 className="text-2xl font-bold text-gray-900">Reviews</h1>
          <p className="text-gray-600 mt-1">Manage user reviews and ratings</p>
        </div>
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
                placeholder="Search by user, item name, comment..."
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
                setStatusFilter(e.target.value as ReviewStatus | '');
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
        data={reviews}
        loading={loading}
        onRowClick={(row) => router.push(`/dashboard/reviews/${row.id}`)}
        emptyMessage="No reviews found"
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

