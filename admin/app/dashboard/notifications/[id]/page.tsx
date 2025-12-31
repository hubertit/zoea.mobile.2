'use client';

import { useState, useEffect } from 'react';
import { useParams, useRouter } from 'next/navigation';
import Link from 'next/link';
import { NotificationsAPI, type NotificationRequest, type ApprovalStatus } from '@/src/lib/api';
import Icon, { 
  faArrowLeft, 
  faEdit, 
  faPaperPlane,
  faCalendar,
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

export default function NotificationDetailPage() {
  const params = useParams();
  const router = useRouter();
  const notificationId = params?.id as string | undefined;

  const [notification, setNotification] = useState<NotificationRequest | null>(null);
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);
  const [statusModalOpen, setStatusModalOpen] = useState(false);

  const [formData, setFormData] = useState({
    status: 'pending' as ApprovalStatus,
    rejectionReason: '',
    revisionNotes: '',
  });

  useEffect(() => {
    if (!notificationId) {
      setLoading(false);
      return;
    }

    const fetchNotification = async () => {
      setLoading(true);
      try {
        // Note: We need to get notification from the list or create a getById endpoint
        // For now, we'll fetch from list and filter
        const response = await NotificationsAPI.listNotificationRequests({ limit: 1000 });
        const found = response.data.find((n) => n.id === notificationId);
        
        if (!found) {
          toast.error('Notification not found');
          router.push('/dashboard/notifications');
          return;
        }

        setNotification(found);
        setFormData({
          status: found.status || 'pending',
          rejectionReason: found.rejectionReason || '',
          revisionNotes: found.revisionNotes || '',
        });
      } catch (error: any) {
        console.error('Failed to fetch notification:', error);
        toast.error(error?.message || 'Failed to load notification');
        router.push('/dashboard/notifications');
      } finally {
        setLoading(false);
      }
    };

    fetchNotification();
  }, [notificationId, router]);

  const handleSaveStatus = async () => {
    if (!notificationId) return;

    setSaving(true);
    try {
      await NotificationsAPI.updateNotificationRequest(notificationId, {
        status: formData.status,
        rejectionReason: formData.rejectionReason || undefined,
        revisionNotes: formData.revisionNotes || undefined,
      });
      
      // Refresh notification data
      const response = await NotificationsAPI.listNotificationRequests({ limit: 1000 });
      const updated = response.data.find((n) => n.id === notificationId);
      if (updated) {
        setNotification(updated);
      }
      setStatusModalOpen(false);
      toast.success('Notification status updated successfully');
    } catch (error: any) {
      console.error('Failed to update notification status:', error);
      toast.error(error?.message || 'Failed to update notification status');
    } finally {
      setSaving(false);
    }
  };

  if (loading) {
    return (
      <div className="flex items-center justify-center min-h-[400px]">
        <div className="text-center">
          <div className="inline-block animate-spin rounded-full h-12 w-12 border-b-2 border-[#0e1a30] mb-4"></div>
          <p className="text-gray-600">Loading notification...</p>
        </div>
      </div>
    );
  }

  if (!notification) {
    return null;
  }

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex items-center justify-between flex-wrap gap-4">
        <div className="flex items-center gap-4">
          <Link href="/dashboard/notifications">
            <Button variant="ghost" size="sm" icon={faArrowLeft}>
              Back
            </Button>
          </Link>
          <div>
            <h1 className="text-2xl font-bold text-gray-900">{notification.title || 'Notification Details'}</h1>
            <p className="text-gray-600 mt-1">
              {notification.requester?.fullName || notification.requester?.email || 'N/A'} • {notification.status || 'N/A'}
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

      {/* Notification Information */}
      <Card>
        <CardHeader>
          <h2 className="text-lg font-semibold text-gray-900">Notification Details</h2>
        </CardHeader>
        <CardBody>
          <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">Title</label>
              <p className="text-sm font-medium text-gray-900">{notification.title || 'N/A'}</p>
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">Status</label>
              <span className={`inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium ${getStatusBadgeColor(notification.status || 'pending')}`}>
                {notification.status?.replace(/_/g, ' ') || 'N/A'}
              </span>
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">Target Type</label>
              <p className="text-sm text-gray-900">{notification.targetType || 'N/A'}</p>
            </div>

            {notification.scheduleAt && (
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  <Icon icon={faCalendar} className="inline mr-1 text-gray-400" size="sm" />
                  Scheduled At
                </label>
                <p className="text-sm text-gray-900">
                  {new Date(notification.scheduleAt).toLocaleString('en-US', {
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
                {notification.createdAt ? new Date(notification.createdAt).toLocaleString('en-US', {
                  month: 'long',
                  day: 'numeric',
                  year: 'numeric',
                  hour: '2-digit',
                  minute: '2-digit',
                }) : 'N/A'}
              </p>
            </div>

            {notification.actionUrl && (
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">Action URL</label>
                <a
                  href={notification.actionUrl}
                  target="_blank"
                  rel="noopener noreferrer"
                  className="text-sm text-[#0e1a30] hover:underline"
                >
                  {notification.actionUrl}
                </a>
              </div>
            )}

            <div className="md:col-span-2">
              <label className="block text-sm font-medium text-gray-700 mb-1">Body</label>
              <p className="text-sm text-gray-900 whitespace-pre-wrap">{notification.body || 'N/A'}</p>
            </div>

            {notification.segments && notification.segments.length > 0 && (
              <div className="md:col-span-2">
                <label className="block text-sm font-medium text-gray-700 mb-1">Segments</label>
                <div className="flex flex-wrap gap-2">
                  {notification.segments.map((segment, index) => (
                    <span
                      key={index}
                      className="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-blue-100 text-blue-800"
                    >
                      {segment}
                    </span>
                  ))}
                </div>
              </div>
            )}
          </div>
        </CardBody>
      </Card>

      {/* Requester Information */}
      {notification.requester && (
        <Card>
          <CardHeader>
            <h2 className="text-lg font-semibold text-gray-900">Requester</h2>
          </CardHeader>
          <CardBody>
            <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">Name</label>
                <p className="text-sm text-gray-900">{notification.requester.fullName || 'N/A'}</p>
              </div>
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">Email</label>
                <p className="text-sm text-gray-900">{notification.requester.email || 'N/A'}</p>
              </div>
            </div>
          </CardBody>
        </Card>
      )}

      {/* Rejection/Revision Notes */}
      {(notification.rejectionReason || notification.revisionNotes) && (
        <Card>
          <CardHeader>
            <h2 className="text-lg font-semibold text-gray-900">Review Notes</h2>
          </CardHeader>
          <CardBody>
            {notification.rejectionReason && (
              <div className="mb-4">
                <label className="block text-sm font-medium text-gray-700 mb-1">Rejection Reason</label>
                <p className="text-sm text-gray-900">{notification.rejectionReason}</p>
              </div>
            )}
            {notification.revisionNotes && (
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">Revision Notes</label>
                <p className="text-sm text-gray-900">{notification.revisionNotes}</p>
              </div>
            )}
          </CardBody>
        </Card>
      )}

      {/* Status Update Modal */}
      <Modal
        isOpen={statusModalOpen}
        onClose={() => {
          setStatusModalOpen(false);
          setFormData({
            status: notification.status || 'pending',
            rejectionReason: notification.rejectionReason || '',
            revisionNotes: notification.revisionNotes || '',
          });
        }}
        title="Update Notification Status"
        size="md"
      >
        <div className="space-y-4">
          <Select
            label="Status"
            value={formData.status}
            onChange={(e) => setFormData({ ...formData, status: e.target.value as ApprovalStatus })}
            options={STATUSES.map((s) => ({ value: s.value, label: s.label }))}
          />

          {formData.status === 'rejected' && (
            <Textarea
              label="Rejection Reason"
              value={formData.rejectionReason}
              onChange={(e) => setFormData({ ...formData, rejectionReason: e.target.value })}
              placeholder="Enter reason for rejection"
              rows={3}
            />
          )}

          {formData.status === 'revision_requested' && (
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
                  status: notification.status || 'pending',
                  rejectionReason: notification.rejectionReason || '',
                  revisionNotes: notification.revisionNotes || '',
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

