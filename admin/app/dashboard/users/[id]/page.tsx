'use client';

import { useState, useEffect } from 'react';
import { useParams, useRouter } from 'next/navigation';
import Link from 'next/link';
import { UsersAPI, type User, type UserRole, type VerificationStatus } from '@/src/lib/api';
import Icon, { 
  faArrowLeft, 
  faEdit, 
  faShieldAlt,
  faEnvelope,
  faPhone,
  faCheck,
  faTimes,
  faHeart,
  faSearch,
  faEye,
  faCalendar,
  faClock,
  faDollarSign,
  faStar,
  faGlobe,
  faMapMarkerAlt,
} from '@/app/components/Icon';
import { toast } from '@/app/components/Toaster';
import { Button, Modal, Breadcrumbs } from '@/app/components';
import Card, { CardHeader, CardBody } from '@/app/components/Card';
import Input from '@/app/components/Input';
import Select from '@/app/components/Select';
import StatusBadge from '@/app/components/StatusBadge';

const ROLES: { value: UserRole; label: string }[] = [
  { value: 'explorer', label: 'Explorer' },
  { value: 'merchant', label: 'Merchant' },
  { value: 'event_organizer', label: 'Event Organizer' },
  { value: 'tour_operator', label: 'Tour Operator' },
  { value: 'admin', label: 'Admin' },
  { value: 'super_admin', label: 'Super Admin' },
];

const VERIFICATION_STATUSES: { value: VerificationStatus; label: string }[] = [
  { value: 'unverified', label: 'Unverified' },
  { value: 'pending', label: 'Pending' },
  { value: 'verified', label: 'Verified' },
  { value: 'rejected', label: 'Rejected' },
];

const getStatusBadgeColor = (isActive: boolean, isBlocked: boolean) => {
  if (isBlocked) return 'bg-red-100 text-red-800';
  if (isActive) return 'bg-green-100 text-green-800';
  return 'bg-gray-100 text-gray-800';
};

const getStatusLabel = (isActive: boolean, isBlocked: boolean) => {
  if (isBlocked) return 'Blocked';
  if (isActive) return 'Active';
  return 'Inactive';
};

