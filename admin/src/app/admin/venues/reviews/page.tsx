'use client';

import { useState, useEffect } from 'react';
import Icon, { faStar, faUsers } from '../../../components/Icon';
import DataTable from '../../../components/DataTable';
import ChartWrapper from '../../../components/ChartWrapper';
import BarChart from '../../../components/charts/BarChart';
import PieChart from '../../../components/charts/PieChart';
import { mockVenues } from '@/lib/mockData';

export default function VenueReviewsPage() {
  const [loading, setLoading] = useState(true);
  const [reviews, setReviews] = useState<any[]>([]);

  useEffect(() => {
    setTimeout(() => {
      setReviews([
        {
          id: 1,
          venue_name: 'The Garden Restaurant',
          reviewer_name: 'John Doe',
          rating: 5,
          comment: 'Excellent food and service!',
          date: '2025-01-15',
        },
        {
          id: 2,
          venue_name: 'Sky Bar',
          reviewer_name: 'Jane Smith',
          rating: 4,
          comment: 'Great atmosphere and views.',
          date: '2025-01-12',
        },
        {
          id: 3,
          venue_name: 'The Garden Restaurant',
          reviewer_name: 'Mike Johnson',
          rating: 5,
          comment: 'Perfect for events!',
          date: '2025-01-10',
        },
      ]);
      setLoading(false);
    }, 500);
  }, []);

  const columns = [
    { key: 'venue_name', label: 'Venue', sortable: true },
    { key: 'reviewer_name', label: 'Reviewer', sortable: true },
    {
      key: 'rating',
      label: 'Rating',
      sortable: true,
      render: (value: number) => (
        <div className="flex items-center gap-1">
          {Array.from({ length: 5 }).map((_, i) => (
            <Icon
              key={i}
              icon={faStar}
              className={i < value ? 'text-yellow-500' : 'text-gray-300'}
              size="xs"
            />
          ))}
          <span className="ml-2 text-sm text-gray-600">{value}</span>
        </div>
      ),
    },
    { key: 'comment', label: 'Comment', sortable: false },
    { key: 'date', label: 'Date', sortable: true, render: (value: string) => new Date(value).toLocaleDateString() },
  ];

  const avgRating = reviews.length > 0
    ? reviews.reduce((sum, r) => sum + r.rating, 0) / reviews.length
    : 0;

  return (
    <div>
      <div className="mb-8">
        <h1 className="text-3xl font-bold text-gray-900 mb-2">Venue Reviews</h1>
        <p className="text-gray-600">View and manage venue reviews and ratings</p>
      </div>

      {/* Summary Stats */}
      <div className="grid grid-cols-1 md:grid-cols-3 gap-6 mb-6">
        <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-6">
          <div className="flex items-center gap-3 mb-2">
            <Icon icon={faUsers} className="text-primary" />
            <p className="text-sm text-gray-500">Total Reviews</p>
          </div>
          <p className="text-2xl font-bold text-gray-900">{reviews.length}</p>
        </div>
        <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-6">
          <div className="flex items-center gap-3 mb-2">
            <Icon icon={faStar} className="text-yellow-600" />
            <p className="text-sm text-gray-500">Average Rating</p>
          </div>
          <p className="text-2xl font-bold text-gray-900">{avgRating.toFixed(1)}</p>
        </div>
        <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-6">
          <div className="flex items-center gap-3 mb-2">
            <Icon icon={faStar} className="text-primary" />
            <p className="text-sm text-gray-500">5 Star Reviews</p>
          </div>
          <p className="text-2xl font-bold text-gray-900">
            {reviews.filter(r => r.rating === 5).length}
          </p>
        </div>
      </div>

      {/* Charts */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6 mb-6">
        <ChartWrapper title="Ratings Distribution" loading={loading}>
          <PieChart
            data={[
              { name: '5 Stars', value: reviews.filter(r => r.rating === 5).length },
              { name: '4 Stars', value: reviews.filter(r => r.rating === 4).length },
              { name: '3 Stars', value: reviews.filter(r => r.rating === 3).length },
              { name: '2 Stars', value: reviews.filter(r => r.rating === 2).length },
              { name: '1 Star', value: reviews.filter(r => r.rating === 1).length },
            ]}
            height={300}
          />
        </ChartWrapper>

        <ChartWrapper title="Top Rated Venues" loading={loading}>
          <BarChart
            data={mockVenues.map(v => ({ name: v.venue_name, rating: v.venue_rating }))}
            dataKey="name"
            bars={[{ key: 'rating', name: 'Rating', color: '#181E29' }]}
            height={300}
          />
        </ChartWrapper>
      </div>

      {/* Data Table */}
      <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-6">
        <h2 className="text-lg font-semibold text-gray-900 mb-4">All Reviews</h2>
        <DataTable
          columns={columns}
          data={reviews}
          loading={loading}
        />
      </div>
    </div>
  );
}

