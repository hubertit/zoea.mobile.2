'use client';

import { useEffect, useState } from 'react';
import DataTable from '../../components/DataTable';
import Icon, { faPlus, faEdit, faTrash, faEye } from '../../components/Icon';
import Link from 'next/link';
import { Property } from '@/types';
import { mockProperties } from '@/lib/mockData';

export default function RealEstatePage() {
  const [properties, setProperties] = useState<Property[]>(mockProperties);
  const [loading, setLoading] = useState(false);
  const [sortKey, setSortKey] = useState<string>('');
  const [sortDirection, setSortDirection] = useState<'asc' | 'desc'>('desc');

  // Using mock data - no API call needed

  const handleSort = (key: string, direction: 'asc' | 'desc') => {
    setSortKey(key);
    setSortDirection(direction);
    
    const sorted = [...properties].sort((a, b) => {
      const aVal = a[key as keyof Property];
      const bVal = b[key as keyof Property];
      
      if (aVal === undefined || aVal === null) return 1;
      if (bVal === undefined || bVal === null) return -1;
      
      if (direction === 'asc') {
        return aVal > bVal ? 1 : -1;
      } else {
        return aVal < bVal ? 1 : -1;
      }
    });
    
    setProperties(sorted);
  };

  const getStatusBadge = (status: string) => {
    const statusColors: Record<string, string> = {
      'available': 'bg-green-100 text-green-800',
      'sold': 'bg-blue-100 text-blue-800',
      'rented': 'bg-purple-100 text-purple-800',
    };
    
    const color = statusColors[status.toLowerCase()] || 'bg-gray-100 text-gray-800';
    
    return (
      <span className={`px-2 py-1 rounded-full text-xs font-medium ${color}`}>
        {status}
      </span>
    );
  };

  const getTypeBadge = (type: string) => {
    const typeColors: Record<string, string> = {
      'sale': 'bg-emerald-100 text-emerald-800',
      'rent': 'bg-blue-100 text-blue-800',
      'booking': 'bg-orange-100 text-orange-800',
    };
    
    const color = typeColors[type.toLowerCase()] || 'bg-gray-100 text-gray-800';
    
    return (
      <span className={`px-2 py-1 rounded-full text-xs font-medium ${color}`}>
        {type}
      </span>
    );
  };

  const columns = [
    {
      key: 'property_id',
      label: 'ID',
      sortable: true,
    },
    {
      key: 'title',
      label: 'Property',
      sortable: true,
      render: (value: string, row: Property) => (
        <div>
          <div className="font-medium text-gray-900">{value}</div>
          <div className="text-xs text-gray-500">{row.address || 'No address'}</div>
        </div>
      ),
    },
    {
      key: 'category',
      label: 'Category',
      sortable: true,
    },
    {
      key: 'bedrooms',
      label: 'Bedrooms',
      sortable: true,
      render: (value: number) => value || '-',
    },
    {
      key: 'bathrooms',
      label: 'Bathrooms',
      sortable: true,
      render: (value: number) => value || '-',
    },
    {
      key: 'price',
      label: 'Price',
      sortable: true,
      render: (value: number) => `RWF ${value.toLocaleString()}`,
    },
    {
      key: 'property_type',
      label: 'Type',
      sortable: true,
      render: (value: string) => getTypeBadge(value),
    },
    {
      key: 'status',
      label: 'Status',
      sortable: true,
      render: (value: string) => getStatusBadge(value),
    },
    {
      key: 'actions',
      label: 'Actions',
      render: (_: any, row: Property) => (
        <div className="flex items-center gap-2">
          <Link
            href={`/admin/real-estate/${row.property_id}`}
            className="p-2 text-primary hover:bg-primary/10 rounded-sm transition-colors"
            title="View"
          >
            <Icon icon={faEye} size="sm" />
          </Link>
          <Link
            href={`/admin/real-estate/${row.property_id}/edit`}
            className="p-2 text-blue-600 hover:bg-blue-50 rounded-sm transition-colors"
            title="Edit"
          >
            <Icon icon={faEdit} size="sm" />
          </Link>
          <button
            onClick={() => {
              if (confirm('Are you sure you want to delete this property?')) {
                // TODO: Implement delete
                console.log('Delete:', row.property_id);
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
          <h1 className="text-3xl font-bold text-gray-900 mb-2">Properties</h1>
          <p className="text-gray-600">Manage real estate listings</p>
        </div>
        <Link
          href="/admin/real-estate/create"
          className="flex items-center gap-2 bg-primary text-white px-4 py-2 rounded-sm hover:bg-primary-600 transition-colors"
        >
          <Icon icon={faPlus} />
          <span>Add Property</span>
        </Link>
      </div>

      <DataTable
        columns={columns}
        data={properties}
        loading={loading}
        onSort={handleSort}
        sortKey={sortKey}
        sortDirection={sortDirection}
      />
    </div>
  );
}

