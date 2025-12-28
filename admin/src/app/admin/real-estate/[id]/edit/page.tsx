'use client';

import { useState, useEffect } from 'react';
import { useRouter, useParams } from 'next/navigation';
import FormInput from '../../../../components/FormInput';
import Icon, { faSave, faArrowLeft, faHome, faMapMarkerAlt, faDollarSign, faBed, faBath } from '../../../../components/Icon';
import Link from 'next/link';
import { mockProperties } from '@/lib/mockData';

export default function EditPropertyPage() {
  const router = useRouter();
  const params = useParams();
  const propertyId = params.id as string;
  const [loading, setLoading] = useState(false);
  const [formData, setFormData] = useState({
    title: '',
    address: '',
    category: 'Apartment',
    bedrooms: '',
    bathrooms: '',
    size: '',
    price: '',
    property_type: 'rent',
    status: 'available',
  });

  useEffect(() => {
    const property = mockProperties.find(p => p.property_id === parseInt(propertyId));
    if (property) {
      setFormData({
        title: property.title,
        address: property.address || '',
        category: property.category,
        bedrooms: property.bedrooms?.toString() || '',
        bathrooms: property.bathrooms?.toString() || '',
        size: property.size?.toString() || '',
        price: property.price.toString(),
        property_type: property.property_type,
        status: property.status,
      });
    }
  }, [propertyId]);

  const handleChange = (e: React.ChangeEvent<HTMLInputElement | HTMLTextAreaElement | HTMLSelectElement>) => {
    setFormData({
      ...formData,
      [e.target.name]: e.target.value,
    });
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);
    
    setTimeout(() => {
      console.log('Updating property:', propertyId, formData);
      setLoading(false);
      router.push('/admin/real-estate');
    }, 1000);
  };

  return (
    <div>
      <div className="mb-8">
        <div className="flex items-center gap-4 mb-4">
          <Link
            href="/admin/real-estate"
            className="p-2 hover:bg-gray-100 rounded-sm transition-colors"
          >
            <Icon icon={faArrowLeft} />
          </Link>
          <div>
            <h1 className="text-3xl font-bold text-gray-900 mb-2">Edit Property</h1>
            <p className="text-gray-600">Update property information</p>
          </div>
        </div>
      </div>

      <form onSubmit={handleSubmit} className="bg-white rounded-sm shadow-sm border border-gray-200 p-6">
        <div className="grid grid-cols-1 md:grid-cols-2 gap-6 mb-6">
          <div className="md:col-span-2">
            <FormInput
              label="Property Title"
              name="title"
              value={formData.title}
              onChange={handleChange}
              placeholder="Modern 3BR Apartment in Kacyiru"
              required
              icon={<Icon icon={faHome} size="sm" />}
            />
          </div>
          
          <div className="md:col-span-2">
            <FormInput
              label="Address"
              name="address"
              value={formData.address}
              onChange={handleChange}
              placeholder="KG 789 St, Kacyiru, Kigali"
              required
              icon={<Icon icon={faMapMarkerAlt} size="sm" />}
            />
          </div>
          
          <FormInput
            label="Category"
            name="category"
            type="select"
            value={formData.category}
            onChange={handleChange}
            required
            options={[
              { value: 'Apartment', label: 'Apartment' },
              { value: 'House', label: 'House' },
              { value: 'Commercial', label: 'Commercial' },
              { value: 'Land', label: 'Land' },
              { value: 'Development', label: 'Development' },
            ]}
          />
          
          <FormInput
            label="Property Type"
            name="property_type"
            type="select"
            value={formData.property_type}
            onChange={handleChange}
            required
            options={[
              { value: 'rent', label: 'Rent' },
              { value: 'sale', label: 'Sale' },
              { value: 'booking', label: 'Booking' },
            ]}
          />
          
          <FormInput
            label="Bedrooms"
            name="bedrooms"
            type="number"
            value={formData.bedrooms}
            onChange={handleChange}
            placeholder="3"
            icon={<Icon icon={faBed} size="sm" />}
          />
          
          <FormInput
            label="Bathrooms"
            name="bathrooms"
            type="number"
            value={formData.bathrooms}
            onChange={handleChange}
            placeholder="2"
            icon={<Icon icon={faBath} size="sm" />}
          />
          
          <FormInput
            label="Size (sqm)"
            name="size"
            type="number"
            value={formData.size}
            onChange={handleChange}
            placeholder="120"
          />
          
          <FormInput
            label="Price (RWF)"
            name="price"
            type="number"
            value={formData.price}
            onChange={handleChange}
            placeholder="150000"
            required
            icon={<Icon icon={faDollarSign} size="sm" />}
          />
          
          <FormInput
            label="Status"
            name="status"
            type="select"
            value={formData.status}
            onChange={handleChange}
            required
            options={[
              { value: 'available', label: 'Available' },
              { value: 'sold', label: 'Sold' },
              { value: 'rented', label: 'Rented' },
            ]}
          />
        </div>

        <div className="flex items-center gap-4 pt-6 border-t border-gray-200">
          <button
            type="submit"
            disabled={loading}
            className="flex items-center gap-2 bg-primary text-white px-6 py-3 rounded-sm hover:bg-primary-600 transition-colors disabled:opacity-50 disabled:cursor-not-allowed"
          >
            <Icon icon={faSave} />
            <span>{loading ? 'Saving...' : 'Save Changes'}</span>
          </button>
          <Link
            href="/admin/real-estate"
            className="flex items-center gap-2 px-6 py-3 border border-gray-300 text-gray-700 rounded-sm hover:bg-gray-50 transition-colors"
          >
            Cancel
          </Link>
        </div>
      </form>
    </div>
  );
}

