'use client';

import { useState, useEffect } from 'react';
import { useRouter } from 'next/navigation';
import { MerchantsAPI, UsersAPI, LocationsAPI, type Merchant, type ApprovalStatus, type CreateMerchantParams, type User, type Country, type City, type ListingType } from '@/src/lib/api';
import Icon, { faSearch, faPlus, faTimes, faBuilding } from '@/app/components/Icon';
import { toast } from '@/app/components/Toaster';
import { DataTable, Pagination, Button, Modal, Input, Select, Textarea } from '@/app/components';
import PageSkeleton from '@/app/components/PageSkeleton';
import { useDebounce } from '@/src/hooks/useDebounce';

const STATUSES: { value: ApprovalStatus | ''; label: string }[] = [
  { value: '', label: 'All Status' },
  { value: 'pending', label: 'Pending' },
  { value: 'approved', label: 'Approved' },
  { value: 'rejected', label: 'Rejected' },
  { value: 'revision_requested', label: 'Revision Requested' },
];

const getStatusBadgeColor = (status: ApprovalStatus) => {
  switch (status) {
    case 'approved':
      return 'bg-green-100 text-green-800';
    case 'pending':
    case 'revision_requested':
      return 'bg-yellow-100 text-yellow-800';
    case 'rejected':
      return 'bg-red-100 text-red-800';
    default:
      return 'bg-gray-100 text-gray-800';
  }
};

