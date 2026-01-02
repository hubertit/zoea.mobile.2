'use client';

import { useState, useEffect } from 'react';
import { useRouter, useParams, useSearchParams } from 'next/navigation';
import { ToursAPI, type Tour, type TourSchedule } from '@/src/lib/api';
import { toast } from '@/app/components/Toaster';
import { Button, Modal, Input, Breadcrumbs, StatusBadge, ConfirmDialog, DataTable } from '@/app/components';
import PageSkeleton from '@/app/components/PageSkeleton';
import Icon, { faArrowLeft, faPlus, faEdit, faTrash, faCalendar } from '@/app/components/Icon';

export default function TourSchedulesPage() {
  const router = useRouter();
  const params = useParams();
  const searchParams = useSearchParams();
  const tourId = params.id as string;
  const operatorId = searchParams.get('operatorId') || '';
  const [tour, setTour] = useState<Tour | null>(null);
  const [schedules, setSchedules] = useState<TourSchedule[]>([]);
  const [loading, setLoading] = useState(true);
  const [showModal, setShowModal] = useState(false);
  const [editingSchedule, setEditingSchedule] = useState<TourSchedule | null>(null);
  const [deletingScheduleId, setDeletingScheduleId] = useState<string | null>(null);
  const [formData, setFormData] = useState({
    date: '',
    startTime: '',
    availableSpots: '',
    priceOverride: '',
    isAvailable: true,
  });

  useEffect(() => {
    if (tourId) {
      fetchTour();
      fetchSchedules();
    }
  }, [tourId]);

  const fetchTour = async () => {
    try {
      const data = await ToursAPI.getTourById(tourId);
      setTour(data);
    } catch (error: any) {
      console.error('Failed to fetch tour:', error);
      toast.error(error?.response?.data?.message || error?.message || 'Failed to load tour');
    }
  };

  const fetchSchedules = async () => {
    setLoading(true);
    try {
      const data = await ToursAPI.getTourSchedules(tourId, { includeUnavailable: true });
      setSchedules(data || []);
    } catch (error: any) {
      console.error('Failed to fetch schedules:', error);
      toast.error(error?.response?.data?.message || error?.message || 'Failed to load schedules');
    } finally {
      setLoading(false);
    }
  };

  const handleSave = async (e: React.FormEvent) => {
    e.preventDefault();
    try {
      const data = {
        date: formData.date,
        startTime: formData.startTime || undefined,
        availableSpots: parseInt(formData.availableSpots),
        priceOverride: formData.priceOverride ? parseFloat(formData.priceOverride) : undefined,
        isAvailable: formData.isAvailable,
      };

      if (editingSchedule) {
        await ToursAPI.updateTourSchedule(editingSchedule.id, data);
        toast.success('Schedule updated successfully');
      } else {
        await ToursAPI.createTourSchedule(tourId, data);
        toast.success('Schedule created successfully');
      }
      setShowModal(false);
      setEditingSchedule(null);
      resetForm();
      fetchSchedules();
    } catch (error: any) {
      console.error('Failed to save schedule:', error);
      toast.error(error?.response?.data?.message || error?.message || 'Failed to save schedule');
    }
  };

  const handleDelete = async (scheduleId: string) => {
    try {
      await ToursAPI.deleteTourSchedule(scheduleId);
      toast.success('Schedule deleted successfully');
      fetchSchedules();
      setDeletingScheduleId(null);
    } catch (error: any) {
      console.error('Failed to delete schedule:', error);
      toast.error(error?.response?.data?.message || error?.message || 'Failed to delete schedule');
    }
  };

  const resetForm = () => {
    setFormData({
      date: '',
      startTime: '',
      availableSpots: '',
      priceOverride: '',
      isAvailable: true,
    });
  };

  const openEditModal = (schedule: TourSchedule) => {
    setEditingSchedule(schedule);
    const scheduleDate = new Date(schedule.date);
    const startTime = schedule.startTime ? new Date(schedule.startTime).toTimeString().slice(0, 5) : '';
    setFormData({
      date: scheduleDate.toISOString().split('T')[0],
      startTime: startTime,
      availableSpots: schedule.availableSpots.toString(),
      priceOverride: schedule.priceOverride?.toString() || '',
      isAvailable: schedule.isAvailable ?? true,
    });
    setShowModal(true);
  };

  const columns = [
    {
      key: 'date',
      label: 'Date',
      sortable: false,
      render: (_: any, row: TourSchedule) => (
        <div>
          <p className="font-medium text-gray-900">
            {new Date(row.date).toLocaleDateString('en-US', { weekday: 'short', year: 'numeric', month: 'short', day: 'numeric' })}
          </p>
          {row.startTime && (
            <p className="text-sm text-gray-500">
              {new Date(`1970-01-01T${row.startTime}`).toLocaleTimeString('en-US', { hour: '2-digit', minute: '2-digit' })}
            </p>
          )}
        </div>
      ),
    },
    {
      key: 'availability',
      label: 'Availability',
      sortable: false,
      render: (_: any, row: TourSchedule) => (
        <div>
          <p className="text-sm text-gray-900">
            {row.availableSpots - (row.bookedSpots || 0)} / {row.availableSpots} spots
          </p>
          {row.bookedSpots && row.bookedSpots > 0 && (
            <p className="text-xs text-gray-500">{row.bookedSpots} booked</p>
          )}
        </div>
      ),
    },
    {
      key: 'price',
      label: 'Price',
      sortable: false,
      render: (_: any, row: TourSchedule) => (
        <div>
          {row.priceOverride ? (
            <p className="font-medium text-gray-900">
              {row.priceOverride.toLocaleString()} {tour?.currency || 'USD'}
            </p>
          ) : (
            <p className="text-sm text-gray-500">
              {tour?.pricePerPerson?.toLocaleString()} {tour?.currency || 'USD'} (default)
            </p>
          )}
        </div>
      ),
    },
    {
      key: 'status',
      label: 'Status',
      sortable: false,
      render: (_: any, row: TourSchedule) => (
        <StatusBadge status={row.isAvailable ? 'active' : 'inactive'} />
      ),
    },
    {
      key: 'actions',
      label: 'Actions',
      sortable: false,
      render: (_: any, row: TourSchedule) => (
        <div className="flex gap-2">
          <Button
            variant="ghost"
            size="sm"
            icon={faEdit}
            onClick={() => openEditModal(row)}
          >
            Edit
          </Button>
          <Button
            variant="ghost"
            size="sm"
            icon={faTrash}
            onClick={() => setDeletingScheduleId(row.id)}
          >
            Delete
          </Button>
        </div>
      ),
    },
  ];

  if (loading && !tour) {
    return <PageSkeleton />;
  }

  return (
    <div className="space-y-6">
      <Breadcrumbs items={[
        { label: 'Dashboard', href: '/dashboard/my-dashboard' },
        { label: 'My Tours', href: `/dashboard/my-tours?operatorId=${operatorId}` },
        { label: tour?.name || 'Tour', href: `/dashboard/my-tours/${tourId}?operatorId=${operatorId}` },
        { label: 'Schedules' }
      ]} />

      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-bold text-gray-900">Tour Schedules</h1>
          <p className="text-gray-600 mt-1">Manage schedules for {tour?.name || 'this tour'}</p>
        </div>
        <Button
          variant="primary"
          icon={faPlus}
          onClick={() => {
            setEditingSchedule(null);
            resetForm();
            setShowModal(true);
          }}
        >
          Add Schedule
        </Button>
      </div>

      <div className="bg-white border border-gray-200 rounded-sm">
        <DataTable
          data={schedules}
          columns={columns}
          loading={loading}
        />
      </div>

      {/* Schedule Modal */}
      <Modal
        isOpen={showModal}
        onClose={() => {
          setShowModal(false);
          setEditingSchedule(null);
          resetForm();
        }}
        title={editingSchedule ? 'Edit Schedule' : 'Add Schedule'}
      >
        <form onSubmit={handleSave} className="space-y-4">
          <Input
            label="Date"
            type="date"
            value={formData.date}
            onChange={(e) => setFormData({ ...formData, date: e.target.value })}
            required
          />
          <Input
            label="Start Time (Optional)"
            type="time"
            value={formData.startTime}
            onChange={(e) => setFormData({ ...formData, startTime: e.target.value })}
          />
          <Input
            label="Available Spots"
            type="number"
            value={formData.availableSpots}
            onChange={(e) => setFormData({ ...formData, availableSpots: e.target.value })}
            required
            min="1"
          />
          <Input
            label="Price Override (Optional)"
            type="number"
            value={formData.priceOverride}
            onChange={(e) => setFormData({ ...formData, priceOverride: e.target.value })}
            placeholder={`Default: ${tour?.pricePerPerson?.toLocaleString()} ${tour?.currency || 'USD'}`}
          />
          <div className="flex items-center gap-2">
            <input
              type="checkbox"
              checked={formData.isAvailable}
              onChange={(e) => setFormData({ ...formData, isAvailable: e.target.checked })}
              className="rounded"
            />
            <span className="text-sm text-gray-700">Available for booking</span>
          </div>
          <div className="flex gap-2 justify-end">
            <Button
              type="button"
              variant="ghost"
              onClick={() => {
                setShowModal(false);
                setEditingSchedule(null);
                resetForm();
              }}
            >
              Cancel
            </Button>
            <Button type="submit" variant="primary">
              {editingSchedule ? 'Update' : 'Create'}
            </Button>
          </div>
        </form>
      </Modal>

      {/* Delete Confirmation */}
      <ConfirmDialog
        isOpen={deletingScheduleId !== null}
        onClose={() => setDeletingScheduleId(null)}
        onConfirm={() => deletingScheduleId && handleDelete(deletingScheduleId)}
        title="Delete Schedule"
        message="Are you sure you want to delete this schedule? This action cannot be undone."
      />
    </div>
  );
}

