'use client';

import { useState, useEffect } from 'react';
import { useRouter, useSearchParams } from 'next/navigation';
import Link from 'next/link';
import { ListingsAPI, CategoriesAPI, type Listing, type ListingStatus, type ListingType, type Category } from '@/src/lib/api';
import Icon, { faSearch, faPlus, faTimes, faBox, faTags } from '@/app/components/Icon';
import { toast } from '@/app/components/Toaster';
import { DataTable, Pagination, Button } from '@/app/components';
import PageSkeleton from '@/app/components/PageSkeleton';
import { useDebounce } from '@/src/hooks/useDebounce';

const STATUSES: { value: ListingStatus | ''; label: string }[] = [
  { value: '', label: 'All Status' },
  { value: 'draft', label: 'Draft' },
  { value: 'pending_review', label: 'Pending Review' },
  { value: 'active', label: 'Active' },
  { value: 'inactive', label: 'Inactive' },
  { value: 'suspended', label: 'Suspended' },
];

const TYPES: { value: ListingType | ''; label: string }[] = [
  { value: '', label: 'All Types' },
  { value: 'hotel', label: 'Hotel' },
  { value: 'restaurant', label: 'Restaurant' },
  { value: 'tour', label: 'Tour' },
  { value: 'event', label: 'Event' },
  { value: 'attraction', label: 'Attraction' },
  { value: 'bar', label: 'Bar' },
  { value: 'club', label: 'Club' },
  { value: 'lounge', label: 'Lounge' },
  { value: 'cafe', label: 'Cafe' },
  { value: 'fast_food', label: 'Fast Food' },
  { value: 'mall', label: 'Mall' },
  { value: 'market', label: 'Market' },
  { value: 'boutique', label: 'Boutique' },
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

export default function ListingsPage() {
  const router = useRouter();
  const searchParams = useSearchParams();
  const [listings, setListings] = useState<Listing[]>([]);
  const [categories, setCategories] = useState<Category[]>([]);
  const [loading, setLoading] = useState(true);
  const [page, setPage] = useState(1);
  const [pageSize, setPageSize] = useState(10);
  const [total, setTotal] = useState(0);
  const [search, setSearch] = useState('');
  const debouncedSearch = useDebounce(search, 500);
  const [statusFilter, setStatusFilter] = useState<ListingStatus | ''>('');
  const [typeFilter, setTypeFilter] = useState<ListingType | ''>('');
  const [categoryFilter, setCategoryFilter] = useState<string>('');

  // Get categoryId from URL params
  useEffect(() => {
    const categoryId = searchParams.get('categoryId');
    if (categoryId) {
      setCategoryFilter(categoryId);
    }
  }, [searchParams]);

  // Fetch categories
  useEffect(() => {
    const fetchCategories = async () => {
      try {
        const data = await CategoriesAPI.listCategories();
        setCategories(data);
      } catch (error: any) {
        console.error('Failed to fetch categories:', error);
      }
    };
    fetchCategories();
  }, []);

  // Fetch listings
  useEffect(() => {
    const fetchListings = async () => {
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

        if (typeFilter) {
          params.type = typeFilter;
        }

        if (categoryFilter) {
          params.categoryId = categoryFilter;
        }

        const response = await ListingsAPI.listListings(params);
        setListings(response.data || []);
        setTotal(response.meta?.total || 0);
      } catch (error: any) {
        console.error('Failed to fetch listings:', error);
        toast.error(error?.message || 'Failed to load listings');
      } finally {
        setLoading(false);
      }
    };

    fetchListings();
  }, [page, pageSize, debouncedSearch, statusFilter, typeFilter, categoryFilter]);

  const totalPages = Math.ceil(total / pageSize);

  const columns = [
    {
      key: 'name',
      label: 'Name',
      sortable: false,
      render: (_: any, row: Listing) => (
        <div className="flex items-center gap-3">
          <div className="w-10 h-10 bg-[#0e1a30]/10 rounded-full flex items-center justify-center">
            <Icon icon={faBox} className="text-[#0e1a30]" size="sm" />
          </div>
          <div>
            <p className="text-sm font-medium text-gray-900">{row?.name || '-'}</p>
            {row?.type && (
              <p className="text-xs text-gray-500">{row.type.replace(/_/g, ' ')}</p>
            )}
          </div>
        </div>
      ),
    },
    {
      key: 'merchant',
      label: 'Merchant',
      sortable: false,
      render: (_: any, row: Listing) => (
        <span className="text-sm text-gray-900">{row?.merchant?.businessName || '-'}</span>
      ),
    },
    {
      key: 'category',
      label: 'Category',
      sortable: false,
      render: (_: any, row: Listing) => (
        row?.category ? (
          <Link href={`/dashboard/categories/${row.category.id}`} className="text-sm text-[#0e1a30] hover:underline">
            {row.category.name}
          </Link>
        ) : (
          <span className="text-sm text-gray-400">-</span>
        )
      ),
    },
    {
      key: 'location',
      label: 'Location',
      sortable: false,
      render: (_: any, row: Listing) => (
        <div>
          {row?.city?.name && (
            <p className="text-sm text-gray-900">{row.city.name}</p>
          )}
          {row?.country?.name && (
            <p className="text-xs text-gray-500">{row.country.name}</p>
          )}
          {!row?.city && !row?.country && (
            <span className="text-sm text-gray-400">-</span>
          )}
        </div>
      ),
    },
    {
      key: 'status',
      label: 'Status',
      sortable: false,
      render: (_: any, row: Listing) => (
        <span className={`inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium ${getStatusBadgeColor(row?.status || 'draft')}`}>
          {row?.status?.replace(/_/g, ' ') || '-'}
        </span>
      ),
    },
    {
      key: 'features',
      label: 'Features',
      sortable: false,
      render: (_: any, row: Listing) => (
        <div className="flex flex-wrap gap-1">
          {row?.isFeatured && (
            <span className="inline-flex items-center px-2 py-0.5 rounded text-xs font-medium bg-blue-100 text-blue-800">
              Featured
            </span>
          )}
          {row?.isVerified && (
            <span className="inline-flex items-center px-2 py-0.5 rounded text-xs font-medium bg-green-100 text-green-800">
              Verified
            </span>
          )}
          {!row?.isFeatured && !row?.isVerified && (
            <span className="text-xs text-gray-400">-</span>
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
          <h1 className="text-2xl font-bold text-gray-900">Listings</h1>
          <p className="text-gray-600 mt-1">Manage business listings and venues</p>
        </div>
        <Link href="/dashboard/listings/create">
          <Button variant="primary" size="md" icon={faPlus}>
            Create Listing
          </Button>
        </Link>
      </div>

      {/* Filters */}
      <div className="bg-white border border-gray-200 rounded-sm p-4">
        <div className="grid grid-cols-1 md:grid-cols-5 gap-4">
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
                placeholder="Search by name, merchant..."
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

          {/* Type Filter */}
          <div>
            <select
              value={typeFilter}
              onChange={(e) => {
                setTypeFilter(e.target.value as ListingType | '');
                setPage(1);
              }}
              className="w-full px-3 py-2 border border-gray-200 rounded-sm focus:outline-none focus:ring-1 focus:ring-[#0e1a30] focus:border-[#0e1a30] text-sm"
            >
              {TYPES.map((type) => (
                <option key={type.value} value={type.value}>
                  {type.label}
                </option>
              ))}
            </select>
          </div>

          {/* Category Filter */}
          <div>
            <select
              value={categoryFilter}
              onChange={(e) => {
                setCategoryFilter(e.target.value);
                setPage(1);
                // Update URL without navigation
                const params = new URLSearchParams(searchParams.toString());
                if (e.target.value) {
                  params.set('categoryId', e.target.value);
                } else {
                  params.delete('categoryId');
                }
                router.push(`/dashboard/listings?${params.toString()}`, { scroll: false });
              }}
              className="w-full px-3 py-2 border border-gray-200 rounded-sm focus:outline-none focus:ring-1 focus:ring-[#0e1a30] focus:border-[#0e1a30] text-sm"
            >
              <option value="">All Categories</option>
              {categories.map((cat) => (
                <option key={cat.id} value={cat.id}>
                  {cat.name}
                </option>
              ))}
            </select>
          </div>
        </div>
        {categoryFilter && (
          <div className="mt-3 flex items-center gap-2">
            <span className="text-sm text-gray-600">Filtered by category:</span>
            <Link href={`/dashboard/categories/${categoryFilter}`} className="text-sm text-[#0e1a30] hover:underline font-medium">
              {categories.find(c => c.id === categoryFilter)?.name || categoryFilter}
            </Link>
            <button
              onClick={() => {
                setCategoryFilter('');
                setPage(1);
                const params = new URLSearchParams(searchParams.toString());
                params.delete('categoryId');
                router.push(`/dashboard/listings?${params.toString()}`, { scroll: false });
              }}
              className="text-sm text-gray-500 hover:text-gray-700"
            >
              <Icon icon={faTimes} size="xs" />
            </button>
          </div>
        )}
      </div>

      {/* Table */}
      <DataTable
        columns={columns}
        data={listings}
        loading={loading}
        onRowClick={(row) => router.push(`/dashboard/listings/${row.id}`)}
        emptyMessage="No listings found"
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

