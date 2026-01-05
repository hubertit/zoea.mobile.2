'use client';

import { useState, useEffect } from 'react';
import { useRouter, useParams, useSearchParams } from 'next/navigation';
import { MerchantPortalAPI, type MerchantListing, type Business, MediaAPI } from '@/src/lib/api';
import { toast } from '@/app/components/Toaster';
import { Button, Modal, Input, Select, SearchableSelect, Textarea, Breadcrumbs, StatusBadge, ConfirmDialog } from '@/app/components';
import PageSkeleton from '@/app/components/PageSkeleton';
import Icon, { faArrowLeft, faEdit, faBox, faCheckCircle, faImage, faPlus, faTrash, faCalendar } from '@/app/components/Icon';
import { faBed, faUtensils } from '@fortawesome/free-solid-svg-icons';
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
  const [images, setImages] = useState<any[]>([]);
  const [roomTypes, setRoomTypes] = useState<any[]>([]);
  const [tables, setTables] = useState<any[]>([]);
  const [showImageModal, setShowImageModal] = useState(false);
  const [showRoomModal, setShowRoomModal] = useState(false);
  const [showTableModal, setShowTableModal] = useState(false);
  const [editingRoom, setEditingRoom] = useState<any>(null);
  const [editingTable, setEditingTable] = useState<any>(null);
  const [deletingImageId, setDeletingImageId] = useState<string | null>(null);
  const [deletingRoomId, setDeletingRoomId] = useState<string | null>(null);
  const [deletingTableId, setDeletingTableId] = useState<string | null>(null);
  const [uploadingImage, setUploadingImage] = useState(false);
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
      setImages(data.images || []);
      setRoomTypes(data.roomTypes || []);
      setTables(data.restaurantTables || []);
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
      const data = await CategoriesAPI.listCategories({ flat: true });
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

  // Image Management
  const handleImageUpload = async (file: File) => {
    if (!businessId) return;
    setUploadingImage(true);
    try {
      const media = await MediaAPI.upload({ file, category: 'listing' });
      await MerchantPortalAPI.addListingImage(businessId, listingId, { mediaId: media.id });
      toast.success('Image added successfully');
      fetchListing();
      setShowImageModal(false);
    } catch (error: any) {
      console.error('Failed to upload image:', error);
      toast.error(error?.response?.data?.message || error?.message || 'Failed to upload image');
    } finally {
      setUploadingImage(false);
    }
  };

  const handleRemoveImage = async (imageId: string) => {
    if (!businessId) return;
    try {
      await MerchantPortalAPI.removeListingImage(businessId, listingId, imageId);
      toast.success('Image removed successfully');
      fetchListing();
      setDeletingImageId(null);
    } catch (error: any) {
      console.error('Failed to remove image:', error);
      toast.error(error?.response?.data?.message || error?.message || 'Failed to remove image');
    }
  };

  // Room Types Management
  const fetchRoomTypes = async () => {
    if (!businessId || listing?.type !== 'hotel') return;
    try {
      const data = await MerchantPortalAPI.getRoomTypes(businessId, listingId);
      setRoomTypes(data);
    } catch (error: any) {
      console.error('Failed to fetch room types:', error);
    }
  };

  const handleSaveRoom = async (roomData: any) => {
    if (!businessId) return;
    try {
      if (editingRoom) {
        await MerchantPortalAPI.updateRoomType(businessId, editingRoom.id, roomData);
        toast.success('Room type updated successfully');
      } else {
        await MerchantPortalAPI.createRoomType(businessId, listingId, roomData);
        toast.success('Room type created successfully');
      }
      fetchRoomTypes();
      setShowRoomModal(false);
      setEditingRoom(null);
    } catch (error: any) {
      console.error('Failed to save room type:', error);
      toast.error(error?.response?.data?.message || error?.message || 'Failed to save room type');
    }
  };

  const handleDeleteRoom = async (roomTypeId: string) => {
    if (!businessId) return;
    try {
      await MerchantPortalAPI.deleteRoomType(businessId, roomTypeId);
      toast.success('Room type deleted successfully');
      fetchRoomTypes();
      setDeletingRoomId(null);
    } catch (error: any) {
      console.error('Failed to delete room type:', error);
      toast.error(error?.response?.data?.message || error?.message || 'Failed to delete room type');
    }
  };

  // Tables Management
  const fetchTables = async () => {
    if (!businessId || listing?.type !== 'restaurant') return;
    try {
      const data = await MerchantPortalAPI.getTables(businessId, listingId);
      setTables(data);
    } catch (error: any) {
      console.error('Failed to fetch tables:', error);
    }
  };

  const handleSaveTable = async (tableData: any) => {
    if (!businessId) return;
    try {
      if (editingTable) {
        await MerchantPortalAPI.updateTable(businessId, editingTable.id, tableData);
        toast.success('Table updated successfully');
      } else {
        await MerchantPortalAPI.createTable(businessId, listingId, tableData);
        toast.success('Table created successfully');
      }
      fetchTables();
      setShowTableModal(false);
      setEditingTable(null);
    } catch (error: any) {
      console.error('Failed to save table:', error);
      toast.error(error?.response?.data?.message || error?.message || 'Failed to save table');
    }
  };

  const handleDeleteTable = async (tableId: string) => {
    if (!businessId) return;
    try {
      await MerchantPortalAPI.deleteTable(businessId, tableId);
      toast.success('Table deleted successfully');
      fetchTables();
      setDeletingTableId(null);
    } catch (error: any) {
      console.error('Failed to delete table:', error);
      toast.error(error?.response?.data?.message || error?.message || 'Failed to delete table');
    }
  };

  useEffect(() => {
    if (listing?.type === 'hotel') {
      fetchRoomTypes();
    } else if (listing?.type === 'restaurant') {
      fetchTables();
    }
  }, [listing?.type, businessId, listingId]);

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
                <SearchableSelect
                  label="Category"
                  value={formData.categoryId}
                  onChange={(value) => setFormData({ ...formData, categoryId: value })}
                  options={categories.map(c => ({ 
                    value: c.id, 
                    label: c.name,
                    group: c.parent?.name || 'Main Category'
                  }))}
                  placeholder="Select category"
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

      {/* Images Section */}
      <div className="bg-white border border-gray-200 rounded-sm p-6">
        <div className="flex items-center justify-between mb-4">
          <h2 className="text-lg font-semibold text-gray-900">Images</h2>
          <Button
            variant="primary"
            size="sm"
            icon={faPlus}
            onClick={() => setShowImageModal(true)}
          >
            Add Image
          </Button>
        </div>
        {images.length > 0 ? (
          <div className="grid grid-cols-2 md:grid-cols-4 lg:grid-cols-6 gap-4">
            {images.map((image) => (
              <div key={image.id} className="relative group">
                <img
                  src={image.media?.thumbnailUrl || image.media?.url || ''}
                  alt="Listing"
                  className="w-full h-32 object-cover rounded-sm"
                />
                {image.isPrimary && (
                  <span className="absolute top-2 left-2 bg-[#0e1a30] text-white text-xs px-2 py-1 rounded">
                    Primary
                  </span>
                )}
                <button
                  onClick={() => setDeletingImageId(image.id)}
                  className="absolute top-2 right-2 bg-red-500 text-white p-1 rounded opacity-0 group-hover:opacity-100 transition-opacity"
                >
                  <Icon icon={faTrash} className="w-3 h-3" />
                </button>
              </div>
            ))}
          </div>
        ) : (
          <p className="text-gray-500 text-center py-8">No images uploaded yet</p>
        )}
      </div>

      {/* Room Types Section (Hotels) */}
      {listing?.type === 'hotel' && (
        <div className="bg-white border border-gray-200 rounded-sm p-6">
          <div className="flex items-center justify-between mb-4">
            <h2 className="text-lg font-semibold text-gray-900 flex items-center gap-2">
              <Icon icon={faBed as any} /> Room Types
            </h2>
            <Button
              variant="primary"
              size="sm"
              icon={faPlus}
              onClick={() => {
                setEditingRoom(null);
                setShowRoomModal(true);
              }}
            >
              Add Room Type
            </Button>
          </div>
          {roomTypes.length > 0 ? (
            <div className="space-y-4">
              {roomTypes.map((room) => (
                <div key={room.id} className="border border-gray-200 rounded-sm p-4 flex items-center justify-between">
                  <div>
                    <h3 className="font-semibold text-gray-900">{room.name}</h3>
                    {room.description && <p className="text-sm text-gray-600 mt-1">{room.description}</p>}
                    <div className="flex gap-4 mt-2 text-sm text-gray-600">
                      <span>Max Occupancy: {room.maxOccupancy}</span>
                      <span>Price: {room.basePrice.toLocaleString()} RWF/night</span>
                    </div>
                  </div>
                  <div className="flex gap-2">
                    <Button
                      variant="ghost"
                      size="sm"
                      icon={faEdit}
                      onClick={() => {
                        setEditingRoom(room);
                        setShowRoomModal(true);
                      }}
                    >
                      Edit
                    </Button>
                    <Button
                      variant="ghost"
                      size="sm"
                      icon={faTrash}
                      onClick={() => setDeletingRoomId(room.id)}
                    >
                      Delete
                    </Button>
                  </div>
                </div>
              ))}
            </div>
          ) : (
            <p className="text-gray-500 text-center py-8">No room types added yet</p>
          )}
        </div>
      )}

      {/* Shop Section */}
      <div className="bg-white border border-gray-200 rounded-sm p-6">
        <div className="flex items-center justify-between mb-4">
          <h2 className="text-lg font-semibold text-gray-900 flex items-center gap-2">
            <Icon icon={faBox} /> Shop Management
          </h2>
          <div className="flex items-center gap-2">
            <span className="text-sm text-gray-600">
              Shop Mode: {listing.isShopEnabled ? (
                <StatusBadge status="active" />
              ) : (
                <StatusBadge status="inactive" />
              )}
            </span>
            {!editMode && (
              <Button
                variant="ghost"
                size="sm"
                icon={faEdit}
                onClick={() => {
                  setEditMode(true);
                  // Enable shop mode in form data if not already set
                  if (!listing.isShopEnabled) {
                    // This will be handled in the shop settings section
                  }
                }}
              >
                Configure Shop
              </Button>
            )}
          </div>
        </div>
        {listing.isShopEnabled ? (
          <>
            <div className="grid grid-cols-1 md:grid-cols-3 gap-4 mb-4">
              <Button
                variant="ghost"
                onClick={() => router.push(`/dashboard/my-listings/${listingId}/products?businessId=${businessId}`)}
                className="h-auto p-4 flex flex-col items-start"
              >
                <div className="flex items-center gap-2 mb-2">
                  <Icon icon={faBox} />
                  <span className="font-semibold">Products</span>
                </div>
                <p className="text-sm text-gray-600 text-left">Manage products and inventory</p>
              </Button>
              <Button
                variant="ghost"
                onClick={() => router.push(`/dashboard/my-listings/${listingId}/services?businessId=${businessId}`)}
                className="h-auto p-4 flex flex-col items-start"
              >
                <div className="flex items-center gap-2 mb-2">
                  <Icon icon={faCalendar} />
                  <span className="font-semibold">Services</span>
                </div>
                <p className="text-sm text-gray-600 text-left">Manage bookable services</p>
              </Button>
              <Button
                variant="ghost"
                onClick={() => router.push(`/dashboard/my-listings/${listingId}/menus?businessId=${businessId}`)}
                className="h-auto p-4 flex flex-col items-start"
              >
                <div className="flex items-center gap-2 mb-2">
                  <Icon icon={faUtensils as any} />
                  <span className="font-semibold">Menus</span>
                </div>
                <p className="text-sm text-gray-600 text-left">Manage menus and menu items</p>
              </Button>
            </div>
            <div className="mt-4">
              <Button
                variant="ghost"
                onClick={() => router.push(`/dashboard/my-orders?businessId=${businessId}&listingId=${listingId}`)}
                className="w-full"
              >
                View All Orders for This Listing
              </Button>
            </div>
          </>
        ) : (
          <div className="text-center py-8">
            <p className="text-gray-600 mb-4">Shop mode is disabled for this listing</p>
            <Button
              variant="primary"
              onClick={async () => {
                if (!businessId) return;
                try {
                  await MerchantPortalAPI.updateShopSettings(businessId, listingId, {
                    isShopEnabled: true,
                    shopSettings: {
                      acceptsOnlineOrders: true,
                      deliveryEnabled: false,
                      pickupEnabled: true,
                      dineInEnabled: false,
                    },
                  });
                  toast.success('Shop mode enabled successfully');
                  fetchListing();
                } catch (error: any) {
                  console.error('Failed to enable shop mode:', error);
                  toast.error(error?.response?.data?.message || error?.message || 'Failed to enable shop mode');
                }
              }}
            >
              Enable Shop Mode
            </Button>
          </div>
        )}
      </div>

      {/* Tables Section (Restaurants) */}
      {listing?.type === 'restaurant' && (
        <div className="bg-white border border-gray-200 rounded-sm p-6">
          <div className="flex items-center justify-between mb-4">
            <h2 className="text-lg font-semibold text-gray-900 flex items-center gap-2">
              <Icon icon={faUtensils as any} /> Tables
            </h2>
            <Button
              variant="primary"
              size="sm"
              icon={faPlus}
              onClick={() => {
                setEditingTable(null);
                setShowTableModal(true);
              }}
            >
              Add Table
            </Button>
          </div>
          {tables.length > 0 ? (
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
              {tables.map((table) => (
                <div key={table.id} className="border border-gray-200 rounded-sm p-4">
                  <div className="flex items-center justify-between mb-2">
                    <h3 className="font-semibold text-gray-900">Table {table.tableNumber}</h3>
                    <StatusBadge status={table.isAvailable ? 'active' : 'inactive'} />
                  </div>
                  <div className="text-sm text-gray-600 space-y-1">
                    <p>Capacity: {table.capacity} guests</p>
                    {table.location && <p>Location: {table.location}</p>}
                  </div>
                  <div className="flex gap-2 mt-3">
                    <Button
                      variant="ghost"
                      size="sm"
                      icon={faEdit}
                      onClick={() => {
                        setEditingTable(table);
                        setShowTableModal(true);
                      }}
                    >
                      Edit
                    </Button>
                    <Button
                      variant="ghost"
                      size="sm"
                      icon={faTrash}
                      onClick={() => setDeletingTableId(table.id)}
                    >
                      Delete
                    </Button>
                  </div>
                </div>
              ))}
            </div>
          ) : (
            <p className="text-gray-500 text-center py-8">No tables added yet</p>
          )}
        </div>
      )}

      {/* Image Upload Modal */}
      <Modal
        isOpen={showImageModal}
        onClose={() => setShowImageModal(false)}
        title="Upload Image"
      >
        <div className="space-y-4">
          <input
            type="file"
            accept="image/*"
            onChange={(e) => {
              const file = e.target.files?.[0];
              if (file) {
                handleImageUpload(file);
              }
            }}
            className="w-full"
            disabled={uploadingImage}
          />
          {uploadingImage && <p className="text-sm text-gray-600">Uploading...</p>}
        </div>
      </Modal>

      {/* Room Type Modal */}
      <RoomTypeModal
        isOpen={showRoomModal}
        onClose={() => {
          setShowRoomModal(false);
          setEditingRoom(null);
        }}
        onSave={handleSaveRoom}
        room={editingRoom}
      />

      {/* Table Modal */}
      <TableModal
        isOpen={showTableModal}
        onClose={() => {
          setShowTableModal(false);
          setEditingTable(null);
        }}
        onSave={handleSaveTable}
        table={editingTable}
      />

      {/* Delete Confirmations */}
      <ConfirmDialog
        isOpen={deletingImageId !== null}
        onClose={() => setDeletingImageId(null)}
        onConfirm={() => deletingImageId && handleRemoveImage(deletingImageId)}
        title="Delete Image"
        message="Are you sure you want to remove this image?"
      />
      <ConfirmDialog
        isOpen={deletingRoomId !== null}
        onClose={() => setDeletingRoomId(null)}
        onConfirm={() => deletingRoomId && handleDeleteRoom(deletingRoomId)}
        title="Delete Room Type"
        message="Are you sure you want to delete this room type?"
      />
      <ConfirmDialog
        isOpen={deletingTableId !== null}
        onClose={() => setDeletingTableId(null)}
        onConfirm={() => deletingTableId && handleDeleteTable(deletingTableId)}
        title="Delete Table"
        message="Are you sure you want to delete this table?"
      />
    </div>
  );
}

