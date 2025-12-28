'use client';

import { useState, useEffect } from 'react';
import Icon, { faStore, faStar, faUsers, faDollarSign } from '../../../components/Icon';
import ChartWrapper from '../../../components/ChartWrapper';
import LineChart from '../../../components/charts/LineChart';
import BarChart from '../../../components/charts/BarChart';
import PieChart from '../../../components/charts/PieChart';
import { mockVenues, mockChartData, mockDashboardStats } from '@/lib/mockData';

export default function VenueAnalyticsPage() {
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    setLoading(false);
  }, []);

  const avgRating = mockVenues.reduce((sum, v) => sum + v.venue_rating, 0) / mockVenues.length;
  const totalReviews = mockVenues.reduce((sum, v) => sum + v.venue_reviews, 0);

  return (
    <div>
      <div className="mb-8">
        <h1 className="text-3xl font-bold text-gray-900 mb-2">Venue Analytics</h1>
        <p className="text-gray-600">Comprehensive venue performance metrics and insights</p>
      </div>

      {/* Summary Stats */}
      <div className="grid grid-cols-1 md:grid-cols-4 gap-6 mb-6">
        <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-6">
          <div className="flex items-center gap-3 mb-2">
            <Icon icon={faStore} className="text-primary" />
            <p className="text-sm text-gray-500">Total Venues</p>
          </div>
          <p className="text-2xl font-bold text-gray-900">{mockDashboardStats.totalVenues}</p>
        </div>
        <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-6">
          <div className="flex items-center gap-3 mb-2">
            <Icon icon={faStar} className="text-yellow-600" />
            <p className="text-sm text-gray-500">Avg Rating</p>
          </div>
          <p className="text-2xl font-bold text-gray-900">{avgRating.toFixed(1)}</p>
        </div>
        <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-6">
          <div className="flex items-center gap-3 mb-2">
            <Icon icon={faUsers} className="text-primary" />
            <p className="text-sm text-gray-500">Total Reviews</p>
          </div>
          <p className="text-2xl font-bold text-gray-900">{totalReviews}</p>
        </div>
        <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-6">
          <div className="flex items-center gap-3 mb-2">
            <Icon icon={faDollarSign} className="text-green-600" />
            <p className="text-sm text-gray-500">Total Revenue</p>
          </div>
          <p className="text-2xl font-bold text-gray-900">
            RWF {mockVenues.reduce((sum, v) => sum + v.venue_price, 0).toLocaleString()}
          </p>
        </div>
      </div>

      {/* Charts */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6 mb-6">
        <ChartWrapper title="Venue Ratings" loading={loading}>
          <BarChart
            data={mockVenues.map(v => ({ name: v.venue_name, rating: v.venue_rating }))}
            dataKey="name"
            bars={[{ key: 'rating', name: 'Rating', color: '#1a74e8' }]}
            height={300}
          />
        </ChartWrapper>

        <ChartWrapper title="Reviews Distribution" loading={loading}>
          <PieChart
            data={[
              { name: '5 Stars', value: 45 },
              { name: '4 Stars', value: 38 },
              { name: '3 Stars', value: 25 },
              { name: '2 Stars', value: 8 },
              { name: '1 Star', value: 4 },
            ]}
            height={300}
          />
        </ChartWrapper>

        <ChartWrapper title="Revenue Trend" loading={loading}>
          <LineChart
            data={mockChartData.revenue}
            dataKey="date"
            lines={[
              { key: 'revenue', name: 'Revenue', color: '#1a74e8' },
            ]}
            height={300}
          />
        </ChartWrapper>

        <ChartWrapper title="Venues by Reviews" loading={loading}>
          <BarChart
            data={mockVenues.map(v => ({ name: v.venue_name, reviews: v.venue_reviews }))}
            dataKey="name"
            bars={[{ key: 'reviews', name: 'Reviews', color: '#1a74e8' }]}
            height={300}
          />
        </ChartWrapper>
      </div>
    </div>
  );
}

