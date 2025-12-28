'use client';

import { useEffect, useState } from 'react';
import DataTable from '../../components/DataTable';
import Icon, { faPlus, faEdit, faTrash, faEye } from '../../components/Icon';
import Link from 'next/link';
import { Application } from '@/types';
import { mockEvents } from '@/lib/mockData';

export default function EventsPage() {
  const [applications, setApplications] = useState<Application[]>(mockEvents);
  const [loading, setLoading] = useState(false);
  const [sortKey, setSortKey] = useState<string>('');
  const [sortDirection, setSortDirection] = useState<'asc' | 'desc'>('desc');

  // Using mock data - no API call needed

  const handleSort = (key: string, direction: 'asc' | 'desc') => {
    setSortKey(key);
    setSortDirection(direction);
    
    const sorted = [...applications].sort((a, b) => {
      const aVal = a[key as keyof Application];
      const bVal = b[key as keyof Application];
      
      if (aVal === undefined || aVal === null) return 1;
      if (bVal === undefined || bVal === null) return -1;
      
      if (direction === 'asc') {
        return aVal > bVal ? 1 : -1;
      } else {
        return aVal < bVal ? 1 : -1;
      }
    });
    
    setApplications(sorted);
  };

  const getStatusBadge = (status: string) => {
    const statusColors: Record<string, string> = {
      'approved': 'bg-green-100 text-green-800',
      'pending': 'bg-yellow-100 text-yellow-800',
      'rejected': 'bg-red-100 text-red-800',
    };
    
    const color = statusColors[status.toLowerCase()] || 'bg-gray-100 text-gray-800';
    
    return (
      <span className={`px-2 py-1 rounded-full text-xs font-medium ${color}`}>
        {status}
      </span>
    );
  };

  const columns = [
    {
      key: 'id',
      label: 'ID',
      sortable: true,
    },
    {
      key: 'first_name',
      label: 'Name',
      sortable: true,
      render: (value: string, row: Application) => (
        <div>
          <div className="font-medium text-gray-900">
            {row.title} {row.first_name} {row.last_name}
          </div>
          <div className="text-xs text-gray-500">{row.email}</div>
        </div>
      ),
    },
    {
      key: 'organization',
      label: 'Organization',
      sortable: true,
    },
    {
      key: 'work_title',
      label: 'Title',
      sortable: true,
    },
    {
      key: 'event',
      label: 'Event',
      sortable: true,
    },
    {
      key: 'status',
      label: 'Status',
      sortable: true,
      render: (value: string) => getStatusBadge(value),
    },
    {
      key: 'updated_date',
      label: 'Updated',
      sortable: true,
      render: (value: string) => {
        const date = new Date(value);
        return date.toLocaleDateString();
      },
    },
    {
      key: 'actions',
      label: 'Actions',
      render: (_: any, row: Application) => (
        <div className="flex items-center gap-2">
          <Link
            href={`/admin/events/${row.id}`}
            className="p-2 text-primary hover:bg-primary/10 rounded-sm transition-colors"
            title="View"
          >
            <Icon icon={faEye} size="sm" />
          </Link>
          <Link
            href={`/admin/events/${row.id}/edit`}
            className="p-2 text-blue-600 hover:bg-blue-50 rounded-sm transition-colors"
            title="Edit"
          >
            <Icon icon={faEdit} size="sm" />
          </Link>
          <button
            onClick={() => {
              if (confirm('Are you sure you want to delete this application?')) {
                // TODO: Implement delete
                console.log('Delete:', row.id);
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
          <h1 className="text-3xl font-bold text-gray-900 mb-2">Event Applications</h1>
          <p className="text-gray-600">Manage and review event applications</p>
        </div>
        <Link
          href="/admin/events/create"
          className="flex items-center gap-2 bg-primary text-white px-4 py-2 rounded-sm hover:bg-primary-600 transition-colors"
        >
          <Icon icon={faPlus} />
          <span>Create Event</span>
        </Link>
      </div>

      <DataTable
        columns={columns}
        data={applications}
        loading={loading}
        onSort={handleSort}
        sortKey={sortKey}
        sortDirection={sortDirection}
      />
    </div>
  );
}

