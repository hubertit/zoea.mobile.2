'use client';

import { useState, useEffect } from 'react';
import { useRouter, useParams, useSearchParams } from 'next/navigation';
import { MerchantPortalAPI } from '@/src/lib/api';
import { toast } from '@/app/components/Toaster';
import { Button, Modal, Input, Select, Textarea, Breadcrumbs, StatusBadge, ConfirmDialog, DataTable, Pagination } from '@/app/components';
import PageSkeleton from '@/app/components/PageSkeleton';
import Icon, { faPlus, faEdit, faTrash, faCalendar } from '@/app/components/Icon';

export default function ServicesPage() {
  const router = useRouter();
  const params = useParams();
  const searchParams = useSearchParams();
  const listingId = params.id as string;
  const businessId = searchParams.get('businessId') || '';
  const [services, setServices] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);
  const [page, setPage] = useState(1);
  const [pageSize, setPageSize] = useState(20);
  const [total, setTotal] = useState(0);
  const [showModal, setShowModal] = useState(false);
  const [editingService, setEditingService] = useState<any>(null);
  const [deletingServiceId, setDeletingServiceId] = useState<string | null>(null);
  const [formData, setFormData] = useState({
    name: '',
    description: '',
    shortDescription: '',
    basePrice: '',
    priceUnit: 'fixed',
    currency: 'RWF',
    duration: '',
    durationUnit: 'hours',
    category: '',
    tags: '',
    isAvailable: true,
    maxConcurrentBookings: '1',
    requiresApproval: false,
    status: 'draft',
    isFeatured: false,
  });

  useEffect(() => {
    if (businessId && listingId) {
      fetchServices();
    }
  }, [businessId, listingId, page, pageSize]);

  const fetchServices = async () => {
    if (!businessId || !listingId) return;
    setLoading(true);
    try {
      const response = await MerchantPortalAPI.getServices(listingId, {
        page,
        limit: pageSize,
      });
      setServices(response.data || []);
      setTotal(response.meta?.total || 0);
    } catch (error: any) {
      console.error('Failed to fetch services:', error);
      toast.error(error?.response?.data?.message || error?.message || 'Failed to load services');
    } finally {
      setLoading(false);
    }
  };

  const handleSave = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!businessId || !listingId) return;

    try {
      const data = {
        listingId,
        name: formData.name,
        description: formData.description || undefined,
        shortDescription: formData.shortDescription || undefined,
        basePrice: parseFloat(formData.basePrice),
        priceUnit: formData.priceUnit as any,
        currency: formData.currency,
        duration: formData.duration ? parseFloat(formData.duration) : undefined,
        durationUnit: formData.durationUnit as any,
        category: formData.category || undefined,
        tags: formData.tags ? formData.tags.split(',').map(t => t.trim()) : [],
        isAvailable: formData.isAvailable,
        maxConcurrentBookings: parseInt(formData.maxConcurrentBookings),
        requiresApproval: formData.requiresApproval,
        status: formData.status as any,
        isFeatured: formData.isFeatured,
      };

      if (editingService) {
        await MerchantPortalAPI.updateService(editingService.id, data);
        toast.success('Service updated successfully');
      } else {
        await MerchantPortalAPI.createService(data);
        toast.success('Service created successfully');
      }
      setShowModal(false);
      setEditingService(null);
      resetForm();
      fetchServices();
    } catch (error: any) {
      console.error('Failed to save service:', error);
      toast.error(error?.response?.data?.message || error?.message || 'Failed to save service');
    }
  };

  const handleDelete = async (serviceId: string) => {
    if (!businessId) return;
    try {
      await MerchantPortalAPI.deleteService(serviceId);
      toast.success('Service deleted successfully');
      fetchServices();
      setDeletingServiceId(null);
    } catch (error: any) {
      console.error('Failed to delete service:', error);
      toast.error(error?.response?.data?.message || error?.message || 'Failed to delete service');
    }
  };

  const resetForm = () => {
    setFormData({
      name: '',
      description: '',
      shortDescription: '',
      basePrice: '',
      priceUnit: 'fixed',
      currency: 'RWF',
      duration: '',
      durationUnit: 'hours',
      category: '',
      tags: '',
      isAvailable: true,
      maxConcurrentBookings: '1',
      requiresApproval: false,
      status: 'draft',
      isFeatured: false,
    });
  };

  const openEditModal = (service: any) => {
    setEditingService(service);
    setFormData({
      name: service.name || '',
      description: service.description || '',
      shortDescription: service.shortDescription || '',
      basePrice: service.basePrice?.toString() || '',
      priceUnit: service.priceUnit || 'fixed',
      currency: service.currency || 'RWF',
      duration: service.duration?.toString() || '',
      durationUnit: service.durationUnit || 'hours',
      category: service.category || '',
      tags: service.tags?.join(', ') || '',
      isAvailable: service.isAvailable ?? true,
      maxConcurrentBookings: service.maxConcurrentBookings?.toString() || '1',
      requiresApproval: service.requiresApproval ?? false,
      status: service.status || 'draft',
      isFeatured: service.isFeatured ?? false,
    });
    setShowModal(true);
  };

  const columns = [
    {
      key: 'name',
      label: 'Service',
      sortable: false,
      render: (_: any, row: any) => (
        <div>
          <p className="font-medium text-gray-900">{row.name}</p>
          {row.shortDescription && (
            <p className="text-sm text-gray-500">{row.shortDescription}</p>
          )}
        </div>
      ),
    },
    {
      key: 'price',
      label: 'Price',
      sortable: false,
      render: (_: any, row: any) => (
        <div>
          <p className="font-medium text-gray-900">
            {row.basePrice?.toLocaleString()} {row.currency || 'RWF'}
          </p>
          <p className="text-sm text-gray-500">
            {row.priceUnit === 'fixed' ? 'Fixed' :
             row.priceUnit === 'per_hour' ? 'Per Hour' :
             row.priceUnit === 'per_session' ? 'Per Session' : row.priceUnit}
          </p>
        </div>
      ),
    },
    {
      key: 'duration',
      label: 'Duration',
      sortable: false,
      render: (_: any, row: any) => (
        <div>
          {row.duration ? (
            <p className="text-sm text-gray-900">
              {row.duration} {row.durationUnit || 'hours'}
            </p>
          ) : (
            <p className="text-sm text-gray-500">Not specified</p>
          )}
        </div>
      ),
    },
    {
      key: 'status',
      label: 'Status',
      sortable: false,
      render: (_: any, row: any) => (
        <StatusBadge
          status={
            row.status === 'active' ? 'active' :
            row.status === 'draft' ? 'pending' : 'pending'
          }
        />
      ),
    },
    {
      key: 'actions',
      label: 'Actions',
      sortable: false,
      render: (_: any, row: any) => (
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
            onClick={() => setDeletingServiceId(row.id)}
          >
            Delete
          </Button>
        </div>
      ),
    },
  ];

  if (loading && services.length === 0) {
    return <PageSkeleton />;
  }

  return (
    <div className="space-y-6">
      <Breadcrumbs items={[
        { label: 'Dashboard', href: '/dashboard/my-dashboard' },
        { label: 'My Listings', href: `/dashboard/my-listings?businessId=${businessId}` },
        { label: 'Listing Details', href: `/dashboard/my-listings/${listingId}?businessId=${businessId}` },
        { label: 'Services' }
      ]} />

      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-bold text-gray-900">Services</h1>
          <p className="text-gray-600 mt-1">Manage bookable services for this listing</p>
        </div>
        <Button
          variant="primary"
          icon={faPlus}
          onClick={() => {
            setEditingService(null);
            resetForm();
            setShowModal(true);
          }}
        >
          Add Service
        </Button>
      </div>

      <div className="bg-white border border-gray-200 rounded-sm">
        <DataTable
          data={services}
          columns={columns}
          loading={loading}
        />
        {total > pageSize && (
          <div className="p-4 border-t border-gray-200">
            <Pagination
              currentPage={page}
              totalPages={Math.ceil(total / pageSize)}
              onPageChange={setPage}
            />
          </div>
        )}
      </div>

      {/* Service Modal */}
      <Modal
        isOpen={showModal}
        onClose={() => {
          setShowModal(false);
          setEditingService(null);
          resetForm();
        }}
        title={editingService ? 'Edit Service' : 'Add Service'}
      >
        <form onSubmit={handleSave} className="space-y-4">
          <Input
            label="Service Name"
            value={formData.name}
            onChange={(e) => setFormData({ ...formData, name: e.target.value })}
            required
          />
          <Input
            label="Short Description"
            value={formData.shortDescription}
            onChange={(e) => setFormData({ ...formData, shortDescription: e.target.value })}
            placeholder="Brief service description"
          />
          <Textarea
            label="Description"
            value={formData.description}
            onChange={(e) => setFormData({ ...formData, description: e.target.value })}
            rows={4}
          />
          <div className="grid grid-cols-2 gap-4">
            <Input
              label="Base Price"
              type="number"
              value={formData.basePrice}
              onChange={(e) => setFormData({ ...formData, basePrice: e.target.value })}
              required
            />
            <Select
              label="Price Unit"
              value={formData.priceUnit}
              onChange={(e) => setFormData({ ...formData, priceUnit: e.target.value })}
              options={[
                { value: 'fixed', label: 'Fixed Price' },
                { value: 'per_hour', label: 'Per Hour' },
                { value: 'per_session', label: 'Per Session' },
              ]}
            />
          </div>
          <div className="grid grid-cols-2 gap-4">
            <Input
              label="Duration"
              type="number"
              value={formData.duration}
              onChange={(e) => setFormData({ ...formData, duration: e.target.value })}
              placeholder="e.g., 2"
            />
            <Select
              label="Duration Unit"
              value={formData.durationUnit}
              onChange={(e) => setFormData({ ...formData, durationUnit: e.target.value })}
              options={[
                { value: 'hours', label: 'Hours' },
                { value: 'minutes', label: 'Minutes' },
                { value: 'days', label: 'Days' },
              ]}
            />
          </div>
          <div className="grid grid-cols-2 gap-4">
            <Select
              label="Currency"
              value={formData.currency}
              onChange={(e) => setFormData({ ...formData, currency: e.target.value })}
              options={[
                { value: 'RWF', label: 'RWF' },
                { value: 'USD', label: 'USD' },
                { value: 'EUR', label: 'EUR' },
              ]}
            />
            <Select
              label="Status"
              value={formData.status}
              onChange={(e) => setFormData({ ...formData, status: e.target.value })}
              options={[
                { value: 'draft', label: 'Draft' },
                { value: 'active', label: 'Active' },
                { value: 'inactive', label: 'Inactive' },
              ]}
            />
          </div>
          <Input
            label="Max Concurrent Bookings"
            type="number"
            value={formData.maxConcurrentBookings}
            onChange={(e) => setFormData({ ...formData, maxConcurrentBookings: e.target.value })}
            placeholder="1"
          />
          <Input
            label="Category (Optional)"
            value={formData.category}
            onChange={(e) => setFormData({ ...formData, category: e.target.value })}
            placeholder="e.g., Wellness, Beauty"
          />
          <Input
            label="Tags (comma-separated)"
            value={formData.tags}
            onChange={(e) => setFormData({ ...formData, tags: e.target.value })}
            placeholder="tag1, tag2, tag3"
          />
          <div className="flex items-center gap-4">
            <label className="flex items-center gap-2">
              <input
                type="checkbox"
                checked={formData.isAvailable}
                onChange={(e) => setFormData({ ...formData, isAvailable: e.target.checked })}
                className="rounded"
              />
              <span className="text-sm text-gray-700">Available</span>
            </label>
            <label className="flex items-center gap-2">
              <input
                type="checkbox"
                checked={formData.requiresApproval}
                onChange={(e) => setFormData({ ...formData, requiresApproval: e.target.checked })}
                className="rounded"
              />
              <span className="text-sm text-gray-700">Requires Approval</span>
            </label>
            <label className="flex items-center gap-2">
              <input
                type="checkbox"
                checked={formData.isFeatured}
                onChange={(e) => setFormData({ ...formData, isFeatured: e.target.checked })}
                className="rounded"
              />
              <span className="text-sm text-gray-700">Featured</span>
            </label>
          </div>
          <div className="flex gap-2 justify-end">
            <Button
              type="button"
              variant="ghost"
              onClick={() => {
                setShowModal(false);
                setEditingService(null);
                resetForm();
              }}
            >
              Cancel
            </Button>
            <Button type="submit" variant="primary">
              {editingService ? 'Update' : 'Create'}
            </Button>
          </div>
        </form>
      </Modal>

      {/* Delete Confirmation */}
      <ConfirmDialog
        isOpen={deletingServiceId !== null}
        onClose={() => setDeletingServiceId(null)}
        onConfirm={() => deletingServiceId && handleDelete(deletingServiceId)}
        title="Delete Service"
        message="Are you sure you want to delete this service? This action cannot be undone."
      />
    </div>
  );
}

