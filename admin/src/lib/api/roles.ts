import apiClient from './client';

export type UserRole = 'explorer' | 'merchant' | 'event_organizer' | 'tour_operator' | 'admin' | 'super_admin';

export interface RoleInfo {
  role: UserRole;
  name: string;
  description: string;
  userCount: number;
  permissions: string[];
}

export interface RoleStats {
  totalRoles: number;
  totalUsers: number;
  roles: RoleInfo[];
}

export const RolesAPI = {
  /**
   * Get role statistics and information
   */
  getRoleStats: async (): Promise<RoleStats> => {
    // Since there's no backend endpoint, we'll fetch users and calculate stats
    const response = await apiClient.get<{ data: any[]; meta: any }>('/admin/users', {
      params: { limit: 1000 }, // Get a large number to calculate stats
    });
    
    const users = response.data.data || [];
    const roleCounts: Record<UserRole, number> = {
      explorer: 0,
      merchant: 0,
      event_organizer: 0,
      tour_operator: 0,
      admin: 0,
      super_admin: 0,
    };

    users.forEach((user: any) => {
      const roles = user.roles || [];
      roles.forEach((role: string | { code?: string; name?: string }) => {
        const roleCode = typeof role === 'string' ? role : (role.code || role.name || '').toLowerCase();
        if (roleCode in roleCounts) {
          roleCounts[roleCode as UserRole]++;
        }
      });
    });

    const roleDefinitions: Record<UserRole, { name: string; description: string; permissions: string[] }> = {
      explorer: {
        name: 'Explorer',
        description: 'Regular users who can browse, book, and review content',
        permissions: ['Browse listings', 'Book services', 'Write reviews', 'Manage favorites', 'View events'],
      },
      merchant: {
        name: 'Merchant',
        description: 'Business owners who can create and manage listings',
        permissions: ['Create listings', 'Manage bookings', 'View analytics', 'Update business info', 'Manage reviews'],
      },
      event_organizer: {
        name: 'Event Organizer',
        description: 'Users who can create and manage events',
        permissions: ['Create events', 'Manage event bookings', 'View event analytics', 'Manage tickets'],
      },
      tour_operator: {
        name: 'Tour Operator',
        description: 'Users who can create and manage tour packages',
        permissions: ['Create tours', 'Manage tour bookings', 'View tour analytics', 'Manage schedules'],
      },
      admin: {
        name: 'Admin',
        description: 'Platform administrators with management capabilities',
        permissions: ['Manage users', 'Manage listings', 'Manage events', 'Manage bookings', 'View analytics', 'Moderate content'],
      },
      super_admin: {
        name: 'Super Admin',
        description: 'Full platform access with all administrative privileges',
        permissions: ['All admin permissions', 'Manage roles', 'System settings', 'Access all data', 'Delete content'],
      },
    };

    const roles: RoleInfo[] = (Object.keys(roleCounts) as UserRole[]).map((role) => ({
      role,
      ...roleDefinitions[role],
      userCount: roleCounts[role],
    }));

    return {
      totalRoles: roles.length,
      totalUsers: users.length,
      roles: roles.sort((a, b) => b.userCount - a.userCount),
    };
  },
};

