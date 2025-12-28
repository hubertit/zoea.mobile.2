'use client';

import { useState } from 'react';
import { useRouter } from 'next/navigation';
import FormInput from '../../../components/FormInput';
import Icon, { faSave, faArrowLeft, faStore, faMapMarkerAlt, faDollarSign } from '../../../components/Icon';
import Link from 'next/link';

export default function CreateVenuePage() {
  const router = useRouter();
  const [loading, setLoading] = useState(false);
  const [formData, setFormData] = useState({
    venue_name: '',
    venue_about: '',
    venue_address: '',
    venue_coordinates: '',
    venue_price: '',
    category_id: '1',
    venue_status: 'active',
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
    
    setTimeout(() => {
      console.log('Creating venue:', formData);
      setLoading(false);
      router.push('/admin/venues');
    }, 1000);
  };

  return (
    <div>
      <div className="mb-8">
        <div className="flex items-center gap-4 mb-4">
          <Link
            href="/admin/venues"
            className="p-2 hover:bg-gray-100 rounded-sm transition-colors"
          >
            <Icon icon={faArrowLeft} />
          </Link>
          <div>
            <h1 className="text-3xl font-bold text-gray-900 mb-2">Create New Venue</h1>
            <p className="text-gray-600">Add a new venue to the platform</p>
          </div>
        </div>
      </div>

      <form onSubmit={handleSubmit} className="bg-white rounded-sm shadow-sm border border-gray-200 p-6">
        <div className="grid grid-cols-1 md:grid-cols-2 gap-6 mb-6">
          <div className="md:col-span-2">
            <FormInput
              label="Venue Name"
              name="venue_name"
              value={formData.venue_name}
              onChange={handleChange}
              placeholder="The Garden Restaurant"
              required
              icon={<Icon icon={faStore} size="sm" />}
            />
          </div>
          
          <div className="md:col-span-2">
            <FormInput
              label="About"
              name="venue_about"
              type="textarea"
              value={formData.venue_about}
              onChange={handleChange}
              placeholder="Describe the venue..."
              rows={4}
            />
          </div>
          
          <FormInput
            label="Address"
            name="venue_address"
            value={formData.venue_address}
            onChange={handleChange}
            placeholder="KG 123 St, Kigali"
            required
            icon={<Icon icon={faMapMarkerAlt} size="sm" />}
          />
          
          <FormInput
            label="Coordinates"
            name="venue_coordinates"
            value={formData.venue_coordinates}
            onChange={handleChange}
            placeholder="-1.9441,30.0619"
            icon={<Icon icon={faMapMarkerAlt} size="sm" />}
          />
          
          <FormInput
            label="Price (RWF)"
            name="venue_price"
            type="number"
            value={formData.venue_price}
            onChange={handleChange}
            placeholder="50000"
            required
            icon={<Icon icon={faDollarSign} size="sm" />}
          />
          
          <FormInput
            label="Category"
            name="category_id"
            type="select"
            value={formData.category_id}
            onChange={handleChange}
            required
            options={[
              { value: '1', label: 'Restaurant' },
              { value: '2', label: 'Bar' },
              { value: '3', label: 'Cafe' },
              { value: '4', label: 'Hotel' },
              { value: '5', label: 'Event Space' },
            ]}
          />
          
          <FormInput
            label="Status"
            name="venue_status"
            type="select"
            value={formData.venue_status}
            onChange={handleChange}
            required
            options={[
              { value: 'active', label: 'Active' },
              { value: 'pending', label: 'Pending' },
              { value: 'inactive', label: 'Inactive' },
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
            <span>{loading ? 'Creating...' : 'Create Venue'}</span>
          </button>
          <Link
            href="/admin/venues"
            className="flex items-center gap-2 px-6 py-3 border border-gray-300 text-gray-700 rounded-sm hover:bg-gray-50 transition-colors"
          >
            Cancel
          </Link>
        </div>
      </form>
    </div>
  );
}

