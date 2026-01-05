'use client';

import { useState, useEffect } from 'react';
import { useRouter, useSearchParams } from 'next/navigation';
import { MerchantPortalAPI, type Business } from '@/src/lib/api';
import { CategoriesAPI, LocationsAPI } from '@/src/lib/api';
import { toast } from '@/app/components/Toaster';
import { Button, Modal, Input, Select, Textarea, Breadcrumbs } from '@/app/components';
import PageSkeleton from '@/app/components/PageSkeleton';
import Icon, { faArrowLeft, faPlus } from '@/app/components/Icon';

export default function CreateListingPage() {
  const router = useRouter();
  const searchParams = useSearchParams();
  const businessId = searchParams.get('businessId') || '';
  const [business, setBusiness] = useState<Business | null>(null);
  const [loading, setLoading] = useState(true);
  const [creating, setCreating] = useState(false);
  const [categories, setCategories] = useState<any[]>([]);
  const [countries, setCountries] = useState<any[]>([]);
  const [cities, setCities] = useState<any[]>([]);
  const [formData, setFormData] = useState({
    name: '',
    description: '',
    shortDescription: '',
    type: '',
    categoryId: '',
    countryId: '',
    cityId: '',
    address: '',
    minPrice: '',
    maxPrice: '',
    priceUnit: '',
    contactPhone: '',
    contactEmail: '',
    website: '',
    status: 'draft' as const,
  });

  useEffect(() => {
    if (businessId) {
      fetchData();
    }
  }, [businessId]);

  const fetchData = async () => {
    setLoading(true);
    try {
      const [businessData, categoriesData, countriesData] = await Promise.all([
        MerchantPortalAPI.getBusiness(businessId),
        CategoriesAPI.listCategories({ flat: true }),
        LocationsAPI.getCountries(),
      ]);
      setBusiness(businessData);
      setCategories(categoriesData || []);
      setCountries(countriesData || []);
    } catch (error: any) {
      console.error('Failed to fetch data:', error);
      toast.error(error?.response?.data?.message || error?.message || 'Failed to load data');
    } finally {
      setLoading(false);
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

  const handleCreate = async () => {
    if (!formData.name || !businessId) {
      toast.error('Listing name is required');
      return;
    }

    setCreating(true);
    try {
      await MerchantPortalAPI.createListing(businessId, {
        name: formData.name,
        description: formData.description || undefined,
        shortDescription: formData.shortDescription || undefined,
        type: formData.type || undefined,
        categoryId: formData.categoryId || undefined,
        countryId: formData.countryId || undefined,
        cityId: formData.cityId || undefined,
        address: formData.address || undefined,
        minPrice: formData.minPrice ? parseFloat(formData.minPrice) : undefined,
        maxPrice: formData.maxPrice ? parseFloat(formData.maxPrice) : undefined,
        priceUnit: formData.priceUnit || undefined,
        contactPhone: formData.contactPhone || undefined,
        contactEmail: formData.contactEmail || undefined,
        website: formData.website || undefined,
        status: formData.status,
      });
      toast.success('Listing created successfully');
      router.push(`/dashboard/my-listings?businessId=${businessId}`);
    } catch (error: any) {
      console.error('Failed to create listing:', error);
      toast.error(error?.response?.data?.message || error?.message || 'Failed to create listing');
    } finally {
      setCreating(false);
    }
  };

  if (loading) {
    return <PageSkeleton />;
  }

  if (!businessId || !business) {
    return (
      <div className="space-y-6">
        <Breadcrumbs items={[
          { label: 'Dashboard', href: '/dashboard/my-dashboard' },
          { label: 'My Listings', href: '/dashboard/my-listings' },
          { label: 'Create Listing' }
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
        { label: 'My Listings', href: '/dashboard/my-listings' },
        { label: 'Create Listing' }
      ]} />

      {/* Header */}
      <div className="flex items-center justify-between flex-wrap gap-4">
        <div className="flex items-center gap-4">
          <Button
            variant="ghost"
            size="sm"
            icon={faArrowLeft}
            onClick={() => router.push(`/dashboard/my-listings?businessId=${businessId}`)}
          >
            Back
          </Button>
          <div>
            <h1 className="text-2xl font-bold text-gray-900">Create New Listing</h1>
            <p className="text-gray-600 mt-1">{business.businessName}</p>
          </div>
        </div>
      </div>

      {/* Form */}
      <div className="bg-white border border-gray-200 rounded-sm p-6">
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
          {/* Left Column */}
          <div className="space-y-4">
            <Input
              label="Listing Name *"
              value={formData.name}
              onChange={(e) => setFormData({ ...formData, name: e.target.value })}
              placeholder="Enter listing name"
              required
            />
            <Input
              label="Short Description"
              value={formData.shortDescription}
              onChange={(e) => setFormData({ ...formData, shortDescription: e.target.value })}
              placeholder="Brief description"
            />
            <Textarea
              label="Description"
              value={formData.description}
              onChange={(e) => setFormData({ ...formData, description: e.target.value })}
              rows={6}
              placeholder="Full description"
            />
            <Select
              label="Type"
              value={formData.type}
              onChange={(e) => setFormData({ ...formData, type: e.target.value })}
              options={[
                { value: '', label: 'Select type' },
                { value: 'hotel', label: 'Hotel' },
                { value: 'restaurant', label: 'Restaurant' },
                { value: 'tour', label: 'Tour' },
                { value: 'attraction', label: 'Attraction' },
                { value: 'bar', label: 'Bar' },
                { value: 'club', label: 'Club' },
                { value: 'lounge', label: 'Lounge' },
                { value: 'cafe', label: 'Cafe' },
                { value: 'fast_food', label: 'Fast Food' },
                { value: 'mall', label: 'Mall' },
                { value: 'market', label: 'Market' },
                { value: 'boutique', label: 'Boutique' },
              ]}
            />
            <Select
              label="Category"
              value={formData.categoryId}
              onChange={(e) => setFormData({ ...formData, categoryId: e.target.value })}
              options={[
                { value: '', label: 'Select category' },
                ...categories.map(c => ({ value: c.id, label: c.name })),
              ]}
            />
          </div>

          {/* Right Column */}
          <div className="space-y-4">
            <div className="grid grid-cols-2 gap-4">
              <Input
                label="Min Price"
                value={formData.minPrice}
                onChange={(e) => setFormData({ ...formData, minPrice: e.target.value })}
                type="number"
                placeholder="0"
              />
              <Input
                label="Max Price"
                value={formData.maxPrice}
                onChange={(e) => setFormData({ ...formData, maxPrice: e.target.value })}
                type="number"
                placeholder="0"
              />
            </div>
            <Select
              label="Price Unit"
              value={formData.priceUnit}
              onChange={(e) => setFormData({ ...formData, priceUnit: e.target.value })}
              options={[
                { value: '', label: 'Select unit' },
                { value: 'per_night', label: 'Per Night' },
                { value: 'per_person', label: 'Per Person' },
                { value: 'per_meal', label: 'Per Meal' },
                { value: 'per_tour', label: 'Per Tour' },
                { value: 'per_event', label: 'Per Event' },
                { value: 'per_hour', label: 'Per Hour' },
                { value: 'per_table', label: 'Per Table' },
              ]}
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
              placeholder="Enter address"
            />
            <Input
              label="Contact Phone"
              value={formData.contactPhone}
              onChange={(e) => setFormData({ ...formData, contactPhone: e.target.value })}
              placeholder="Enter phone number"
            />
            <Input
              label="Contact Email"
              value={formData.contactEmail}
              onChange={(e) => setFormData({ ...formData, contactEmail: e.target.value })}
              type="email"
              placeholder="Enter email"
            />
            <Input
              label="Website"
              value={formData.website}
              onChange={(e) => setFormData({ ...formData, website: e.target.value })}
              placeholder="https://example.com"
            />
          </div>
        </div>

        <div className="flex justify-end gap-3 mt-6 pt-6 border-t border-gray-200">
          <Button
            variant="ghost"
            onClick={() => router.push(`/dashboard/my-listings?businessId=${businessId}`)}
          >
            Cancel
          </Button>
          <Button
            variant="primary"
            onClick={handleCreate}
            loading={creating}
            icon={faPlus}
          >
            Create Listing
          </Button>
        </div>
      </div>
    </div>
  );
}

