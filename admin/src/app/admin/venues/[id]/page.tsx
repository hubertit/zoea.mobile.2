'use client';

import { useState, useEffect } from 'react';
import { useParams } from 'next/navigation';
import Icon, { faEdit, faArrowLeft, faStore, faMapMarkerAlt, faDollarSign, faStar, faUsers } from '../../../components/Icon';
import Link from 'next/link';
import { mockVenues } from '@/lib/mockData';

export default function VenueDetailPage() {
  const params = useParams();
  const venueId = params.id as string;
  const [venue, setVenue] = useState(mockVenues.find(v => v.venue_id === parseInt(venueId)));

  useEffect(() => {
    const foundVenue = mockVenues.find(v => v.venue_id === parseInt(venueId));
    setVenue(foundVenue);
  }, [venueId]);

  if (!venue) {
    return (
      <div>
        <div className="text-center py-12">
          <p className="text-gray-500">Venue not found</p>
        </div>
      </div>
    );
  }

  const getStatusBadge = (status: string) => {
    const statusColors: Record<string, string> = {
      'active': 'bg-green-100 text-green-800',
      'pending': 'bg-yellow-100 text-yellow-800',
      'inactive': 'bg-gray-100 text-gray-800',
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
              href="/admin/venues"
              className="p-2 hover:bg-gray-100 rounded-sm transition-colors"
            >
              <Icon icon={faArrowLeft} />
            </Link>
            <div>
              <h1 className="text-3xl font-bold text-gray-900 mb-2">{venue.venue_name}</h1>
              <p className="text-gray-600">Venue Details</p>
            </div>
          </div>
          <Link
            href={`/admin/venues/${venueId}/edit`}
            className="flex items-center gap-2 bg-primary text-white px-4 py-2 rounded-sm hover:bg-primary-600 transition-colors"
          >
            <Icon icon={faEdit} />
            <span>Edit Venue</span>
          </Link>
        </div>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        <div className="lg:col-span-2 space-y-6">
          <div className="bg-white rounded-sm shadow-sm border border-gray-200 p-6">
            <h2 className="text-lg font-semibold text-gray-900 mb-4">Venue Information</h2>
            <div className="space-y-4">
              <div>
                <p className="text-sm text-gray-500 mb-1">About</p>
                <p className="text-gray-900">{venue.venue_about}</p>
              </div>
              
              <div className="flex items-center gap-3">
                <Icon icon={faMapMarkerAlt} className="text-gray-400" />
                <div>
                  <p className="text-sm text-gray-500">Address</p>
                  <p className="font-medium text-gray-900">{venue.venue_address}</p>
                </div>
              </div>
              
              {venue.venue_coordinates && (
                <div>
                  <p className="text-sm text-gray-500 mb-1">Coordinates</p>
                  <p className="font-mono text-sm text-gray-900">{venue.venue_coordinates}</p>
                </div>
              )}
            </div>
          </div>
        </div>

        <div className="space-y-6">
          <div className="bg-white rounded-sm shadow-sm border border-gray-200 p-6">
            <h2 className="text-lg font-semibold text-gray-900 mb-4">Details</h2>
            <div className="space-y-4">
              <div>
                <p className="text-sm text-gray-500 mb-1">Venue ID</p>
                <p className="font-medium text-gray-900">#{venue.venue_id}</p>
              </div>
              
              <div className="flex items-center gap-2">
                <Icon icon={faStar} className="text-yellow-500" />
                <div>
                  <p className="text-sm text-gray-500">Rating</p>
                  <p className="font-medium text-gray-900">
                    {venue.venue_rating} ({venue.venue_reviews} reviews)
                  </p>
                </div>
              </div>
              
              <div className="flex items-center gap-2">
                <Icon icon={faDollarSign} className="text-gray-400" />
                <div>
                  <p className="text-sm text-gray-500">Price</p>
                  <p className="font-medium text-gray-900">RWF {venue.venue_price.toLocaleString()}</p>
                </div>
              </div>
              
              <div>
                <p className="text-sm text-gray-500 mb-2">Status</p>
                {getStatusBadge(venue.venue_status)}
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}