// Room Type Modal Component
function RoomTypeModal({ isOpen, onClose, onSave, room }: any) {
  const [formData, setFormData] = useState({
    name: '',
    description: '',
    maxOccupancy: '',
    pricePerNight: '',
    amenities: '',
  });

  useEffect(() => {
    if (room) {
      setFormData({
        name: room.name || '',
        description: room.description || '',
        maxOccupancy: room.maxOccupancy?.toString() || '',
        pricePerNight: room.basePrice?.toString() || '',
        amenities: room.amenities?.join(', ') || '',
      });
    } else {
      setFormData({
        name: '',
        description: '',
        maxOccupancy: '',
        pricePerNight: '',
        amenities: '',
      });
    }
  }, [room, isOpen]);

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    onSave({
      name: formData.name,
      description: formData.description || undefined,
      maxOccupancy: parseInt(formData.maxOccupancy),
      pricePerNight: parseFloat(formData.pricePerNight),
      amenities: formData.amenities ? formData.amenities.split(',').map((a: string) => a.trim()).filter(Boolean) : undefined,
    });
  };

  return (
    <Modal isOpen={isOpen} onClose={onClose} title={room ? 'Edit Room Type' : 'Add Room Type'}>
      <form onSubmit={handleSubmit} className="space-y-4">
        <Input
          label="Room Name"
          value={formData.name}
          onChange={(e) => setFormData({ ...formData, name: e.target.value })}
          required
        />
        <Textarea
          label="Description"
          value={formData.description}
          onChange={(e) => setFormData({ ...formData, description: e.target.value })}
          rows={3}
        />
        <Input
          label="Max Occupancy"
          type="number"
          value={formData.maxOccupancy}
          onChange={(e) => setFormData({ ...formData, maxOccupancy: e.target.value })}
          required
        />
        <Input
          label="Price Per Night (RWF)"
          type="number"
          value={formData.pricePerNight}
          onChange={(e) => setFormData({ ...formData, pricePerNight: e.target.value })}
          required
        />
        <Input
          label="Amenities (comma-separated)"
          value={formData.amenities}
          onChange={(e) => setFormData({ ...formData, amenities: e.target.value })}
          placeholder="WiFi, TV, AC, etc."
        />
        <div className="flex gap-2 justify-end">
          <Button type="button" variant="ghost" onClick={onClose}>
            Cancel
          </Button>
          <Button type="submit" variant="primary">
            {room ? 'Update' : 'Create'}
          </Button>
        </div>
      </form>
    </Modal>
  );
}

