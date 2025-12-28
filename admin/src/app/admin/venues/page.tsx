'use client';

import { useEffect, useState } from 'react';
import DataTable from '../../components/DataTable';
import Icon, { faPlus, faEdit, faTrash, faEye, faStar } from '../../components/Icon';
import Link from 'next/link';
import { Venue } from '@/types';
import { mockVenues } from '@/lib/mockData';

export default function VenuesPage() {
  const [venues, setVenues] = useState<Venue[]>(mockVenues);
  const [loading, setLoading] = useState(false);
  const [sortKey, setSortKey] = useState<string>('');
  const [sortDirection, setSortDirection] = useState<'asc' | 'desc'>('desc');

  // Using mock data - no API call needed

  const handleSort = (key: string, direction: 'asc' | 'desc') => {
    setSortKey(key);
    setSortDirection(direction);
    
    const sorted = [...venues].sort((a, b) => {
      const aVal = a[key as keyof Venue];
      const bVal = b[key as keyof Venue];
      
      if (aVal === undefined || aVal === null) return 1;
      if (bVal === undefined || bVal === null) return -1;
      
      if (direction === 'asc') {
        return aVal > bVal ? 1 : -1;
      } else {
        return aVal < bVal ? 1 : -1;
      }
    });
    
    setVenues(sorted);
  };

  const getStatusBadge = (status: string) => {
    const statusColors: Record<string, string> = {
      'active': 'bg-green-100 text-green-800',
      'pending': 'bg-yellow-100 text-yellow-800',
      'inactive': 'bg-gray-100 text-gray-800',
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
      key: 'venue_id',
      label: 'ID',
      sortable: true,
    },
    {
      key: 'venue_name',
      label: 'Venue Name',
      sortable: true,
      render: (value: string, row: Venue) => (
        <div>
          <div className="font-medium text-gray-900">{value}</div>
          <div className="text-xs text-gray-500">{row.venue_address || 'No address'}</div>
        </div>
      ),
    },
    {
      key: 'venue_rating',
      label: 'Rating',
      sortable: true,
      render: (value: number, row: Venue) => (
        <div className="flex items-center gap-1">
          <span className="font-medium">{value}</span>
          <Icon icon={faStar} className="text-yellow-500" size="xs" />
          <span className="text-xs text-gray-500">({row.venue_reviews} reviews)</span>
        </div>
      ),
    },
    {
      key: 'venue_price',
      label: 'Price',
      sortable: true,
      render: (value: number) => `RWF ${value.toLocaleString()}`,
    },
    {
      key: 'venue_status',
      label: 'Status',
      sortable: true,
      render: (value: string) => getStatusBadge(value),
    },
    {
      key: 'actions',
      label: 'Actions',
      render: (_: any, row: Venue) => (
        <div className="flex items-center gap-2">
          <Link
            href={`/admin/venues/${row.venue_id}`}
            className="p-2 text-primary hover:bg-primary/10 rounded-sm transition-colors"
            title="View"
          >
            <Icon icon={faEye} size="sm" />
          </Link>
          <Link
            href={`/admin/venues/${row.venue_id}/edit`}
            className="p-2 text-blue-600 hover:bg-blue-50 rounded-sm transition-colors"
            title="Edit"
          >
            <Icon icon={faEdit} size="sm" />
          </Link>
          <button
            onClick={() => {
              if (confirm('Are you sure you want to delete this venue?')) {
                // TODO: Implement delete
                console.log('Delete:', row.venue_id);
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
          <h1 className="text-3xl font-bold text-gray-900 mb-2">Venues</h1>
          <p className="text-gray-600">Manage restaurants, bars, cafes, and other venues</p>
        </div>
        <Link
          href="/admin/venues/create"
          className="flex items-center gap-2 bg-primary text-white px-4 py-2 rounded-sm hover:bg-primary-600 transition-colors"
        >
          <Icon icon={faPlus} />
          <span>Add Venue</span>
        </Link>
      </div>

      <DataTable
        columns={columns}
        data={venues}
        loading={loading}
        onSort={handleSort}
        sortKey={sortKey}
        sortDirection={sortDirection}
      />
    </div>
  );
}

