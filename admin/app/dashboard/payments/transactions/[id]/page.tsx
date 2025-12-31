'use client';

import { useState, useEffect } from 'react';
import { useParams, useRouter } from 'next/navigation';
import Link from 'next/link';
import { PaymentsAPI, type Transaction, type TransactionStatus } from '@/src/lib/api';
import Icon, { 
  faArrowLeft, 
  faEdit, 
  faDollarSign,
  faCreditCard,
} from '@/app/components/Icon';
import { toast } from '@/app/components/Toaster';
import { Button, Modal } from '@/app/components';
import Card, { CardHeader, CardBody } from '@/app/components/Card';
import Select from '@/app/components/Select';

const STATUSES: { value: TransactionStatus; label: string }[] = [
  { value: 'pending', label: 'Pending' },
  { value: 'completed', label: 'Completed' },
  { value: 'failed', label: 'Failed' },
  { value: 'cancelled', label: 'Cancelled' },
];

const getStatusBadgeColor = (status: TransactionStatus) => {
  switch (status) {
    case 'completed':
      return 'bg-green-100 text-green-800';
    case 'pending':
      return 'bg-yellow-100 text-yellow-800';
    case 'failed':
    case 'cancelled':
      return 'bg-red-100 text-red-800';
    default:
      return 'bg-gray-100 text-gray-800';
  }
};

export default function TransactionDetailPage() {
  const params = useParams();
  const router = useRouter();
  const transactionId = params?.id as string | undefined;

  const [transaction, setTransaction] = useState<Transaction | null>(null);
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);
  const [statusModalOpen, setStatusModalOpen] = useState(false);

  const [formData, setFormData] = useState({
    status: 'pending' as TransactionStatus,
  });

  useEffect(() => {
    if (!transactionId) {
      setLoading(false);
      return;
    }

    const fetchTransaction = async () => {
      setLoading(true);
      try {
        const transactionData = await PaymentsAPI.getTransactionById(transactionId);
        setTransaction(transactionData);
        setFormData({
          status: transactionData.status || 'pending',
        });
      } catch (error: any) {
        console.error('Failed to fetch transaction:', error);
        toast.error(error?.message || 'Failed to load transaction');
        router.push('/dashboard/payments');
      } finally {
        setLoading(false);
      }
    };

    fetchTransaction();
  }, [transactionId, router]);

  const handleSaveStatus = async () => {
    if (!transactionId) return;

    setSaving(true);
    try {
      await PaymentsAPI.updateTransactionStatus(transactionId, {
        status: formData.status,
      });
      
      // Refresh transaction data
      const updatedTransaction = await PaymentsAPI.getTransactionById(transactionId);
      setTransaction(updatedTransaction);
      setStatusModalOpen(false);
      toast.success('Transaction status updated successfully');
    } catch (error: any) {
      console.error('Failed to update transaction status:', error);
      toast.error(error?.message || 'Failed to update transaction status');
    } finally {
      setSaving(false);
    }
  };

  if (loading) {
    return (
      <div className="flex items-center justify-center min-h-[400px]">
        <div className="text-center">
          <div className="inline-block animate-spin rounded-full h-12 w-12 border-b-2 border-[#0e1a30] mb-4"></div>
          <p className="text-gray-600">Loading transaction...</p>
        </div>
      </div>
    );
  }

  if (!transaction) {
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
              Transaction {transaction.reference || transaction.id.substring(0, 8)}
            </h1>
            <p className="text-gray-600 mt-1">
              {transaction.type?.replace(/_/g, ' ') || 'N/A'} • {transaction.status || 'N/A'}
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

      {/* Transaction Information */}
      <Card>
        <CardHeader>
          <h2 className="text-lg font-semibold text-gray-900">Transaction Details</h2>
        </CardHeader>
        <CardBody>
          <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">Reference</label>
              <p className="text-sm font-medium text-gray-900">{transaction.reference || transaction.id.substring(0, 8) || 'N/A'}</p>
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">Type</label>
              <p className="text-sm text-gray-900">{transaction.type?.replace(/_/g, ' ') || 'N/A'}</p>
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">Status</label>
              <span className={`inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium ${getStatusBadgeColor(transaction.status || 'pending')}`}>
                {transaction.status?.replace(/_/g, ' ') || 'N/A'}
              </span>
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                <Icon icon={faDollarSign} className="inline mr-1 text-gray-400" size="sm" />
                Amount
              </label>
              <p className="text-sm font-medium text-gray-900">
                {transaction.currency || 'RWF'} {transaction.amount?.toLocaleString() || '0'}
              </p>
            </div>

            {transaction.paymentMethod && (
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  <Icon icon={faCreditCard} className="inline mr-1 text-gray-400" size="sm" />
                  Payment Method
                </label>
                <p className="text-sm text-gray-900">{transaction.paymentMethod}</p>
              </div>
            )}

            {transaction.description && (
              <div className="md:col-span-2">
                <label className="block text-sm font-medium text-gray-700 mb-1">Description</label>
                <p className="text-sm text-gray-900">{transaction.description}</p>
              </div>
            )}

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">Created At</label>
              <p className="text-sm text-gray-900">
                {transaction.createdAt ? new Date(transaction.createdAt).toLocaleString('en-US', {
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

      {/* Related Information */}
      {(transaction.user || transaction.merchant || transaction.booking) && (
        <Card>
          <CardHeader>
            <h2 className="text-lg font-semibold text-gray-900">Related Information</h2>
          </CardHeader>
          <CardBody>
            <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
              {transaction.user && (
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">User</label>
                  <p className="text-sm text-gray-900">{transaction.user.fullName || transaction.user.email || 'N/A'}</p>
                </div>
              )}

              {transaction.merchant && (
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">Merchant</label>
                  <p className="text-sm text-gray-900">{transaction.merchant.businessName || 'N/A'}</p>
                </div>
              )}

              {transaction.booking && (
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">Booking</label>
                  <p className="text-sm text-gray-900">{transaction.booking.bookingNumber || 'N/A'}</p>
                </div>
              )}
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
            status: transaction.status || 'pending',
          });
        }}
        title="Update Transaction Status"
        size="md"
      >
        <div className="space-y-4">
          <Select
            label="Status"
            value={formData.status}
            onChange={(e) => setFormData({ ...formData, status: e.target.value as TransactionStatus })}
            options={STATUSES.map((s) => ({ value: s.value, label: s.label }))}
          />

          <div className="flex items-center gap-2 justify-end pt-4 border-t border-gray-200">
            <Button
              variant="secondary"
              size="md"
              onClick={() => {
                setStatusModalOpen(false);
                setFormData({
                  status: transaction.status || 'pending',
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