// Table Modal Component
function TableModal({ isOpen, onClose, onSave, table }: any) {
  const [formData, setFormData] = useState({
    tableNumber: '',
    capacity: '',
    location: '',
    isAvailable: true,
  });

  useEffect(() => {
    if (table) {
      setFormData({
        tableNumber: table.tableNumber || '',
        capacity: table.capacity?.toString() || '',
        location: table.location || '',
        isAvailable: table.isAvailable ?? true,
      });
    } else {
      setFormData({
        tableNumber: '',
        capacity: '',
        location: '',
        isAvailable: true,
      });
    }
  }, [table, isOpen]);

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    onSave({
      tableNumber: formData.tableNumber,
      capacity: parseInt(formData.capacity),
      location: formData.location || undefined,
      isAvailable: formData.isAvailable,
    });
  };

  return (
    <Modal isOpen={isOpen} onClose={onClose} title={table ? 'Edit Table' : 'Add Table'}>
      <form onSubmit={handleSubmit} className="space-y-4">
        <Input
          label="Table Number"
          value={formData.tableNumber}
          onChange={(e) => setFormData({ ...formData, tableNumber: e.target.value })}
          required
        />
        <Input
          label="Capacity"
          type="number"
          value={formData.capacity}
          onChange={(e) => setFormData({ ...formData, capacity: e.target.value })}
          required
        />
        <Input
          label="Location"
          value={formData.location}
          onChange={(e) => setFormData({ ...formData, location: e.target.value })}
          placeholder="e.g., Main Dining, Patio, etc."
        />
        <div className="flex items-center gap-2">
          <input
            type="checkbox"
            id="isAvailable"
            checked={formData.isAvailable}
            onChange={(e) => setFormData({ ...formData, isAvailable: e.target.checked })}
            className="w-4 h-4"
          />
          <label htmlFor="isAvailable" className="text-sm text-gray-700">
            Available for booking
          </label>
        </div>
        <div className="flex gap-2 justify-end">
          <Button type="button" variant="ghost" onClick={onClose}>
            Cancel
          </Button>
          <Button type="submit" variant="primary">
            {table ? 'Update' : 'Create'}
          </Button>
        </div>
      </form>
    </Modal>
  );
}

