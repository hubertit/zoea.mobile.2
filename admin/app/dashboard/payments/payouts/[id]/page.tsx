'use client';

import { useState, useEffect } from 'react';
import { useParams, useRouter } from 'next/navigation';
import Link from 'next/link';
import { PaymentsAPI, type Payout, type PaymentStatus } from '@/src/lib/api';
import Icon, { 
  faArrowLeft, 
  faEdit, 
  faDollarSign,
} from '@/app/components/Icon';
import { toast } from '@/app/components/Toaster';
import { Button, Modal } from '@/app/components';
import Card, { CardHeader, CardBody } from '@/app/components/Card';
import Select from '@/app/components/Select';

const STATUSES: { value: PaymentStatus; label: string }[] = [
  { value: 'pending', label: 'Pending' },
  { value: 'processing', label: 'Processing' },
  { value: 'completed', label: 'Completed' },
  { value: 'failed', label: 'Failed' },
  { value: 'refunded', label: 'Refunded' },
  { value: 'partially_refunded', label: 'Partially Refunded' },
];

const getStatusBadgeColor = (status: PaymentStatus) => {
  switch (status) {
    case 'completed':
      return 'bg-green-100 text-green-800';
    case 'pending':
    case 'processing':
      return 'bg-yellow-100 text-yellow-800';
    case 'failed':
      return 'bg-red-100 text-red-800';
    case 'refunded':
    case 'partially_refunded':
      return 'bg-orange-100 text-orange-800';
    default:
      return 'bg-gray-100 text-gray-800';
  }
};

export default function PayoutDetailPage() {
  const params = useParams();
  const router = useRouter();
  const payoutId = params?.id as string | undefined;

  const [payout, setPayout] = useState<Payout | null>(null);
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);
  const [statusModalOpen, setStatusModalOpen] = useState(false);

  const [formData, setFormData] = useState({
    status: 'pending' as PaymentStatus,
  });

  useEffect(() => {
    if (!payoutId) {
      setLoading(false);
      return;
    }

    const fetchPayout = async () => {
      setLoading(true);
      try {
        const payoutData = await PaymentsAPI.getPayoutById(payoutId);
        setPayout(payoutData);
        setFormData({
          status: payoutData.status || 'pending',
        });
      } catch (error: any) {
        console.error('Failed to fetch payout:', error);
        toast.error(error?.message || 'Failed to load payout');
        router.push('/dashboard/payments');
      } finally {
        setLoading(false);
      }
    };

    fetchPayout();
  }, [payoutId, router]);

  const handleSaveStatus = async () => {
    if (!payoutId) return;

    setSaving(true);
    try {
      await PaymentsAPI.updatePayoutStatus(payoutId, {
        status: formData.status,
      });
      
      // Refresh payout data
      const updatedPayout = await PaymentsAPI.getPayoutById(payoutId);
      setPayout(updatedPayout);
      setStatusModalOpen(false);
      toast.success('Payout status updated successfully');
    } catch (error: any) {
      console.error('Failed to update payout status:', error);
      toast.error(error?.message || 'Failed to update payout status');
    } finally {
      setSaving(false);
    }
  };

  if (loading) {
    return (
      <div className="flex items-center justify-center min-h-[400px]">
        <div className="text-center">
          <div className="inline-block animate-spin rounded-full h-12 w-12 border-b-2 border-[#0e1a30] mb-4"></div>
          <p className="text-gray-600">Loading payout...</p>
        </div>
      </div>
    );
  }

  if (!payout) {
    return null;
  }

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex items-center justify-between flex-wrap gap-4">
        <div className="flex items-center gap-4">
          <Link href="/dashboard/payments">
            <Button variant="ghost" size="sm" icon={faArrowLeft}>
              Back
            </Button>
          </Link>
          <div>
            <h1 className="text-2xl font-bold text-gray-900">
              Payout {payout.reference || payout.id.substring(0, 8)}
            </h1>
            <p className="text-gray-600 mt-1">
              {payout.merchant?.businessName || 'N/A'} • {payout.status || 'N/A'}
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

      {/* Payout Information */}
      <Card>
        <CardHeader>
          <h2 className="text-lg font-semibold text-gray-900">Payout Details</h2>
        </CardHeader>
        <CardBody>
          <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">Reference</label>
              <p className="text-sm font-medium text-gray-900">{payout.reference || payout.id.substring(0, 8) || 'N/A'}</p>
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">Status</label>
              <span className={`inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium ${getStatusBadgeColor(payout.status || 'pending')}`}>
                {payout.status?.replace(/_/g, ' ') || 'N/A'}
              </span>
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                <Icon icon={faDollarSign} className="inline mr-1 text-gray-400" size="sm" />
                Amount
              </label>
              <p className="text-sm font-medium text-gray-900">
                {payout.currency || 'RWF'} {payout.amount?.toLocaleString() || '0'}
              </p>
            </div>

            {payout.processedAt && (
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">Processed At</label>
                <p className="text-sm text-gray-900">
                  {new Date(payout.processedAt).toLocaleString('en-US', {
                    month: 'long',
                    day: 'numeric',
                    year: 'numeric',
                    hour: '2-digit',
                    minute: '2-digit',
                  })}
                </p>
              </div>
            )}

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">Created At</label>
              <p className="text-sm text-gray-900">
                {payout.createdAt ? new Date(payout.createdAt).toLocaleString('en-US', {
                  month: 'long',
                  day: 'numeric',
                  year: 'numeric',
                  hour: '2-digit',
                  minute: '2-digit',
                }) : 'N/A'}
              </p>
            </div>
          </div>
        </CardBody>
      </Card>

      {/* Merchant Information */}
      {payout.merchant && (
        <Card>
          <CardHeader>
            <h2 className="text-lg font-semibold text-gray-900">Merchant</h2>
          </CardHeader>
          <CardBody>
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">Business Name</label>
              <p className="text-sm text-gray-900">{payout.merchant.businessName || 'N/A'}</p>
            </div>
          </CardBody>
        </Card>
      )}

      {/* Bank Account Information */}
      {payout.bankAccountInfo && (
        <Card>
          <CardHeader>
            <h2 className="text-lg font-semibold text-gray-900">Bank Account Information</h2>
          </CardHeader>
          <CardBody>
            <div className="space-y-2">
              {Object.entries(payout.bankAccountInfo).map(([key, value]) => (
                <div key={key} className="grid grid-cols-2 gap-4">
                  <label className="text-sm font-medium text-gray-700">{key.replace(/([A-Z])/g, ' $1').trim()}</label>
                  <p className="text-sm text-gray-900">{String(value)}</p>
                </div>
              ))}
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
            status: payout.status || 'pending',
          });
        }}
        title="Update Payout Status"
        size="md"
      >
        <div className="space-y-4">
          <Select
            label="Status"
            value={formData.status}
            onChange={(e) => setFormData({ ...formData, status: e.target.value as PaymentStatus })}
            options={STATUSES.map((s) => ({ value: s.value, label: s.label }))}
          />

          <div className="flex items-center gap-2 justify-end pt-4 border-t border-gray-200">
            <Button
              variant="secondary"
              size="md"
              onClick={() => {
                setStatusModalOpen(false);
                setFormData({
                  status: payout.status || 'pending',
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

