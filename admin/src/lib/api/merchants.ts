import apiClient from './client';

export type ApprovalStatus = 'pending' | 'approved' | 'rejected' | 'revision_requested';
export type ListingType = 'hotel' | 'restaurant' | 'tour' | 'event' | 'attraction' | 'bar' | 'club' | 'lounge' | 'cafe' | 'fast_food' | 'mall' | 'market' | 'boutique';

export interface Merchant {
  id: string;
  userId: string;
  businessName: string;
  businessType?: ListingType | null;
  businessRegistrationNumber?: string | null;
  taxId?: string | null;
  description?: string | null;
  businessEmail?: string | null;
  businessPhone?: string | null;
  website?: string | null;
  socialLinks?: Record<string, any> | null;
  registrationStatus: ApprovalStatus;
  isVerified: boolean;
  countryId?: string | null;
  cityId?: string | null;
  districtId?: string | null;
  address?: string | null;
  createdAt: string;
  updatedAt: string;
  user?: { id: string; fullName: string; email: string } | null;
  country?: { id: string; name: string; code: string } | null;
  city?: { id: string; name: string } | null;
}

export interface ListMerchantsParams {
  page?: number;
  limit?: number;
  search?: string;
  registrationStatus?: ApprovalStatus;
  isVerified?: boolean;
  countryId?: string;
  cityId?: string;
}

export interface ListMerchantsResponse {
  data: Merchant[];
  meta: {
    total: number;
    page: number;
    limit: number;
    totalPages: number;
  };
}

export interface CreateMerchantParams {
  userId: string;
  businessName: string;
  businessType?: ListingType;
  businessRegistrationNumber?: string;
  taxId?: string;
  description?: string;
  businessEmail?: string;
  businessPhone?: string;
  website?: string;
  socialLinks?: Record<string, any>;
  countryId?: string;
  cityId?: string;
  districtId?: string;
  address?: string;
}

export interface UpdateMerchantParams extends Partial<CreateMerchantParams> {}

export interface UpdateMerchantStatusParams {
  registrationStatus?: ApprovalStatus;
  rejectionReason?: string;
  revisionNotes?: string;
  isVerified?: boolean;
}

export interface UpdateMerchantSettingsParams {
  commissionRate?: number; // 0-100
  payoutSchedule?: string;
  bankAccountInfo?: Record<string, any>;
  isVerified?: boolean;
}

export const MerchantsAPI = {
  /**
   * List merchants with filters and pagination
   */
  listMerchants: async (params: ListMerchantsParams = {}): Promise<ListMerchantsResponse> => {
    const response = await apiClient.get<ListMerchantsResponse>('/admin/merchants', { params });
    return response.data;
  },

  /**
   * Get merchant by ID
   */
  getMerchantById: async (id: string): Promise<Merchant> => {
    const response = await apiClient.get<Merchant>(`/admin/merchants/${id}`);
    return response.data;
  },

  /**
   * Create merchant profile on behalf of a user
   */
  createMerchant: async (data: CreateMerchantParams): Promise<Merchant> => {
    const response = await apiClient.post<Merchant>('/admin/merchants', data);
    return response.data;
  },

  /**
   * Update merchant profile details
   */
  updateMerchant: async (id: string, data: UpdateMerchantParams): Promise<Merchant> => {
    const response = await apiClient.put<Merchant>(`/admin/merchants/${id}`, data);
    return response.data;
  },

  /**
   * Update merchant registration status
   */
  updateMerchantStatus: async (id: string, data: UpdateMerchantStatusParams): Promise<Merchant> => {
    const response = await apiClient.patch<Merchant>(`/admin/merchants/${id}/status`, data);
    return response.data;
  },

  /**
   * Update merchant commission, payout & verification settings
   */
  updateMerchantSettings: async (id: string, data: UpdateMerchantSettingsParams): Promise<Merchant> => {
    const response = await apiClient.patch<Merchant>(`/admin/merchants/${id}/settings`, data);
    return response.data;
  },

  /**
   * Soft delete merchant profile
   */
  deleteMerchant: async (id: string): Promise<void> => {
    await apiClient.delete(`/admin/merchants/${id}`);
  },

  /**
   * Restore soft-deleted merchant profile
   */
  restoreMerchant: async (id: string): Promise<Merchant> => {
    const response = await apiClient.patch<Merchant>(`/admin/merchants/${id}/restore`);
    return response.data;
  },

  /**
   * Get current user's merchant profiles
   */
  getMyMerchantProfiles: async (): Promise<Merchant[]> => {
    const response = await apiClient.get<Merchant[]>('/users/me/businesses');
    return response.data;
  },
};