export default function UserDetailPage() {
  const params = useParams();
  const router = useRouter();
  const userId = params?.id as string | undefined;

  const [user, setUser] = useState<User | null>(null);
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);
  const [assigningRoles, setAssigningRoles] = useState(false);
  const [editMode, setEditMode] = useState(false);
  const [roleModalOpen, setRoleModalOpen] = useState(false);
  const [statusModalOpen, setStatusModalOpen] = useState(false);

  const [formData, setFormData] = useState({
    isActive: true,
    isBlocked: false,
    verificationStatus: 'unverified' as VerificationStatus,
  });

  const [selectedRoles, setSelectedRoles] = useState<UserRole[]>([]);

  useEffect(() => {
    if (!userId) {
      setLoading(false);
      return;
    }

    const fetchUser = async () => {
      setLoading(true);
      try {
        const userData = await UsersAPI.getUserById(userId);
        setUser(userData);
        setFormData({
          isActive: userData.isActive || false,
          isBlocked: userData.isBlocked || false,
          verificationStatus: userData.verificationStatus || 'unverified',
        });
        // Extract roles from user data
        const roles = userData.roles || [];
        const roleValues = roles.map((role) => 
          typeof role === 'string' ? role : (role as any).code || role
        ).filter(Boolean) as UserRole[];
        setSelectedRoles(roleValues);
      } catch (error: any) {
        console.error('Failed to fetch user:', error);
        toast.error(error?.message || 'Failed to load user');
        router.push('/dashboard/users');
      } finally {
        setLoading(false);
      }
    };

    fetchUser();
  }, [userId, router]);

  const handleSaveStatus = async () => {
    if (!userId) return;

    setSaving(true);
    try {
      await UsersAPI.updateUserStatus(userId, {
        isActive: formData.isActive,
        isBlocked: formData.isBlocked,
        verificationStatus: formData.verificationStatus,
      });
      
      // Refresh user data
      const updatedUser = await UsersAPI.getUserById(userId);
      setUser(updatedUser);
      setStatusModalOpen(false);
      setEditMode(false);
      toast.success('User status updated successfully');
    } catch (error: any) {
      console.error('Failed to update user status:', error);
      toast.error(error?.message || 'Failed to update user status');
    } finally {
      setSaving(false);
    }
  };

  const handleAssignRoles = async () => {
    if (!userId) return;

    if (selectedRoles.length === 0) {
      toast.error('Please select at least one role');
      return;
    }

    setAssigningRoles(true);
    try {
      await UsersAPI.updateUserRoles(userId, { roles: selectedRoles });
      
      // Refresh user data
      const updatedUser = await UsersAPI.getUserById(userId);
      setUser(updatedUser);
      setRoleModalOpen(false);
      toast.success('Roles updated successfully');
    } catch (error: any) {
      console.error('Failed to assign roles:', error);
      toast.error(error?.message || 'Failed to assign roles');
    } finally {
      setAssigningRoles(false);
    }
  };

  const handleRoleToggle = (role: UserRole) => {
    setSelectedRoles((prev) =>
      prev.includes(role)
        ? prev.filter((r) => r !== role)
        : [...prev, role]
    );
  };

  if (loading) {
    return (
      <div className="flex items-center justify-center min-h-[400px]">
        <div className="text-center">
          <div className="inline-block animate-spin rounded-full h-12 w-12 border-b-2 border-[#0e1a30] mb-4"></div>
          <p className="text-gray-600">Loading user...</p>
        </div>
      </div>
    );
  }

  if (!user) {
    return null;
  }

  const currentRoles = user.roles || [];
  const currentRoleValues = currentRoles.map((role) => 
    typeof role === 'string' ? role : (role as any).code || role
  ).filter(Boolean) as UserRole[];

  return (
    <div className="space-y-6">
      <Breadcrumbs items={[
        { label: 'Users', href: '/dashboard/users' },
        { label: user?.fullName || 'User Details' }
      ]} />
      
      {/* Header */}
      <div className="flex items-center justify-between flex-wrap gap-4">
        <div className="flex items-center gap-4">
          <Link href="/dashboard/users">
            <Button variant="ghost" size="sm" icon={faArrowLeft}>
              Back
            </Button>
          </Link>
          <div>
            <h1 className="text-2xl font-bold text-gray-900">User Details</h1>
            <p className="text-gray-600 mt-1">
              {user.fullName || 'N/A'} • {user.phoneNumber || 'N/A'}
            </p>
          </div>
        </div>
        <div className="flex items-center gap-2">
          <Button
            onClick={() => {
              setSelectedRoles([...currentRoleValues]);
              setRoleModalOpen(true);
            }}
            variant="secondary"
            size="sm"
            icon={faShieldAlt}
          >
            Manage Roles
          </Button>
          <Button
            onClick={() => {
              setEditMode(true);
              setStatusModalOpen(true);
            }}
            variant="primary"
            size="sm"
            icon={faEdit}
          >
            Update Status
          </Button>
        </div>
      </div>

      {/* User Info */}
      <Card>
        <CardHeader>
          <h2 className="text-lg font-semibold text-gray-900">User Information</h2>
        </CardHeader>
        <CardBody>
          <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
            {/* Name */}
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Full Name
              </label>
              <p className="text-sm text-gray-900">{user.fullName || 'N/A'}</p>
            </div>

            {/* Email */}
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Email
              </label>
              <div className="flex items-center gap-2">
                <Icon icon={faEnvelope} className="text-gray-400" size="sm" />
                <p className="text-sm text-gray-900">{user.email || 'N/A'}</p>
              </div>
            </div>

            {/* Phone */}
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Phone Number
              </label>
              <div className="flex items-center gap-2">
                <Icon icon={faPhone} className="text-gray-400" size="sm" />
                <p className="text-sm text-gray-900">{user.phoneNumber || 'N/A'}</p>
              </div>
            </div>

            {/* Status */}
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Status
              </label>
              <span className={`inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium ${getStatusBadgeColor(user.isActive || false, user.isBlocked || false)}`}>
                {getStatusLabel(user.isActive || false, user.isBlocked || false)}
              </span>
            </div>

            {/* Verification Status */}
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Verification Status
              </label>
              <StatusBadge status={user.verificationStatus || 'unverified'} />
            </div>

            {/* Created At with Time */}
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                <Icon icon={faCalendar} className="inline mr-1 text-gray-400" size="sm" />
                Date Joined
              </label>
              <div>
                <p className="text-sm text-gray-900">
                  {user.createdAt ? new Date(user.createdAt).toLocaleDateString('en-US', {
                    year: 'numeric',
                    month: 'long',
                    day: 'numeric',
                  }) : 'N/A'}
                </p>
                {user.createdAt && (
                  <p className="text-xs text-gray-500 mt-1">
                    <Icon icon={faClock} className="inline mr-1" size="xs" />
                    {new Date(user.createdAt).toLocaleTimeString('en-US', {
                      hour: '2-digit',
                      minute: '2-digit',
                      second: '2-digit',
                    })}
                  </p>
                )}
              </div>
            </div>

            {/* Country/City */}
            {user.country && (
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  Location
                </label>
                <p className="text-sm text-gray-900">
                  {user.city?.name || ''} {user.city?.name && user.country?.name ? ', ' : ''}
                  {user.country?.name || ''}
                </p>
              </div>
            )}
          </div>
        </CardBody>
      </Card>

      {/* Activity Summary */}
      {user.user_activity_summary && (
        <Card>
          <CardHeader>
            <h2 className="text-lg font-semibold text-gray-900">Activity Summary</h2>
          </CardHeader>
          <CardBody>
            <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
              <div>
                <label className="block text-xs text-gray-500 mb-1">Total Views</label>
                <p className="text-lg font-semibold text-gray-900">{user.user_activity_summary.totalViews?.toLocaleString() || '0'}</p>
              </div>
              <div>
                <label className="block text-xs text-gray-500 mb-1">Total Bookings</label>
                <p className="text-lg font-semibold text-gray-900">{user.user_activity_summary.totalBookings?.toLocaleString() || '0'}</p>
              </div>
              <div>
                <label className="block text-xs text-gray-500 mb-1">Total Spent</label>
                <p className="text-lg font-semibold text-gray-900">
                  {user.user_activity_summary.totalSpent ? `RWF ${Number(user.user_activity_summary.totalSpent).toLocaleString()}` : 'RWF 0'}
                </p>
              </div>
              <div>
                <label className="block text-xs text-gray-500 mb-1">Total Reviews</label>
                <p className="text-lg font-semibold text-gray-900">{user.user_activity_summary.totalReviews?.toLocaleString() || '0'}</p>
              </div>
              {user.user_activity_summary.lastActiveAt && (
                <div className="md:col-span-2">
                  <label className="block text-xs text-gray-500 mb-1">Last Active</label>
                  <p className="text-sm text-gray-900">
                    {new Date(user.user_activity_summary.lastActiveAt).toLocaleString('en-US', {
                      month: 'short',
                      day: 'numeric',
                      year: 'numeric',
                      hour: '2-digit',
                      minute: '2-digit',
                    })}
                  </p>
                </div>
              )}
              {user.user_activity_summary.favoriteCategories && user.user_activity_summary.favoriteCategories.length > 0 && (
                <div className="md:col-span-2">
                  <label className="block text-xs text-gray-500 mb-1">Favorite Categories</label>
                  <div className="flex flex-wrap gap-1 mt-1">
                    {user.user_activity_summary.favoriteCategories.map((cat, idx) => (
                      <span key={idx} className="inline-flex items-center px-2 py-0.5 rounded text-xs font-medium bg-blue-100 text-blue-800">
                        {cat}
                      </span>
                    ))}
                  </div>
                </div>
              )}
            </div>
          </CardBody>
        </Card>
      )}

      {/* Statistics */}
      {user._count && (
        <Card>
          <CardHeader>
            <h2 className="text-lg font-semibold text-gray-900">Statistics</h2>
          </CardHeader>
          <CardBody>
            <div className="grid grid-cols-2 md:grid-cols-5 gap-4">
              <div>
                <label className="block text-xs text-gray-500 mb-1">Bookings</label>
                <p className="text-lg font-semibold text-gray-900">{user._count.bookings || 0}</p>
              </div>
              <div>
                <label className="block text-xs text-gray-500 mb-1">Reviews</label>
                <p className="text-lg font-semibold text-gray-900">{user._count.reviews || 0}</p>
              </div>
              <div>
                <label className="block text-xs text-gray-500 mb-1">Favorites</label>
                <p className="text-lg font-semibold text-gray-900">{user._count.favorites || 0}</p>
              </div>
              <div>
                <label className="block text-xs text-gray-500 mb-1">Searches</label>
                <p className="text-lg font-semibold text-gray-900">{user._count.searchHistory || 0}</p>
              </div>
              <div>
                <label className="block text-xs text-gray-500 mb-1">Viewed</label>
                <p className="text-lg font-semibold text-gray-900">{user._count.recentlyViewed || 0}</p>
              </div>
            </div>
          </CardBody>
        </Card>
      )}

      {/* Preferences */}
      {(user.preferredCurrency || user.preferredLanguage || user.timezone || user.user_content_preferences) && (
        <Card>
          <CardHeader>
            <h2 className="text-lg font-semibold text-gray-900">Preferences</h2>
          </CardHeader>
          <CardBody>
            <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
              {user.preferredCurrency && (
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">
                    <Icon icon={faDollarSign} className="inline mr-1 text-gray-400" size="sm" />
                    Preferred Currency
                  </label>
                  <p className="text-sm text-gray-900">{user.preferredCurrency}</p>
                </div>
              )}
              {user.preferredLanguage && (
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">
                    <Icon icon={faGlobe} className="inline mr-1 text-gray-400" size="sm" />
                    Preferred Language
                  </label>
                  <p className="text-sm text-gray-900">{user.preferredLanguage}</p>
                </div>
              )}
              {user.timezone && (
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">
                    <Icon icon={faClock} className="inline mr-1 text-gray-400" size="sm" />
                    Timezone
                  </label>
                  <p className="text-sm text-gray-900">{user.timezone}</p>
                </div>
              )}
              {user.maxDistance && (
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">
                    <Icon icon={faMapMarkerAlt} className="inline mr-1 text-gray-400" size="sm" />
                    Max Distance (km)
                  </label>
                  <p className="text-sm text-gray-900">{user.maxDistance}</p>
                </div>
              )}
              {user.user_content_preferences && (
                <>
                  {user.user_content_preferences.showEvents !== null && (
                    <div>
                      <label className="block text-sm font-medium text-gray-700 mb-1">Show Events</label>
                      <p className="text-sm text-gray-900">{user.user_content_preferences.showEvents ? 'Yes' : 'No'}</p>
                    </div>
                  )}
                  {user.user_content_preferences.showListings !== null && (
                    <div>
                      <label className="block text-sm font-medium text-gray-700 mb-1">Show Listings</label>
                      <p className="text-sm text-gray-900">{user.user_content_preferences.showListings ? 'Yes' : 'No'}</p>
                    </div>
                  )}
                  {user.user_content_preferences.showTours !== null && (
                    <div>
                      <label className="block text-sm font-medium text-gray-700 mb-1">Show Tours</label>
                      <p className="text-sm text-gray-900">{user.user_content_preferences.showTours ? 'Yes' : 'No'}</p>
                    </div>
                  )}
                  {user.user_content_preferences.preferredPriceRange && (
                    <div>
                      <label className="block text-sm font-medium text-gray-700 mb-1">Preferred Price Range</label>
                      <p className="text-sm text-gray-900">{user.user_content_preferences.preferredPriceRange}</p>
                    </div>
                  )}
                </>
              )}
            </div>
          </CardBody>
        </Card>
      )}

      {/* Favorites */}
      {user.favorites && user.favorites.length > 0 && (
        <Card>
          <CardHeader>
            <div className="flex items-center justify-between">
              <h2 className="text-lg font-semibold text-gray-900">
                <Icon icon={faHeart} className="inline mr-2 text-red-500" size="sm" />
                Favorites ({user.favorites.length})
              </h2>
            </div>
          </CardHeader>
          <CardBody>
            <div className="grid grid-cols-1 md:grid-cols-2 gap-3">
              {user.favorites.map((fav) => (
                <div key={fav.id} className="p-3 border border-gray-200 rounded-sm">
                  <div>
                    {fav.listing && (
                      <Link href={`/dashboard/listings/${fav.listing.id}`} className="text-sm font-medium text-[#0e1a30] hover:underline">
                        {fav.listing.name} ({fav.listing.type?.replace(/_/g, ' ')})
                      </Link>
                    )}
                    {fav.event && (
                      <Link href={`/dashboard/events/${fav.event.id}`} className="text-sm font-medium text-[#0e1a30] hover:underline">
                        {fav.event.name}
                      </Link>
                    )}
                    {fav.tour && (
                      <span className="text-sm font-medium text-gray-900">{fav.tour.name}</span>
                    )}
                    <p className="text-xs text-gray-500 mt-1">
                      {new Date(fav.createdAt).toLocaleDateString('en-US', {
                        month: 'short',
                        day: 'numeric',
                        year: 'numeric',
                      })}
                    </p>
                  </div>
                </div>
              ))}
            </div>
          </CardBody>
        </Card>
      )}

      {/* Search History */}
      {user.searchHistory && user.searchHistory.length > 0 && (
        <Card>
          <CardHeader>
            <div className="flex items-center justify-between">
              <h2 className="text-lg font-semibold text-gray-900">
                <Icon icon={faSearch} className="inline mr-2 text-gray-400" size="sm" />
                Search History ({user.searchHistory.length})
              </h2>
            </div>
          </CardHeader>
          <CardBody>
            <div className="grid grid-cols-1 md:grid-cols-2 gap-3">
              {user.searchHistory.map((search) => (
                <div key={search.id} className="p-3 border border-gray-200 rounded-sm">
                  <p className="text-sm font-medium text-gray-900">{search.query}</p>
                  <div className="flex items-center gap-4 mt-1">
                    {search.resultCount !== null && (
                      <span className="text-xs text-gray-500">{search.resultCount} results</span>
                    )}
                    <span className="text-xs text-gray-500">
                      {new Date(search.createdAt).toLocaleDateString('en-US', {
                        month: 'short',
                        day: 'numeric',
                        year: 'numeric',
                        hour: '2-digit',
                        minute: '2-digit',
                      })}
                    </span>
                  </div>
                </div>
              ))}
            </div>
          </CardBody>
        </Card>
      )}

      {/* Recently Viewed */}
      {user.recentlyViewed && user.recentlyViewed.length > 0 && (
        <Card>
          <CardHeader>
            <div className="flex items-center justify-between">
              <h2 className="text-lg font-semibold text-gray-900">
                <Icon icon={faEye} className="inline mr-2 text-gray-400" size="sm" />
                Recently Viewed ({user.recentlyViewed.length})
              </h2>
            </div>
          </CardHeader>
          <CardBody>
            <div className="grid grid-cols-1 md:grid-cols-2 gap-3">
              {user.recentlyViewed.map((viewed) => (
                <div key={viewed.id} className="p-3 border border-gray-200 rounded-sm">
                  {viewed.listing && (
                    <Link href={`/dashboard/listings/${viewed.listing.id}`} className="text-sm font-medium text-[#0e1a30] hover:underline">
                      {viewed.listing.name} ({viewed.listing.type?.replace(/_/g, ' ')})
                    </Link>
                  )}
                  {viewed.event && (
                    <Link href={`/dashboard/events/${viewed.event.id}`} className="text-sm font-medium text-[#0e1a30] hover:underline">
                      {viewed.event.name}
                    </Link>
                  )}
                  {viewed.tour && (
                    <span className="text-sm font-medium text-gray-900">{viewed.tour.name}</span>
                  )}
                  <p className="text-xs text-gray-500 mt-1">
                    {new Date(viewed.viewedAt).toLocaleDateString('en-US', {
                      month: 'short',
                      day: 'numeric',
                      year: 'numeric',
                      hour: '2-digit',
                      minute: '2-digit',
                    })}
                  </p>
                </div>
              ))}
            </div>
          </CardBody>
        </Card>
      )}

      {/* Recent Bookings */}
      {user.bookings && user.bookings.length > 0 && (
        <Card>
          <CardHeader>
            <div className="flex items-center justify-between">
              <h2 className="text-lg font-semibold text-gray-900">
                Recent Bookings ({user.bookings.length})
              </h2>
              <Link href={`/dashboard/bookings?userId=${user.id}`}>
                <Button variant="ghost" size="sm">View All</Button>
              </Link>
            </div>
          </CardHeader>
          <CardBody>
            <div className="grid grid-cols-1 md:grid-cols-2 gap-3">
              {user.bookings.map((booking) => (
                <Link key={booking.id} href={`/dashboard/bookings/${booking.id}`}>
                  <div className="p-3 border border-gray-200 rounded-sm hover:bg-gray-50 cursor-pointer">
                    <p className="text-sm font-medium text-gray-900">#{booking.bookingNumber}</p>
                    <div className="flex flex-wrap items-center gap-2 mt-1">
                      {booking.listing && (
                        <span className="text-xs text-gray-500">{booking.listing.name}</span>
                      )}
                      {booking.event && (
                        <span className="text-xs text-gray-500">{booking.event.name}</span>
                      )}
                      <span className="text-xs font-medium text-gray-700">
                        {booking.currency || 'RWF'} {booking.totalAmount?.toLocaleString() || '0'}
                      </span>
                      <span className={`inline-flex items-center px-2 py-0.5 rounded-full text-xs font-medium ${
                        booking.status === 'completed' ? 'bg-green-100 text-green-800' :
                        booking.status === 'confirmed' ? 'bg-blue-100 text-blue-800' :
                        'bg-yellow-100 text-yellow-800'
                      }`}>
                        {booking.status}
                      </span>
                    </div>
                    <p className="text-xs text-gray-500 mt-1">
                      {new Date(booking.createdAt).toLocaleDateString('en-US', {
                        month: 'short',
                        day: 'numeric',
                        year: 'numeric',
                      })}
                    </p>
                  </div>
                </Link>
              ))}
            </div>
          </CardBody>
        </Card>
      )}

      {/* Recent Reviews */}
      {user.reviews && user.reviews.length > 0 && (
        <Card>
          <CardHeader>
            <div className="flex items-center justify-between">
              <h2 className="text-lg font-semibold text-gray-900">
                <Icon icon={faStar} className="inline mr-2 text-yellow-500" size="sm" />
                Recent Reviews ({user.reviews.length})
              </h2>
            </div>
          </CardHeader>
          <CardBody>
            <div className="grid grid-cols-1 md:grid-cols-2 gap-3">
              {user.reviews.map((review) => (
                <div key={review.id} className="p-3 border border-gray-200 rounded-sm">
                  <div className="flex items-center gap-2 mb-2">
                    <div className="flex items-center">
                      {[...Array(5)].map((_, i) => (
                        <Icon
                          key={i}
                          icon={faStar}
                          className={i < (review.rating || 0) ? 'text-yellow-400' : 'text-gray-300'}
                          size="xs"
                        />
                      ))}
                    </div>
                    {review.listing && (
                      <Link href={`/dashboard/listings/${review.listing.id}`} className="text-xs text-[#0e1a30] hover:underline">
                        {review.listing.name}
                      </Link>
                    )}
                    {review.event && (
                      <Link href={`/dashboard/events/${review.event.id}`} className="text-xs text-[#0e1a30] hover:underline">
                        {review.event.name}
                      </Link>
                    )}
                  </div>
                  {review.comment && (
                    <p className="text-sm text-gray-700 mb-2">{review.comment}</p>
                  )}
                  <p className="text-xs text-gray-500">
                    {new Date(review.createdAt).toLocaleDateString('en-US', {
                      month: 'short',
                      day: 'numeric',
                      year: 'numeric',
                    })}
                  </p>
                </div>
              ))}
            </div>
          </CardBody>
        </Card>
      )}

      {/* Roles */}
      <Card>
        <CardHeader>
          <div className="flex items-center justify-between">
            <h2 className="text-lg font-semibold text-gray-900">Roles</h2>
          </div>
        </CardHeader>
        <CardBody>
          <div className="flex flex-wrap gap-2">
            {currentRoleValues.length > 0 ? (
              currentRoleValues.map((role, index) => (
                <span
                  key={index}
                  className="inline-flex items-center px-3 py-1 rounded-full text-sm font-medium bg-blue-100 text-blue-800"
                >
                  {role.replace(/_/g, ' ')}
                </span>
              ))
            ) : (
              <p className="text-sm text-gray-500">No roles assigned</p>
            )}
          </div>
        </CardBody>
      </Card>

      {/* Status Update Modal */}
      <Modal
        isOpen={statusModalOpen}
        onClose={() => {
          setStatusModalOpen(false);
          setEditMode(false);
          setFormData({
            isActive: user.isActive || false,
            isBlocked: user.isBlocked || false,
            verificationStatus: user.verificationStatus || 'unverified',
          });
        }}
        title="Update User Status"
        size="md"
      >
        <div className="space-y-4">
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">
              Active Status
            </label>
            <div className="flex items-center gap-4">
              <label className="flex items-center gap-2">
                <input
                  type="checkbox"
                  checked={formData.isActive}
                  onChange={(e) => setFormData({ ...formData, isActive: e.target.checked })}
                  className="w-4 h-4 text-[#0e1a30] border-gray-300 rounded focus:ring-[#0e1a30]"
                />
                <span className="text-sm text-gray-700">Active</span>
              </label>
              <label className="flex items-center gap-2">
                <input
                  type="checkbox"
                  checked={formData.isBlocked}
                  onChange={(e) => setFormData({ ...formData, isBlocked: e.target.checked })}
                  className="w-4 h-4 text-[#0e1a30] border-gray-300 rounded focus:ring-[#0e1a30]"
                />
                <span className="text-sm text-gray-700">Blocked</span>
              </label>
            </div>
          </div>

          <div>
            <Select
              label="Verification Status"
              value={formData.verificationStatus}
              onChange={(e) => setFormData({ ...formData, verificationStatus: e.target.value as VerificationStatus })}
              options={VERIFICATION_STATUSES.map((s) => ({ value: s.value, label: s.label }))}
            />
          </div>

          <div className="flex items-center gap-2 justify-end pt-4 border-t border-gray-200">
            <Button
              variant="secondary"
              size="md"
              onClick={() => {
                setStatusModalOpen(false);
                setEditMode(false);
                setFormData({
                  isActive: user.isActive || false,
                  isBlocked: user.isBlocked || false,
                  verificationStatus: user.verificationStatus || 'unverified',
                });
              }}
              disabled={saving}
            >
              Cancel
            </Button>
            <Button
              variant="primary"
              size="md"
              onClick={handleSaveStatus}
              loading={saving}
            >
              Save Changes
            </Button>
          </div>
        </div>
      </Modal>

      {/* Role Assignment Modal */}
      <Modal
        isOpen={roleModalOpen}
        onClose={() => {
          setRoleModalOpen(false);
          setSelectedRoles([...currentRoleValues]);
        }}
        title="Manage Roles"
        size="lg"
      >
        <div className="space-y-4">
          <p className="text-sm text-gray-600 mb-4">
            Select roles to assign to {user.fullName || 'this user'}
          </p>
          <div className="grid grid-cols-2 md:grid-cols-3 gap-3">
            {ROLES.map((role) => (
              <label
                key={role.value}
                className={`flex items-center gap-2 p-3 border-2 rounded-sm cursor-pointer transition-all ${
                  selectedRoles.includes(role.value)
                    ? 'border-[#0e1a30] bg-[#0e1a30]/5'
                    : 'border-gray-200 hover:border-gray-300'
                }`}
              >
                <input
                  type="checkbox"
                  checked={selectedRoles.includes(role.value)}
                  onChange={() => handleRoleToggle(role.value)}
                  className="w-4 h-4 text-[#0e1a30] border-gray-300 rounded focus:ring-[#0e1a30]"
                />
                <span className="text-sm font-medium text-gray-700">{role.label}</span>
              </label>
            ))}
          </div>
          <div className="flex items-center gap-2 justify-end pt-4 border-t border-gray-200">
            <Button
              variant="secondary"
              size="md"
              onClick={() => {
                setRoleModalOpen(false);
                setSelectedRoles([...currentRoleValues]);
              }}
              disabled={assigningRoles}
            >
              Cancel
            </Button>
            <Button
              variant="primary"
              size="md"
              onClick={handleAssignRoles}
              disabled={assigningRoles || selectedRoles.length === 0}
              loading={assigningRoles}
            >
              Assign Roles
            </Button>
          </div>
        </div>
      </Modal>
    </div>
  );
}
