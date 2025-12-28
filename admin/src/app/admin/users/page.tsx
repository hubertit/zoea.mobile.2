'use client';

import { useEffect, useState } from 'react';
import DataTable from '../../components/DataTable';
import Icon, { faPlus, faEdit, faTrash, faEye } from '../../components/Icon';
import Link from 'next/link';
import { User } from '@/types';
import { mockUsers } from '@/lib/mockData';

export default function UsersPage() {
  const [users, setUsers] = useState<User[]>(mockUsers);
  const [loading, setLoading] = useState(false);
  const [sortKey, setSortKey] = useState<string>('');
  const [sortDirection, setSortDirection] = useState<'asc' | 'desc'>('desc');

  // Using mock data - no API call needed

  const handleSort = (key: string, direction: 'asc' | 'desc') => {
    setSortKey(key);
    setSortDirection(direction);
    
    const sorted = [...users].sort((a, b) => {
      const aVal = a[key as keyof User];
      const bVal = b[key as keyof User];
      
      if (aVal === undefined || aVal === null) return 1;
      if (bVal === undefined || bVal === null) return -1;
      
      if (direction === 'asc') {
        return aVal > bVal ? 1 : -1;
      } else {
        return aVal < bVal ? 1 : -1;
      }
    });
    
    setUsers(sorted);
  };

  const getStatusBadge = (status: string) => {
    const isActive = status.toLowerCase() === 'active';
    return (
      <span className={`px-2 py-1 rounded-full text-xs font-medium ${
        isActive ? 'bg-green-100 text-green-800' : 'bg-gray-100 text-gray-800'
      }`}>
        {status}
      </span>
    );
  };

  const columns = [
    {
      key: 'user_id',
      label: 'ID',
      sortable: true,
    },
    {
      key: 'user_fname',
      label: 'Name',
      sortable: true,
      render: (value: string, row: User) => (
        <div>
          <div className="font-medium text-gray-900">
            {row.user_fname || ''} {row.user_lname || ''}
          </div>
          <div className="text-xs text-gray-500">{row.user_email || 'No email'}</div>
        </div>
      ),
    },
    {
      key: 'account_type',
      label: 'Type',
      sortable: true,
    },
    {
      key: 'user_phone',
      label: 'Phone',
      sortable: true,
    },
    {
      key: 'user_status',
      label: 'Status',
      sortable: true,
      render: (value: string) => getStatusBadge(value),
    },
    {
      key: 'user_reg_date',
      label: 'Registered',
      sortable: true,
      render: (value: string) => {
        const date = new Date(value);
        return date.toLocaleDateString();
      },
    },
    {
      key: 'actions',
      label: 'Actions',
      render: (_: any, row: User) => (
        <div className="flex items-center gap-2">
          <Link
            href={`/admin/users/${row.user_id}`}
            className="p-2 text-primary hover:bg-primary/10 rounded-sm transition-colors"
            title="View"
          >
            <Icon icon={faEye} size="sm" />
          </Link>
          <Link
            href={`/admin/users/${row.user_id}/edit`}
            className="p-2 text-blue-600 hover:bg-blue-50 rounded-sm transition-colors"
            title="Edit"
          >
            <Icon icon={faEdit} size="sm" />
          </Link>
          <button
            onClick={() => {
              if (confirm('Are you sure you want to delete this user?')) {
                // TODO: Implement delete
                console.log('Delete:', row.user_id);
              }
            }}
            className="p-2 text-red-600 hover:bg-red-50 rounded-sm transition-colors"
            title="Delete"
          >
            <Icon icon={faTrash} size="sm" />
          </button>
        </div>
      ),
    },
  ];

  return (
    <div>
      <div className="mb-8 flex items-center justify-between">
        <div>
          <h1 className="text-3xl font-bold text-gray-900 mb-2">Users</h1>
          <p className="text-gray-600">Manage platform users</p>
        </div>
        <Link
          href="/admin/users/create"
          className="flex items-center gap-2 bg-primary text-white px-4 py-2 rounded-sm hover:bg-primary-600 transition-colors"
        >
          <Icon icon={faPlus} />
          <span>Add User</span>
        </Link>
      </div>

      <DataTable
        columns={columns}
        data={users}
        loading={loading}
        onSort={handleSort}
        sortKey={sortKey}
        sortDirection={sortDirection}
      />
    </div>
  );
}

