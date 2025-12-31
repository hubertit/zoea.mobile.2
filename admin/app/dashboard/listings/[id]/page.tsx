'use client';

import { useState, useEffect } from 'react';
import { useParams, useRouter } from 'next/navigation';
import Link from 'next/link';
import { ListingsAPI, type Listing, type ListingStatus } from '@/src/lib/api';
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
} from '@/app/components/Icon';
import { toast } from '@/app/components/Toaster';
import { Button, Modal } from '@/app/components';
import Card, { CardHeader, CardBody } from '@/app/components/Card';
import Select from '@/app/components/Select';
import StatusBadge from '@/app/components/StatusBadge';

const STATUSES: { value: ListingStatus; label: string }[] = [
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

export default function ListingDetailPage() {
  const params = useParams();
  const router = useRouter();
  const listingId = params?.id as string | undefined;

  const [listing, setListing] = useState<Listing | null>(null);
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);
  const [statusModalOpen, setStatusModalOpen] = useState(false);

  const [formData, setFormData] = useState({
    status: 'draft' as ListingStatus,
    isFeatured: false,
    isVerified: false,
    isBlocked: false,
  });

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
              setStatusModalOpen(true);
            }}
            variant="primary"
            size="sm"
            icon={faEdit}
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

