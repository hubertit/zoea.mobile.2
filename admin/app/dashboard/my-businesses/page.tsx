'use client';

import { useState, useEffect } from 'react';
import { useRouter, useSearchParams } from 'next/navigation';
import { MerchantPortalAPI, type Business } from '@/src/lib/api';
import { toast } from '@/app/components/Toaster';
import { DataTable, Button, Modal, Input, Select, Textarea, Breadcrumbs, StatusBadge } from '@/app/components';
import PageSkeleton from '@/app/components/PageSkeleton';
import Icon, { faPlus, faBuilding, faEdit, faEye } from '@/app/components/Icon';
import { useAuthStore } from '@/src/store/auth';
import { LocationsAPI } from '@/src/lib/api';

export default function MyBusinessesPage() {
  const router = useRouter();
  const searchParams = useSearchParams();
  const { user } = useAuthStore();
  const [businesses, setBusinesses] = useState<Business[]>([]);
  const [loading, setLoading] = useState(true);
  const [showCreateModal, setShowCreateModal] = useState(false);
  const [creating, setCreating] = useState(false);
  const [countries, setCountries] = useState<any[]>([]);
  const [cities, setCities] = useState<any[]>([]);
  const [formData, setFormData] = useState({
    businessName: '',
    businessType: '',
    businessRegistrationNumber: '',
    taxId: '',
    description: '',
    businessEmail: '',
    businessPhone: '',
    website: '',
    countryId: '',
    cityId: '',
    districtId: '',
    address: '',
  });

  useEffect(() => {
    if (searchParams.get('create') === 'true') {
      setShowCreateModal(true);
    }
  }, [searchParams]);

  useEffect(() => {
    fetchBusinesses();
    fetchLocations();
  }, []);

  const fetchBusinesses = async () => {
    setLoading(true);
    try {
      const data = await MerchantPortalAPI.getMyBusinesses();
      setBusinesses(data);
    } catch (error: any) {
      console.error('Failed to fetch businesses:', error);
      toast.error(error?.response?.data?.message || error?.message || 'Failed to load businesses');
    } finally {
      setLoading(false);
    }
  };

  const fetchLocations = async () => {
    try {
      const countriesData = await LocationsAPI.getCountries();
      setCountries(countriesData || []);
    } catch (error) {
      console.error('Failed to fetch countries:', error);
    }
  };

  const handleCountryChange = async (countryId: string) => {
    setFormData({ ...formData, countryId, cityId: '', districtId: '' });
    if (countryId) {
      try {
        const citiesData = await LocationsAPI.getCities(countryId);
        setCities(citiesData || []);
      } catch (error) {
        console.error('Failed to fetch cities:', error);
      }
    } else {
      setCities([]);
    }
  };

  const handleCreate = async () => {
    if (!formData.businessName || !formData.businessType) {
      toast.error('Business name and type are required');
      return;
    }

    setCreating(true);
    try {
      await MerchantPortalAPI.createBusiness({
        businessName: formData.businessName,
        businessType: formData.businessType,
        businessRegistrationNumber: formData.businessRegistrationNumber || undefined,
        taxId: formData.taxId || undefined,
        description: formData.description || undefined,
        businessEmail: formData.businessEmail || undefined,
        businessPhone: formData.businessPhone || undefined,
        website: formData.website || undefined,
        countryId: formData.countryId || undefined,
        cityId: formData.cityId || undefined,
        districtId: formData.districtId || undefined,
        address: formData.address || undefined,
      });
      toast.success('Business created successfully');
      setShowCreateModal(false);
      setFormData({
        businessName: '',
        businessType: '',
        businessRegistrationNumber: '',
        taxId: '',
        description: '',
        businessEmail: '',
        businessPhone: '',
        website: '',
        countryId: '',
        cityId: '',
        districtId: '',
        address: '',
      });
      fetchBusinesses();
    } catch (error: any) {
      console.error('Failed to create business:', error);
      toast.error(error?.response?.data?.message || error?.message || 'Failed to create business');
    } finally {
      setCreating(false);
    }
  };

  const getStatusBadge = (status: string) => {
    switch (status) {
      case 'approved':
        return <StatusBadge status="active" />;
      case 'pending':
        return <StatusBadge status="pending" />;
      case 'rejected':
        return <StatusBadge status="inactive" />;
      default:
        return <StatusBadge status="pending" />;
    }
  };

  const columns = [
    {
      key: 'businessName',
      label: 'Business Name',
      sortable: true,
      render: (value: string, row: Business) => (
        <div className="flex items-center gap-3">
          <div className="w-10 h-10 bg-gray-100 rounded-sm flex items-center justify-center flex-shrink-0">
            <Icon icon={faBuilding} className="text-gray-600" size="sm" />
          </div>
          <div>
            <div className="font-medium text-gray-900">{value}</div>
            <div className="text-xs text-gray-500">{row.businessType || 'N/A'}</div>
          </div>
        </div>
      ),
    },
    {
      key: 'registrationStatus',
      label: 'Status',
      sortable: true,
      render: (value: string) => getStatusBadge(value),
    },
    {
      key: '_count',
      label: 'Listings',
      render: (value: any) => (
        <span className="text-sm text-gray-700">{value?.listings || 0}</span>
      ),
    },
    {
      key: '_count',
      label: 'Bookings',
      render: (value: any) => (
        <span className="text-sm text-gray-700">{value?.bookings || 0}</span>
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
      render: (_: any, row: Business) => (
        <div className="flex items-center gap-2">
          <Button
            variant="ghost"
            size="sm"
            icon={faEye}
            onClick={() => router.push(`/dashboard/my-businesses/${row.id}`)}
          >
            View
          </Button>
          <Button
            variant="ghost"
            size="sm"
            icon={faEdit}
            onClick={() => router.push(`/dashboard/my-businesses/${row.id}?edit=true`)}
          >
            Edit
          </Button>
        </div>
      ),
    },
  ];

  if (loading) {
    return <PageSkeleton />;
  }

  return (
    <div className="space-y-6">
      <Breadcrumbs items={[
        { label: 'Dashboard', href: '/dashboard/my-dashboard' },
        { label: 'My Businesses' }
      ]} />

      {/* Header */}
      <div className="flex items-center justify-between flex-wrap gap-4">
        <div>
          <h1 className="text-2xl font-bold text-gray-900">My Businesses</h1>
          <p className="text-gray-600 mt-1">Manage your business profiles</p>
        </div>
        <Button 
          variant="primary" 
          size="md" 
          icon={faPlus} 
          onClick={() => setShowCreateModal(true)}
        >
          Create Business
        </Button>
      </div>

      {/* Table */}
      <DataTable
        columns={columns}
        data={businesses}
        loading={loading}
        onRowClick={(row) => router.push(`/dashboard/my-businesses/${row.id}`)}
        emptyMessage="No businesses found. Create your first business to get started."
        showNumbering={true}
        enableClientSort={true}
        enableColumnVisibility={true}
      />

      {/* Create Modal */}
      <Modal
        isOpen={showCreateModal}
        onClose={() => {
          setShowCreateModal(false);
          setFormData({
            businessName: '',
            businessType: '',
            businessRegistrationNumber: '',
            taxId: '',
            description: '',
            businessEmail: '',
            businessPhone: '',
            website: '',
            countryId: '',
            cityId: '',
            districtId: '',
            address: '',
          });
        }}
        title="Create New Business"
        size="lg"
      >
        <div className="space-y-4">
          <Input
            label="Business Name *"
            value={formData.businessName}
            onChange={(e) => setFormData({ ...formData, businessName: e.target.value })}
            placeholder="Enter business name"
            required
          />
          <Select
            label="Business Type *"
            value={formData.businessType}
            onChange={(e) => setFormData({ ...formData, businessType: e.target.value })}
            options={[
              { value: '', label: 'Select type' },
              { value: 'hotel', label: 'Hotel' },
              { value: 'restaurant', label: 'Restaurant' },
              { value: 'attraction', label: 'Attraction' },
              { value: 'activity', label: 'Activity' },
              { value: 'rental', label: 'Rental' },
              { value: 'nightlife', label: 'Nightlife' },
              { value: 'spa', label: 'Spa' },
              { value: 'other', label: 'Other' },
            ]}
            required
          />
          <Input
            label="Registration Number"
            value={formData.businessRegistrationNumber}
            onChange={(e) => setFormData({ ...formData, businessRegistrationNumber: e.target.value })}
            placeholder="Enter registration number"
          />
          <Input
            label="Tax ID"
            value={formData.taxId}
            onChange={(e) => setFormData({ ...formData, taxId: e.target.value })}
            placeholder="Enter tax ID"
          />
          <Textarea
            label="Description"
            value={formData.description}
            onChange={(e) => setFormData({ ...formData, description: e.target.value })}
            placeholder="Enter business description"
            rows={4}
          />
          <Input
            label="Business Email"
            value={formData.businessEmail}
            onChange={(e) => setFormData({ ...formData, businessEmail: e.target.value })}
            placeholder="Enter business email"
            type="email"
          />
          <Input
            label="Business Phone"
            value={formData.businessPhone}
            onChange={(e) => setFormData({ ...formData, businessPhone: e.target.value })}
            placeholder="Enter business phone"
          />
          <Input
            label="Website"
            value={formData.website}
            onChange={(e) => setFormData({ ...formData, website: e.target.value })}
            placeholder="https://example.com"
          />
          <Select
            label="Country"
            value={formData.countryId}
            onChange={(e) => handleCountryChange(e.target.value)}
            options={[
              { value: '', label: 'Select country' },
              ...countries.map(c => ({ value: c.id, label: c.name })),
            ]}
          />
          <Select
            label="City"
            value={formData.cityId}
            onChange={(e) => setFormData({ ...formData, cityId: e.target.value })}
            options={[
              { value: '', label: 'Select city' },
              ...cities.map(c => ({ value: c.id, label: c.name })),
            ]}
            disabled={!formData.countryId}
          />
          <Input
            label="Address"
            value={formData.address}
            onChange={(e) => setFormData({ ...formData, address: e.target.value })}
            placeholder="Enter business address"
          />
          <div className="flex justify-end gap-3 mt-6">
            <Button
              variant="ghost"
              onClick={() => {
                setShowCreateModal(false);
                setFormData({
                  businessName: '',
                  businessType: '',
                  businessRegistrationNumber: '',
                  taxId: '',
                  description: '',
                  businessEmail: '',
                  businessPhone: '',
                  website: '',
                  countryId: '',
                  cityId: '',
                  districtId: '',
                  address: '',
                });
              }}
            >
              Cancel
            </Button>
            <Button
              variant="primary"
              onClick={handleCreate}
              loading={creating}
            >
              Create Business
            </Button>
          </div>
        </div>
      </Modal>
    </div>
  );
}

