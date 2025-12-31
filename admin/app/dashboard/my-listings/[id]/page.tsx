'use client';

import { useState, useEffect } from 'react';
import { useRouter, useParams, useSearchParams } from 'next/navigation';
import { MerchantPortalAPI, type MerchantListing, type Business } from '@/src/lib/api';
import { toast } from '@/app/components/Toaster';
import { Button, Modal, Input, Select, Textarea, Breadcrumbs, StatusBadge } from '@/app/components';
import PageSkeleton from '@/app/components/PageSkeleton';
import Icon, { faArrowLeft, faEdit, faBox, faCheckCircle } from '@/app/components/Icon';
import { CategoriesAPI } from '@/src/lib/api';

export default function ListingDetailPage() {
  const router = useRouter();
  const params = useParams();
  const searchParams = useSearchParams();
  const listingId = params.id as string;
  const businessId = searchParams.get('businessId') || '';
  const [listing, setListing] = useState<MerchantListing | null>(null);
  const [business, setBusiness] = useState<Business | null>(null);
  const [loading, setLoading] = useState(true);
  const [editMode, setEditMode] = useState(false);
  const [saving, setSaving] = useState(false);
  const [submitting, setSubmitting] = useState(false);
  const [categories, setCategories] = useState<any[]>([]);
  const [formData, setFormData] = useState({
    name: '',
    description: '',
    shortDescription: '',
    type: '',
    categoryId: '',
    minPrice: '',
    maxPrice: '',
    priceUnit: '',
    contactPhone: '',
    contactEmail: '',
    website: '',
    address: '',
  });

  useEffect(() => {
    if (searchParams.get('edit') === 'true') {
      setEditMode(true);
    }
    if (businessId) {
      fetchListing();
      fetchBusiness();
      fetchCategories();
    }
  }, [businessId, listingId]);

  const fetchListing = async () => {
    if (!businessId) return;
    setLoading(true);
    try {
      const data = await MerchantPortalAPI.getListing(businessId, listingId);
      setListing(data);
      setFormData({
        name: data.name || '',
        description: data.description || '',
        shortDescription: data.shortDescription || '',
        type: data.type || '',
        categoryId: data.categoryId || '',
        minPrice: data.minPrice?.toString() || '',
        maxPrice: data.maxPrice?.toString() || '',
        priceUnit: data.priceUnit || '',
        contactPhone: data.contactPhone || '',
        contactEmail: data.contactEmail || '',
        website: data.website || '',
        address: data.address || '',
      });
    } catch (error: any) {
      console.error('Failed to fetch listing:', error);
      toast.error(error?.response?.data?.message || error?.message || 'Failed to load listing');
    } finally {
      setLoading(false);
    }
  };

  const fetchBusiness = async () => {
    if (!businessId) return;
    try {
      const data = await MerchantPortalAPI.getBusiness(businessId);
      setBusiness(data);
    } catch (error) {
      console.error('Failed to fetch business:', error);
    }
  };

  const fetchCategories = async () => {
    try {
      const data = await CategoriesAPI.listCategories();
      setCategories(data || []);
    } catch (error) {
      console.error('Failed to fetch categories:', error);
    }
  };

  const handleSave = async () => {
    if (!businessId) return;
    setSaving(true);
    try {
      await MerchantPortalAPI.updateListing(businessId, listingId, {
        name: formData.name,
        description: formData.description || undefined,
        shortDescription: formData.shortDescription || undefined,
        type: formData.type || undefined,
        categoryId: formData.categoryId || undefined,
        minPrice: formData.minPrice ? parseFloat(formData.minPrice) : undefined,
        maxPrice: formData.maxPrice ? parseFloat(formData.maxPrice) : undefined,
        priceUnit: formData.priceUnit || undefined,
        contactPhone: formData.contactPhone || undefined,
        contactEmail: formData.contactEmail || undefined,
        website: formData.website || undefined,
        address: formData.address || undefined,
      });
      toast.success('Listing updated successfully');
      setEditMode(false);
      fetchListing();
    } catch (error: any) {
      console.error('Failed to update listing:', error);
      toast.error(error?.response?.data?.message || error?.message || 'Failed to update listing');
    } finally {
      setSaving(false);
    }
  };

  const handleSubmit = async () => {
    if (!businessId) return;
    if (listing?.status !== 'draft') {
      toast.error('Only draft listings can be submitted for review');
      return;
    }
    setSubmitting(true);
    try {
      await MerchantPortalAPI.submitListing(businessId, listingId);
      toast.success('Listing submitted for review');
      fetchListing();
    } catch (error: any) {
      console.error('Failed to submit listing:', error);
      toast.error(error?.response?.data?.message || error?.message || 'Failed to submit listing');
    } finally {
      setSubmitting(false);
    }
  };

  if (loading) {
    return <PageSkeleton />;
  }

  if (!listing || !businessId) {
    return (
      <div className="space-y-6">
        <Breadcrumbs items={[
          { label: 'Dashboard', href: '/dashboard/my-dashboard' },
          { label: 'My Listings', href: '/dashboard/my-listings' },
          { label: 'Listing Details' }
        ]} />
        <div className="text-center py-12">
          <p className="text-gray-600">Listing not found</p>
        </div>
      </div>
    );
  }

  return (
    <div className="space-y-6">
      <Breadcrumbs items={[
        { label: 'Dashboard', href: '/dashboard/my-dashboard' },
        { label: 'My Listings', href: '/dashboard/my-listings' },
        { label: listing.name }
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
            <h1 className="text-2xl font-bold text-gray-900">{listing.name}</h1>
            <p className="text-gray-600 mt-1">{business?.businessName || 'Business'}</p>
          </div>
        </div>
        <div className="flex items-center gap-2">
          {listing.status === 'draft' && (
            <Button
              variant="secondary"
              size="sm"
              icon={faCheckCircle}
              onClick={handleSubmit}
              loading={submitting}
            >
              Submit for Review
            </Button>
          )}
          {!editMode ? (
            <Button
              variant="primary"
              size="sm"
              icon={faEdit}
              onClick={() => setEditMode(true)}
            >
              Edit Listing
            </Button>
          ) : (
            <>
              <Button
                variant="ghost"
                size="sm"
                onClick={() => {
                  setEditMode(false);
                  if (listing) {
                    setFormData({
                      name: listing.name || '',
                      description: listing.description || '',
                      shortDescription: listing.shortDescription || '',
                      type: listing.type || '',
                      categoryId: listing.categoryId || '',
                      minPrice: listing.minPrice?.toString() || '',
                      maxPrice: listing.maxPrice?.toString() || '',
                      priceUnit: listing.priceUnit || '',
                      contactPhone: listing.contactPhone || '',
                      contactEmail: listing.contactEmail || '',
                      website: listing.website || '',
                      address: listing.address || '',
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

      {/* Listing Info */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        {/* Left Column */}
        <div className="space-y-6">
          <div className="bg-white border border-gray-200 rounded-sm p-6">
            <h2 className="text-lg font-semibold text-gray-900 mb-4">Listing Information</h2>
            {editMode ? (
              <div className="space-y-4">
                <Input
                  label="Name"
                  value={formData.name}
                  onChange={(e) => setFormData({ ...formData, name: e.target.value })}
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
            ) : (
              <div className="space-y-3">
                <div>
                  <p className="text-sm text-gray-600">Name</p>
                  <p className="text-gray-900 font-medium">{listing.name}</p>
                </div>
                {listing.shortDescription && (
                  <div>
                    <p className="text-sm text-gray-600">Short Description</p>
                    <p className="text-gray-900">{listing.shortDescription}</p>
                  </div>
                )}
                {listing.description && (
                  <div>
                    <p className="text-sm text-gray-600">Description</p>
                    <p className="text-gray-900">{listing.description}</p>
                  </div>
                )}
                <div>
                  <p className="text-sm text-gray-600">Type</p>
                  <p className="text-gray-900 capitalize">{listing.type?.replace('_', ' ') || 'N/A'}</p>
                </div>
              </div>
            )}
          </div>

          <div className="bg-white border border-gray-200 rounded-sm p-6">
            <h2 className="text-lg font-semibold text-gray-900 mb-4">Pricing</h2>
            {editMode ? (
              <div className="space-y-4">
                <Input
                  label="Min Price"
                  value={formData.minPrice}
                  onChange={(e) => setFormData({ ...formData, minPrice: e.target.value })}
                  type="number"
                />
                <Input
                  label="Max Price"
                  value={formData.maxPrice}
                  onChange={(e) => setFormData({ ...formData, maxPrice: e.target.value })}
                  type="number"
                />
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
              </div>
            ) : (
              <div className="space-y-3">
                {listing.minPrice && (
                  <div>
                    <p className="text-sm text-gray-600">Price Range</p>
                    <p className="text-gray-900 font-medium">
                      {listing.minPrice.toLocaleString()}
                      {listing.maxPrice && ` - ${listing.maxPrice.toLocaleString()}`}
                      {listing.priceUnit && ` ${listing.priceUnit.replace('_', ' ')}`}
                    </p>
                  </div>
                )}
              </div>
            )}
          </div>
        </div>

        {/* Right Column */}
        <div className="space-y-6">
          <div className="bg-white border border-gray-200 rounded-sm p-6">
            <h2 className="text-lg font-semibold text-gray-900 mb-4">Status</h2>
            <div className="space-y-3">
              <div>
                <p className="text-sm text-gray-600">Status</p>
                <div className="mt-1">
                  <StatusBadge status={listing.status === 'active' ? 'active' : listing.status === 'pending_review' ? 'pending' : listing.status === 'suspended' ? 'inactive' : 'pending'} />
                </div>
              </div>
              {listing.isFeatured && (
                <div>
                  <p className="text-sm text-gray-600">Featured</p>
                  <p className="text-gray-900 font-medium">Yes</p>
                </div>
              )}
              {listing.isVerified && (
                <div>
                  <p className="text-sm text-gray-600">Verified</p>
                  <p className="text-gray-900 font-medium">Yes</p>
                </div>
              )}
            </div>
          </div>

          <div className="bg-white border border-gray-200 rounded-sm p-6">
            <h2 className="text-lg font-semibold text-gray-900 mb-4">Contact Information</h2>
            {editMode ? (
              <div className="space-y-4">
                <Input
                  label="Contact Phone"
                  value={formData.contactPhone}
                  onChange={(e) => setFormData({ ...formData, contactPhone: e.target.value })}
                />
                <Input
                  label="Contact Email"
                  value={formData.contactEmail}
                  onChange={(e) => setFormData({ ...formData, contactEmail: e.target.value })}
                  type="email"
                />
                <Input
                  label="Website"
                  value={formData.website}
                  onChange={(e) => setFormData({ ...formData, website: e.target.value })}
                />
                <Input
                  label="Address"
                  value={formData.address}
                  onChange={(e) => setFormData({ ...formData, address: e.target.value })}
                />
              </div>
            ) : (
              <div className="space-y-3">
                {listing.contactPhone && (
                  <div>
                    <p className="text-sm text-gray-600">Phone</p>
                    <p className="text-gray-900">{listing.contactPhone}</p>
                  </div>
                )}
                {listing.contactEmail && (
                  <div>
                    <p className="text-sm text-gray-600">Email</p>
                    <p className="text-gray-900">{listing.contactEmail}</p>
                  </div>
                )}
                {listing.website && (
                  <div>
                    <p className="text-sm text-gray-600">Website</p>
                    <a href={listing.website} target="_blank" rel="noopener noreferrer" className="text-[#0e1a30] hover:underline">
                      {listing.website}
                    </a>
                  </div>
                )}
                {listing.address && (
                  <div>
                    <p className="text-sm text-gray-600">Address</p>
                    <p className="text-gray-900">{listing.address}</p>
                  </div>
                )}
              </div>
            )}
          </div>
        </div>
      </div>
    </div>
  );
}

