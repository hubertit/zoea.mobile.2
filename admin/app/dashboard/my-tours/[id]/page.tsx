'use client';

import { useState, useEffect } from 'react';
import { useRouter, useParams, useSearchParams } from 'next/navigation';
import { ToursAPI, type Tour } from '@/src/lib/api';
import { toast } from '@/app/components/Toaster';
import { Button, Modal, Input, Select, Textarea, Breadcrumbs, StatusBadge, ConfirmDialog } from '@/app/components';
import PageSkeleton from '@/app/components/PageSkeleton';
import Icon, { faArrowLeft, faEdit, faTrash, faRoute, faCalendar, faPlus } from '@/app/components/Icon';
import { CategoriesAPI, LocationsAPI } from '@/src/lib/api';

export default function TourDetailPage() {
  const router = useRouter();
  const params = useParams();
  const searchParams = useSearchParams();
  const tourId = params.id as string;
  const operatorId = searchParams.get('operatorId') || '';
  const [tour, setTour] = useState<Tour | null>(null);
  const [loading, setLoading] = useState(true);
  const [editMode, setEditMode] = useState(false);
  const [saving, setSaving] = useState(false);
  const [deleting, setDeleting] = useState(false);
  const [showDeleteModal, setShowDeleteModal] = useState(false);
  const [categories, setCategories] = useState<any[]>([]);
  const [countries, setCountries] = useState<any[]>([]);
  const [cities, setCities] = useState<any[]>([]);
  const [formData, setFormData] = useState({
    name: '',
    description: '',
    shortDescription: '',
    type: '',
    categoryId: '',
    countryId: '',
    cityId: '',
    startLocationName: '',
    endLocationName: '',
    durationDays: '',
    durationHours: '',
    pricePerPerson: '',
    currency: 'USD',
    groupDiscountPercentage: '',
    minGroupSize: '1',
    maxGroupSize: '20',
    difficultyLevel: '',
    languages: [] as string[],
    includes: [] as string[],
    excludes: [] as string[],
    requirements: [] as string[],
    status: 'draft',
  });

  useEffect(() => {
    if (tourId) {
      fetchTour();
      fetchCategories();
      fetchLocations();
    }
  }, [tourId]);

  const fetchTour = async () => {
    setLoading(true);
    try {
      const data = await ToursAPI.getTourById(tourId);
      setTour(data);
      setFormData({
        name: data.name || '',
        description: data.description || '',
        shortDescription: data.shortDescription || '',
        type: data.type || '',
        categoryId: data.categoryId || '',
        countryId: data.countryId || '',
        cityId: data.cityId || '',
        startLocationName: (data as any).startLocationName || '',
        endLocationName: (data as any).endLocationName || '',
        durationDays: (data as any).durationDays?.toString() || '',
        durationHours: (data as any).durationHours?.toString() || '',
        pricePerPerson: data.pricePerPerson?.toString() || '',
        currency: data.currency || 'USD',
        groupDiscountPercentage: (data as any).groupDiscountPercentage?.toString() || '',
        minGroupSize: (data as any).minGroupSize?.toString() || '1',
        maxGroupSize: (data as any).maxGroupSize?.toString() || '20',
        difficultyLevel: (data as any).difficultyLevel || '',
        languages: (data as any).languages || ['en'],
        includes: (data as any).includes || [],
        excludes: (data as any).excludes || [],
        requirements: (data as any).requirements || [],
        status: data.status || 'draft',
      });
    } catch (error: any) {
      console.error('Failed to fetch tour:', error);
      toast.error(error?.response?.data?.message || error?.message || 'Failed to load tour');
    } finally {
      setLoading(false);
    }
  };

  const fetchCategories = async () => {
    try {
      const data = await CategoriesAPI.listCategories({ type: 'tour' });
      setCategories(data.data || []);
    } catch (error) {
      console.error('Failed to fetch categories:', error);
    }
  };

  const fetchLocations = async () => {
    try {
      const [countriesData, citiesData] = await Promise.all([
        LocationsAPI.listCountries(),
        LocationsAPI.listCities(),
      ]);
      setCountries(countriesData || []);
      setCities(citiesData || []);
    } catch (error) {
      console.error('Failed to fetch locations:', error);
    }
  };

  const handleSave = async () => {
    if (!operatorId) return;
    setSaving(true);
    try {
      const data: any = {};
      if (formData.name) data.name = formData.name;
      if (formData.description) data.description = formData.description;
      if (formData.shortDescription) data.shortDescription = formData.shortDescription;
      if (formData.type) data.type = formData.type;
      if (formData.categoryId) data.categoryId = formData.categoryId;
      if (formData.countryId) data.countryId = formData.countryId;
      if (formData.cityId) data.cityId = formData.cityId;
      if (formData.startLocationName) data.startLocationName = formData.startLocationName;
      if (formData.endLocationName) data.endLocationName = formData.endLocationName;
      if (formData.durationDays) data.durationDays = parseInt(formData.durationDays);
      if (formData.durationHours) data.durationHours = parseFloat(formData.durationHours);
      if (formData.pricePerPerson) data.pricePerPerson = parseFloat(formData.pricePerPerson);
      if (formData.currency) data.currency = formData.currency;
      if (formData.groupDiscountPercentage) data.groupDiscountPercentage = parseFloat(formData.groupDiscountPercentage);
      if (formData.minGroupSize) data.minGroupSize = parseInt(formData.minGroupSize);
      if (formData.maxGroupSize) data.maxGroupSize = parseInt(formData.maxGroupSize);
      if (formData.difficultyLevel) data.difficultyLevel = formData.difficultyLevel;
      if (formData.languages.length > 0) data.languages = formData.languages;
      if (formData.includes.length > 0) data.includes = formData.includes;
      if (formData.excludes.length > 0) data.excludes = formData.excludes;
      if (formData.requirements.length > 0) data.requirements = formData.requirements;
      if (formData.status) data.status = formData.status;

      await ToursAPI.updateTour(tourId, data);
      toast.success('Tour updated successfully');
      setEditMode(false);
      fetchTour();
    } catch (error: any) {
      console.error('Failed to update tour:', error);
      toast.error(error?.response?.data?.message || error?.message || 'Failed to update tour');
    } finally {
      setSaving(false);
    }
  };

  const handleDelete = async () => {
    setDeleting(true);
    try {
      await ToursAPI.deleteTour(tourId);
      toast.success('Tour deleted successfully');
      router.push(`/dashboard/my-tours?operatorId=${operatorId}`);
    } catch (error: any) {
      console.error('Failed to delete tour:', error);
      toast.error(error?.response?.data?.message || error?.message || 'Failed to delete tour');
    } finally {
      setDeleting(false);
      setShowDeleteModal(false);
    }
  };

  if (loading) {
    return <PageSkeleton />;
  }

  if (!tour) {
    return (
      <div className="space-y-6">
        <Breadcrumbs items={[
          { label: 'Dashboard', href: '/dashboard/my-dashboard' },
          { label: 'My Tours', href: `/dashboard/my-tours?operatorId=${operatorId}` },
          { label: 'Tour Details' }
        ]} />
        <div className="text-center py-12">
          <p className="text-gray-600">Tour not found</p>
        </div>
      </div>
    );
  }

  return (
    <div className="space-y-6">
      <Breadcrumbs items={[
        { label: 'Dashboard', href: '/dashboard/my-dashboard' },
        { label: 'My Tours', href: `/dashboard/my-tours?operatorId=${operatorId}` },
        { label: tour.name }
      ]} />

      <div className="flex items-center justify-between">
        <div className="flex items-center gap-4">
          <Button
            variant="ghost"
            size="sm"
            icon={faArrowLeft}
            onClick={() => router.push(`/dashboard/my-tours?operatorId=${operatorId}`)}
          >
            Back
          </Button>
          <div>
            <h1 className="text-2xl font-bold text-gray-900">{tour.name}</h1>
            <p className="text-gray-600 mt-1">{tour.operator?.companyName || 'Tour Operator'}</p>
          </div>
        </div>
        <div className="flex items-center gap-2">
          {!editMode ? (
            <>
              <Button
                variant="ghost"
                size="sm"
                icon={faCalendar}
                onClick={() => router.push(`/dashboard/my-tours/${tourId}/schedules?operatorId=${operatorId}`)}
              >
                Manage Schedules
              </Button>
              <Button
                variant="ghost"
                size="sm"
                icon={faEdit}
                onClick={() => setEditMode(true)}
              >
                Edit Tour
              </Button>
              <Button
                variant="ghost"
                size="sm"
                icon={faTrash}
                onClick={() => setShowDeleteModal(true)}
              >
                Delete
              </Button>
            </>
          ) : (
            <>
              <Button
                variant="ghost"
                size="sm"
                onClick={() => {
                  setEditMode(false);
                  fetchTour();
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

      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        {/* Left Column */}
        <div className="space-y-6">
          <div className="bg-white border border-gray-200 rounded-sm p-6">
            <h2 className="text-lg font-semibold text-gray-900 mb-4">Tour Information</h2>
            {editMode ? (
              <div className="space-y-4">
                <Input
                  label="Tour Name"
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
                    { value: 'wildlife', label: 'Wildlife' },
                    { value: 'cultural', label: 'Cultural' },
                    { value: 'adventure', label: 'Adventure' },
                    { value: 'hiking', label: 'Hiking' },
                    { value: 'city', label: 'City' },
                    { value: 'beach', label: 'Beach' },
                    { value: 'safari', label: 'Safari' },
                  ]}
                />
                <Select
                  label="Category"
                  value={formData.categoryId}
                  onChange={(e) => setFormData({ ...formData, categoryId: e.target.value })}
                  options={[
                    { value: '', label: 'Select category' },
                    ...categories.map(c => ({ value: c.id, label: c.name })),
                  ]}
                />
              </div>
            ) : (
              <div className="space-y-3">
                <div>
                  <p className="text-sm text-gray-600">Name</p>
                  <p className="text-gray-900 font-medium">{tour.name}</p>
                </div>
                {tour.shortDescription && (
                  <div>
                    <p className="text-sm text-gray-600">Short Description</p>
                    <p className="text-gray-900">{tour.shortDescription}</p>
                  </div>
                )}
                {tour.description && (
                  <div>
                    <p className="text-sm text-gray-600">Description</p>
                    <p className="text-gray-900">{tour.description}</p>
                  </div>
                )}
                <div>
                  <p className="text-sm text-gray-600">Type</p>
                  <p className="text-gray-900 capitalize">{tour.type || 'N/A'}</p>
                </div>
                <div>
                  <p className="text-sm text-gray-600">Category</p>
                  <p className="text-gray-900">{tour.category?.name || 'N/A'}</p>
                </div>
              </div>
            )}
          </div>

          <div className="bg-white border border-gray-200 rounded-sm p-6">
            <h2 className="text-lg font-semibold text-gray-900 mb-4">Location</h2>
            {editMode ? (
              <div className="space-y-4">
                <Select
                  label="Country"
                  value={formData.countryId}
                  onChange={(e) => {
                    setFormData({ ...formData, countryId: e.target.value, cityId: '' });
                  }}
                  options={[
                    { value: '', label: 'Select country' },
                    ...countries.map(c => ({ value: c.id, label: c.name })),
                  ]}
                />
                <Select
                  label="City"
                  value={formData.cityId}
                  onChange={(e) => setFormData({ ...formData, cityId: e.target.value })}
                  options={[
                    { value: '', label: 'Select city' },
                    ...cities.filter(c => !formData.countryId || c.countryId === formData.countryId).map(c => ({ value: c.id, label: c.name })),
                  ]}
                />
                <Input
                  label="Start Location"
                  value={formData.startLocationName}
                  onChange={(e) => setFormData({ ...formData, startLocationName: e.target.value })}
                  placeholder="e.g., Volcanoes National Park"
                />
                <Input
                  label="End Location"
                  value={formData.endLocationName}
                  onChange={(e) => setFormData({ ...formData, endLocationName: e.target.value })}
                  placeholder="e.g., Kigali City"
                />
              </div>
            ) : (
              <div className="space-y-3">
                <div>
                  <p className="text-sm text-gray-600">Location</p>
                  <p className="text-gray-900">
                    {tour.city?.name || ''}{tour.country?.name ? `, ${tour.country.name}` : ''}
                  </p>
                </div>
                {(tour as any).startLocationName && (
                  <div>
                    <p className="text-sm text-gray-600">Start Location</p>
                    <p className="text-gray-900">{(tour as any).startLocationName}</p>
                  </div>
                )}
                {(tour as any).endLocationName && (
                  <div>
                    <p className="text-sm text-gray-600">End Location</p>
                    <p className="text-gray-900">{(tour as any).endLocationName}</p>
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
                  <StatusBadge
                    status={
                      tour.status === 'active' ? 'active' :
                      tour.status === 'draft' ? 'pending' : 'inactive'
                    }
                  />
                </div>
              </div>
            </div>
          </div>

          <div className="bg-white border border-gray-200 rounded-sm p-6">
            <h2 className="text-lg font-semibold text-gray-900 mb-4">Pricing & Details</h2>
            {editMode ? (
              <div className="space-y-4">
                <div className="grid grid-cols-2 gap-4">
                  <Input
                    label="Duration (Days)"
                    type="number"
                    value={formData.durationDays}
                    onChange={(e) => setFormData({ ...formData, durationDays: e.target.value })}
                  />
                  <Input
                    label="Duration (Hours)"
                    type="number"
                    value={formData.durationHours}
                    onChange={(e) => setFormData({ ...formData, durationHours: e.target.value })}
                  />
                </div>
                <div className="grid grid-cols-2 gap-4">
                  <Input
                    label="Price Per Person"
                    type="number"
                    value={formData.pricePerPerson}
                    onChange={(e) => setFormData({ ...formData, pricePerPerson: e.target.value })}
                  />
                  <Select
                    label="Currency"
                    value={formData.currency}
                    onChange={(e) => setFormData({ ...formData, currency: e.target.value })}
                    options={[
                      { value: 'USD', label: 'USD' },
                      { value: 'RWF', label: 'RWF' },
                      { value: 'EUR', label: 'EUR' },
                    ]}
                  />
                </div>
                <div className="grid grid-cols-2 gap-4">
                  <Input
                    label="Min Group Size"
                    type="number"
                    value={formData.minGroupSize}
                    onChange={(e) => setFormData({ ...formData, minGroupSize: e.target.value })}
                  />
                  <Input
                    label="Max Group Size"
                    type="number"
                    value={formData.maxGroupSize}
                    onChange={(e) => setFormData({ ...formData, maxGroupSize: e.target.value })}
                  />
                </div>
                <Input
                  label="Group Discount (%)"
                  type="number"
                  value={formData.groupDiscountPercentage}
                  onChange={(e) => setFormData({ ...formData, groupDiscountPercentage: e.target.value })}
                />
                <Select
                  label="Difficulty Level"
                  value={formData.difficultyLevel}
                  onChange={(e) => setFormData({ ...formData, difficultyLevel: e.target.value })}
                  options={[
                    { value: '', label: 'Select difficulty' },
                    { value: 'easy', label: 'Easy' },
                    { value: 'moderate', label: 'Moderate' },
                    { value: 'hard', label: 'Hard' },
                    { value: 'extreme', label: 'Extreme' },
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
            ) : (
              <div className="space-y-3">
                {tour.pricePerPerson && (
                  <div>
                    <p className="text-sm text-gray-600">Price Per Person</p>
                    <p className="text-gray-900 font-medium">
                      {tour.pricePerPerson.toLocaleString()} {tour.currency || 'USD'}
                    </p>
                  </div>
                )}
                {(tour as any).durationDays && (
                  <div>
                    <p className="text-sm text-gray-600">Duration</p>
                    <p className="text-gray-900">
                      {(tour as any).durationDays} day(s)
                      {(tour as any).durationHours && `, ${(tour as any).durationHours} hour(s)`}
                    </p>
                  </div>
                )}
                {(tour as any).minGroupSize && (tour as any).maxGroupSize && (
                  <div>
                    <p className="text-sm text-gray-600">Group Size</p>
                    <p className="text-gray-900">
                      {(tour as any).minGroupSize} - {(tour as any).maxGroupSize} people
                    </p>
                  </div>
                )}
                {(tour as any).difficultyLevel && (
                  <div>
                    <p className="text-sm text-gray-600">Difficulty</p>
                    <p className="text-gray-900 capitalize">{(tour as any).difficultyLevel}</p>
                  </div>
                )}
              </div>
            )}
          </div>
        </div>
      </div>

      {/* Delete Confirmation */}
      <ConfirmDialog
        isOpen={showDeleteModal}
        onClose={() => setShowDeleteModal(false)}
        onConfirm={handleDelete}
        title="Delete Tour"
        message="Are you sure you want to delete this tour? This action cannot be undone."
      />
    </div>
  );
}

