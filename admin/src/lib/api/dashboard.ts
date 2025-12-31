import apiClient from './client';

export interface DashboardStats {
  users: {
    total: number;
    active: number;
    newThisMonth: number;
  };
  listings: {
    total: number;
    active: number;
    pending: number;
  };
  events: {
    total: number;
    active: number;
    upcoming: number;
  };
  bookings: {
    total: number;
    pending: number;
    completed: number;
    thisMonth: number;
  };
  revenue: {
    total: number;
    thisMonth: number;
    lastMonth: number;
  };
}

export async function getDashboardStats(): Promise<DashboardStats> {
  try {
    // Fetch counts from admin endpoints with limit=1 to get just the meta.total
    const [usersRes, listingsRes, eventsRes, bookingsRes] = await Promise.all([
      apiClient.get('/admin/users', { params: { limit: 1, page: 1 } }),
      apiClient.get('/admin/listings', { params: { limit: 1, page: 1 } }),
      apiClient.get('/admin/events', { params: { limit: 1, page: 1 } }),
      apiClient.get('/admin/bookings', { params: { limit: 1, page: 1 } }),
    ]);

    // Get active users count
    const activeUsersRes = await apiClient.get('/admin/users', {
      params: { limit: 1, page: 1, isActive: 'true' },
    });

    // Get active listings count
    const activeListingsRes = await apiClient.get('/admin/listings', {
      params: { limit: 1, page: 1, status: 'active' },
    });

    // Get pending listings count
    const pendingListingsRes = await apiClient.get('/admin/listings', {
      params: { limit: 1, page: 1, status: 'pending_review' },
    });

    // Get active events count (events with status 'published' are active)
    const activeEventsRes = await apiClient.get('/admin/events', {
      params: { limit: 1, page: 1, status: 'published' },
    });

    // Get pending bookings count
    const pendingBookingsRes = await apiClient.get('/admin/bookings', {
      params: { limit: 1, page: 1, status: 'pending' },
    });

    // Get completed bookings count
    const completedBookingsRes = await apiClient.get('/admin/bookings', {
      params: { limit: 1, page: 1, status: 'completed' },
    });

    // Calculate this month's date range
    const now = new Date();
    const startOfMonth = new Date(now.getFullYear(), now.getMonth(), 1);
    const startOfMonthISO = startOfMonth.toISOString();

    // Get new users this month - use startDate filter if available, otherwise get all and filter client-side
    let newUsersThisMonth = 0;
    try {
      const newUsersThisMonthRes = await apiClient.get('/admin/users', {
        params: { limit: 100, page: 1 }, // Get more to filter by date
      });
      if (newUsersThisMonthRes.data?.data) {
        newUsersThisMonth = newUsersThisMonthRes.data.data.filter((user: any) => {
          const createdAt = new Date(user.createdAt);
          return createdAt >= startOfMonth;
        }).length;
      }
    } catch (e) {
      // If filtering fails, just use 0
      console.warn('Could not fetch new users this month:', e);
    }

    // Get bookings this month - use startDate filter
    let bookingsThisMonth = 0;
    try {
      const bookingsThisMonthRes = await apiClient.get('/admin/bookings', {
        params: { limit: 100, page: 1 }, // Get more to filter by date
      });
      if (bookingsThisMonthRes.data?.data) {
        bookingsThisMonth = bookingsThisMonthRes.data.data.filter((booking: any) => {
          const createdAt = new Date(booking.bookingDate || booking.createdAt);
          return createdAt >= startOfMonth;
        }).length;
      }
    } catch (e) {
      // If filtering fails, just use 0
      console.warn('Could not fetch bookings this month:', e);
    }

    // Get upcoming events (events with startDate in future)
    let upcomingEvents = 0;
    try {
      const upcomingEventsRes = await apiClient.get('/admin/events', {
        params: { limit: 100, page: 1 }, // Get more to filter by date
      });
      if (upcomingEventsRes.data?.data) {
        const now = new Date();
        upcomingEvents = upcomingEventsRes.data.data.filter((event: any) => {
          const startDate = new Date(event.startDate);
          return startDate > now;
        }).length;
      }
    } catch (e) {
      // If filtering fails, just use 0
      console.warn('Could not fetch upcoming events:', e);
    }

    return {
      users: {
        total: usersRes.data?.meta?.total || 0,
        active: activeUsersRes.data?.meta?.total || 0,
        newThisMonth: newUsersThisMonth,
      },
      listings: {
        total: listingsRes.data?.meta?.total || 0,
        active: activeListingsRes.data?.meta?.total || 0,
        pending: pendingListingsRes.data?.meta?.total || 0,
      },
      events: {
        total: eventsRes.data?.meta?.total || 0,
        active: activeEventsRes.data?.meta?.total || 0,
        upcoming: upcomingEvents,
      },
      bookings: {
        total: bookingsRes.data?.meta?.total || 0,
        pending: pendingBookingsRes.data?.meta?.total || 0,
        completed: completedBookingsRes.data?.meta?.total || 0,
        thisMonth: bookingsThisMonth,
      },
      revenue: {
        total: 0, // Will need to calculate from payments/transactions
        thisMonth: 0,
        lastMonth: 0,
      },
    };
  } catch (error: any) {
    console.error('Error fetching dashboard stats:', {
      message: error?.message,
      status: error?.status,
      response: error?.response?.data,
      stack: error?.stack,
    });
    // Return default values on error
    return {
      users: { total: 0, active: 0, newThisMonth: 0 },
      listings: { total: 0, active: 0, pending: 0 },
      events: { total: 0, active: 0, upcoming: 0 },
      bookings: { total: 0, pending: 0, completed: 0, thisMonth: 0 },
      revenue: { total: 0, thisMonth: 0, lastMonth: 0 },
    };
  }
}

