'use client';

import { useState, useEffect } from 'react';
import { useRouter, useSearchParams } from 'next/navigation';
import { MerchantPortalAPI, type Business, type MerchantListing, type MerchantPortalListingStatus } from '@/src/lib/api';
import { toast } from '@/app/components/Toaster';
import { DataTable, Pagination, Button, Breadcrumbs, StatusBadge } from '@/app/components';
import PageSkeleton from '@/app/components/PageSkeleton';
import { useDebounce } from '@/src/hooks/useDebounce';
import Icon, { faSearch, faPlus, faBox, faEye, faEdit } from '@/app/components/Icon';

const STATUSES: { value: MerchantPortalListingStatus | ''; label: string }[] = [
  { value: '', label: 'All Status' },
  { value: 'draft', label: 'Draft' },
  { value: 'pending_review', label: 'Pending Review' },
  { value: 'active', label: 'Active' },
  { value: 'inactive', label: 'Inactive' },
  { value: 'suspended', label: 'Suspended' },
];

export default function MyListingsPage() {
  const router = useRouter();
  const searchParams = useSearchParams();
  const [businesses, setBusinesses] = useState<Business[]>([]);
  const [selectedBusinessId, setSelectedBusinessId] = useState<string | null>(null);
  const [listings, setListings] = useState<MerchantListing[]>([]);
  const [loading, setLoading] = useState(true);
  const [page, setPage] = useState(1);
  const [pageSize, setPageSize] = useState(10);
  const [total, setTotal] = useState(0);
  const [search, setSearch] = useState('');
  const debouncedSearch = useDebounce(search, 500);
  const [statusFilter, setStatusFilter] = useState<MerchantPortalListingStatus | ''>('');

  useEffect(() => {
    if (searchParams.get('create') === 'true' && selectedBusinessId) {
      router.push(`/dashboard/my-listings?businessId=${selectedBusinessId}&create=true`);
    }
  }, [selectedBusinessId, searchParams, router]);

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

  // Fetch listings
  useEffect(() => {
    if (!selectedBusinessId) return;

    const fetchListings = async () => {
      setLoading(true);
      try {
        const response = await MerchantPortalAPI.getListings(selectedBusinessId, {
          page,
          limit: pageSize,
          status: statusFilter || undefined,
        });
        // Filter by search term client-side since API might not support it
        let filteredListings = response.data || [];
        if (debouncedSearch) {
          filteredListings = filteredListings.filter(l =>
            l.name.toLowerCase().includes(debouncedSearch.toLowerCase()) ||
            l.description?.toLowerCase().includes(debouncedSearch.toLowerCase())
          );
        }
        setListings(filteredListings);
        setTotal(response.meta?.total || 0);
      } catch (error: any) {
        console.error('Failed to fetch listings:', error);
        toast.error(error?.response?.data?.message || error?.message || 'Failed to load listings');
      } finally {
        setLoading(false);
      }
    };

    fetchListings();
  }, [page, pageSize, statusFilter, selectedBusinessId, debouncedSearch]);

  const totalPages = Math.ceil(total / pageSize);

  const columns = [
    {
      key: 'name',
      label: 'Name',
      sortable: true,
      render: (value: string, row: MerchantListing) => (
        <div className="flex items-center gap-3">
          <div className="w-10 h-10 bg-gray-100 rounded-sm flex items-center justify-center flex-shrink-0">
            <Icon icon={faBox} className="text-gray-600" size="sm" />
          </div>
          <div>
            <div className="font-medium text-gray-900">{value}</div>
            {row.type && (
              <div className="text-xs text-gray-500 capitalize">{row.type.replace('_', ' ')}</div>
            )}
          </div>
        </div>
      ),
    },
    {
      key: 'status',
      label: 'Status',
      sortable: true,
      render: (value: MerchantPortalListingStatus) => (
        <StatusBadge status={value === 'active' ? 'active' : value === 'pending_review' ? 'pending' : value === 'suspended' ? 'inactive' : 'pending'} />
      ),
    },
    {
      key: 'minPrice',
      label: 'Price',
      render: (value: number | null, row: MerchantListing) => {
        if (value && row.maxPrice) {
          return (
            <span className="text-sm text-gray-700">
              {value.toLocaleString()} - {row.maxPrice.toLocaleString()} {row.priceUnit?.replace('_', ' ') || ''}
            </span>
          );
        }
        if (value) {
          return (
            <span className="text-sm text-gray-700">
              {value.toLocaleString()} {row.priceUnit?.replace('_', ' ') || ''}
            </span>
          );
        }
        return <span className="text-sm text-gray-500">-</span>;
      },
    },
    {
      key: 'createdAt',
      label: 'Created',
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
      render: (_: any, row: MerchantListing) => (
        <div className="flex items-center gap-2">
          <Button
            variant="ghost"
            size="sm"
            icon={faEye}
            onClick={() => router.push(`/dashboard/my-listings/${row.id}?businessId=${selectedBusinessId}`)}
          >
            View
          </Button>
          <Button
            variant="ghost"
            size="sm"
            icon={faEdit}
            onClick={() => router.push(`/dashboard/my-listings/${row.id}?businessId=${selectedBusinessId}&edit=true`)}
          >
            Edit
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
          { label: 'My Listings' }
        ]} />
        <div className="flex items-center justify-center min-h-[400px]">
          <div className="text-center">
            <p className="text-gray-600">No businesses found. Create a business first.</p>
            <Button
              variant="primary"
              className="mt-4"
              onClick={() => router.push('/dashboard/my-businesses?create=true')}
            >
              Create Business
            </Button>
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
        { label: 'My Listings' }
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
          <Button 
            variant="primary" 
            size="md" 
            icon={faPlus} 
            onClick={() => router.push(`/dashboard/my-listings?businessId=${selectedBusinessId}&create=true`)}
          >
            Create Listing
          </Button>
        </div>
      </div>

      {/* Filters */}
      <div className="bg-white border border-gray-200 rounded-sm p-4">
        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
          {/* Search */}
          <div>
            <div className="relative">
              <Icon
                icon={faSearch}
                className="absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400"
                size="sm"
              />
              <input
                type="text"
                placeholder="Search listings..."
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
                setStatusFilter(e.target.value as MerchantPortalListingStatus | '');
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
        data={listings}
        loading={loading}
        onRowClick={(row) => router.push(`/dashboard/my-listings/${row.id}?businessId=${selectedBusinessId}`)}
        emptyMessage="No listings found. Create your first listing to get started."
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
