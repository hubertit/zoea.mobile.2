'use client';

import { useState, useEffect } from 'react';
import { useParams, useRouter } from 'next/navigation';
import Link from 'next/link';
import { EventsAPI, type Event, type EventStatus } from '@/src/lib/api';
import Icon, { 
  faArrowLeft, 
  faEdit, 
  faMapMarkerAlt,
  faCalendar,
  faUsers,
  faLock,
  faGlobe,
  faCheckCircle,
  faTimesCircle,
} from '@/app/components/Icon';
import { toast } from '@/app/components/Toaster';
import { Button, Modal } from '@/app/components';
import Card, { CardHeader, CardBody } from '@/app/components/Card';
import Select from '@/app/components/Select';

const STATUSES: { value: EventStatus; label: string }[] = [
  { value: 'draft', label: 'Draft' },
  { value: 'pending_review', label: 'Pending Review' },
  { value: 'published', label: 'Published' },
  { value: 'ongoing', label: 'Ongoing' },
  { value: 'completed', label: 'Completed' },
  { value: 'cancelled', label: 'Cancelled' },
  { value: 'suspended', label: 'Suspended' },
];

const getStatusBadgeColor = (status: EventStatus) => {
  switch (status) {
    case 'published':
    case 'ongoing':
      return 'bg-green-100 text-green-800';
    case 'pending_review':
      return 'bg-yellow-100 text-yellow-800';
    case 'cancelled':
    case 'suspended':
      return 'bg-red-100 text-red-800';
    case 'completed':
      return 'bg-blue-100 text-blue-800';
    default:
      return 'bg-gray-100 text-gray-800';
  }
};

