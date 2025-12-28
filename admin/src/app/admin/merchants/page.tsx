'use client';

import { useEffect, useState } from 'react';
import DataTable from '../../components/DataTable';
import Icon, { faPlus, faEdit, faTrash, faEye, faStore, faCheckCircle } from '../../components/Icon';
import Link from 'next/link';
import { Merchant } from '@/types';

export default function MerchantsPage() {
  const [merchants, setMerchants] = useState<Merchant[]>([]);
  const [loading, setLoading] = useState(true);
  const [sortKey, setSortKey] = useState<string>('');
  const [sortDirection, setSortDirection] = useState<'asc' | 'desc'>('desc');
  const [filterType, setFilterType] = useState<string>('all');
  const [filterStatus, setFilterStatus] = useState<string>('all');

  useEffect(() => {
    fetchMerchants();
  }, [filterType, filterStatus]);

  const fetchMerchants = async () => {
    setLoading(true);
    try {
      let url = '/api/merchants?limit=100';
      if (filterType !== 'all') url += `&type=${filterType}`;
      if (filterStatus !== 'all') url += `&status=${filterStatus}`;
      
      const response = await fetch(url);
      if (response.ok) {
        const data = await response.json();
        setMerchants(data);
      }
    } catch (error) {
      console.error('Error fetching merchants:', error);
    } finally {
      setLoading(false);
    }
  };

  const handleSort = (key: string, direction: 'asc' | 'desc') => {
    setSortKey(key);
    setSortDirection(direction);
    
    const sorted = [...merchants].sort((a, b) => {
      const aVal = a[key as keyof Merchant];
      const bVal = b[key as keyof Merchant];
      
      if (aVal === undefined || aVal === null) return 1;
      if (bVal === undefined || bVal === null) return -1;
      
      if (direction === 'asc') {
        return aVal > bVal ? 1 : -1;
      } else {
        return aVal < bVal ? 1 : -1;
      }
    });
    
    setMerchants(sorted);
  };

  const handleDelete = async (merchant_id: number) => {
    if (!confirm('Are you sure you want to delete this merchant?')) return;

    try {
      const response = await fetch(`/api/merchants?merchant_id=${merchant_id}`, {
        method: 'DELETE',
      });

      if (response.ok) {
        fetchMerchants();
      } else {
        alert('Failed to delete merchant');
      }
    } catch (error) {
      console.error('Error deleting merchant:', error);
      alert('Failed to delete merchant');
    }
  };

  const getStatusBadge = (status: string) => {
    const statusColors: Record<string, string> = {
      active: 'bg-green-100 text-green-800',
      pending: 'bg-yellow-100 text-yellow-800',
      inactive: 'bg-gray-100 text-gray-800',
      suspended: 'bg-red-100 text-red-800',
    };
    
    return (
      <span className={`px-2 py-1 rounded-full text-xs font-medium ${statusColors[status.toLowerCase()] || 'bg-gray-100 text-gray-800'}`}>
        {status}
      </span>
    );
  };

  const getTypesBadges = (types: string[]) => {
    const typeColors: Record<string, string> = {
      hotel: 'bg-blue-100 text-blue-800',
      restaurant: 'bg-orange-100 text-orange-800',
      venue: 'bg-purple-100 text-purple-800',
      shop: 'bg-pink-100 text-pink-800',
      service: 'bg-teal-100 text-teal-800',
      other: 'bg-gray-100 text-gray-800',
    };
    
    return (
      <div className="flex flex-wrap gap-1">
        {types.map((type, idx) => (
          <span 
            key={idx}
            className={`px-2 py-1 rounded-full text-xs font-medium ${typeColors[type.toLowerCase()] || 'bg-gray-100 text-gray-800'}`}
          >
            {type}
          </span>
        ))}
      </div>
    );
  };

  const columns = [
    {
      key: 'merchant_id',
      label: 'ID',
      sortable: true,
    },
    {
      key: 'merchant_name',
      label: 'Business Name',
      sortable: true,
      render: (value: string, row: Merchant) => (
        <div>
          <div className="font-medium text-gray-900">{value}</div>
          <div className="text-xs text-gray-500">{row.business_email}</div>
        </div>
      ),
    },
    {
      key: 'merchant_types',
      label: 'Categories',
      sortable: false,
      render: (value: string[], row: Merchant) => getTypesBadges(value),
    },
    {
      key: 'business_phone',
      label: 'Phone',
      sortable: true,
    },
    {
      key: 'business_address',
      label: 'Address',
      sortable: true,
      render: (value: string) => (
        <div className="max-w-xs truncate" title={value}>
          {value}
        </div>
      ),
    },
    {
      key: 'rating',
      label: 'Rating',
      sortable: true,
      render: (value: number, row: Merchant) => (
        <div>
          <div className="font-medium">⭐ {value.toFixed(1)}</div>
          <div className="text-xs text-gray-500">{row.total_reviews} reviews</div>
          <div className="text-xs text-gray-500 mt-1">{row.total_listings} listings</div>
        </div>
      ),
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
      render: (_: any, row: Merchant) => (
        <div className="flex items-center gap-2">
          <Link
            href={`/admin/merchants/${row.merchant_id}`}
            className="p-2 text-primary hover:bg-primary/10 rounded-sm transition-colors"
            title="View"
          >
            <Icon icon={faEye} size="sm" />
          </Link>
          <Link
            href={`/admin/merchants/${row.merchant_id}/edit`}
            className="p-2 text-blue-600 hover:bg-blue-50 rounded-sm transition-colors"
            title="Edit"
          >
            <Icon icon={faEdit} size="sm" />
          </Link>
          <button
            onClick={() => handleDelete(row.merchant_id)}
            className="p-2 text-red-600 hover:bg-red-50 rounded-sm transition-colors"
            title="Delete"
          >
            <Icon icon={faTrash} size="sm" />
          </button>
        </div>
      ),
    },
  ];

  // Calculate stats
  const totalMerchants = merchants.length;
  const activeMerchants = merchants.filter(m => m.status === 'active').length;
  const pendingMerchants = merchants.filter(m => m.status === 'pending').length;
  const averageRating = merchants.length > 0 
    ? (merchants.reduce((sum, m) => sum + m.rating, 0) / merchants.length).toFixed(1)
    : '0.0';

  return (
    <div>
      <div className="mb-8 flex items-center justify-between">
        <div>
          <h1 className="text-3xl font-bold text-gray-900 mb-2">Merchants Management</h1>
          <p className="text-gray-600">Manage merchants, hotels, restaurants, and venues</p>
        </div>
        <Link
          href="/admin/merchants/create"
          className="flex items-center gap-2 bg-primary text-white px-4 py-2 rounded-sm hover:bg-primary-600 transition-colors"
        >
          <Icon icon={faPlus} />
          <span>Add Merchant</span>
        </Link>
      </div>

      {/* Summary Stats */}
      <div className="grid grid-cols-1 md:grid-cols-4 gap-6 mb-6">
        <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-6">
          <div className="flex items-center gap-3 mb-2">
            <Icon icon={faStore} className="text-primary" />
            <p className="text-sm text-gray-500">Total Merchants</p>
          </div>
          <p className="text-2xl font-bold text-gray-900">{totalMerchants}</p>
        </div>
        <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-6">
          <div className="flex items-center gap-3 mb-2">
            <Icon icon={faCheckCircle} className="text-green-600" />
            <p className="text-sm text-gray-500">Active Merchants</p>
          </div>
          <p className="text-2xl font-bold text-gray-900">{activeMerchants}</p>
        </div>
        <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-6">
          <div className="flex items-center gap-3 mb-2">
            <Icon icon={faCheckCircle} className="text-yellow-600" />
            <p className="text-sm text-gray-500">Pending Approval</p>
          </div>
          <p className="text-2xl font-bold text-gray-900">{pendingMerchants}</p>
        </div>
        <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-6">
          <div className="flex items-center gap-3 mb-2">
            <span className="text-2xl">⭐</span>
            <p className="text-sm text-gray-500">Average Rating</p>
          </div>
          <p className="text-2xl font-bold text-gray-900">{averageRating}</p>
        </div>
      </div>

      {/* Filters */}
      <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-4 mb-6">
        <div className="flex flex-wrap gap-4">
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">
              Filter by Type
            </label>
            <select
              value={filterType}
              onChange={(e) => setFilterType(e.target.value)}
              className="px-4 py-2 border border-gray-300 rounded-sm focus:outline-none focus:ring-1 focus:ring-primary"
            >
              <option value="all">All Types</option>
              <option value="hotel">Hotels</option>
              <option value="restaurant">Restaurants</option>
              <option value="venue">Venues</option>
              <option value="shop">Shops</option>
              <option value="service">Services</option>
              <option value="other">Other</option>
            </select>
          </div>
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">
              Filter by Status
            </label>
            <select
              value={filterStatus}
              onChange={(e) => setFilterStatus(e.target.value)}
              className="px-4 py-2 border border-gray-300 rounded-sm focus:outline-none focus:ring-1 focus:ring-primary"
            >
              <option value="all">All Status</option>
              <option value="active">Active</option>
              <option value="pending">Pending</option>
              <option value="inactive">Inactive</option>
              <option value="suspended">Suspended</option>
            </select>
          </div>
        </div>
      </div>

      {/* Data Table */}
      <DataTable
        columns={columns}
        data={merchants}
        loading={loading}
        onSort={handleSort}
        sortKey={sortKey}
        sortDirection={sortDirection}
      />
    </div>
  );
}

