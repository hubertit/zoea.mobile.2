'use client';

import { useState, useEffect } from 'react';
import { useRouter, useParams } from 'next/navigation';
import FormInput from '../../../../components/FormInput';
import Icon, { faSave, faArrowLeft, faUser, faEnvelope, faPhone } from '../../../../components/Icon';
import Link from 'next/link';
import { mockUsers } from '@/lib/mockData';

export default function EditUserPage() {
  const router = useRouter();
  const params = useParams();
  const userId = params.id as string;
  const [loading, setLoading] = useState(false);
  const [formData, setFormData] = useState({
    user_fname: '',
    user_lname: '',
    user_email: '',
    user_phone: '',
    account_type: 'customer',
    user_status: 'active',
  });

  useEffect(() => {
    // Load user data (mock)
    const user = mockUsers.find(u => u.user_id === parseInt(userId));
    if (user) {
      setFormData({
        user_fname: user.user_fname || '',
        user_lname: user.user_lname || '',
        user_email: user.user_email || '',
        user_phone: user.user_phone || '',
        account_type: user.account_type,
        user_status: user.user_status,
      });
    }
  }, [userId]);

  const handleChange = (e: React.ChangeEvent<HTMLInputElement | HTMLTextAreaElement | HTMLSelectElement>) => {
    setFormData({
      ...formData,
      [e.target.name]: e.target.value,
    });
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);
    
    // Simulate API call
    setTimeout(() => {
      console.log('Updating user:', userId, formData);
      setLoading(false);
      router.push('/admin/users');
    }, 1000);
  };

  return (
    <div>
      <div className="mb-8">
        <div className="flex items-center gap-4 mb-4">
          <Link
            href="/admin/users"
            className="p-2 hover:bg-gray-100 rounded-sm transition-colors"
          >
            <Icon icon={faArrowLeft} />
          </Link>
          <div>
            <h1 className="text-3xl font-bold text-gray-900 mb-2">Edit User</h1>
            <p className="text-gray-600">Update user information</p>
          </div>
        </div>
      </div>

      <form onSubmit={handleSubmit} className="bg-white rounded-sm shadow-sm border border-gray-200 p-6">
        <div className="grid grid-cols-1 md:grid-cols-2 gap-6 mb-6">
          <FormInput
            label="First Name"
            name="user_fname"
            value={formData.user_fname}
            onChange={handleChange}
            placeholder="John"
            required
            icon={<Icon icon={faUser} size="sm" />}
          />
          
          <FormInput
            label="Last Name"
            name="user_lname"
            value={formData.user_lname}
            onChange={handleChange}
            placeholder="Doe"
            required
            icon={<Icon icon={faUser} size="sm" />}
          />
          
          <FormInput
            label="Email"
            name="user_email"
            type="email"
            value={formData.user_email}
            onChange={handleChange}
            placeholder="john.doe@example.com"
            required
            icon={<Icon icon={faEnvelope} size="sm" />}
          />
          
          <FormInput
            label="Phone"
            name="user_phone"
            type="tel"
            value={formData.user_phone}
            onChange={handleChange}
            placeholder="+250788123456"
            required
            icon={<Icon icon={faPhone} size="sm" />}
          />
          
          <FormInput
            label="Account Type"
            name="account_type"
            type="select"
            value={formData.account_type}
            onChange={handleChange}
            required
            options={[
              { value: 'customer', label: 'Customer' },
              { value: 'merchant', label: 'Merchant (Venue Owner)' },
              { value: 'agent', label: 'Real Estate Agent' },
              { value: 'vendor', label: 'Vendor' },
            ]}
          />
          
          <FormInput
            label="Status"
            name="user_status"
            type="select"
            value={formData.user_status}
            onChange={handleChange}
            required
            options={[
              { value: 'active', label: 'Active' },
              { value: 'inactive', label: 'Inactive' },
              { value: 'suspended', label: 'Suspended' },
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
            href="/admin/users"
            className="flex items-center gap-2 px-6 py-3 border border-gray-300 text-gray-700 rounded-sm hover:bg-gray-50 transition-colors"
          >
            Cancel
          </Link>
        </div>
      </form>
    </div>
  );
}