export default function EventDetailPage() {
  const params = useParams();
  const router = useRouter();
  const eventId = params?.id as string | undefined;

  const [event, setEvent] = useState<Event | null>(null);
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);
  const [statusModalOpen, setStatusModalOpen] = useState(false);

  const [formData, setFormData] = useState({
    status: 'draft' as EventStatus,
    isBlocked: false,
  });

  useEffect(() => {
    if (!eventId) {
      setLoading(false);
      return;
    }

    const fetchEvent = async () => {
      setLoading(true);
      try {
        const eventData = await EventsAPI.getEventById(eventId);
        setEvent(eventData);
        setFormData({
          status: eventData.status || 'draft',
          isBlocked: eventData.isBlocked || false,
        });
      } catch (error: any) {
        console.error('Failed to fetch event:', error);
        toast.error(error?.message || 'Failed to load event');
        router.push('/dashboard/events');
      } finally {
        setLoading(false);
      }
    };

    fetchEvent();
  }, [eventId, router]);

  const handleSaveStatus = async () => {
    if (!eventId) return;

    setSaving(true);
    try {
      await EventsAPI.updateEventStatus(eventId, {
        status: formData.status,
        isBlocked: formData.isBlocked,
      });
      
      // Refresh event data
      const updatedEvent = await EventsAPI.getEventById(eventId);
      setEvent(updatedEvent);
      setStatusModalOpen(false);
      toast.success('Event status updated successfully');
    } catch (error: any) {
      console.error('Failed to update event status:', error);
      toast.error(error?.message || 'Failed to update event status');
    } finally {
      setSaving(false);
    }
  };

  if (loading) {
    return (
      <div className="flex items-center justify-center min-h-[400px]">
        <div className="text-center">
          <div className="inline-block animate-spin rounded-full h-12 w-12 border-b-2 border-[#0e1a30] mb-4"></div>
          <p className="text-gray-600">Loading event...</p>
        </div>
      </div>
    );
  }

  if (!event) {
    return null;
  }

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex items-center justify-between flex-wrap gap-4">
        <div className="flex items-center gap-4">
          <Link href="/dashboard/events">
            <Button variant="ghost" size="sm" icon={faArrowLeft}>
              Back
            </Button>
          </Link>
          <div>
            <h1 className="text-2xl font-bold text-gray-900">{event.name || 'Event Details'}</h1>
            <p className="text-gray-600 mt-1">
              {event.organizer?.organizationName || 'N/A'} • {event.city?.name || 'N/A'}
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
              <p className="text-sm text-gray-900">{event.name || 'N/A'}</p>
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">Status</label>
              <span className={`inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium ${getStatusBadgeColor(event.status || 'draft')}`}>
                {event.status?.replace(/_/g, ' ') || 'N/A'}
              </span>
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">Privacy</label>
              <div className="flex items-center gap-2">
                {event.privacy === 'private' || event.privacy === 'invite_only' ? (
                  <Icon icon={faLock} className="text-gray-400" size="sm" />
                ) : (
                  <Icon icon={faGlobe} className="text-gray-400" size="sm" />
                )}
                <p className="text-sm text-gray-900">{event.privacy?.replace(/_/g, ' ') || 'N/A'}</p>
              </div>
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">Setup</label>
              <p className="text-sm text-gray-900">{event.setup?.replace(/_/g, ' ') || 'N/A'}</p>
            </div>

            {event.maxAttendance && (
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  <Icon icon={faUsers} className="inline mr-1 text-gray-400" size="sm" />
                  Max Attendance
                </label>
                <p className="text-sm text-gray-900">{event.maxAttendance.toLocaleString()}</p>
              </div>
            )}

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">Blocked</label>
              {event.isBlocked ? (
                <span className="inline-flex items-center gap-1 px-2 py-0.5 rounded text-xs font-medium bg-red-100 text-red-800">
                  <Icon icon={faTimesCircle} size="xs" />
                  Blocked
                </span>
              ) : (
                <span className="inline-flex items-center gap-1 px-2 py-0.5 rounded text-xs font-medium bg-green-100 text-green-800">
                  <Icon icon={faCheckCircle} size="xs" />
                  Not Blocked
                </span>
              )}
            </div>

            {event.description && (
              <div className="md:col-span-2">
                <label className="block text-sm font-medium text-gray-700 mb-1">Description</label>
                <p className="text-sm text-gray-900 whitespace-pre-wrap">{event.description}</p>
              </div>
            )}
          </div>
        </CardBody>
      </Card>

      {/* Date & Time */}
      {(event.startDate || event.endDate) && (
        <Card>
          <CardHeader>
            <h2 className="text-lg font-semibold text-gray-900">Date & Time</h2>
          </CardHeader>
          <CardBody>
            <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
              {event.startDate && (
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">
                    <Icon icon={faCalendar} className="inline mr-1 text-gray-400" size="sm" />
                    Start Date
                  </label>
                  <p className="text-sm text-gray-900">
                    {new Date(event.startDate).toLocaleString('en-US', {
                      month: 'long',
                      day: 'numeric',
                      year: 'numeric',
                      hour: '2-digit',
                      minute: '2-digit',
                    })}
                  </p>
                </div>
              )}

              {event.endDate && (
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">
                    <Icon icon={faCalendar} className="inline mr-1 text-gray-400" size="sm" />
                    End Date
                  </label>
                  <p className="text-sm text-gray-900">
                    {new Date(event.endDate).toLocaleString('en-US', {
                      month: 'long',
                      day: 'numeric',
                      year: 'numeric',
                      hour: '2-digit',
                      minute: '2-digit',
                    })}
                  </p>
                </div>
              )}
            </div>
          </CardBody>
        </Card>
      )}

      {/* Location Information */}
      {(event.address || event.city || event.countryId) && (
        <Card>
          <CardHeader>
            <h2 className="text-lg font-semibold text-gray-900">Location</h2>
          </CardHeader>
          <CardBody>
            <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
              {event.address && (
                <div className="md:col-span-2">
                  <label className="block text-sm font-medium text-gray-700 mb-1">
                    <Icon icon={faMapMarkerAlt} className="inline mr-1 text-gray-400" size="sm" />
                    Address
                  </label>
                  <p className="text-sm text-gray-900">{event.address}</p>
                </div>
              )}

              {event.city && (
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">City</label>
                  <p className="text-sm text-gray-900">{event.city.name}</p>
                </div>
              )}
            </div>
          </CardBody>
        </Card>
      )}

      {/* Organizer Information */}
      {event.organizer && (
        <Card>
          <CardHeader>
            <h2 className="text-lg font-semibold text-gray-900">Organizer</h2>
          </CardHeader>
          <CardBody>
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">Organization Name</label>
              <p className="text-sm text-gray-900">{event.organizer.organizationName || 'N/A'}</p>
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
            status: event.status || 'draft',
            isBlocked: event.isBlocked || false,
          });
        }}
        title="Update Event Status"
        size="md"
      >
        <div className="space-y-4">
          <Select
            label="Status"
            value={formData.status}
            onChange={(e) => setFormData({ ...formData, status: e.target.value as EventStatus })}
            options={STATUSES.map((s) => ({ value: s.value, label: s.label }))}
          />

          <div>
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

          <div className="flex items-center gap-2 justify-end pt-4 border-t border-gray-200">
            <Button
              variant="secondary"
              size="md"
              onClick={() => {
                setStatusModalOpen(false);
                setFormData({
                  status: event.status || 'draft',
                  isBlocked: event.isBlocked || false,
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

