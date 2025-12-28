'use client';

import { useState } from 'react';
import { useRouter } from 'next/navigation';
import FormInput from '../../../components/FormInput';
import Icon, { faSave, faArrowLeft, faStore, faEnvelope, faPhone, faMapMarkerAlt } from '../../../components/Icon';
import Link from 'next/link';

export default function CreateMerchantPage() {
  const router = useRouter();
  const [loading, setLoading] = useState(false);
  const [formData, setFormData] = useState({
    merchant_name: '',
    business_email: '',
    business_phone: '',
    business_address: '',
    business_description: '',
    tax_id: '',
    license_number: '',
    status: 'pending',
  });
  const [selectedTypes, setSelectedTypes] = useState<string[]>(['restaurant']);

  const handleChange = (e: React.ChangeEvent<HTMLInputElement | HTMLTextAreaElement | HTMLSelectElement>) => {
    setFormData({
      ...formData,
      [e.target.name]: e.target.value,
    });
  };

  const handleTypeChange = (type: string) => {
    setSelectedTypes(prev => {
      if (prev.includes(type)) {
        return prev.filter(t => t !== type);
      } else {
        return [...prev, type];
      }
    });
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    
    if (selectedTypes.length === 0) {
      alert('Please select at least one business category');
      return;
    }
    
    setLoading(true);
    
    try {
      const response = await fetch('/api/merchants', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          ...formData,
          merchant_types: selectedTypes,
        }),
      });

      if (response.ok) {
        alert('Merchant created successfully!');
        router.push('/admin/merchants');
      } else {
        const error = await response.json();
        alert(error.error || 'Failed to create merchant');
      }
    } catch (error) {
      console.error('Error creating merchant:', error);
      alert('Failed to create merchant');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div>
      <div className="mb-8">
        <div className="flex items-center gap-4 mb-4">
          <Link
            href="/admin/merchants"
            className="p-2 hover:bg-gray-100 rounded-sm transition-colors"
          >
            <Icon icon={faArrowLeft} />
          </Link>
          <div>
            <h1 className="text-3xl font-bold text-gray-900 mb-2">Create New Merchant</h1>
            <p className="text-gray-600">Add a new merchant to the platform</p>
          </div>
        </div>
      </div>

      <form onSubmit={handleSubmit} className="bg-white rounded-sm shadow-sm border border-gray-200 p-6">
        <div className="grid grid-cols-1 md:grid-cols-2 gap-6 mb-6">
          <FormInput
            label="Business Name"
            name="merchant_name"
            value={formData.merchant_name}
            onChange={handleChange}
            placeholder="Amazing Hotel & Spa"
            required
            icon={<Icon icon={faStore} size="sm" />}
          />
          
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">
              Business Categories <span className="text-red-500">*</span>
            </label>
            <p className="text-xs text-gray-500 mb-3">Select all categories that apply to your business</p>
            <div className="grid grid-cols-2 gap-3">
              {[
                { value: 'hotel', label: 'Hotel', color: 'blue' },
                { value: 'restaurant', label: 'Restaurant', color: 'orange' },
                { value: 'venue', label: 'Venue', color: 'purple' },
                { value: 'shop', label: 'Shop', color: 'pink' },
                { value: 'service', label: 'Service', color: 'teal' },
                { value: 'other', label: 'Other', color: 'gray' },
              ].map(type => (
                <label
                  key={type.value}
                  className={`
                    flex items-center gap-2 p-3 border-2 rounded-sm cursor-pointer transition-all
                    ${selectedTypes.includes(type.value)
                      ? `border-${type.color}-500 bg-${type.color}-50`
                      : 'border-gray-200 hover:border-gray-300'
                    }
                  `}
                >
                  <input
                    type="checkbox"
                    checked={selectedTypes.includes(type.value)}
                    onChange={() => handleTypeChange(type.value)}
                    className="w-4 h-4"
                  />
                  <span className="text-sm font-medium">{type.label}</span>
                </label>
              ))}
            </div>
          </div>
          
          <FormInput
            label="Business Email"
            name="business_email"
            type="email"
            value={formData.business_email}
            onChange={handleChange}
            placeholder="contact@business.com"
            required
            icon={<Icon icon={faEnvelope} size="sm" />}
          />
          
          <FormInput
            label="Business Phone"
            name="business_phone"
            type="tel"
            value={formData.business_phone}
            onChange={handleChange}
            placeholder="+250788123456"
            required
            icon={<Icon icon={faPhone} size="sm" />}
          />
          
          <FormInput
            label="Tax ID"
            name="tax_id"
            value={formData.tax_id}
            onChange={handleChange}
            placeholder="TAX123456"
          />
          
          <FormInput
            label="License Number"
            name="license_number"
            value={formData.license_number}
            onChange={handleChange}
            placeholder="LIC789012"
          />
          
          <FormInput
            label="Status"
            name="status"
            type="select"
            value={formData.status}
            onChange={handleChange}
            required
            options={[
              { value: 'pending', label: 'Pending' },
              { value: 'active', label: 'Active' },
              { value: 'inactive', label: 'Inactive' },
              { value: 'suspended', label: 'Suspended' },
            ]}
          />
        </div>

        <div className="mb-6">
          <FormInput
            label="Business Address"
            name="business_address"
            value={formData.business_address}
            onChange={handleChange}
            placeholder="KN 123 St, Kigali, Rwanda"
            required
            icon={<Icon icon={faMapMarkerAlt} size="sm" />}
          />
        </div>

        <div className="mb-6">
          <FormInput
            label="Business Description"
            name="business_description"
            type="textarea"
            value={formData.business_description}
            onChange={handleChange}
            placeholder="Describe your business, services, and unique offerings..."
            rows={6}
          />
        </div>

        <div className="flex items-center gap-4 pt-6 border-t border-gray-200">
          <button
            type="submit"
            disabled={loading}
            className="flex items-center gap-2 bg-primary text-white px-6 py-3 rounded-sm hover:bg-primary-600 transition-colors disabled:opacity-50 disabled:cursor-not-allowed"
          >
            <Icon icon={faSave} />
            <span>{loading ? 'Creating...' : 'Create Merchant'}</span>
          </button>
          <Link
            href="/admin/merchants"
            className="flex items-center gap-2 px-6 py-3 border border-gray-300 text-gray-700 rounded-sm hover:bg-gray-50 transition-colors"
          >
            Cancel
          </Link>
        </div>
      </form>
    </div>
  );
}

