'use client';

import { useState, useEffect } from 'react';
import { useParams, useRouter } from 'next/navigation';
import Link from 'next/link';
import { ListingsAPI, CategoriesAPI, CountriesAPI, MediaAPI, type Listing, type ListingStatus, type ListingType, type PriceUnit, type Category } from '@/src/lib/api';
import apiClient from '@/src/lib/api/client';
import Icon, { 
  faArrowLeft, 
  faEdit, 
  faMapMarkerAlt,
  faPhone,
  faEnvelope,
  faGlobe,
  faStar,
  faCheckCircle,
  faTimesCircle,
  faImage,
  faTimes,
} from '@/app/components/Icon';
import { toast } from '@/app/components/Toaster';
import { Button, Modal, Breadcrumbs } from '@/app/components';
import Card, { CardHeader, CardBody } from '@/app/components/Card';
import Select from '@/app/components/Select';
import SearchableSelect from '@/app/components/SearchableSelect';
import Input from '@/app/components/Input';
import Textarea from '@/app/components/Textarea';
import StatusBadge from '@/app/components/StatusBadge';

const STATUSES: { value: ListingStatus; label: string }[] = [
  { value: 'draft', label: 'Draft' },
  { value: 'pending_review', label: 'Pending Review' },
  { value: 'active', label: 'Active' },
  { value: 'inactive', label: 'Inactive' },
  { value: 'suspended', label: 'Suspended' },
];

