'use client';

import { useState, useEffect } from 'react';
import { useRouter } from 'next/navigation';
import { MerchantPortalAPI, type Business, type DashboardData } from '@/src/lib/api';
import { toast } from '@/app/components/Toaster';
import { StatCard, Button, Breadcrumbs } from '@/app/components';
import PageSkeleton from '@/app/components/PageSkeleton';
import Icon, { faBuilding, faClipboardList, faDollarSign, faStar, faArrowRight, faPlus } from '@/app/components/Icon';
import { useAuthStore } from '@/src/store/auth';

export default function MerchantDashboardPage() {
  const router = useRouter();
  const { user } = useAuthStore();
  const [businesses, setBusinesses] = useState<Business[]>([]);
  const [selectedBusinessId, setSelectedBusinessId] = useState<string | null>(null);
  const [dashboardData, setDashboardData] = useState<DashboardData | null>(null);
  const [loading, setLoading] = useState(true);
  const [dashboardLoading, setDashboardLoading] = useState(false);

  // Fetch businesses
  useEffect(() => {
    const fetchBusinesses = async () => {
      try {
        const data = await MerchantPortalAPI.getMyBusinesses();
        setBusinesses(data);
        if (data.length > 0 && !selectedBusinessId) {
          setSelectedBusinessId(data[0].id);
        }
      } catch (error: any) {
        console.error('Failed to fetch businesses:', error);
        toast.error(error?.response?.data?.message || error?.message || 'Failed to load businesses');
      } finally {
        setLoading(false);
      }
    };

    fetchBusinesses();
  }, []);

  // Fetch dashboard data when business is selected
  useEffect(() => {
    if (!selectedBusinessId) return;

    const fetchDashboard = async () => {
      setDashboardLoading(true);
      try {
        const data = await MerchantPortalAPI.getDashboard(selectedBusinessId);
        setDashboardData(data);
      } catch (error: any) {
        console.error('Failed to fetch dashboard:', error);
        toast.error(error?.response?.data?.message || error?.message || 'Failed to load dashboard');
      } finally {
        setDashboardLoading(false);
      }
    };

    fetchDashboard();
  }, [selectedBusinessId]);

  if (loading) {
    return <PageSkeleton />;
  }

  if (businesses.length === 0) {
    return (
      <div className="space-y-6">
        <Breadcrumbs items={[
          { label: 'Dashboard', href: '/dashboard' },
          { label: 'My Dashboard' }
        ]} />
        <div className="flex items-center justify-center min-h-[400px]">
          <div className="text-center">
            <Icon icon={faBuilding} className="text-gray-400 mx-auto mb-4" size="2x" />
            <h2 className="text-xl font-semibold text-gray-900 mb-2">No Business Found</h2>
            <p className="text-gray-600 mb-6">Create your first business to get started</p>
            <Button
              variant="primary"
              icon={faPlus}
              onClick={() => router.push('/dashboard/my-businesses?create=true')}
            >
              Create Business
            </Button>
          </div>
        </div>
      </div>
    );
  }

  const selectedBusiness = businesses.find(b => b.id === selectedBusinessId);

  return (
    <div className="space-y-6">
      <Breadcrumbs items={[
        { label: 'Dashboard', href: '/dashboard' },
        { label: 'My Dashboard' }
      ]} />

      {/* Business Selector */}
      <div className="bg-white border border-gray-200 rounded-sm p-4">
        <div className="flex items-center justify-between flex-wrap gap-4">
          <div className="flex-1 min-w-0">
            <label className="block text-sm font-medium text-gray-700 mb-2">
              Select Business
            </label>
            <select
              value={selectedBusinessId || ''}
              onChange={(e) => setSelectedBusinessId(e.target.value)}
              className="w-full md:w-auto px-3 py-2 border border-gray-200 rounded-sm focus:outline-none focus:ring-1 focus:ring-[#0e1a30] focus:border-[#0e1a30] text-sm"
            >
              {businesses.map((business) => (
                <option key={business.id} value={business.id}>
                  {business.businessName} {business.registrationStatus !== 'approved' && `(${business.registrationStatus})`}
                </option>
              ))}
            </select>
          </div>
          <div className="flex items-center gap-2">
            <Button
              variant="outline"
              size="sm"
              onClick={() => router.push(`/dashboard/my-businesses/${selectedBusinessId}`)}
            >
              View Business
            </Button>
            <Button
              variant="primary"
              size="sm"
              icon={faPlus}
              onClick={() => router.push('/dashboard/my-businesses?create=true')}
            >
              New Business
            </Button>
          </div>
        </div>
      </div>

      {dashboardLoading ? (
        <PageSkeleton />
      ) : dashboardData ? (
        <>
          {/* Overview Stats */}
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4">
            <StatCard
              title="Total Revenue"
              value={`${dashboardData.overview.totalRevenue.toLocaleString()} RWF`}
              icon={faDollarSign}
              trend={
                dashboardData.thisMonth.revenueChange
                  ? {
                      value: parseFloat(dashboardData.thisMonth.revenueChange),
                      label: 'vs last month',
                    }
                  : undefined
              }
            />
            <StatCard
              title="Total Bookings"
              value={dashboardData.overview.totalBookings.toString()}
              icon={faClipboardList}
              trend={
                dashboardData.thisMonth.bookingsChange
                  ? {
                      value: parseFloat(dashboardData.thisMonth.bookingsChange),
                      label: 'vs last month',
                    }
                  : undefined
              }
            />
            <StatCard
              title="Active Listings"
              value={dashboardData.overview.activeListings.toString()}
              icon={faBuilding}
              subtitle={`${dashboardData.overview.totalListings} total`}
            />
            <StatCard
              title="Average Rating"
              value={dashboardData.overview.averageRating.toFixed(1)}
              icon={faStar}
              subtitle={`${dashboardData.reviews.totalReviews} reviews`}
            />
          </div>

          {/* This Month Summary */}
          <div className="bg-white border border-gray-200 rounded-sm p-6">
            <h2 className="text-lg font-semibold text-gray-900 mb-4">This Month</h2>
            <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
              <div>
                <p className="text-sm text-gray-600 mb-1">Bookings</p>
                <p className="text-2xl font-bold text-gray-900">{dashboardData.thisMonth.bookings}</p>
                {dashboardData.thisMonth.bookingsChange && (
                  <p className={`text-sm mt-1 ${parseFloat(dashboardData.thisMonth.bookingsChange) >= 0 ? 'text-green-600' : 'text-red-600'}`}>
                    {parseFloat(dashboardData.thisMonth.bookingsChange) >= 0 ? '+' : ''}
                    {dashboardData.thisMonth.bookingsChange}% vs last month
                  </p>
                )}
              </div>
              <div>
                <p className="text-sm text-gray-600 mb-1">Revenue</p>
                <p className="text-2xl font-bold text-gray-900">{dashboardData.thisMonth.revenue.toLocaleString()} RWF</p>
                {dashboardData.thisMonth.revenueChange && (
                  <p className={`text-sm mt-1 ${parseFloat(dashboardData.thisMonth.revenueChange) >= 0 ? 'text-green-600' : 'text-red-600'}`}>
                    {parseFloat(dashboardData.thisMonth.revenueChange) >= 0 ? '+' : ''}
                    {dashboardData.thisMonth.revenueChange}% vs last month
                  </p>
                )}
              </div>
            </div>
          </div>

          {/* Recent Bookings */}
          <div className="bg-white border border-gray-200 rounded-sm p-6">
            <div className="flex items-center justify-between mb-4">
              <h2 className="text-lg font-semibold text-gray-900">Recent Bookings</h2>
              <Button
                variant="ghost"
                size="sm"
                onClick={() => router.push(`/dashboard/my-bookings?businessId=${selectedBusinessId}`)}
              >
                View All <Icon icon={faArrowRight} className="ml-1" size="xs" />
              </Button>
            </div>
            {dashboardData.recentBookings.length === 0 ? (
              <p className="text-gray-500 text-center py-8">No recent bookings</p>
            ) : (
              <div className="space-y-3">
                {dashboardData.recentBookings.map((booking) => (
                  <div
                    key={booking.id}
                    className="flex items-center justify-between p-3 border border-gray-200 rounded-sm hover:bg-gray-50 cursor-pointer"
                    onClick={() => router.push(`/dashboard/my-bookings/${booking.id}?businessId=${selectedBusinessId}`)}
                  >
                    <div className="flex-1">
                      <p className="font-medium text-gray-900">{booking.bookingNumber}</p>
                      <p className="text-sm text-gray-600">
                        {booking.user?.fullName || 'Guest'} • {booking.listing?.name || 'Listing'}
                      </p>
                      <p className="text-xs text-gray-500 mt-1">
                        {new Date(booking.createdAt).toLocaleDateString()}
                      </p>
                    </div>
                    <div className="text-right">
                      <p className="font-semibold text-gray-900">
                        {booking.totalAmount.toLocaleString()} {booking.currency}
                      </p>
                      <span className={`inline-block px-2 py-1 text-xs rounded-sm mt-1 ${
                        booking.status === 'confirmed' ? 'bg-green-100 text-green-800' :
                        booking.status === 'pending' ? 'bg-yellow-100 text-yellow-800' :
                        booking.status === 'cancelled' ? 'bg-red-100 text-red-800' :
                        'bg-gray-100 text-gray-800'
                      }`}>
                        {booking.status}
                      </span>
                    </div>
                  </div>
                ))}
              </div>
            )}
          </div>

          {/* Top Listings */}
          <div className="bg-white border border-gray-200 rounded-sm p-6">
            <h2 className="text-lg font-semibold text-gray-900 mb-4">Top Listings</h2>
            {dashboardData.topListings.length === 0 ? (
              <p className="text-gray-500 text-center py-8">No listings yet</p>
            ) : (
              <div className="space-y-3">
                {dashboardData.topListings.map((listing) => (
                  <div
                    key={listing.id}
                    className="flex items-center justify-between p-3 border border-gray-200 rounded-sm hover:bg-gray-50 cursor-pointer"
                    onClick={() => router.push(`/dashboard/my-listings/${listing.id}?businessId=${selectedBusinessId}`)}
                  >
                    <div className="flex-1">
                      <p className="font-medium text-gray-900">{listing.name}</p>
                      <p className="text-sm text-gray-600">
                        {listing.bookingCount} bookings • {listing.rating.toFixed(1)} ⭐
                      </p>
                    </div>
                    <Icon icon={faArrowRight} className="text-gray-400" size="sm" />
                  </div>
                ))}
              </div>
            )}
          </div>
        </>
      ) : null}
    </div>
  );
}

