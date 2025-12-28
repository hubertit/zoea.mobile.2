'use client';

import { useState } from 'react';
import { useParams, useRouter } from 'next/navigation';
import FormInput from '../../../../../components/FormInput';
import Icon, { faSave, faArrowLeft, faList, faDollarSign, faTag } from '../../../../../components/Icon';
import Link from 'next/link';

export default function CreateListingPage() {
  const params = useParams();
  const router = useRouter();
  const merchant_id = params.id as string;
  const [loading, setLoading] = useState(false);
  const [formData, setFormData] = useState({
    listing_type: 'hotel',
    listing_name: '',
    description: '',
    price: '',
    currency: 'RWF',
    category: '',
    capacity: '',
    availability: 'available',
    status: 'draft',
  });

  const handleChange = (e: React.ChangeEvent<HTMLInputElement | HTMLTextAreaElement | HTMLSelectElement>) => {
    setFormData({
      ...formData,
      [e.target.name]: e.target.value,
    });
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);
    
    try {
      const response = await fetch(`/api/merchants/${merchant_id}/listings`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          ...formData,
          price: parseFloat(formData.price),
          capacity: formData.capacity ? parseInt(formData.capacity) : null,
        }),
      });

      if (response.ok) {
        router.push(`/admin/merchants/${merchant_id}`);
      } else {
        const error = await response.json();
        alert(error.error || 'Failed to create listing');
      }
    } catch (error) {
      console.error('Error creating listing:', error);
      alert('Failed to create listing');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div>
      <div className="mb-8">
        <div className="flex items-center gap-4 mb-4">
          <Link
            href={`/admin/merchants/${merchant_id}`}
            className="p-2 hover:bg-gray-100 rounded-sm transition-colors"
          >
            <Icon icon={faArrowLeft} />
          </Link>
          <div>
            <h1 className="text-3xl font-bold text-gray-900 mb-2">Create New Listing</h1>
            <p className="text-gray-600">Add a new listing for this merchant</p>
          </div>
        </div>
      </div>

      <form onSubmit={handleSubmit} className="bg-white rounded-sm shadow-sm border border-gray-200 p-6">
        <div className="grid grid-cols-1 md:grid-cols-2 gap-6 mb-6">
          <FormInput
            label="Listing Type"
            name="listing_type"
            type="select"
            value={formData.listing_type}
            onChange={handleChange}
            required
            icon={<Icon icon={faTag} size="sm" />}
            options={[
              { value: 'hotel', label: 'Hotel Room' },
              { value: 'restaurant', label: 'Restaurant Menu/Table' },
              { value: 'venue', label: 'Venue/Event Space' },
              { value: 'product', label: 'Product' },
              { value: 'service', label: 'Service' },
            ]}
          />
          
          <FormInput
            label="Listing Name"
            name="listing_name"
            value={formData.listing_name}
            onChange={handleChange}
            placeholder="Deluxe Suite, Conference Hall, etc."
            required
            icon={<Icon icon={faList} size="sm" />}
          />
          
          <FormInput
            label="Price"
            name="price"
            type="number"
            value={formData.price}
            onChange={handleChange}
            placeholder="50000"
            required
            icon={<Icon icon={faDollarSign} size="sm" />}
          />
          
          <FormInput
            label="Currency"
            name="currency"
            type="select"
            value={formData.currency}
            onChange={handleChange}
            required
            options={[
              { value: 'RWF', label: 'RWF (Rwandan Franc)' },
              { value: 'USD', label: 'USD (US Dollar)' },
              { value: 'EUR', label: 'EUR (Euro)' },
              { value: 'GBP', label: 'GBP (British Pound)' },
            ]}
          />
          
          <FormInput
            label="Category"
            name="category"
            value={formData.category}
            onChange={handleChange}
            placeholder="e.g., Standard, Deluxe, Premium"
          />
          
          <FormInput
            label="Capacity"
            name="capacity"
            type="number"
            value={formData.capacity}
            onChange={handleChange}
            placeholder="e.g., 2 for double room, 50 for event hall"
          />
          
          <FormInput
            label="Availability"
            name="availability"
            type="select"
            value={formData.availability}
            onChange={handleChange}
            required
            options={[
              { value: 'available', label: 'Available' },
              { value: 'unavailable', label: 'Unavailable' },
              { value: 'booked', label: 'Booked' },
            ]}
          />
          
          <FormInput
            label="Status"
            name="status"
            type="select"
            value={formData.status}
            onChange={handleChange}
            required
            options={[
              { value: 'draft', label: 'Draft' },
              { value: 'active', label: 'Active' },
              { value: 'inactive', label: 'Inactive' },
            ]}
          />
        </div>

        <div className="mb-6">
          <FormInput
            label="Description"
            name="description"
            type="textarea"
            value={formData.description}
            onChange={handleChange}
            placeholder="Describe the listing, amenities, features, etc."
            required
            rows={6}
          />
        </div>

        <div className="bg-blue-50 border border-blue-200 rounded-sm p-4 mb-6">
          <h3 className="font-semibold text-blue-900 mb-2">Listing Type Examples</h3>
          <ul className="text-sm text-blue-800 space-y-1">
            <li><strong>Hotel:</strong> Standard Room, Deluxe Suite, Presidential Suite</li>
            <li><strong>Restaurant:</strong> Table for 2, Table for 4, Private Dining Room</li>
            <li><strong>Venue:</strong> Conference Hall, Wedding Venue, Event Space</li>
            <li><strong>Product:</strong> Any product from the merchant's shop</li>
            <li><strong>Service:</strong> Spa treatments, Tours, Activities</li>
          </ul>
        </div>

        <div className="flex items-center gap-4 pt-6 border-t border-gray-200">
          <button
            type="submit"
            disabled={loading}
            className="flex items-center gap-2 bg-primary text-white px-6 py-3 rounded-sm hover:bg-primary-600 transition-colors disabled:opacity-50 disabled:cursor-not-allowed"
          >
            <Icon icon={faSave} />
            <span>{loading ? 'Creating...' : 'Create Listing'}</span>
          </button>
          <Link
            href={`/admin/merchants/${merchant_id}`}
            className="flex items-center gap-2 px-6 py-3 border border-gray-300 text-gray-700 rounded-sm hover:bg-gray-50 transition-colors"
          >
            Cancel
          </Link>
        </div>
      </form>
    </div>
  );
}

