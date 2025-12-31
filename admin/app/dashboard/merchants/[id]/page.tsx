'use client';

import { useState, useEffect } from 'react';
import { useParams, useRouter } from 'next/navigation';
import Link from 'next/link';
import { MerchantsAPI, type Merchant, type ApprovalStatus } from '@/src/lib/api';
import Icon, { 
  faArrowLeft, 
  faEdit, 
  faMapMarkerAlt,
  faPhone,
  faEnvelope,
  faGlobe,
  faCheckCircle,
  faTimesCircle,
  faBuilding,
} from '@/app/components/Icon';
import { toast } from '@/app/components/Toaster';
import { Button, Modal } from '@/app/components';
import Card, { CardHeader, CardBody } from '@/app/components/Card';
import Select from '@/app/components/Select';
import Textarea from '@/app/components/Textarea';

const STATUSES: { value: ApprovalStatus; label: string }[] = [
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

export default function MerchantDetailPage() {
  const params = useParams();
  const router = useRouter();
  const merchantId = params?.id as string | undefined;

  const [merchant, setMerchant] = useState<Merchant | null>(null);
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);
  const [statusModalOpen, setStatusModalOpen] = useState(false);

  const [formData, setFormData] = useState({
    registrationStatus: 'pending' as ApprovalStatus,
    isVerified: false,
    rejectionReason: '',
    revisionNotes: '',
  });

  useEffect(() => {
    if (!merchantId) {
      setLoading(false);
      return;
    }

    const fetchMerchant = async () => {
      setLoading(true);
      try {
        const merchantData = await MerchantsAPI.getMerchantById(merchantId);
        setMerchant(merchantData);
        setFormData({
          registrationStatus: merchantData.registrationStatus || 'pending',
          isVerified: merchantData.isVerified || false,
          rejectionReason: '',
          revisionNotes: '',
        });
      } catch (error: any) {
        console.error('Failed to fetch merchant:', error);
        toast.error(error?.message || 'Failed to load merchant');
        router.push('/dashboard/merchants');
      } finally {
        setLoading(false);
      }
    };

    fetchMerchant();
  }, [merchantId, router]);

  const handleSaveStatus = async () => {
    if (!merchantId) return;

    setSaving(true);
    try {
      await MerchantsAPI.updateMerchantStatus(merchantId, {
        registrationStatus: formData.registrationStatus,
        isVerified: formData.isVerified,
        rejectionReason: formData.rejectionReason || undefined,
        revisionNotes: formData.revisionNotes || undefined,
      });
      
      // Refresh merchant data
      const updatedMerchant = await MerchantsAPI.getMerchantById(merchantId);
      setMerchant(updatedMerchant);
      setStatusModalOpen(false);
      toast.success('Merchant status updated successfully');
    } catch (error: any) {
      console.error('Failed to update merchant status:', error);
      toast.error(error?.message || 'Failed to update merchant status');
    } finally {
      setSaving(false);
    }
  };

  if (loading) {
    return (
      <div className="flex items-center justify-center min-h-[400px]">
        <div className="text-center">
          <div className="inline-block animate-spin rounded-full h-12 w-12 border-b-2 border-[#0e1a30] mb-4"></div>
          <p className="text-gray-600">Loading merchant...</p>
        </div>
      </div>
    );
  }

  if (!merchant) {
    return null;
  }

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex items-center justify-between flex-wrap gap-4">
        <div className="flex items-center gap-4">
          <Link href="/dashboard/merchants">
            <Button variant="ghost" size="sm" icon={faArrowLeft}>
              Back
            </Button>
          </Link>
          <div>
            <h1 className="text-2xl font-bold text-gray-900">{merchant.businessName || 'Merchant Details'}</h1>
            <p className="text-gray-600 mt-1">
              {merchant.user?.fullName || merchant.user?.email || 'N/A'} • {merchant.city?.name || 'N/A'}
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
              <label className="block text-sm font-medium text-gray-700 mb-1">Business Name</label>
              <p className="text-sm text-gray-900">{merchant.businessName || 'N/A'}</p>
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">Business Type</label>
              <p className="text-sm text-gray-900">{merchant.businessType?.replace(/_/g, ' ') || 'N/A'}</p>
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">Registration Status</label>
              <span className={`inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium ${getStatusBadgeColor(merchant.registrationStatus || 'pending')}`}>
                {merchant.registrationStatus?.replace(/_/g, ' ') || 'N/A'}
              </span>
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">Verification</label>
              {merchant.isVerified ? (
                <span className="inline-flex items-center gap-1 px-2 py-0.5 rounded text-xs font-medium bg-green-100 text-green-800">
                  <Icon icon={faCheckCircle} size="xs" />
                  Verified
                </span>
              ) : (
                <span className="inline-flex items-center gap-1 px-2 py-0.5 rounded text-xs font-medium bg-gray-100 text-gray-800">
                  <Icon icon={faTimesCircle} size="xs" />
                  Not Verified
                </span>
              )}
            </div>

            {merchant.businessRegistrationNumber && (
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">Registration Number</label>
                <p className="text-sm text-gray-900">{merchant.businessRegistrationNumber}</p>
              </div>
            )}

            {merchant.taxId && (
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">Tax ID</label>
                <p className="text-sm text-gray-900">{merchant.taxId}</p>
              </div>
            )}

            {merchant.description && (
              <div className="md:col-span-2">
                <label className="block text-sm font-medium text-gray-700 mb-1">Description</label>
                <p className="text-sm text-gray-900 whitespace-pre-wrap">{merchant.description}</p>
              </div>
            )}
          </div>
        </CardBody>
      </Card>

      {/* Contact Information */}
      {(merchant.businessEmail || merchant.businessPhone || merchant.website) && (
        <Card>
          <CardHeader>
            <h2 className="text-lg font-semibold text-gray-900">Contact Information</h2>
          </CardHeader>
          <CardBody>
            <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
              {merchant.businessEmail && (
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">
                    <Icon icon={faEnvelope} className="inline mr-1 text-gray-400" size="sm" />
                    Email
                  </label>
                  <p className="text-sm text-gray-900">{merchant.businessEmail}</p>
                </div>
              )}

              {merchant.businessPhone && (
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">
                    <Icon icon={faPhone} className="inline mr-1 text-gray-400" size="sm" />
                    Phone
                  </label>
                  <p className="text-sm text-gray-900">{merchant.businessPhone}</p>
                </div>
              )}

              {merchant.website && (
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">
                    <Icon icon={faGlobe} className="inline mr-1 text-gray-400" size="sm" />
                    Website
                  </label>
                  <a
                    href={merchant.website}
                    target="_blank"
                    rel="noopener noreferrer"
                    className="text-sm text-[#0e1a30] hover:underline"
                  >
                    {merchant.website}
                  </a>
                </div>
              )}
            </div>
          </CardBody>
        </Card>
      )}

      {/* Location Information */}
      {(merchant.address || merchant.city || merchant.country) && (
        <Card>
          <CardHeader>
            <h2 className="text-lg font-semibold text-gray-900">Location</h2>
          </CardHeader>
          <CardBody>
            <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
              {merchant.address && (
                <div className="md:col-span-2">
                  <label className="block text-sm font-medium text-gray-700 mb-1">
                    <Icon icon={faMapMarkerAlt} className="inline mr-1 text-gray-400" size="sm" />
                    Address
                  </label>
                  <p className="text-sm text-gray-900">{merchant.address}</p>
                </div>
              )}

              {merchant.city && (
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">City</label>
                  <p className="text-sm text-gray-900">{merchant.city.name}</p>
                </div>
              )}

              {merchant.country && (
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">Country</label>
                  <p className="text-sm text-gray-900">{merchant.country.name}</p>
                </div>
              )}
            </div>
          </CardBody>
        </Card>
      )}

      {/* Owner Information */}
      {merchant.user && (
        <Card>
          <CardHeader>
            <h2 className="text-lg font-semibold text-gray-900">Owner</h2>
          </CardHeader>
          <CardBody>
            <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">Name</label>
                <p className="text-sm text-gray-900">{merchant.user.fullName || 'N/A'}</p>
              </div>
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">Email</label>
                <p className="text-sm text-gray-900">{merchant.user.email || 'N/A'}</p>
              </div>
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
            registrationStatus: merchant.registrationStatus || 'pending',
            isVerified: merchant.isVerified || false,
            rejectionReason: '',
            revisionNotes: '',
          });
        }}
        title="Update Merchant Status"
        size="md"
      >
        <div className="space-y-4">
          <Select
            label="Registration Status"
            value={formData.registrationStatus}
            onChange={(e) => setFormData({ ...formData, registrationStatus: e.target.value as ApprovalStatus })}
            options={STATUSES.map((s) => ({ value: s.value, label: s.label }))}
          />

          <div>
            <label className="flex items-center gap-2">
              <input
                type="checkbox"
                checked={formData.isVerified}
                onChange={(e) => setFormData({ ...formData, isVerified: e.target.checked })}
                className="w-4 h-4 text-[#0e1a30] border-gray-300 rounded focus:ring-[#0e1a30]"
              />
              <span className="text-sm text-gray-700">Verified</span>
            </label>
          </div>

          {formData.registrationStatus === 'rejected' && (
            <Textarea
              label="Rejection Reason"
              value={formData.rejectionReason}
              onChange={(e) => setFormData({ ...formData, rejectionReason: e.target.value })}
              placeholder="Enter reason for rejection"
              rows={3}
            />
          )}

          {formData.registrationStatus === 'revision_requested' && (
            <Textarea
              label="Revision Notes"
              value={formData.revisionNotes}
              onChange={(e) => setFormData({ ...formData, revisionNotes: e.target.value })}
              placeholder="Enter revision notes"
              rows={3}
            />
          )}

          <div className="flex items-center gap-2 justify-end pt-4 border-t border-gray-200">
            <Button
              variant="secondary"
              size="md"
              onClick={() => {
                setStatusModalOpen(false);
                setFormData({
                  registrationStatus: merchant.registrationStatus || 'pending',
                  isVerified: merchant.isVerified || false,
                  rejectionReason: '',
                  revisionNotes: '',
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

