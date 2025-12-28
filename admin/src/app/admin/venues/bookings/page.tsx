'use client';

import { useState, useEffect } from 'react';
import Icon, { faCalendar, faCheck, faClock, faTimes } from '../../../components/Icon';
import DataTable from '../../../components/DataTable';
import ChartWrapper from '../../../components/ChartWrapper';
import BarChart from '../../../components/charts/BarChart';
import PieChart from '../../../components/charts/PieChart';
import { mockVenues } from '@/lib/mockData';

export default function VenueBookingsPage() {
  const [loading, setLoading] = useState(true);
  const [bookings, setBookings] = useState<any[]>([]);

  useEffect(() => {
    // Simulate data fetching
    setTimeout(() => {
      setBookings([
        {
          id: 1,
          venue_name: 'The Garden Restaurant',
          customer_name: 'John Doe',
          booking_date: '2025-01-20',
          event_date: '2025-01-25',
          guests: 50,
          status: 'confirmed',
          amount: 50000,
        },
        {
          id: 2,
          venue_name: 'Sky Bar',
          customer_name: 'Jane Smith',
          booking_date: '2025-01-18',
          event_date: '2025-01-30',
          guests: 30,
          status: 'pending',
          amount: 35000,
        },
        {
          id: 3,
          venue_name: 'The Garden Restaurant',
          customer_name: 'Mike Johnson',
          booking_date: '2025-01-15',
          event_date: '2025-01-22',
          guests: 75,
          status: 'confirmed',
          amount: 75000,
        },
      ]);
      setLoading(false);
    }, 500);
  }, []);

  const columns = [
    { key: 'venue_name', label: 'Venue', sortable: true },
    { key: 'customer_name', label: 'Customer', sortable: true },
    { key: 'event_date', label: 'Event Date', sortable: true, render: (value: string) => new Date(value).toLocaleDateString() },
    { key: 'guests', label: 'Guests', sortable: true },
    {
      key: 'status',
      label: 'Status',
      sortable: true,
      render: (value: string) => {
        const colors: Record<string, string> = {
          confirmed: 'bg-green-100 text-green-800',
          pending: 'bg-yellow-100 text-yellow-800',
          cancelled: 'bg-red-100 text-red-800',
        };
        const color = colors[value] || 'bg-gray-100 text-gray-800';
        return (
          <span className={`px-2 py-1 rounded-full text-xs font-medium ${color}`}>
            {value}
          </span>
        );
      },
    },
    { key: 'amount', label: 'Amount', sortable: true, render: (value: number) => `RWF ${value.toLocaleString()}` },
  ];

  const confirmedCount = bookings.filter(b => b.status === 'confirmed').length;
  const pendingCount = bookings.filter(b => b.status === 'pending').length;
  const cancelledCount = bookings.filter(b => b.status === 'cancelled').length;

  return (
    <div>
      <div className="mb-8">
        <h1 className="text-3xl font-bold text-gray-900 mb-2">Venue Bookings</h1>
        <p className="text-gray-600">Manage and view all venue bookings</p>
      </div>

      {/* Summary Stats */}
      <div className="grid grid-cols-1 md:grid-cols-4 gap-6 mb-6">
        <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-6">
          <div className="flex items-center gap-3 mb-2">
            <Icon icon={faCalendar} className="text-primary" />
            <p className="text-sm text-gray-500">Total Bookings</p>
          </div>
          <p className="text-2xl font-bold text-gray-900">{bookings.length}</p>
        </div>
        <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-6">
          <div className="flex items-center gap-3 mb-2">
            <Icon icon={faCheck} className="text-green-600" />
            <p className="text-sm text-gray-500">Confirmed</p>
          </div>
          <p className="text-2xl font-bold text-gray-900">{confirmedCount}</p>
        </div>
        <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-6">
          <div className="flex items-center gap-3 mb-2">
            <Icon icon={faClock} className="text-yellow-600" />
            <p className="text-sm text-gray-500">Pending</p>
          </div>
          <p className="text-2xl font-bold text-gray-900">{pendingCount}</p>
        </div>
        <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-6">
          <div className="flex items-center gap-3 mb-2">
            <Icon icon={faTimes} className="text-red-600" />
            <p className="text-sm text-gray-500">Cancelled</p>
          </div>
          <p className="text-2xl font-bold text-gray-900">{cancelledCount}</p>
        </div>
      </div>

      {/* Charts */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6 mb-6">
        <ChartWrapper title="Bookings by Status" loading={loading}>
          <PieChart
            data={[
              { name: 'Confirmed', value: confirmedCount },
              { name: 'Pending', value: pendingCount },
              { name: 'Cancelled', value: cancelledCount },
            ]}
            height={300}
          />
        </ChartWrapper>

        <ChartWrapper title="Bookings by Venue" loading={loading}>
          <BarChart
            data={mockVenues.map(v => ({
              name: v.venue_name,
              bookings: Math.floor(Math.random() * 10) + 5,
            }))}
            dataKey="name"
            bars={[{ key: 'bookings', name: 'Bookings', color: '#181E29' }]}
            height={300}
          />
        </ChartWrapper>
      </div>

      {/* Data Table */}
      <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-6">
        <h2 className="text-lg font-semibold text-gray-900 mb-4">All Bookings</h2>
        <DataTable
          columns={columns}
          data={bookings}
          loading={loading}
        />
      </div>
    </div>
  );
}