const TYPES: { value: ListingType; label: string }[] = [
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

const PRICE_UNITS: { value: PriceUnit; label: string }[] = [
  { value: 'per_night', label: 'Per Night' },
  { value: 'per_person', label: 'Per Person' },
  { value: 'per_meal', label: 'Per Meal' },
  { value: 'per_tour', label: 'Per Tour' },
  { value: 'per_event', label: 'Per Event' },
  { value: 'per_hour', label: 'Per Hour' },
  { value: 'per_table', label: 'Per Table' },
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

export default function ListingDetailPage() {
  const params = useParams();
  const router = useRouter();
  const listingId = params?.id as string | undefined;

  const [listing, setListing] = useState<Listing | null>(null);
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);
  const [statusModalOpen, setStatusModalOpen] = useState(false);
  const [editModalOpen, setEditModalOpen] = useState(false);
  const [categories, setCategories] = useState<Category[]>([]);
  const [countries, setCountries] = useState<Array<{ id: string; name: string; code: string }>>([]);
  const [cities, setCities] = useState<Array<{ id: string; name: string }>>([]);

  const [formData, setFormData] = useState({
    status: 'draft' as ListingStatus,
    isFeatured: false,
    isVerified: false,
    isBlocked: false,
  });

  const [editFormData, setEditFormData] = useState({
    name: '',
    shortDescription: '',
    description: '',
    type: '' as ListingType | '',
    categoryId: '',
    countryId: '',
    cityId: '',
    address: '',
    latitude: undefined as number | undefined,
    longitude: undefined as number | undefined,
    contactPhone: '',
    contactEmail: '',
    website: '',
    minPrice: '',
    maxPrice: '',
    priceUnit: '' as PriceUnit | '',
    status: 'draft' as ListingStatus,
    isFeatured: false,
    isVerified: false,
  });
  const [googlePlacesKey, setGooglePlacesKey] = useState<string>('');
  const [uploadedImages, setUploadedImages] = useState<Array<{ id: string; url: string; isPrimary?: boolean }>>([]);
  const [uploadingImage, setUploadingImage] = useState(false);
  const [existingImages, setExistingImages] = useState<Array<{ id: string; url: string; isPrimary?: boolean }>>([]);

  useEffect(() => {
    if (!listingId) {
      setLoading(false);
      return;
    }

    const fetchListing = async () => {
      setLoading(true);
      try {
        const listingData = await ListingsAPI.getListingById(listingId);
        setListing(listingData);
        setFormData({
          status: listingData.status || 'draft',
          isFeatured: listingData.isFeatured || false,
          isVerified: listingData.isVerified || false,
          isBlocked: listingData.isBlocked || false,
        });
        setEditFormData({
          name: listingData.name || '',
          shortDescription: listingData.shortDescription || '',
          description: listingData.description || '',
          type: listingData.type || '',
          categoryId: listingData.categoryId || '',
          countryId: listingData.countryId || '',
          cityId: listingData.cityId || '',
          address: listingData.address || '',
          latitude: (listingData as any).latitude,
          longitude: (listingData as any).longitude,
          contactPhone: listingData.contactPhone || '',
          contactEmail: listingData.contactEmail || '',
          website: listingData.website || '',
          minPrice: listingData.minPrice?.toString() || '',
          maxPrice: listingData.maxPrice?.toString() || '',
          priceUnit: listingData.priceUnit || '',
          status: listingData.status || 'draft',
          isFeatured: listingData.isFeatured || false,
          isVerified: listingData.isVerified || false,
        });
        
        // Load existing images if available
        if ((listingData as any).images && Array.isArray((listingData as any).images)) {
          setExistingImages((listingData as any).images.map((img: any) => ({
            id: img.id || img.mediaId,
            url: img.url || img.media?.url,
            isPrimary: img.isPrimary || false,
          })));
        }
      } catch (error: any) {
        console.error('Failed to fetch listing:', error);
        toast.error(error?.message || 'Failed to load listing');
        router.push('/dashboard/listings');
      } finally {
        setLoading(false);
      }
    };

    fetchListing();
  }, [listingId, router]);

  useEffect(() => {
    const fetchCategories = async () => {
      try {
        const response = await CategoriesAPI.listCategories({ flat: true });
        // CategoriesAPI.listCategories returns Category[] directly
        setCategories(Array.isArray(response) ? response : []);
      } catch (error) {
        console.error('Failed to fetch categories:', error);
      }
    };
    
    const fetchCountries = async () => {
      try {
        const response = await CountriesAPI.getActiveCountries();
        setCountries(response);
      } catch (error) {
        console.error('Failed to fetch countries:', error);
      }
    };
    
    fetchCategories();
    fetchCountries();
  }, []);

  // Load cities when country changes
  useEffect(() => {
    const fetchCities = async () => {
      if (!editFormData.countryId) {
        setCities([]);
        return;
      }
      
      try {
        const response = await CountriesAPI.getCitiesByCountry(editFormData.countryId);
        setCities(response);
      } catch (error) {
        console.error('Failed to fetch cities:', error);
        setCities([]);
      }
    };
    
    fetchCities();
  }, [editFormData.countryId]);

  const handleSaveStatus = async () => {
    if (!listingId) return;

    setSaving(true);
    try {
      await ListingsAPI.updateListingStatus(listingId, {
        status: formData.status,
        isFeatured: formData.isFeatured,
        isVerified: formData.isVerified,
        isBlocked: formData.isBlocked,
      });
      
      // Refresh listing data
      const updatedListing = await ListingsAPI.getListingById(listingId);
      setListing(updatedListing);
      setStatusModalOpen(false);
      toast.success('Listing status updated successfully');
    } catch (error: any) {
      console.error('Failed to update listing status:', error);
      toast.error(error?.message || 'Failed to update listing status');
    } finally {
      setSaving(false);
    }
  };

  const handleSaveEdit = async () => {
    if (!listingId) return;

    setSaving(true);
    try {
      await ListingsAPI.updateListing(listingId, {
        name: editFormData.name,
        shortDescription: editFormData.shortDescription || undefined,
        description: editFormData.description || undefined,
        type: editFormData.type || undefined,
        categoryId: editFormData.categoryId || undefined,
        countryId: editFormData.countryId || undefined,
        cityId: editFormData.cityId || undefined,
        address: editFormData.address || undefined,
        latitude: editFormData.latitude,
        longitude: editFormData.longitude,
        contactPhone: editFormData.contactPhone || undefined,
        contactEmail: editFormData.contactEmail || undefined,
        website: editFormData.website || undefined,
        minPrice: editFormData.minPrice ? parseFloat(editFormData.minPrice) : undefined,
        maxPrice: editFormData.maxPrice ? parseFloat(editFormData.maxPrice) : undefined,
        priceUnit: editFormData.priceUnit || undefined,
        status: editFormData.status,
        isFeatured: editFormData.isFeatured,
        isVerified: editFormData.isVerified,
      });
      
      // Upload new images if any
      if (uploadedImages.length > 0) {
        try {
          const imagePromises = uploadedImages.map((img, idx) =>
            apiClient.post(`/listings/${listingId}/images`, {
              merchantId: listing?.merchantId,
              mediaId: img.id,
              isPrimary: img.isPrimary || (existingImages.length === 0 && idx === 0),
            })
          );
          await Promise.all(imagePromises);
        } catch (imgError: any) {
          console.error('Failed to add images:', imgError);
          toast.error('Listing updated but failed to add some images');
        }
      }
      
      // Refresh listing data
      const updatedListing = await ListingsAPI.getListingById(listingId);
      setListing(updatedListing);
      setEditModalOpen(false);
      setUploadedImages([]);
      toast.success('Listing updated successfully');
    } catch (error: any) {
      console.error('Failed to update listing:', error);
      toast.error(error?.message || 'Failed to update listing');
    } finally {
      setSaving(false);
    }
  };

  if (loading) {
    return (
      <div className="flex items-center justify-center min-h-[400px]">
        <div className="text-center">
          <div className="inline-block animate-spin rounded-full h-12 w-12 border-b-2 border-[#0e1a30] mb-4"></div>
          <p className="text-gray-600">Loading listing...</p>
        </div>
      </div>
    );
  }

  if (!listing) {
    return null;
  }

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex items-center justify-between flex-wrap gap-4">
        <div className="flex items-center gap-4">
          <Link href="/dashboard/listings">
            <Button variant="ghost" size="sm" icon={faArrowLeft}>
              Back
            </Button>
          </Link>
          <div>
            <h1 className="text-2xl font-bold text-gray-900">{listing.name || 'Listing Details'}</h1>
            <p className="text-gray-600 mt-1">
              {listing.type?.replace(/_/g, ' ') || 'N/A'} • {listing.city?.name || 'N/A'}
            </p>
          </div>
        </div>
        <div className="flex items-center gap-2">
          <Button
            onClick={() => {
              setEditModalOpen(true);
            }}
            variant="primary"
            size="sm"
            icon={faEdit}
          >
            Edit Listing
          </Button>
          <Button
            onClick={() => {
              setStatusModalOpen(true);
            }}
            variant="secondary"
            size="sm"
          >
            Update Status
          </Button>
        </div>
      </div>

      {/* Basic Information */}
      <Card>
        <CardHeader>
          <h2 className="text-lg font-semibold text-gray-900">Basic Information</h2>
        </CardHeader>
        <CardBody>
          <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">Name</label>
              <p className="text-sm text-gray-900">{listing.name || 'N/A'}</p>
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">Type</label>
              <p className="text-sm text-gray-900">{listing.type?.replace(/_/g, ' ') || 'N/A'}</p>
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">Status</label>
              <span className={`inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium ${getStatusBadgeColor(listing.status || 'draft')}`}>
                {listing.status?.replace(/_/g, ' ') || 'N/A'}
              </span>
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">Features</label>
              <div className="flex flex-wrap gap-2">
                {listing.isFeatured && (
                  <span className="inline-flex items-center gap-1 px-2 py-0.5 rounded text-xs font-medium bg-blue-100 text-blue-800">
                    <Icon icon={faStar} size="xs" />
                    Featured
                  </span>
                )}
                {listing.isVerified && (
                  <span className="inline-flex items-center gap-1 px-2 py-0.5 rounded text-xs font-medium bg-green-100 text-green-800">
                    <Icon icon={faCheckCircle} size="xs" />
                    Verified
                  </span>
                )}
                {listing.isBlocked && (
                  <span className="inline-flex items-center gap-1 px-2 py-0.5 rounded text-xs font-medium bg-red-100 text-red-800">
                    <Icon icon={faTimesCircle} size="xs" />
                    Blocked
                  </span>
                )}
                {!listing.isFeatured && !listing.isVerified && !listing.isBlocked && (
                  <span className="text-xs text-gray-400">-</span>
                )}
              </div>
            </div>

            {listing.shortDescription && (
              <div className="md:col-span-2">
                <label className="block text-sm font-medium text-gray-700 mb-1">Short Description</label>
                <p className="text-sm text-gray-900">{listing.shortDescription}</p>
              </div>
            )}

            {listing.description && (
              <div className="md:col-span-2">
                <label className="block text-sm font-medium text-gray-700 mb-1">Description</label>
                <p className="text-sm text-gray-900 whitespace-pre-wrap">{listing.description}</p>
              </div>
            )}
          </div>
        </CardBody>
      </Card>

      {/* Location Information */}
      <Card>
        <CardHeader>
          <h2 className="text-lg font-semibold text-gray-900">Location</h2>
        </CardHeader>
        <CardBody>
          <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
            {listing.address && (
              <div className="md:col-span-2">
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  <Icon icon={faMapMarkerAlt} className="inline mr-1 text-gray-400" size="sm" />
                  Address
                </label>
                <p className="text-sm text-gray-900">{listing.address}</p>
              </div>
            )}

            {listing.city && (
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">City</label>
                <p className="text-sm text-gray-900">{listing.city.name}</p>
              </div>
            )}

            {listing.country && (
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">Country</label>
                <p className="text-sm text-gray-900">{listing.country.name}</p>
              </div>
            )}
          </div>
        </CardBody>
      </Card>

      {/* Contact Information */}
      {(listing.contactPhone || listing.contactEmail || listing.website) && (
        <Card>
          <CardHeader>
            <h2 className="text-lg font-semibold text-gray-900">Contact Information</h2>
          </CardHeader>
          <CardBody>
            <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
              {listing.contactPhone && (
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">
                    <Icon icon={faPhone} className="inline mr-1 text-gray-400" size="sm" />
                    Phone
                  </label>
                  <p className="text-sm text-gray-900">{listing.contactPhone}</p>
                </div>
              )}

              {listing.contactEmail && (
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">
                    <Icon icon={faEnvelope} className="inline mr-1 text-gray-400" size="sm" />
                    Email
                  </label>
                  <p className="text-sm text-gray-900">{listing.contactEmail}</p>
                </div>
              )}

              {listing.website && (
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">
                    <Icon icon={faGlobe} className="inline mr-1 text-gray-400" size="sm" />
                    Website
                  </label>
                  <a
                    href={listing.website}
                    target="_blank"
                    rel="noopener noreferrer"
                    className="text-sm text-[#0e1a30] hover:underline"
                  >
                    {listing.website}
                  </a>
                </div>
              )}
            </div>
          </CardBody>
        </Card>
      )}

      {/* Pricing */}
      {(listing.minPrice || listing.maxPrice) && (
        <Card>
          <CardHeader>
            <h2 className="text-lg font-semibold text-gray-900">Pricing</h2>
          </CardHeader>
          <CardBody>
            <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
              {listing.minPrice && (
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">Min Price</label>
                  <p className="text-sm text-gray-900">
                    {listing.priceUnit || 'RWF'} {listing.minPrice.toLocaleString()}
                  </p>
                </div>
              )}

              {listing.maxPrice && (
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">Max Price</label>
                  <p className="text-sm text-gray-900">
                    {listing.priceUnit || 'RWF'} {listing.maxPrice.toLocaleString()}
                  </p>
                </div>
              )}
            </div>
          </CardBody>
        </Card>
      )}

      {/* Merchant Information */}
      {listing.merchant && (
        <Card>
          <CardHeader>
            <h2 className="text-lg font-semibold text-gray-900">Merchant</h2>
          </CardHeader>
          <CardBody>
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">Business Name</label>
              <p className="text-sm text-gray-900">{listing.merchant.businessName || 'N/A'}</p>
            </div>
          </CardBody>
        </Card>
      )}

      {/* Edit Listing Modal */}
      <Modal
        isOpen={editModalOpen}
        onClose={() => {
          setEditModalOpen(false);
          if (listing) {
            setEditFormData({
              name: listing.name || '',
              shortDescription: listing.shortDescription || '',
              description: listing.description || '',
              type: listing.type || '',
              categoryId: listing.categoryId || '',
              countryId: listing.countryId || '',
              cityId: listing.cityId || '',
              address: listing.address || '',
              latitude: (listing as any).latitude,
              longitude: (listing as any).longitude,
              contactPhone: listing.contactPhone || '',
              contactEmail: listing.contactEmail || '',
              website: listing.website || '',
              minPrice: listing.minPrice?.toString() || '',
              maxPrice: listing.maxPrice?.toString() || '',
              priceUnit: listing.priceUnit || '',
              status: listing.status || 'draft',
              isFeatured: listing.isFeatured || false,
              isVerified: listing.isVerified || false,
            });
            setUploadedImages([]);
          }
        }}
        title="Edit Listing"
        size="lg"
      >
        <div className="space-y-4 max-h-[70vh] overflow-y-auto">
          <Input
            label="Name"
            value={editFormData.name}
            onChange={(e) => setEditFormData({ ...editFormData, name: e.target.value })}
            required
          />

          <Textarea
            label="Short Description"
            value={editFormData.shortDescription}
            onChange={(e) => setEditFormData({ ...editFormData, shortDescription: e.target.value })}
            rows={2}
          />

          <Textarea
            label="Description"
            value={editFormData.description}
            onChange={(e) => setEditFormData({ ...editFormData, description: e.target.value })}
            rows={4}
          />

          <div className="grid grid-cols-2 gap-4">
            <Select
              label="Type"
              value={editFormData.type}
              onChange={(e) => setEditFormData({ ...editFormData, type: e.target.value as ListingType })}
              options={[{ value: '', label: 'Select Type' }, ...TYPES.map((t) => ({ value: t.value, label: t.label }))]}
            />

            <SearchableSelect
              label="Category"
              value={editFormData.categoryId}
              onChange={(value) => setEditFormData({ ...editFormData, categoryId: value })}
              options={categories.map((c) => ({ 
                value: c.id, 
                label: c.name,
                group: c.parent?.name || 'Main Category'
              }))}
              placeholder="Select Category"
            />
          </div>

          <div className="grid grid-cols-2 gap-4">
            <Select
              label="Country"
              value={editFormData.countryId}
              onChange={(e) => {
                setEditFormData({ ...editFormData, countryId: e.target.value, cityId: '' });
              }}
              options={[{ value: '', label: 'Select Country' }, ...countries.map((c) => ({ value: c.id, label: c.name }))]}
              required
            />

            <Select
              label="City"
              value={editFormData.cityId}
              onChange={(e) => setEditFormData({ ...editFormData, cityId: e.target.value })}
              options={[{ value: '', label: 'Select City' }, ...cities.map((c) => ({ value: c.id, label: c.name }))]}
              disabled={!editFormData.countryId}
            />
          </div>

          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">
              Address (with Google Places)
            </label>
            <Input
              value={editFormData.address}
              onChange={(e) => setEditFormData({ ...editFormData, address: e.target.value })}
              placeholder="Start typing address..."
              id="edit-listing-address-autocomplete"
            />
            {(editFormData.latitude && editFormData.longitude) && (
              <p className="text-xs text-gray-500 mt-1">
                Coordinates: {editFormData.latitude.toFixed(7)}, {editFormData.longitude.toFixed(7)}
              </p>
            )}
          </div>

          <div className="col-span-2">
            <label className="block text-sm font-medium text-gray-700 mb-1">
              Images
            </label>
            
            {/* Existing Images */}
            {existingImages.length > 0 && (
              <div className="mb-4">
                <p className="text-sm text-gray-600 mb-2">Existing Images:</p>
                <div className="grid grid-cols-3 gap-4">
                  {existingImages.map((img) => (
                    <div key={img.id} className="relative">
                      <img src={img.url} alt="Listing" className="w-full h-24 object-cover rounded-md" />
                      {img.isPrimary && (
                        <span className="absolute top-1 left-1 bg-blue-500 text-white text-xs px-2 py-1 rounded">Primary</span>
                      )}
                    </div>
                  ))}
                </div>
              </div>
            )}

            {/* New Images */}
            {uploadedImages.length > 0 && (
              <div className="mb-4">
                <p className="text-sm text-gray-600 mb-2">New Images to Upload:</p>
                <div className="grid grid-cols-3 gap-4">
                  {uploadedImages.map((img, index) => (
                    <div key={index} className="relative">
                      <img src={img.url} alt={`Preview ${index}`} className="w-full h-24 object-cover rounded-md" />
                      <button
                        type="button"
                        onClick={() => setUploadedImages(uploadedImages.filter((_, i) => i !== index))}
                        className="absolute top-1 right-1 bg-red-500 text-white rounded-full p-1 text-xs"
                      >
                        <Icon icon={faTimes} size="xs" />
                      </button>
                      {img.isPrimary && (
                        <span className="absolute top-1 left-1 bg-blue-500 text-white text-xs px-2 py-1 rounded">Primary</span>
                      )}
                    </div>
                  ))}
                </div>
              </div>
            )}

            <input
              type="file"
              accept="image/*"
              multiple
              onChange={async (e) => {
                const files = Array.from(e.target.files || []);
                if (files.length === 0) return;
                
                // Validate file sizes (max 10MB before compression)
                const maxSize = 10 * 1024 * 1024;
                const invalidFiles = files.filter(f => f.size > maxSize);
                if (invalidFiles.length > 0) {
                  toast.error(
                    `Some images are too large (max ${(maxSize / 1024 / 1024).toFixed(0)}MB). ` +
                    `Large images: ${invalidFiles.map(f => f.name).join(', ')}`
                  );
                  return;
                }
                
                setUploadingImage(true);
                try {
                  const uploadPromises = files.map(file => MediaAPI.upload({ file, category: 'listing' }));
                  const uploaded = await Promise.all(uploadPromises);
                  const newImages = uploaded.map((media, idx) => ({
                    id: media.id,
                    url: media.url,
                    isPrimary: uploadedImages.length === 0 && existingImages.length === 0 && idx === 0,
                  }));
                  setUploadedImages([...uploadedImages, ...newImages]);
                  toast.success(`${files.length} image(s) uploaded and compressed successfully`);
                } catch (error: any) {
                  console.error('Failed to upload images:', error);
                  toast.error(error?.response?.data?.message || error?.message || 'Failed to upload images');
                } finally {
                  setUploadingImage(false);
                }
              }}
              className="hidden"
              id="edit-listing-image-upload"
              disabled={uploadingImage}
            />
            <label
              htmlFor="edit-listing-image-upload"
              className="inline-flex items-center gap-2 px-4 py-2 border border-gray-300 rounded-sm cursor-pointer hover:bg-gray-50 disabled:opacity-50"
            >
              <Icon icon={faImage} />
              {uploadingImage ? 'Uploading & Compressing...' : 'Upload Images (max 10MB, auto-compressed to <1MB)'}
            </label>
          </div>

          <div className="grid grid-cols-2 gap-4">
            <Input
              label="Contact Phone"
              value={editFormData.contactPhone}
              onChange={(e) => setEditFormData({ ...editFormData, contactPhone: e.target.value })}
            />

            <Input
              label="Contact Email"
              type="email"
              value={editFormData.contactEmail}
              onChange={(e) => setEditFormData({ ...editFormData, contactEmail: e.target.value })}
            />
          </div>

          <Input
            label="Website"
            type="url"
            value={editFormData.website}
            onChange={(e) => setEditFormData({ ...editFormData, website: e.target.value })}
          />

          <div className="grid grid-cols-3 gap-4">
            <Input
              label="Min Price"
              type="number"
              value={editFormData.minPrice}
              onChange={(e) => setEditFormData({ ...editFormData, minPrice: e.target.value })}
            />

            <Input
              label="Max Price"
              type="number"
              value={editFormData.maxPrice}
              onChange={(e) => setEditFormData({ ...editFormData, maxPrice: e.target.value })}
            />

            <Select
              label="Price Unit"
              value={editFormData.priceUnit}
              onChange={(e) => setEditFormData({ ...editFormData, priceUnit: e.target.value as PriceUnit })}
              options={[{ value: '', label: 'Select Unit' }, ...PRICE_UNITS.map((u) => ({ value: u.value, label: u.label }))]}
            />
          </div>

          <Select
            label="Status"
            value={editFormData.status}
            onChange={(e) => setEditFormData({ ...editFormData, status: e.target.value as ListingStatus })}
            options={STATUSES.map((s) => ({ value: s.value, label: s.label }))}
          />

          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">Flags</label>
            <div className="space-y-2">
              <label className="flex items-center gap-2">
                <input
                  type="checkbox"
                  checked={editFormData.isFeatured}
                  onChange={(e) => setEditFormData({ ...editFormData, isFeatured: e.target.checked })}
                  className="w-4 h-4 text-[#0e1a30] border-gray-300 rounded focus:ring-[#0e1a30]"
                />
                <span className="text-sm text-gray-700">Featured</span>
              </label>
              <label className="flex items-center gap-2">
                <input
                  type="checkbox"
                  checked={editFormData.isVerified}
                  onChange={(e) => setEditFormData({ ...editFormData, isVerified: e.target.checked })}
                  className="w-4 h-4 text-[#0e1a30] border-gray-300 rounded focus:ring-[#0e1a30]"
                />
                <span className="text-sm text-gray-700">Verified</span>
              </label>
            </div>
          </div>

          <div className="flex items-center gap-2 justify-end pt-4 border-t border-gray-200">
            <Button
              variant="secondary"
              size="md"
              onClick={() => {
                setEditModalOpen(false);
                if (listing) {
                  setEditFormData({
                    name: listing.name || '',
                    shortDescription: listing.shortDescription || '',
                    description: listing.description || '',
                    type: listing.type || '',
                    categoryId: listing.categoryId || '',
                    countryId: listing.countryId || '',
                    cityId: listing.cityId || '',
                    address: listing.address || '',
                    latitude: (listing as any).latitude,
                    longitude: (listing as any).longitude,
                    contactPhone: listing.contactPhone || '',
                    contactEmail: listing.contactEmail || '',
                    website: listing.website || '',
                    minPrice: listing.minPrice?.toString() || '',
                    maxPrice: listing.maxPrice?.toString() || '',
                    priceUnit: listing.priceUnit || '',
                    status: listing.status || 'draft',
                    isFeatured: listing.isFeatured || false,
                    isVerified: listing.isVerified || false,
                  });
                  setUploadedImages([]);
                }
              }}
              disabled={saving}
            >
              Cancel
            </Button>
            <Button
              variant="primary"
              size="md"
              onClick={handleSaveEdit}
              loading={saving}
            >
              Save Changes
            </Button>
          </div>
        </div>
      </Modal>

      {/* Status Update Modal */}
      <Modal
        isOpen={statusModalOpen}
        onClose={() => {
          setStatusModalOpen(false);
          setFormData({
            status: listing.status || 'draft',
            isFeatured: listing.isFeatured || false,
            isVerified: listing.isVerified || false,
            isBlocked: listing.isBlocked || false,
          });
        }}
        title="Update Listing Status"
        size="md"
      >
        <div className="space-y-4">
          <Select
            label="Status"
            value={formData.status}
            onChange={(e) => setFormData({ ...formData, status: e.target.value as ListingStatus })}
            options={STATUSES.map((s) => ({ value: s.value, label: s.label }))}
          />

          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">Flags</label>
            <div className="space-y-2">
              <label className="flex items-center gap-2">
                <input
                  type="checkbox"
                  checked={formData.isFeatured}
                  onChange={(e) => setFormData({ ...formData, isFeatured: e.target.checked })}
                  className="w-4 h-4 text-[#0e1a30] border-gray-300 rounded focus:ring-[#0e1a30]"
                />
                <span className="text-sm text-gray-700">Featured</span>
              </label>
              <label className="flex items-center gap-2">
                <input
                  type="checkbox"
                  checked={formData.isVerified}
                  onChange={(e) => setFormData({ ...formData, isVerified: e.target.checked })}
                  className="w-4 h-4 text-[#0e1a30] border-gray-300 rounded focus:ring-[#0e1a30]"
                />
                <span className="text-sm text-gray-700">Verified</span>
              </label>
              <label className="flex items-center gap-2">
                <input
                  type="checkbox"
                  checked={formData.isBlocked}
                  onChange={(e) => setFormData({ ...formData, isBlocked: e.target.checked })}
                  className="w-4 h-4 text-[#0e1a30] border-gray-300 rounded focus:ring-[#0e1a30]"
                />
                <span className="text-sm text-gray-700">Blocked</span>
              </label>
            </div>
          </div>

          <div className="flex items-center gap-2 justify-end pt-4 border-t border-gray-200">
            <Button
              variant="secondary"
              size="md"
              onClick={() => {
                setStatusModalOpen(false);
                setFormData({
                  status: listing.status || 'draft',
                  isFeatured: listing.isFeatured || false,
                  isVerified: listing.isVerified || false,
                  isBlocked: listing.isBlocked || false,
                });
              }}
              disabled={saving}
            >
              Cancel
            </Button>
            <Button
              variant="primary"
              size="md"
              onClick={handleSaveStatus}
              loading={saving}
            >
              Save Changes
            </Button>
          </div>
        </div>
      </Modal>
    </div>
  );
}

