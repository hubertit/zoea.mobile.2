'use client';

import { useState, useEffect } from 'react';
import { useRouter, useParams } from 'next/navigation';
import FormInput from '../../../../components/FormInput';
import Icon, { faSave, faArrowLeft, faCalendar, faUser, faEnvelope, faPhone, faBuilding } from '../../../../components/Icon';
import Link from 'next/link';
import { mockEvents } from '@/lib/mockData';

export default function EditEventPage() {
  const router = useRouter();
  const params = useParams();
  const eventId = params.id as string;
  const [loading, setLoading] = useState(false);
  const [formData, setFormData] = useState({
    event: '',
    title: 'Mr.',
    first_name: '',
    last_name: '',
    organization: '',
    work_title: '',
    phone: '',
    email: '',
    status: 'pending',
  });

  useEffect(() => {
    const event = mockEvents.find(e => e.id === parseInt(eventId));
    if (event) {
      setFormData({
        event: event.event,
        title: event.title,
        first_name: event.first_name,
        last_name: event.last_name,
        organization: event.organization,
        work_title: event.work_title,
        phone: event.phone,
        email: event.email,
        status: event.status,
      });
    }
  }, [eventId]);

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
      console.log('Updating event:', eventId, formData);
      setLoading(false);
      router.push('/admin/events');
    }, 1000);
  };

  return (
    <div>
      <div className="mb-8">
        <div className="flex items-center gap-4 mb-4">
          <Link
            href="/admin/events"
            className="p-2 hover:bg-gray-100 rounded-sm transition-colors"
          >
            <Icon icon={faArrowLeft} />
          </Link>
          <div>
            <h1 className="text-3xl font-bold text-gray-900 mb-2">Edit Event</h1>
            <p className="text-gray-600">Update event application</p>
          </div>
        </div>
      </div>

      <form onSubmit={handleSubmit} className="bg-white rounded-sm shadow-sm border border-gray-200 p-6">
        <div className="grid grid-cols-1 md:grid-cols-2 gap-6 mb-6">
          <div className="md:col-span-2">
            <FormInput
              label="Event Name"
              name="event"
              value={formData.event}
              onChange={handleChange}
              placeholder="Tech Summit 2025"
              required
              icon={<Icon icon={faCalendar} size="sm" />}
            />
          </div>
          
          <FormInput
            label="Title"
            name="title"
            type="select"
            value={formData.title}
            onChange={handleChange}
            required
            options={[
              { value: 'Mr.', label: 'Mr.' },
              { value: 'Mrs.', label: 'Mrs.' },
              { value: 'Ms.', label: 'Ms.' },
              { value: 'Dr.', label: 'Dr.' },
            ]}
          />
          
          <FormInput
            label="First Name"
            name="first_name"
            value={formData.first_name}
            onChange={handleChange}
            placeholder="John"
            required
            icon={<Icon icon={faUser} size="sm" />}
          />
          
          <FormInput
            label="Last Name"
            name="last_name"
            value={formData.last_name}
            onChange={handleChange}
            placeholder="Doe"
            required
            icon={<Icon icon={faUser} size="sm" />}
          />
          
          <FormInput
            label="Organization"
            name="organization"
            value={formData.organization}
            onChange={handleChange}
            placeholder="Company Name"
            required
            icon={<Icon icon={faBuilding} size="sm" />}
          />
          
          <FormInput
            label="Work Title"
            name="work_title"
            value={formData.work_title}
            onChange={handleChange}
            placeholder="CEO"
            required
          />
          
          <FormInput
            label="Email"
            name="email"
            type="email"
            value={formData.email}
            onChange={handleChange}
            placeholder="john@example.com"
            required
            icon={<Icon icon={faEnvelope} size="sm" />}
          />
          
          <FormInput
            label="Phone"
            name="phone"
            type="tel"
            value={formData.phone}
            onChange={handleChange}
            placeholder="+250788123456"
            required
            icon={<Icon icon={faPhone} size="sm" />}
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
              { value: 'approved', label: 'Approved' },
              { value: 'rejected', label: 'Rejected' },
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
            href="/admin/events"
            className="flex items-center gap-2 px-6 py-3 border border-gray-300 text-gray-700 rounded-sm hover:bg-gray-50 transition-colors"
          >
            Cancel
          </Link>
        </div>
      </form>
    </div>
  );
}

