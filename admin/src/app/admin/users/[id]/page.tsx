'use client';

import { useState, useEffect } from 'react';
import { useParams } from 'next/navigation';
import Icon, { faEdit, faArrowLeft, faUser, faEnvelope, faPhone, faCalendar, faShield } from '../../../components/Icon';
import Link from 'next/link';
import { mockUsers } from '@/lib/mockData';

export default function UserDetailPage() {
  const params = useParams();
  const userId = params.id as string;
  const [user, setUser] = useState(mockUsers.find(u => u.user_id === parseInt(userId)));

  useEffect(() => {
    // In real app, fetch user data
    const foundUser = mockUsers.find(u => u.user_id === parseInt(userId));
    setUser(foundUser);
  }, [userId]);

  if (!user) {
    return (
      <div>
        <div className="text-center py-12">
          <p className="text-gray-500">User not found</p>
        </div>
      </div>
    );
  }

  const getStatusBadge = (status: string) => {
    const isActive = status.toLowerCase() === 'active';
    return (
      <span className={`px-3 py-1 rounded-full text-sm font-medium ${
        isActive ? 'bg-green-100 text-green-800' : 'bg-gray-100 text-gray-800'
      }`}>
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
              href="/admin/users"
              className="p-2 hover:bg-gray-100 rounded-sm transition-colors"
            >
              <Icon icon={faArrowLeft} />
            </Link>
            <div>
              <h1 className="text-3xl font-bold text-gray-900 mb-2">
                {user.user_fname} {user.user_lname}
              </h1>
              <p className="text-gray-600">User Details</p>
            </div>
          </div>
          <Link
            href={`/admin/users/${userId}/edit`}
            className="flex items-center gap-2 bg-primary text-white px-4 py-2 rounded-sm hover:bg-primary-600 transition-colors"
          >
            <Icon icon={faEdit} />
            <span>Edit User</span>
          </Link>
        </div>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        {/* Main Info */}
        <div className="lg:col-span-2 space-y-6">
          <div className="bg-white rounded-sm shadow-sm border border-gray-200 p-6">
            <h2 className="text-lg font-semibold text-gray-900 mb-4">Personal Information</h2>
            <div className="space-y-4">
              <div className="flex items-center gap-3">
                <Icon icon={faUser} className="text-gray-400" />
                <div>
                  <p className="text-sm text-gray-500">Full Name</p>
                  <p className="font-medium text-gray-900">
                    {user.user_fname} {user.user_lname}
                  </p>
                </div>
              </div>
              
              <div className="flex items-center gap-3">
                <Icon icon={faEnvelope} className="text-gray-400" />
                <div>
                  <p className="text-sm text-gray-500">Email</p>
                  <p className="font-medium text-gray-900">{user.user_email}</p>
                </div>
              </div>
              
              <div className="flex items-center gap-3">
                <Icon icon={faPhone} className="text-gray-400" />
                <div>
                  <p className="text-sm text-gray-500">Phone</p>
                  <p className="font-medium text-gray-900">{user.user_phone}</p>
                </div>
              </div>
              
              <div className="flex items-center gap-3">
                <Icon icon={faCalendar} className="text-gray-400" />
                <div>
                  <p className="text-sm text-gray-500">Registration Date</p>
                  <p className="font-medium text-gray-900">
                    {new Date(user.user_reg_date).toLocaleDateString()}
                  </p>
                </div>
              </div>
            </div>
          </div>
        </div>

        {/* Sidebar */}
        <div className="space-y-6">
          <div className="bg-white rounded-sm shadow-sm border border-gray-200 p-6">
            <h2 className="text-lg font-semibold text-gray-900 mb-4">Account Details</h2>
            <div className="space-y-4">
              <div>
                <p className="text-sm text-gray-500 mb-1">User ID</p>
                <p className="font-medium text-gray-900">#{user.user_id}</p>
              </div>
              
              <div>
                <p className="text-sm text-gray-500 mb-1">Account Type</p>
                <p className="font-medium text-gray-900 capitalize">{user.account_type.replace('_', ' ')}</p>
              </div>
              
              <div>
                <p className="text-sm text-gray-500 mb-2">Status</p>
                {getStatusBadge(user.user_status)}
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}

