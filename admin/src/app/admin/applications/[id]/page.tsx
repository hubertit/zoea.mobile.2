'use client';

import { useState, useEffect } from 'react';
import { useParams } from 'next/navigation';
import Icon, { faEdit, faArrowLeft, faCalendar, faUser, faEnvelope, faPhone, faBuilding } from '../../../components/Icon';
import Link from 'next/link';
import { mockEvents } from '@/lib/mockData';

export default function ApplicationDetailPage() {
  const params = useParams();
  const applicationId = params.id as string;
  const [application, setApplication] = useState(mockEvents.find(e => e.id === parseInt(applicationId)));

  useEffect(() => {
    const found = mockEvents.find(e => e.id === parseInt(applicationId));
    setApplication(found);
  }, [applicationId]);

  if (!application) {
    return (
      <div>
        <div className="text-center py-12">
          <p className="text-gray-500">Application not found</p>
        </div>
      </div>
    );
  }

  const getStatusBadge = (status: string) => {
    const statusColors: Record<string, string> = {
      'approved': 'bg-green-100 text-green-800',
      'pending': 'bg-yellow-100 text-yellow-800',
      'rejected': 'bg-red-100 text-red-800',
    };
    const color = statusColors[status.toLowerCase()] || 'bg-gray-100 text-gray-800';
    return (
      <span className={`px-3 py-1 rounded-full text-sm font-medium ${color}`}>
        {status}
      </span>
    );
  };

  return (
    <div>
      <div className="mb-8">
        <div className="flex items-center justify-between mb-4">
          <div className="flex items-center gap-4">
            <Link
              href="/admin/applications"
              className="p-2 hover:bg-gray-100 rounded-sm transition-colors"
            >
              <Icon icon={faArrowLeft} />
            </Link>
            <div>
              <h1 className="text-3xl font-bold text-gray-900 mb-2">{application.event}</h1>
              <p className="text-gray-600">Application Details</p>
            </div>
          </div>
          <Link
            href={`/admin/applications/${applicationId}/edit`}
            className="flex items-center gap-2 bg-primary text-white px-4 py-2 rounded-sm hover:bg-primary-600 transition-colors"
          >
            <Icon icon={faEdit} />
            <span>Edit Application</span>
          </Link>
        </div>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        <div className="lg:col-span-2 space-y-6">
          <div className="bg-white rounded-sm shadow-sm border border-gray-200 p-6">
            <h2 className="text-lg font-semibold text-gray-900 mb-4">Event Information</h2>
            <div className="space-y-4">
              <div className="flex items-center gap-3">
                <Icon icon={faCalendar} className="text-gray-400" />
                <div>
                  <p className="text-sm text-gray-500">Event Name</p>
                  <p className="font-medium text-gray-900">{application.event}</p>
                </div>
              </div>
            </div>
          </div>

          <div className="bg-white rounded-sm shadow-sm border border-gray-200 p-6">
            <h2 className="text-lg font-semibold text-gray-900 mb-4">Applicant Information</h2>
            <div className="space-y-4">
              <div className="flex items-center gap-3">
                <Icon icon={faUser} className="text-gray-400" />
                <div>
                  <p className="text-sm text-gray-500">Full Name</p>
                  <p className="font-medium text-gray-900">
                    {application.title} {application.first_name} {application.last_name}
                  </p>
                </div>
              </div>
              
              <div className="flex items-center gap-3">
                <Icon icon={faBuilding} className="text-gray-400" />
                <div>
                  <p className="text-sm text-gray-500">Organization</p>
                  <p className="font-medium text-gray-900">{application.organization}</p>
                </div>
              </div>
              
              <div>
                <p className="text-sm text-gray-500 mb-1">Work Title</p>
                <p className="font-medium text-gray-900">{application.work_title}</p>
              </div>
              
              <div className="flex items-center gap-3">
                <Icon icon={faEnvelope} className="text-gray-400" />
                <div>
                  <p className="text-sm text-gray-500">Email</p>
                  <p className="font-medium text-gray-900">{application.email}</p>
                </div>
              </div>
              
              <div className="flex items-center gap-3">
                <Icon icon={faPhone} className="text-gray-400" />
                <div>
                  <p className="text-sm text-gray-500">Phone</p>
                  <p className="font-medium text-gray-900">{application.phone}</p>
                </div>
              </div>
            </div>
          </div>
        </div>

        <div className="space-y-6">
          <div className="bg-white rounded-sm shadow-sm border border-gray-200 p-6">
            <h2 className="text-lg font-semibold text-gray-900 mb-4">Status</h2>
            <div className="space-y-4">
              <div>
                <p className="text-sm text-gray-500 mb-2">Application Status</p>
                {getStatusBadge(application.status)}
              </div>
              
              <div>
                <p className="text-sm text-gray-500 mb-1">Application ID</p>
                <p className="font-medium text-gray-900">#{application.id}</p>
              </div>
              
              <div>
                <p className="text-sm text-gray-500 mb-1">Last Updated</p>
                <p className="font-medium text-gray-900">
                  {new Date(application.updated_date).toLocaleDateString()}
                </p>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}

