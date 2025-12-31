'use client';

import { useState, useEffect } from 'react';
import { useRouter } from 'next/navigation';
import { ListingsAPI, CategoriesAPI, type Listing, type ListingStatus, type ListingType, type Category } from '@/src/lib/api';
import Icon, { faSearch, faPlus, faBox, faFilter, faChevronDown, faChevronUp } from '@/app/components/Icon';
import { toast } from '@/app/components/Toaster';
import { DataTable, Pagination, Button, Breadcrumbs } from '@/app/components';
import PageSkeleton from '@/app/components/PageSkeleton';
import { useDebounce } from '@/src/hooks/useDebounce';
import { useAuthStore } from '@/src/store/auth';
import { MerchantsAPI } from '@/src/lib/api';
import StatusBadge from '@/app/components/StatusBadge';

const STATUSES: { value: ListingStatus | ''; label: string }[] = [
  { value: '', label: 'All Status' },
  { value: 'draft', label: 'Draft' },
  { value: 'pending_review', label: 'Pending Review' },
  { value: 'active', label: 'Active' },
  { value: 'inactive', label: 'Inactive' },
  { value: 'suspended', label: 'Suspended' },
];

const getStatusBadgeColor = (status: ListingStatus) => {
  switch (status) {
    case 'active':
      return 'bg-green-100 text-green-800';
    case 'pending_review':
      return 'bg-yellow-100 text-yellow-800';
    case 'suspended':
      return 'bg-red-100 text-red-800';
    case 'inactive':
      return 'bg-gray-100 text-gray-800';
    default:
      return 'bg-gray-100 text-gray-800';
  }
};

export default function MyListingsPage() {
  const router = useRouter();
  const { user } = useAuthStore();
  const [listings, setListings] = useState<Listing[]>([]);
  const [loading, setLoading] = useState(true);
  const [page, setPage] = useState(1);
  const [pageSize, setPageSize] = useState(10);
  const [total, setTotal] = useState(0);
  const [search, setSearch] = useState('');
  const debouncedSearch = useDebounce(search, 500);
  const [statusFilter, setStatusFilter] = useState<ListingStatus | ''>('');
  const [merchantId, setMerchantId] = useState<string | null>(null);
  const [showAdvancedFilters, setShowAdvancedFilters] = useState(false);

  // Get merchant profile ID from user
  useEffect(() => {
    const fetchMerchantProfile = async () => {
      if (!user?.id) return;
      
      try {
        // Fetch merchant profiles for the current user
        const response = await MerchantsAPI.listMerchants({ 
          limit: 1,
          // We'll need to filter by userId - check if API supports it
        });
        
        // For now, let's try to get merchant by searching for user's listings
        // Or we can add a userId filter to the API
        // As a workaround, we'll fetch all merchants and filter client-side
        const allMerchants = await MerchantsAPI.listMerchants({ limit: 1000 });
        const userMerchant = allMerchants.data.find(m => m.userId === user.id);
        
        if (userMerchant) {
          setMerchantId(userMerchant.id);
        }
      } catch (error) {
        console.error('Failed to fetch merchant profile:', error);
      }
    };

    fetchMerchantProfile();
  }, [user]);

  // Fetch listings
  useEffect(() => {
    if (!merchantId) return;

    const fetchListings = async () => {
      setLoading(true);
      try {
        const response = await ListingsAPI.listListings({
          page,
          limit: pageSize,
          search: debouncedSearch || undefined,
          status: statusFilter || undefined,
          merchantId,
        });
        setListings(response.data || []);
        setTotal(response.meta?.total || 0);
      } catch (error: any) {
        console.error('Failed to fetch listings:', error);
        toast.error(error?.response?.data?.message || error?.message || 'Failed to load listings');
      } finally {
        setLoading(false);
      }
    };

    fetchListings();
  }, [page, pageSize, debouncedSearch, statusFilter, merchantId]);

  const totalPages = Math.ceil(total / pageSize);

  const columns = [
    {
      key: 'name',
      label: 'Name',
      sortable: true,
      render: (value: string, row: Listing) => (
        <div className="flex items-center gap-3">
          <div className="w-10 h-10 bg-gray-100 rounded-sm flex items-center justify-center flex-shrink-0">
            <Icon icon={faBox} className="text-gray-600" size="sm" />
          </div>
          <div>
            <div className="font-medium text-gray-900">{value}</div>
            {row.category && (
              <div className="text-xs text-gray-500">{row.category.name}</div>
            )}
          </div>
        </div>
      ),
    },
    {
      key: 'type',
      label: 'Type',
      sortable: true,
      render: (value: ListingType) => (
        <span className="text-sm text-gray-700 capitalize">{value?.replace('_', ' ') || '-'}</span>
      ),
    },
    {
      key: 'status',
      label: 'Status',
      sortable: true,
      render: (value: ListingStatus) => (
        <StatusBadge status={value} />
      ),
    },
    {
      key: 'minPrice',
      label: 'Price',
      render: (value: number | null, row: Listing) => {
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
      key: 'city',
      label: 'Location',
      render: (value: any, row: Listing) => (
        <span className="text-sm text-gray-700">
          {row.city?.name || '-'}
        </span>
      ),
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
      render: (_: any, row: Listing) => (
        <div className="flex items-center gap-2">
          <Button
            variant="ghost"
            size="sm"
            onClick={() => router.push(`/dashboard/listings/${row.id}`)}
          >
            View
          </Button>
        </div>
      ),
    },
  ];

  if (!merchantId) {
    return (
      <div className="flex items-center justify-center min-h-[400px]">
        <div className="text-center">
          <p className="text-gray-600">No merchant profile found. Please contact support.</p>
        </div>
      </div>
    );
  }

  if (loading && listings.length === 0) {
    return <PageSkeleton />;
  }

  return (
    <div className="space-y-6">
      <Breadcrumbs items={[
        { label: 'Dashboard', href: '/dashboard' },
        { label: 'My Listings' }
      ]} />
      
      {/* Header */}
      <div className="flex items-center justify-between flex-wrap gap-4">
        <div>
          <h1 className="text-2xl font-bold text-gray-900">My Listings</h1>
          <p className="text-gray-600 mt-1">Manage your business listings</p>
        </div>
        <Button 
          variant="primary" 
          size="md" 
          icon={faPlus} 
          onClick={() => router.push('/dashboard/listings?create=true')}
        >
          Create Listing
        </Button>
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
                setStatusFilter(e.target.value as ListingStatus | '');
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
        onRowClick={(row) => router.push(`/dashboard/listings/${row.id}`)}
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

