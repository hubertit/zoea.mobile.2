'use client';

import { useState, useEffect } from 'react';
import { useParams } from 'next/navigation';
import Icon, { faEdit, faArrowLeft, faHome, faMapMarkerAlt, faDollarSign, faBed, faBath, faRuler } from '../../../components/Icon';
import Link from 'next/link';
import { mockProperties } from '@/lib/mockData';

export default function PropertyDetailPage() {
  const params = useParams();
  const propertyId = params.id as string;
  const [property, setProperty] = useState(mockProperties.find(p => p.property_id === parseInt(propertyId)));

  useEffect(() => {
    const foundProperty = mockProperties.find(p => p.property_id === parseInt(propertyId));
    setProperty(foundProperty);
  }, [propertyId]);

  if (!property) {
    return (
      <div>
        <div className="text-center py-12">
          <p className="text-gray-500">Property not found</p>
        </div>
      </div>
    );
  }

  const getStatusBadge = (status: string) => {
    const statusColors: Record<string, string> = {
      'available': 'bg-green-100 text-green-800',
      'sold': 'bg-blue-100 text-blue-800',
      'rented': 'bg-purple-100 text-purple-800',
    };
    const color = statusColors[status.toLowerCase()] || 'bg-gray-100 text-gray-800';
    return (
      <span className={`px-3 py-1 rounded-full text-sm font-medium ${color}`}>
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
      <span className={`px-3 py-1 rounded-full text-sm font-medium ${color}`}>
        {type}
      </span>
    );
  };

  return (
    <div>
      <div className="mb-8">
        <div className="flex items-center justify-between mb-4">
          <div className="flex items-center gap-4">
            <Link
              href="/admin/real-estate"
              className="p-2 hover:bg-gray-100 rounded-sm transition-colors"
            >
              <Icon icon={faArrowLeft} />
            </Link>
            <div>
              <h1 className="text-3xl font-bold text-gray-900 mb-2">{property.title}</h1>
              <p className="text-gray-600">Property Details</p>
            </div>
          </div>
          <Link
            href={`/admin/real-estate/${propertyId}/edit`}
            className="flex items-center gap-2 bg-primary text-white px-4 py-2 rounded-sm hover:bg-primary-600 transition-colors"
          >
            <Icon icon={faEdit} />
            <span>Edit Property</span>
          </Link>
        </div>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        <div className="lg:col-span-2 space-y-6">
          <div className="bg-white rounded-sm shadow-sm border border-gray-200 p-6">
            <h2 className="text-lg font-semibold text-gray-900 mb-4">Property Information</h2>
            <div className="space-y-4">
              <div className="flex items-center gap-3">
                <Icon icon={faMapMarkerAlt} className="text-gray-400" />
                <div>
                  <p className="text-sm text-gray-500">Address</p>
                  <p className="font-medium text-gray-900">{property.address || 'No address provided'}</p>
                </div>
              </div>
              
              <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
                {property.bedrooms && (
                  <div className="flex items-center gap-2">
                    <Icon icon={faBed} className="text-gray-400" />
                    <div>
                      <p className="text-xs text-gray-500">Bedrooms</p>
                      <p className="font-medium text-gray-900">{property.bedrooms}</p>
                    </div>
                  </div>
                )}
                
                {property.bathrooms && (
                  <div className="flex items-center gap-2">
                    <Icon icon={faBath} className="text-gray-400" />
                    <div>
                      <p className="text-xs text-gray-500">Bathrooms</p>
                      <p className="font-medium text-gray-900">{property.bathrooms}</p>
                    </div>
                  </div>
                )}
                
                {property.size && (
                  <div className="flex items-center gap-2">
                    <Icon icon={faRuler} className="text-gray-400" />
                    <div>
                      <p className="text-xs text-gray-500">Size</p>
                      <p className="font-medium text-gray-900">{property.size} sqm</p>
                    </div>
                  </div>
                )}
              </div>
            </div>
          </div>
        </div>

        <div className="space-y-6">
          <div className="bg-white rounded-sm shadow-sm border border-gray-200 p-6">
            <h2 className="text-lg font-semibold text-gray-900 mb-4">Details</h2>
            <div className="space-y-4">
              <div>
                <p className="text-sm text-gray-500 mb-1">Property ID</p>
                <p className="font-medium text-gray-900">#{property.property_id}</p>
              </div>
              
              <div>
                <p className="text-sm text-gray-500 mb-1">Category</p>
                <p className="font-medium text-gray-900">{property.category}</p>
              </div>
              
              <div>
                <p className="text-sm text-gray-500 mb-2">Type</p>
                {getTypeBadge(property.property_type)}
              </div>
              
              <div className="flex items-center gap-2">
                <Icon icon={faDollarSign} className="text-gray-400" />
                <div>
                  <p className="text-sm text-gray-500">Price</p>
                  <p className="font-medium text-gray-900">RWF {property.price.toLocaleString()}</p>
                </div>
              </div>
              
              <div>
                <p className="text-sm text-gray-500 mb-2">Status</p>
                {getStatusBadge(property.status)}
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}