export default function MerchantsPage() {
  const router = useRouter();
  const [merchants, setMerchants] = useState<Merchant[]>([]);
  const [loading, setLoading] = useState(true);
  const [page, setPage] = useState(1);
  const [pageSize, setPageSize] = useState(10);
  const [total, setTotal] = useState(0);
  const [search, setSearch] = useState('');
  const debouncedSearch = useDebounce(search, 500);
  const [statusFilter, setStatusFilter] = useState<ApprovalStatus | ''>('');
  const [showCreateModal, setShowCreateModal] = useState(false);
  const [creating, setCreating] = useState(false);
  const [users, setUsers] = useState<User[]>([]);
  const [countries, setCountries] = useState<Country[]>([]);
  const [cities, setCities] = useState<City[]>([]);
  const [formData, setFormData] = useState<Partial<CreateMerchantParams>>({
    userId: '',
    businessName: '',
    businessType: undefined,
    businessRegistrationNumber: '',
    taxId: '',
    description: '',
    businessEmail: '',
    businessPhone: '',
    website: '',
    countryId: '',
    cityId: '',
    address: '',
  });

  const BUSINESS_TYPES: { value: ListingType | ''; label: string }[] = [
    { value: '', label: 'Select type' },
    { value: 'hotel', label: 'Hotel' },
    { value: 'restaurant', label: 'Restaurant' },
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

  useEffect(() => {
    const fetchMerchants = async () => {
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
          params.registrationStatus = statusFilter;
        }

        const response = await MerchantsAPI.listMerchants(params);
        setMerchants(response.data || []);
        setTotal(response.meta?.total || 0);
      } catch (error: any) {
        console.error('Failed to fetch merchants:', error);
        toast.error(error?.message || 'Failed to load merchants');
      } finally {
        setLoading(false);
      }
    };

    fetchMerchants();
  }, [page, pageSize, debouncedSearch, statusFilter]);

  // Fetch users, countries for create modal
  useEffect(() => {
    if (showCreateModal) {
      const fetchData = async () => {
        try {
          const [usersRes, countriesRes] = await Promise.all([
            UsersAPI.listUsers({ limit: 100, page: 1 }),
            LocationsAPI.getCountries(),
          ]);
          setUsers(usersRes.data || []);
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

  const totalPages = Math.ceil(total / pageSize);

  const columns = [
    {
      key: 'businessName',
      label: 'Business',
      sortable: false,
      render: (_: any, row: Merchant) => (
        <div className="flex items-center gap-3">
          <div className="w-10 h-10 bg-[#0e1a30]/10 rounded-full flex items-center justify-center">
            <Icon icon={faBuilding} className="text-[#0e1a30]" size="sm" />
          </div>
          <div>
            <p className="text-sm font-medium text-gray-900">{row?.businessName || '-'}</p>
            {row?.user && (
              <p className="text-xs text-gray-500">{row.user.fullName || row.user.email}</p>
            )}
          </div>
        </div>
      ),
    },
    {
      key: 'contact',
      label: 'Contact',
      sortable: false,
      render: (_: any, row: Merchant) => (
        <div>
          {row?.businessEmail && (
            <p className="text-sm text-gray-900">{row.businessEmail}</p>
          )}
          {row?.businessPhone && (
            <p className="text-xs text-gray-500">{row.businessPhone}</p>
          )}
          {!row?.businessEmail && !row?.businessPhone && (
            <span className="text-sm text-gray-400">-</span>
          )}
        </div>
      ),
    },
    {
      key: 'location',
      label: 'Location',
      sortable: false,
      render: (_: any, row: Merchant) => (
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
      render: (_: any, row: Merchant) => (
        <div className="flex flex-col gap-1">
          <span className={`inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium ${getStatusBadgeColor(row?.registrationStatus || 'pending')}`}>
            {row?.registrationStatus?.replace(/_/g, ' ') || '-'}
          </span>
          {row?.isVerified && (
            <span className="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-green-100 text-green-800">
              Verified
            </span>
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
          <h1 className="text-2xl font-bold text-gray-900">Merchants</h1>
          <p className="text-gray-600 mt-1">Manage merchant profiles and businesses</p>
        </div>
        <Button variant="primary" size="md" icon={faPlus} onClick={() => setShowCreateModal(true)}>
          Create Merchant
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
                placeholder="Search by business name, email, phone or owner..."
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
                setStatusFilter(e.target.value as ApprovalStatus | '');
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
        data={merchants}
        loading={loading}
        onRowClick={(row) => router.push(`/dashboard/merchants/${row.id}`)}
        emptyMessage="No merchants found"
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

      {/* Create Merchant Modal */}
      <Modal
        isOpen={showCreateModal}
        onClose={() => {
          setShowCreateModal(false);
          setFormData({
            userId: '',
            businessName: '',
            businessType: undefined,
            businessRegistrationNumber: '',
            taxId: '',
            description: '',
            businessEmail: '',
            businessPhone: '',
            website: '',
            countryId: '',
            cityId: '',
            address: '',
          });
        }}
        title="Create New Merchant"
        size="lg"
      >
        <div className="space-y-4 max-h-[70vh] overflow-y-auto">
          <div className="grid grid-cols-2 gap-4">
            <div className="col-span-2">
              <label className="block text-sm font-medium text-gray-700 mb-1">
                User (Owner) <span className="text-red-500">*</span>
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
                Business Name <span className="text-red-500">*</span>
              </label>
              <Input
                value={formData.businessName || ''}
                onChange={(e) => setFormData({ ...formData, businessName: e.target.value })}
                placeholder="Enter business name"
              />
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Business Type
              </label>
              <Select
                value={formData.businessType || ''}
                onChange={(e) => setFormData({ ...formData, businessType: e.target.value as ListingType || undefined })}
                options={BUSINESS_TYPES}
              />
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Registration Number
              </label>
              <Input
                value={formData.businessRegistrationNumber || ''}
                onChange={(e) => setFormData({ ...formData, businessRegistrationNumber: e.target.value || undefined })}
                placeholder="Enter registration number"
              />
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Tax ID
              </label>
              <Input
                value={formData.taxId || ''}
                onChange={(e) => setFormData({ ...formData, taxId: e.target.value || undefined })}
                placeholder="Enter tax ID"
              />
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Business Email
              </label>
              <Input
                type="email"
                value={formData.businessEmail || ''}
                onChange={(e) => setFormData({ ...formData, businessEmail: e.target.value || undefined })}
                placeholder="Enter business email"
              />
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Business Phone
              </label>
              <Input
                type="tel"
                value={formData.businessPhone || ''}
                onChange={(e) => setFormData({ ...formData, businessPhone: e.target.value || undefined })}
                placeholder="Enter business phone"
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
                Description
              </label>
              <Textarea
                value={formData.description || ''}
                onChange={(e) => setFormData({ ...formData, description: e.target.value || undefined })}
                placeholder="Enter business description"
                rows={4}
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
                  businessName: '',
                  businessType: undefined,
                  businessRegistrationNumber: '',
                  taxId: '',
                  description: '',
                  businessEmail: '',
                  businessPhone: '',
                  website: '',
                  countryId: '',
                  cityId: '',
                  address: '',
                });
              }}
            >
              Cancel
            </Button>
            <Button
              variant="primary"
              onClick={async () => {
                if (!formData.userId || !formData.businessName) {
                  toast.error('Please provide user and business name');
                  return;
                }
                
                setCreating(true);
                try {
                  await MerchantsAPI.createMerchant(formData as CreateMerchantParams);
                  toast.success('Merchant created successfully');
                  setShowCreateModal(false);
                  setFormData({
                    userId: '',
                    businessName: '',
                    businessType: undefined,
                    businessRegistrationNumber: '',
                    taxId: '',
                    description: '',
                    businessEmail: '',
                    businessPhone: '',
                    website: '',
                    countryId: '',
                    cityId: '',
                    address: '',
                  });
                  // Refresh merchants
                  const response = await MerchantsAPI.listMerchants({ page, limit: pageSize });
                  setMerchants(response.data || []);
                  setTotal(response.meta?.total || 0);
                } catch (error: any) {
                  console.error('Failed to create merchant:', error);
                  toast.error(error?.response?.data?.message || error?.message || 'Failed to create merchant');
                } finally {
                  setCreating(false);
                }
              }}
              loading={creating}
            >
              Create Merchant
            </Button>
          </div>
        </div>
      </Modal>
    </div>
  );
}

