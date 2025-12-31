import apiClient from './client';

export interface OrganizerProfile {
  id: string;
  userId: string;
  organizationName: string;
  organizationType?: string | null;
  description?: string | null;
  contactEmail?: string | null;
  contactPhone?: string | null;
  website?: string | null;
  countryId?: string | null;
  cityId?: string | null;
  isVerified: boolean;
  createdAt: string;
  updatedAt: string;
  user?: { id: string; fullName: string; email: string } | null;
  country?: { id: string; name: string; code: string } | null;
  city?: { id: string; name: string } | null;
}

export const OrganizersAPI = {
  /**
   * Get organizer profiles for a user (for admin, we'll fetch all)
   * Note: This uses the user's endpoint, but for admin we might need a different approach
   */
  getOrganizerProfiles: async (userId?: string): Promise<OrganizerProfile[]> => {
    // For now, we'll need to fetch users with event_organizer role
    // and then get their organizer profiles
    // This is a workaround until we have an admin endpoint
    const response = await apiClient.get<OrganizerProfile[]>(userId 
      ? `/users/${userId}/organizer-profiles`
      : '/users/me/organizer-profiles'
    );
    return response.data;
  },
};

