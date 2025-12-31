import apiClient from './client';

export type UserRole = 'explorer' | 'merchant' | 'event_organizer' | 'tour_operator' | 'admin' | 'super_admin';
export type VerificationStatus = 'unverified' | 'pending' | 'verified' | 'rejected';

export interface User {
  id: string;
  fullName: string | null;
  email: string | null;
  phoneNumber: string | null;
  roles: UserRole[];
  verificationStatus: VerificationStatus | null;
  isActive: boolean;
  isBlocked: boolean;
  createdAt: string;
  country?: { id: string; name: string; code: string } | null;
  city?: { id: string; name: string } | null;
}

export interface ListUsersParams {
  page?: number;
  limit?: number;
  search?: string;
  role?: UserRole;
  verificationStatus?: VerificationStatus;
  isActive?: boolean;
}

export interface ListUsersResponse {
  data: User[];
  meta: {
    total: number;
    page: number;
    limit: number;
    totalPages: number;
  };
}

export interface UpdateUserStatusParams {
  isActive?: boolean;
  isBlocked?: boolean;
  verificationStatus?: VerificationStatus;
}

export interface UpdateUserRolesParams {
  roles: UserRole[];
}

export const UsersAPI = {
  /**
   * List users with filters and pagination
   */
  listUsers: async (params: ListUsersParams = {}): Promise<ListUsersResponse> => {
    const response = await apiClient.get<ListUsersResponse>('/admin/users', { params });
    return response.data;
  },

  /**
   * Get user by ID
   */
  getUserById: async (id: string): Promise<User> => {
    const response = await apiClient.get<User>(`/admin/users/${id}`);
    return response.data;
  },

  /**
   * Update user status (active, blocked, verification)
   */
  updateUserStatus: async (id: string, data: UpdateUserStatusParams): Promise<User> => {
    const response = await apiClient.patch<User>(`/admin/users/${id}/status`, data);
    return response.data;
  },

  /**
   * Update user roles
   */
  updateUserRoles: async (id: string, data: UpdateUserRolesParams): Promise<{ id: string; roles: UserRole[]; updatedAt: string }> => {
    const response = await apiClient.patch(`/admin/users/${id}/roles`, data);
    return response.data;
  },
};

