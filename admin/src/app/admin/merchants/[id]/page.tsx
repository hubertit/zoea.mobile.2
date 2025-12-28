'use client';

import { useEffect, useState } from 'react';
import { useParams } from 'next/navigation';
import Icon, { faArrowLeft, faEdit, faStore, faEnvelope, faPhone, faMapMarkerAlt, faPlus } from '../../../components/Icon';
import Link from 'next/link';
import { Merchant, MerchantListing } from '@/types';
import DataTable from '../../../components/DataTable';

export default function MerchantDetailPage() {
  const params = useParams();
  const merchant_id = params.id as string;
  const [merchant, setMerchant] = useState<Merchant | null>(null);
  const [listings, setListings] = useState<MerchantListing[]>([]);
  const [loading, setLoading] = useState(true);
  const [listingsLoading, setListingsLoading] = useState(true);

  useEffect(() => {
    if (merchant_id) {
      fetchMerchant();
      fetchListings();
    }
  }, [merchant_id]);

  const fetchMerchant = async () => {
    setLoading(true);
    try {
      const response = await fetch(`/api/merchants/${merchant_id}`);
      if (response.ok) {
        const data = await response.json();
        setMerchant(data);
      }
    } catch (error) {
      console.error('Error fetching merchant:', error);
    } finally {
      setLoading(false);
    }
  };

  const fetchListings = async () => {
    setListingsLoading(true);
    try {
      const response = await fetch(`/api/merchants/${merchant_id}/listings`);
      if (response.ok) {
        const data = await response.json();
        setListings(data);
      }
    } catch (error) {
      console.error('Error fetching listings:', error);
    } finally {
      setListingsLoading(false);
    }
  };

  const getStatusBadge = (status: string) => {
    const statusColors: Record<string, string> = {
      active: 'bg-green-100 text-green-800',
      pending: 'bg-yellow-100 text-yellow-800',
      inactive: 'bg-gray-100 text-gray-800',
      suspended: 'bg-red-100 text-red-800',
      draft: 'bg-blue-100 text-blue-800',
      available: 'bg-green-100 text-green-800',
      unavailable: 'bg-red-100 text-red-800',
      booked: 'bg-orange-100 text-orange-800',
    };
    
    return (
      <span className={`px-2 py-1 rounded-full text-xs font-medium ${statusColors[status.toLowerCase()] || 'bg-gray-100 text-gray-800'}`}>
        {status}
      </span>
    );
  };

  const listingColumns = [
    {
      key: 'listing_id',
      label: 'ID',
      sortable: true,
    },
    {
      key: 'listing_name',
      label: 'Name',
      sortable: true,
      render: (value: string, row: MerchantListing) => (
        <div>
          <div className="font-medium text-gray-900">{value}</div>
          <div className="text-xs text-gray-500">{row.listing_type}</div>
        </div>
      ),
    },
    {
      key: 'price',
      label: 'Price',
      sortable: true,
      render: (value: number, row: MerchantListing) => (
        `${row.currency} ${value.toLocaleString()}`
      ),
    },
    {
      key: 'availability',
      label: 'Availability',
      sortable: true,
      render: (value: string) => getStatusBadge(value),
    },
    {
      key: 'status',
      label: 'Status',
      sortable: true,
      render: (value: string) => getStatusBadge(value),
    },
    {
      key: 'rating',
      label: 'Rating',
      sortable: true,
      render: (value: number, row: MerchantListing) => (
        <div>
          <div>⭐ {value.toFixed(1)}</div>
          <div className="text-xs text-gray-500">{row.reviews_count} reviews</div>
        </div>
      ),
    },
  ];

  if (loading) {
    return (
      <div className="flex items-center justify-center h-64">
        <div className="text-gray-500">Loading...</div>
      </div>
    );
  }

  if (!merchant) {
    return (
      <div className="flex items-center justify-center h-64">
        <div className="text-gray-500">Merchant not found</div>
      </div>
    );
  }

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
          <div className="flex-1">
            <h1 className="text-3xl font-bold text-gray-900 mb-2">{merchant.merchant_name}</h1>
            <p className="text-gray-600">Merchant Details and Listings</p>
          </div>
          <Link
            href={`/admin/merchants/${merchant_id}/edit`}
            className="flex items-center gap-2 bg-primary text-white px-4 py-2 rounded-sm hover:bg-primary-600 transition-colors"
          >
            <Icon icon={faEdit} />
            <span>Edit Merchant</span>
          </Link>
        </div>
      </div>

      {/* Merchant Details */}
      <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-6 mb-6">
        <h2 className="text-xl font-semibold text-gray-900 mb-4">Business Information</h2>
        <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
          <div>
            <div className="flex items-center gap-3 mb-4">
              <Icon icon={faStore} className="text-primary" />
              <div>
                <p className="text-sm text-gray-500">Business Name</p>
                <p className="font-medium text-gray-900">{merchant.merchant_name}</p>
              </div>
            </div>
            <div className="flex items-center gap-3 mb-4">
              <Icon icon={faEnvelope} className="text-primary" />
              <div>
                <p className="text-sm text-gray-500">Email</p>
                <p className="font-medium text-gray-900">{merchant.business_email}</p>
              </div>
            </div>
            <div className="flex items-center gap-3 mb-4">
              <Icon icon={faPhone} className="text-primary" />
              <div>
                <p className="text-sm text-gray-500">Phone</p>
                <p className="font-medium text-gray-900">{merchant.business_phone}</p>
              </div>
            </div>
            <div className="flex items-center gap-3">
              <Icon icon={faMapMarkerAlt} className="text-primary" />
              <div>
                <p className="text-sm text-gray-500">Address</p>
                <p className="font-medium text-gray-900">{merchant.business_address}</p>
              </div>
            </div>
          </div>
          <div>
            <div className="mb-4">
              <p className="text-sm text-gray-500 mb-2">Business Categories</p>
              <div className="flex flex-wrap gap-2">
                {merchant.merchant_types.map((type, idx) => {
                  const typeColors: Record<string, string> = {
                    hotel: 'bg-blue-100 text-blue-800',
                    restaurant: 'bg-orange-100 text-orange-800',
                    venue: 'bg-purple-100 text-purple-800',
                    shop: 'bg-pink-100 text-pink-800',
                    service: 'bg-teal-100 text-teal-800',
                    other: 'bg-gray-100 text-gray-800',
                  };
                  return (
                    <span 
                      key={idx}
                      className={`px-3 py-1 rounded-full text-sm font-medium ${typeColors[type] || 'bg-gray-100 text-gray-800'}`}
                    >
                      {type}
                    </span>
                  );
                })}
              </div>
            </div>
            <div className="mb-4">
              <p className="text-sm text-gray-500 mb-1">Status</p>
              {getStatusBadge(merchant.status)}
            </div>
            <div className="mb-4">
              <p className="text-sm text-gray-500 mb-1">Rating</p>
              <p className="font-medium text-gray-900">⭐ {merchant.rating.toFixed(1)} ({merchant.total_reviews} reviews)</p>
            </div>
            {merchant.tax_id && (
              <div className="mb-4">
                <p className="text-sm text-gray-500 mb-1">Tax ID</p>
                <p className="font-medium text-gray-900">{merchant.tax_id}</p>
              </div>
            )}
            {merchant.license_number && (
              <div>
                <p className="text-sm text-gray-500 mb-1">License Number</p>
                <p className="font-medium text-gray-900">{merchant.license_number}</p>
              </div>
            )}
          </div>
        </div>
        {merchant.business_description && (
          <div className="mt-6 pt-6 border-t border-gray-200">
            <p className="text-sm text-gray-500 mb-2">Description</p>
            <p className="text-gray-900">{merchant.business_description}</p>
          </div>
        )}
      </div>

      {/* Merchant Listings */}
      <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-6">
        <div className="flex items-center justify-between mb-4">
          <h2 className="text-xl font-semibold text-gray-900">Listings</h2>
          <Link
            href={`/admin/merchants/${merchant_id}/listings/create`}
            className="flex items-center gap-2 bg-primary text-white px-4 py-2 rounded-sm hover:bg-primary-600 transition-colors"
          >
            <Icon icon={faPlus} />
            <span>Add Listing</span>
          </Link>
        </div>
        <DataTable
          columns={listingColumns}
          data={listings}
          loading={listingsLoading}
        />
      </div>
    </div>
  );
}

