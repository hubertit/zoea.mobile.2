'use client';

import { useState, useEffect } from 'react';
import { useRouter, useSearchParams } from 'next/navigation';
import Link from 'next/link';
import { ListingsAPI, CategoriesAPI, MerchantsAPI, LocationsAPI, type Listing, type ListingStatus, type ListingType, type Category, type CreateListingParams, type Merchant, type Country, type City } from '@/src/lib/api';
import Icon, { faSearch, faPlus, faTimes, faBox, faTags } from '@/app/components/Icon';
import { toast } from '@/app/components/Toaster';
import { DataTable, Pagination, Button, Modal, Input, Select, Textarea, Breadcrumbs } from '@/app/components';
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
  const [showCreateModal, setShowCreateModal] = useState(false);
  const [creating, setCreating] = useState(false);
  const [merchants, setMerchants] = useState<Merchant[]>([]);
  const [countries, setCountries] = useState<Country[]>([]);
  const [cities, setCities] = useState<City[]>([]);
  const [formData, setFormData] = useState<Partial<CreateListingParams>>({
    merchantId: '',
    name: '',
    description: '',
    shortDescription: '',
    type: undefined,
    categoryId: '',
    countryId: '',
    cityId: '',
    address: '',
    minPrice: undefined,
    maxPrice: undefined,
    contactPhone: '',
    contactEmail: '',
    website: '',
    status: 'draft',
  });

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

  // Fetch merchants, countries, cities for create modal
  useEffect(() => {
    if (showCreateModal) {
      const fetchData = async () => {
        try {
          const [merchantsRes, countriesRes] = await Promise.all([
            MerchantsAPI.listMerchants({ limit: 100, page: 1 }),
            LocationsAPI.getCountries(),
          ]);
          setMerchants(merchantsRes.data || []);
          setCountries(countriesRes || []);
        } catch (error: any) {
          console.error('Failed to fetch data:', error);
        }
      };
      fetchData();
    }
  }, [showCreateModal]);

  // Fetch cities when country changes
  useEffect(() => {
    if (formData.countryId) {
      LocationsAPI.getCities(formData.countryId).then(setCities).catch(console.error);
    } else {
      setCities([]);
    }
  }, [formData.countryId]);

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
      <Breadcrumbs items={[{ label: 'Listings' }]} />
      
      {/* Header */}
      <div className="flex items-center justify-between flex-wrap gap-4">
        <div>
          <h1 className="text-2xl font-bold text-gray-900">Listings</h1>
          <p className="text-gray-600 mt-1">Manage business listings and venues</p>
        </div>
        <Button variant="primary" size="md" icon={faPlus} onClick={() => setShowCreateModal(true)}>
          Create Listing
        </Button>
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
          pageSize={pageSize}
          onPageSizeChange={(size) => {
            setPageSize(size);
            setPage(1);
          }}
          totalItems={total}
        />
      )}

      {/* Create Listing Modal */}
      <Modal
        isOpen={showCreateModal}
        onClose={() => {
          setShowCreateModal(false);
          setFormData({
            merchantId: '',
            name: '',
            description: '',
            shortDescription: '',
            type: undefined,
            categoryId: '',
            countryId: '',
            cityId: '',
            address: '',
            minPrice: undefined,
            maxPrice: undefined,
            contactPhone: '',
            contactEmail: '',
            website: '',
            status: 'draft',
          });
        }}
        title="Create New Listing"
        size="xl"
      >
        <div className="space-y-4 max-h-[70vh] overflow-y-auto">
          <div className="grid grid-cols-2 gap-4">
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Merchant <span className="text-red-500">*</span>
              </label>
              <Select
                value={formData.merchantId || ''}
                onChange={(e) => setFormData({ ...formData, merchantId: e.target.value })}
                options={[
                  { value: '', label: 'Select merchant' },
                  ...merchants.map(m => ({ value: m.id, label: m.businessName })),
                ]}
              />
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Name <span className="text-red-500">*</span>
              </label>
              <Input
                value={formData.name || ''}
                onChange={(e) => setFormData({ ...formData, name: e.target.value })}
                placeholder="Enter listing name"
              />
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Type
              </label>
              <Select
                value={formData.type || ''}
                onChange={(e) => setFormData({ ...formData, type: e.target.value as ListingType || undefined })}
                options={[
                  { value: '', label: 'Select type' },
                  ...TYPES.filter(t => t.value).map(t => ({ value: t.value, label: t.label })),
                ]}
              />
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Category
              </label>
              <Select
                value={formData.categoryId || ''}
                onChange={(e) => setFormData({ ...formData, categoryId: e.target.value || undefined })}
                options={[
                  { value: '', label: 'Select category' },
                  ...categories.map(c => ({ value: c.id, label: c.name })),
                ]}
              />
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Country
              </label>
              <Select
                value={formData.countryId || ''}
                onChange={(e) => setFormData({ ...formData, countryId: e.target.value || undefined, cityId: '' })}
                options={[
                  { value: '', label: 'Select country' },
                  ...countries.map(c => ({ value: c.id, label: c.name })),
                ]}
              />
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                City
              </label>
              <Select
                value={formData.cityId || ''}
                onChange={(e) => setFormData({ ...formData, cityId: e.target.value || undefined })}
                options={[
                  { value: '', label: 'Select city' },
                  ...cities.map(c => ({ value: c.id, label: c.name })),
                ]}
                disabled={!formData.countryId}
              />
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Min Price
              </label>
              <Input
                type="number"
                value={formData.minPrice || ''}
                onChange={(e) => setFormData({ ...formData, minPrice: e.target.value ? parseFloat(e.target.value) : undefined })}
                placeholder="0"
              />
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Max Price
              </label>
              <Input
                type="number"
                value={formData.maxPrice || ''}
                onChange={(e) => setFormData({ ...formData, maxPrice: e.target.value ? parseFloat(e.target.value) : undefined })}
                placeholder="0"
              />
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Contact Phone
              </label>
              <Input
                type="tel"
                value={formData.contactPhone || ''}
                onChange={(e) => setFormData({ ...formData, contactPhone: e.target.value || undefined })}
                placeholder="Enter phone number"
              />
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Contact Email
              </label>
              <Input
                type="email"
                value={formData.contactEmail || ''}
                onChange={(e) => setFormData({ ...formData, contactEmail: e.target.value || undefined })}
                placeholder="Enter email"
              />
            </div>

            <div className="col-span-2">
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Website
              </label>
              <Input
                type="url"
                value={formData.website || ''}
                onChange={(e) => setFormData({ ...formData, website: e.target.value || undefined })}
                placeholder="https://example.com"
              />
            </div>

            <div className="col-span-2">
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Address
              </label>
              <Input
                value={formData.address || ''}
                onChange={(e) => setFormData({ ...formData, address: e.target.value || undefined })}
                placeholder="Enter address"
              />
            </div>

            <div className="col-span-2">
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Short Description
              </label>
              <Textarea
                value={formData.shortDescription || ''}
                onChange={(e) => setFormData({ ...formData, shortDescription: e.target.value || undefined })}
                placeholder="Brief description"
                rows={2}
              />
            </div>

            <div className="col-span-2">
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Description
              </label>
              <Textarea
                value={formData.description || ''}
                onChange={(e) => setFormData({ ...formData, description: e.target.value || undefined })}
                placeholder="Full description"
                rows={4}
              />
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Status
              </label>
              <Select
                value={formData.status || 'draft'}
                onChange={(e) => setFormData({ ...formData, status: e.target.value as ListingStatus })}
                options={STATUSES.filter(s => s.value).map(s => ({ value: s.value, label: s.label }))}
              />
            </div>
          </div>

          <div className="flex justify-end gap-3 pt-4 border-t border-gray-200">
            <Button
              variant="outline"
              onClick={() => {
                setShowCreateModal(false);
                setFormData({
                  merchantId: '',
                  name: '',
                  description: '',
                  shortDescription: '',
                  type: undefined,
                  categoryId: '',
                  countryId: '',
                  cityId: '',
                  address: '',
                  minPrice: undefined,
                  maxPrice: undefined,
                  contactPhone: '',
                  contactEmail: '',
                  website: '',
                  status: 'draft',
                });
              }}
            >
              Cancel
            </Button>
            <Button
              variant="primary"
              onClick={async () => {
                if (!formData.merchantId || !formData.name) {
                  toast.error('Please provide merchant and name');
                  return;
                }
                
                setCreating(true);
                try {
                  await ListingsAPI.createListing(formData as CreateListingParams);
                  toast.success('Listing created successfully');
                  setShowCreateModal(false);
                  setFormData({
                    merchantId: '',
                    name: '',
                    description: '',
                    shortDescription: '',
                    type: undefined,
                    categoryId: '',
                    countryId: '',
                    cityId: '',
                    address: '',
                    minPrice: undefined,
                    maxPrice: undefined,
                    contactPhone: '',
                    contactEmail: '',
                    website: '',
                    status: 'draft',
                  });
                  // Refresh listings
                  const response = await ListingsAPI.listListings({ page, limit: pageSize });
                  setListings(response.data || []);
                  setTotal(response.meta?.total || 0);
                } catch (error: any) {
                  console.error('Failed to create listing:', error);
                  toast.error(error?.response?.data?.message || error?.message || 'Failed to create listing');
                } finally {
                  setCreating(false);
                }
              }}
              loading={creating}
            >
              Create Listing
            </Button>
          </div>
        </div>
      </Modal>
    </div>
  );
}

