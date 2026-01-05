'use client';

import { useState, useEffect } from 'react';
import { useRouter, useSearchParams } from 'next/navigation';
import { ToursAPI } from '@/src/lib/api';
import { toast } from '@/app/components/Toaster';
import { Button, Input, Select, SearchableSelect, Textarea, Breadcrumbs } from '@/app/components';
import PageSkeleton from '@/app/components/PageSkeleton';
import Icon, { faArrowLeft, faRoute } from '@/app/components/Icon';
import { CategoriesAPI, LocationsAPI } from '@/src/lib/api';

export default function CreateTourPage() {
  const router = useRouter();
  const searchParams = useSearchParams();
  const operatorId = searchParams.get('operatorId') || '';
  const [loading, setLoading] = useState(false);
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
    languages: ['en'],
    includes: '',
    excludes: '',
    requirements: '',
  });

  useEffect(() => {
    fetchCategories();
    fetchLocations();
  }, []);

  const fetchCategories = async () => {
    try {
      const data = await CategoriesAPI.listCategories({ flat: true });
      setCategories(data || []);
    } catch (error) {
      console.error('Failed to fetch categories:', error);
    }
  };

  const fetchLocations = async () => {
    try {
      const [countriesData, citiesData] = await Promise.all([
        LocationsAPI.getCountries(),
        LocationsAPI.getCities(),
      ]);
      setCountries(countriesData || []);
      setCities(citiesData || []);
    } catch (error) {
      console.error('Failed to fetch locations:', error);
    }
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!operatorId) {
      toast.error('Operator ID is required');
      return;
    }

    setLoading(true);
    try {
      const data: any = {
        operatorId,
        name: formData.name,
        description: formData.description || undefined,
        shortDescription: formData.shortDescription || undefined,
        type: formData.type || undefined,
        categoryId: formData.categoryId || undefined,
        countryId: formData.countryId || undefined,
        cityId: formData.cityId || undefined,
        startLocationName: formData.startLocationName || undefined,
        endLocationName: formData.endLocationName || undefined,
        currency: formData.currency || 'USD',
      };

      if (formData.durationDays) data.durationDays = parseInt(formData.durationDays);
      if (formData.durationHours) data.durationHours = parseFloat(formData.durationHours);
      if (formData.pricePerPerson) data.pricePerPerson = parseFloat(formData.pricePerPerson);
      if (formData.groupDiscountPercentage) data.groupDiscountPercentage = parseFloat(formData.groupDiscountPercentage);
      if (formData.minGroupSize) data.minGroupSize = parseInt(formData.minGroupSize);
      if (formData.maxGroupSize) data.maxGroupSize = parseInt(formData.maxGroupSize);
      if (formData.difficultyLevel) data.difficultyLevel = formData.difficultyLevel;
      if (formData.languages.length > 0) data.languages = formData.languages;
      if (formData.includes) data.includes = formData.includes.split('\n').filter(l => l.trim());
      if (formData.excludes) data.excludes = formData.excludes.split('\n').filter(l => l.trim());
      if (formData.requirements) data.requirements = formData.requirements.split('\n').filter(l => l.trim());

      const tour = await ToursAPI.createTour(data);
      toast.success('Tour created successfully');
      router.push(`/dashboard/my-tours/${tour.id}?operatorId=${operatorId}`);
    } catch (error: any) {
      console.error('Failed to create tour:', error);
      toast.error(error?.response?.data?.message || error?.message || 'Failed to create tour');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="space-y-6">
      <Breadcrumbs items={[
        { label: 'Dashboard', href: '/dashboard/my-dashboard' },
        { label: 'My Tours', href: `/dashboard/my-tours?operatorId=${operatorId}` },
        { label: 'Create Tour' }
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
            <h1 className="text-2xl font-bold text-gray-900">Create New Tour</h1>
            <p className="text-gray-600 mt-1">Add a new tour package</p>
          </div>
        </div>
      </div>

      <form onSubmit={handleSubmit} className="space-y-6">
        <div className="bg-white border border-gray-200 rounded-sm p-6">
          <h2 className="text-lg font-semibold text-gray-900 mb-4">Basic Information</h2>
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
            <SearchableSelect
              label="Category"
              value={formData.categoryId}
              onChange={(value) => setFormData({ ...formData, categoryId: value })}
              options={categories.map(c => ({ 
                value: c.id, 
                label: c.name,
                group: c.parent?.name || 'Main Category'
              }))}
              placeholder="Select category"
            />
          </div>
        </div>

        <div className="bg-white border border-gray-200 rounded-sm p-6">
          <h2 className="text-lg font-semibold text-gray-900 mb-4">Location</h2>
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
        </div>

        <div className="bg-white border border-gray-200 rounded-sm p-6">
          <h2 className="text-lg font-semibold text-gray-900 mb-4">Pricing & Details</h2>
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
          </div>
        </div>

        <div className="bg-white border border-gray-200 rounded-sm p-6">
          <h2 className="text-lg font-semibold text-gray-900 mb-4">Additional Information</h2>
          <div className="space-y-4">
            <Textarea
              label="What's Included (one per line)"
              value={formData.includes}
              onChange={(e) => setFormData({ ...formData, includes: e.target.value })}
              rows={4}
              placeholder="Transportation&#10;Meals&#10;Guide"
            />
            <Textarea
              label="What's Excluded (one per line)"
              value={formData.excludes}
              onChange={(e) => setFormData({ ...formData, excludes: e.target.value })}
              rows={4}
              placeholder="Personal expenses&#10;Tips"
            />
            <Textarea
              label="Requirements (one per line)"
              value={formData.requirements}
              onChange={(e) => setFormData({ ...formData, requirements: e.target.value })}
              rows={4}
              placeholder="Valid passport&#10;Travel insurance"
            />
          </div>
        </div>

        <div className="flex gap-2 justify-end">
          <Button
            type="button"
            variant="ghost"
            onClick={() => router.push(`/dashboard/my-tours?operatorId=${operatorId}`)}
          >
            Cancel
          </Button>
          <Button type="submit" variant="primary" loading={loading}>
            Create Tour
          </Button>
        </div>
      </form>
    </div>
  );
}

