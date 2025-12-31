'use client';

import { useState, useEffect } from 'react';
import { useRouter, useParams, useSearchParams } from 'next/navigation';
import { MerchantPortalAPI, type Business } from '@/src/lib/api';
import { toast } from '@/app/components/Toaster';
import { Button, Modal, Input, Select, Textarea, Breadcrumbs, StatusBadge } from '@/app/components';
import PageSkeleton from '@/app/components/PageSkeleton';
import Icon, { faArrowLeft, faEdit, faBuilding } from '@/app/components/Icon';
import { LocationsAPI } from '@/src/lib/api';

export default function BusinessDetailPage() {
  const router = useRouter();
  const params = useParams();
  const searchParams = useSearchParams();
  const businessId = params.id as string;
  const [business, setBusiness] = useState<Business | null>(null);
  const [loading, setLoading] = useState(true);
  const [editMode, setEditMode] = useState(false);
  const [saving, setSaving] = useState(false);
  const [countries, setCountries] = useState<any[]>([]);
  const [cities, setCities] = useState<any[]>([]);
  const [formData, setFormData] = useState({
    businessName: '',
    businessType: '',
    description: '',
    businessEmail: '',
    businessPhone: '',
    website: '',
    countryId: '',
    cityId: '',
    address: '',
  });

  useEffect(() => {
    if (searchParams.get('edit') === 'true') {
      setEditMode(true);
    }
    fetchBusiness();
    fetchLocations();
  }, [businessId]);

  const fetchBusiness = async () => {
    setLoading(true);
    try {
      const data = await MerchantPortalAPI.getBusiness(businessId);
      setBusiness(data);
      setFormData({
        businessName: data.businessName || '',
        businessType: data.businessType || '',
        description: data.description || '',
        businessEmail: data.businessEmail || '',
        businessPhone: data.businessPhone || '',
        website: data.website || '',
        countryId: data.countryId || '',
        cityId: data.cityId || '',
        address: data.address || '',
      });
      if (data.countryId) {
        const citiesData = await LocationsAPI.getCities(data.countryId);
        setCities(citiesData || []);
      }
    } catch (error: any) {
      console.error('Failed to fetch business:', error);
      toast.error(error?.response?.data?.message || error?.message || 'Failed to load business');
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
    setFormData({ ...formData, countryId, cityId: '' });
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

  const handleSave = async () => {
    setSaving(true);
    try {
      await MerchantPortalAPI.updateBusiness(businessId, {
        businessName: formData.businessName,
        businessType: formData.businessType,
        description: formData.description || undefined,
        businessEmail: formData.businessEmail || undefined,
        businessPhone: formData.businessPhone || undefined,
        website: formData.website || undefined,
        countryId: formData.countryId || undefined,
        cityId: formData.cityId || undefined,
        address: formData.address || undefined,
      });
      toast.success('Business updated successfully');
      setEditMode(false);
      fetchBusiness();
    } catch (error: any) {
      console.error('Failed to update business:', error);
      toast.error(error?.response?.data?.message || error?.message || 'Failed to update business');
    } finally {
      setSaving(false);
    }
  };

  if (loading) {
    return <PageSkeleton />;
  }

  if (!business) {
    return (
      <div className="space-y-6">
        <Breadcrumbs items={[
          { label: 'Dashboard', href: '/dashboard/my-dashboard' },
          { label: 'My Businesses', href: '/dashboard/my-businesses' },
          { label: 'Business Details' }
        ]} />
        <div className="text-center py-12">
          <p className="text-gray-600">Business not found</p>
        </div>
      </div>
    );
  }

  return (
    <div className="space-y-6">
      <Breadcrumbs items={[
        { label: 'Dashboard', href: '/dashboard/my-dashboard' },
        { label: 'My Businesses', href: '/dashboard/my-businesses' },
        { label: business.businessName }
      ]} />

      {/* Header */}
      <div className="flex items-center justify-between flex-wrap gap-4">
        <div className="flex items-center gap-4">
          <Button
            variant="ghost"
            size="sm"
            icon={faArrowLeft}
            onClick={() => router.push('/dashboard/my-businesses')}
          >
            Back
          </Button>
          <div>
            <h1 className="text-2xl font-bold text-gray-900">{business.businessName}</h1>
            <p className="text-gray-600 mt-1">{business.businessType || 'N/A'}</p>
          </div>
        </div>
        <div className="flex items-center gap-2">
          {!editMode ? (
            <Button
              variant="primary"
              size="sm"
              icon={faEdit}
              onClick={() => setEditMode(true)}
            >
              Edit Business
            </Button>
          ) : (
            <>
              <Button
                variant="ghost"
                size="sm"
                onClick={() => {
                  setEditMode(false);
                  if (business) {
                    setFormData({
                      businessName: business.businessName || '',
                      businessType: business.businessType || '',
                      description: business.description || '',
                      businessEmail: business.businessEmail || '',
                      businessPhone: business.businessPhone || '',
                      website: business.website || '',
                      countryId: business.countryId || '',
                      cityId: business.cityId || '',
                      address: business.address || '',
                    });
                  }
                }}
              >
                Cancel
              </Button>
              <Button
                variant="primary"
                size="sm"
                onClick={handleSave}
                loading={saving}
              >
                Save Changes
              </Button>
            </>
          )}
        </div>
      </div>

      {/* Business Info */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        {/* Left Column */}
        <div className="space-y-6">
          <div className="bg-white border border-gray-200 rounded-sm p-6">
            <h2 className="text-lg font-semibold text-gray-900 mb-4">Business Information</h2>
            {editMode ? (
              <div className="space-y-4">
                <Input
                  label="Business Name"
                  value={formData.businessName}
                  onChange={(e) => setFormData({ ...formData, businessName: e.target.value })}
                  required
                />
                <Select
                  label="Business Type"
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
                />
                <Textarea
                  label="Description"
                  value={formData.description}
                  onChange={(e) => setFormData({ ...formData, description: e.target.value })}
                  rows={4}
                />
              </div>
            ) : (
              <div className="space-y-3">
                <div>
                  <p className="text-sm text-gray-600">Business Name</p>
                  <p className="text-gray-900 font-medium">{business.businessName}</p>
                </div>
                <div>
                  <p className="text-sm text-gray-600">Business Type</p>
                  <p className="text-gray-900 font-medium">{business.businessType || 'N/A'}</p>
                </div>
                {business.description && (
                  <div>
                    <p className="text-sm text-gray-600">Description</p>
                    <p className="text-gray-900">{business.description}</p>
                  </div>
                )}
              </div>
            )}
          </div>

          <div className="bg-white border border-gray-200 rounded-sm p-6">
            <h2 className="text-lg font-semibold text-gray-900 mb-4">Contact Information</h2>
            {editMode ? (
              <div className="space-y-4">
                <Input
                  label="Business Email"
                  value={formData.businessEmail}
                  onChange={(e) => setFormData({ ...formData, businessEmail: e.target.value })}
                  type="email"
                />
                <Input
                  label="Business Phone"
                  value={formData.businessPhone}
                  onChange={(e) => setFormData({ ...formData, businessPhone: e.target.value })}
                />
                <Input
                  label="Website"
                  value={formData.website}
                  onChange={(e) => setFormData({ ...formData, website: e.target.value })}
                />
              </div>
            ) : (
              <div className="space-y-3">
                {business.businessEmail && (
                  <div>
                    <p className="text-sm text-gray-600">Email</p>
                    <p className="text-gray-900">{business.businessEmail}</p>
                  </div>
                )}
                {business.businessPhone && (
                  <div>
                    <p className="text-sm text-gray-600">Phone</p>
                    <p className="text-gray-900">{business.businessPhone}</p>
                  </div>
                )}
                {business.website && (
                  <div>
                    <p className="text-sm text-gray-600">Website</p>
                    <a href={business.website} target="_blank" rel="noopener noreferrer" className="text-[#0e1a30] hover:underline">
                      {business.website}
                    </a>
                  </div>
                )}
              </div>
            )}
          </div>
        </div>

        {/* Right Column */}
        <div className="space-y-6">
          <div className="bg-white border border-gray-200 rounded-sm p-6">
            <h2 className="text-lg font-semibold text-gray-900 mb-4">Status & Verification</h2>
            <div className="space-y-3">
              <div>
                <p className="text-sm text-gray-600">Registration Status</p>
                <div className="mt-1">
                  <StatusBadge status={business.registrationStatus === 'approved' ? 'active' : business.registrationStatus === 'pending' ? 'pending' : 'inactive'} />
                </div>
              </div>
              <div>
                <p className="text-sm text-gray-600">Verification</p>
                <p className="text-gray-900 font-medium">{business.isVerified ? 'Verified' : 'Not Verified'}</p>
              </div>
            </div>
          </div>

          <div className="bg-white border border-gray-200 rounded-sm p-6">
            <h2 className="text-lg font-semibold text-gray-900 mb-4">Location</h2>
            {editMode ? (
              <div className="space-y-4">
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
                />
              </div>
            ) : (
              <div className="space-y-3">
                {business.address && (
                  <div>
                    <p className="text-sm text-gray-600">Address</p>
                    <p className="text-gray-900">{business.address}</p>
                  </div>
                )}
              </div>
            )}
          </div>

          <div className="bg-white border border-gray-200 rounded-sm p-6">
            <h2 className="text-lg font-semibold text-gray-900 mb-4">Statistics</h2>
            <div className="space-y-3">
              <div>
                <p className="text-sm text-gray-600">Total Listings</p>
                <p className="text-2xl font-bold text-gray-900">{business._count?.listings || 0}</p>
              </div>
              <div>
                <p className="text-sm text-gray-600">Total Bookings</p>
                <p className="text-2xl font-bold text-gray-900">{business._count?.bookings || 0}</p>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}

