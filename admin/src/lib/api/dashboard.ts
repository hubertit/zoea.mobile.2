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
      params: { limit: 1, page: 1, isActive: true },
    });

    // Get active listings count
    const activeListingsRes = await apiClient.get('/admin/listings', {
      params: { limit: 1, page: 1, status: 'active' },
    });

    // Get pending listings count
    const pendingListingsRes = await apiClient.get('/admin/listings', {
      params: { limit: 1, page: 1, status: 'pending_review' },
    });

    // Get active events count
    const activeEventsRes = await apiClient.get('/admin/events', {
      params: { limit: 1, page: 1, status: 'active' },
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

    // Get new users this month
    const newUsersThisMonthRes = await apiClient.get('/admin/users', {
      params: { limit: 1, page: 1, createdAtFrom: startOfMonthISO },
    });

    // Get bookings this month
    const bookingsThisMonthRes = await apiClient.get('/admin/bookings', {
      params: { limit: 1, page: 1, createdAtFrom: startOfMonthISO },
    });

    // Get upcoming events (events with startDate in future)
    const upcomingEventsRes = await apiClient.get('/admin/events', {
      params: { limit: 1, page: 1, startDateFrom: new Date().toISOString() },
    });

    return {
      users: {
        total: usersRes.data.meta?.total || 0,
        active: activeUsersRes.data.meta?.total || 0,
        newThisMonth: newUsersThisMonthRes.data.meta?.total || 0,
      },
      listings: {
        total: listingsRes.data.meta?.total || 0,
        active: activeListingsRes.data.meta?.total || 0,
        pending: pendingListingsRes.data.meta?.total || 0,
      },
      events: {
        total: eventsRes.data.meta?.total || 0,
        active: activeEventsRes.data.meta?.total || 0,
        upcoming: upcomingEventsRes.data.meta?.total || 0,
      },
      bookings: {
        total: bookingsRes.data.meta?.total || 0,
        pending: pendingBookingsRes.data.meta?.total || 0,
        completed: completedBookingsRes.data.meta?.total || 0,
        thisMonth: bookingsThisMonthRes.data.meta?.total || 0,
      },
      revenue: {
        total: 0, // Will need to calculate from payments/transactions
        thisMonth: 0,
        lastMonth: 0,
      },
    };
  } catch (error) {
    console.error('Error fetching dashboard stats:', error);
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

