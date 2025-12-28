'use client';

import { useState } from 'react';
import Icon, { faDownload, faStar, faUsers, faThumbsUp, faArrowLeft } from '../../../../components/Icon';
import Link from 'next/link';
import ChartWrapper from '../../../../components/ChartWrapper';
import BarChart from '../../../../components/charts/BarChart';
import PieChart from '../../../../components/charts/PieChart';
import DataTable from '../../../../components/DataTable';
import { mockVenues } from '@/lib/mockData';

export default function VenueReviewsReportPage() {
  const [dateRange, setDateRange] = useState({
    start: '2025-01-01',
    end: '2025-12-31',
  });

  const totalReviews = mockVenues.reduce((sum, v) => sum + v.venue_reviews, 0);
  const avgRating = mockVenues.reduce((sum, v) => sum + v.venue_rating, 0) / mockVenues.length;
  const fiveStar = 45;
  const fourStar = 38;

  const columns = [
    { key: 'venue_name', label: 'Venue', sortable: true },
    { key: 'venue_rating', label: 'Rating', sortable: true, render: (value: number) => `${value.toFixed(1)} ⭐` },
    { key: 'venue_reviews', label: 'Reviews', sortable: true },
    { key: 'positive_rate', label: 'Positive Rate', sortable: true, render: (value: number) => `${value}%` },
  ];

  const reviewData = mockVenues.map(v => ({
    ...v,
    positive_rate: Math.floor(Math.random() * 20) + 80,
  }));

  return (
    <div>
      <div className="mb-8">
        <div className="flex items-center justify-between mb-4">
          <div className="flex items-center gap-4">
            <Link
              href="/admin/reports"
              className="p-2 hover:bg-gray-100 rounded-lg transition-colors"
            >
              <Icon icon={faArrowLeft} />
            </Link>
            <div>
              <h1 className="text-3xl font-bold text-gray-900 mb-2">Review & Rating Report</h1>
              <p className="text-gray-600">Venue reviews and rating analytics</p>
            </div>
          </div>
          <button className="flex items-center gap-2 bg-primary text-white px-4 py-2 rounded-lg hover:bg-primary-600 transition-colors">
            <Icon icon={faDownload} />
            <span>Export</span>
          </button>
        </div>
      </div>

      {/* Filters */}
      <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-6 mb-6">
        <h2 className="text-lg font-semibold text-gray-900 mb-4">Filters</h2>
        <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">Start Date</label>
            <input
              type="date"
              value={dateRange.start}
              onChange={(e) => setDateRange({ ...dateRange, start: e.target.value })}
              className="w-full px-4 py-2 border border-gray-200 rounded-lg focus:outline-none focus:border-primary"
            />
          </div>
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">End Date</label>
            <input
              type="date"
              value={dateRange.end}
              onChange={(e) => setDateRange({ ...dateRange, end: e.target.value })}
              className="w-full px-4 py-2 border border-gray-200 rounded-lg focus:outline-none focus:border-primary"
            />
          </div>
          <div className="flex items-end">
            <button className="w-full bg-primary text-white px-4 py-2 rounded-lg hover:bg-primary-600 transition-colors">
              Apply Filters
            </button>
          </div>
        </div>
      </div>

      {/* Summary Stats */}
      <div className="grid grid-cols-1 md:grid-cols-4 gap-6 mb-6">
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
            <Icon icon={faThumbsUp} className="text-green-600" />
            <p className="text-sm text-gray-500">5 Star Reviews</p>
          </div>
          <p className="text-2xl font-bold text-gray-900">{fiveStar}</p>
        </div>
        <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-6">
          <div className="flex items-center gap-3 mb-2">
            <Icon icon={faStar} className="text-primary" />
            <p className="text-sm text-gray-500">4 Star Reviews</p>
          </div>
          <p className="text-2xl font-bold text-gray-900">{fourStar}</p>
        </div>
      </div>

      {/* Charts */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6 mb-6">
        <ChartWrapper title="Ratings Distribution">
          <PieChart
            data={[
              { name: '5 Stars', value: fiveStar },
              { name: '4 Stars', value: fourStar },
              { name: '3 Stars', value: 25 },
              { name: '2 Stars', value: 8 },
              { name: '1 Star', value: 4 },
            ]}
            height={300}
          />
        </ChartWrapper>

        <ChartWrapper title="Top Rated Venues">
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
        <h2 className="text-lg font-semibold text-gray-900 mb-4">Venue Reviews Summary</h2>
        <DataTable
          columns={columns}
          data={reviewData}
          loading={false}
        />
      </div>
    </div>
  );
}

