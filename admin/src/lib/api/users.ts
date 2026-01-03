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
  updatedAt?: string;
  country?: { id: string; name: string; code: string } | null;
  city?: { id: string; name: string } | null;
  // User preferences
  preferredCurrency?: string | null;
  preferredLanguage?: string | null;
  timezone?: string | null;
  maxDistance?: number | null;
  notificationPreferences?: Record<string, any> | null;
  marketingConsent?: boolean | null;
  // User data collection fields
  countryOfOrigin?: string | null;
  userType?: string | null;
  visitPurpose?: string | null;
  ageRange?: string | null;
  lengthOfStay?: string | null;
  travelParty?: string | null;
  // Related data
  merchantProfiles?: Array<{
    id: string;
    businessName: string;
    registrationStatus: string;
    createdAt: string;
    _count: { listings: number; bookings: number };
  }>;
  bookings?: Array<{
    id: string;
    bookingNumber: string;
    status: string;
    totalAmount: number;
    currency: string;
    createdAt: string;
    listing?: { id: string; name: string } | null;
    event?: { id: string; name: string } | null;
  }>;
  reviews?: Array<{
    id: string;
    rating: number;
    comment: string | null;
    createdAt: string;
    listing?: { id: string; name: string } | null;
    event?: { id: string; name: string } | null;
  }>;
  favorites?: Array<{
    id: string;
    createdAt: string;
    listing?: { id: string; name: string; type: string } | null;
    event?: { id: string; name: string } | null;
    tour?: { id: string; name: string } | null;
  }>;
  searchHistory?: Array<{
    id: string;
    query: string;
    filters: any;
    resultCount: number | null;
    createdAt: string;
  }>;
  recentlyViewed?: Array<{
    id: string;
    viewedAt: string;
    listing?: { id: string; name: string; type: string } | null;
    event?: { id: string; name: string } | null;
    tour?: { id: string; name: string } | null;
  }>;
  user_activity_summary?: {
    totalViews: number | null;
    totalBookings: number | null;
    totalSpent: number | null;
    totalReviews: number | null;
    favoriteCategories: string[];
    favoriteLocations: string[];
    lastActiveAt: string | null;
    firstBookingAt: string | null;
    lastBookingAt: string | null;
  } | null;
  user_content_preferences?: {
    selectedCountries: string[];
    selectedCities: string[];
    showCurrentLocation: boolean | null;
    showSelectedOnly: boolean | null;
    showEvents: boolean | null;
    showListings: boolean | null;
    showTours: boolean | null;
    showPromotions: boolean | null;
    preferredCategories: string[];
    hiddenCategories: string[];
    minPrice: number | null;
    maxPrice: number | null;
    preferredPriceRange: string | null;
  } | null;
  _count?: {
    bookings: number;
    reviews: number;
    favorites: number;
    searchHistory: number;
    recentlyViewed: number;
  };
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

export interface CreateUserParams {
  email?: string;
  phoneNumber?: string;
  password: string;
  fullName?: string;
  roles?: UserRole[];
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
   * Find user by phone number or email
   * Returns the first matching user or null if not found
   */
  findByPhoneOrEmail: async (phoneNumber?: string, email?: string): Promise<User | null> => {
    if (!phoneNumber && !email) return null;
    
    // Search for existing user by phone or email
    const searchTerms: string[] = [];
    if (phoneNumber) searchTerms.push(phoneNumber);
    if (email) searchTerms.push(email);
    
    for (const search of searchTerms) {
      try {
        const response = await apiClient.get<ListUsersResponse>('/admin/users', { 
          params: { search, limit: 1 } 
        });
        if (response.data.data.length > 0) {
          const user = response.data.data[0];
          // Verify it's an exact match
          if (
            (phoneNumber && user.phoneNumber === phoneNumber) ||
            (email && user.email === email)
          ) {
            return user;
          }
        }
      } catch (error) {
        console.error('Error searching for user:', error);
      }
    }
    
    return null;
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

  /**
   * Create a new user (uses registration endpoint, then assigns roles if provided)
   */
  createUser: async (data: CreateUserParams): Promise<User> => {
    // First, register the user
    const registerResponse = await apiClient.post<{ user: { id: string } }>('/auth/register', {
      email: data.email,
      phoneNumber: data.phoneNumber,
      password: data.password,
      fullName: data.fullName,
    });
    
    const userId = registerResponse.data.user.id;
    
    // If roles are provided, assign them
    if (data.roles && data.roles.length > 0) {
      await apiClient.patch(`/admin/users/${userId}/roles`, { roles: data.roles });
    }
    
    // Fetch and return the created user
    return UsersAPI.getUserById(userId);
  },
};

