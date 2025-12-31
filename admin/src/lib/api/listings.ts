import apiClient from './client';

export type ListingStatus = 'draft' | 'pending_review' | 'active' | 'inactive' | 'suspended';
export type ListingType = 'hotel' | 'restaurant' | 'tour' | 'event' | 'attraction' | 'bar' | 'club' | 'lounge' | 'cafe' | 'fast_food' | 'mall' | 'market' | 'boutique';
export type PriceUnit = 'per_night' | 'per_person' | 'per_meal' | 'per_tour' | 'per_event' | 'per_hour' | 'per_table';

export interface Listing {
  id: string;
  name: string;
  slug?: string | null;
  description?: string | null;
  shortDescription?: string | null;
  type?: ListingType | null;
  status: ListingStatus;
  isFeatured: boolean;
  isVerified: boolean;
  isBlocked: boolean;
  minPrice?: number | null;
  maxPrice?: number | null;
  priceUnit?: PriceUnit | null;
  contactPhone?: string | null;
  contactEmail?: string | null;
  website?: string | null;
  address?: string | null;
  merchantId: string;
  categoryId?: string | null;
  countryId?: string | null;
  cityId?: string | null;
  createdAt: string;
  updatedAt: string;
  merchant?: { id: string; businessName: string } | null;
  category?: { id: string; name: string } | null;
  country?: { id: string; name: string; code: string } | null;
  city?: { id: string; name: string } | null;
}

export interface ListListingsParams {
  page?: number;
  limit?: number;
  search?: string;
  status?: ListingStatus;
  type?: ListingType;
  isFeatured?: boolean;
  isVerified?: boolean;
  merchantId?: string;
  countryId?: string;
  cityId?: string;
  categoryId?: string;
}

export interface ListListingsResponse {
  data: Listing[];
  meta: {
    total: number;
    page: number;
    limit: number;
    totalPages: number;
  };
}

export interface CreateListingParams {
  merchantId: string;
  name: string;
  slug?: string;
  description?: string;
  shortDescription?: string;
  type?: ListingType;
  categoryId?: string;
  countryId?: string;
  cityId?: string;
  districtId?: string;
  address?: string;
  postalCode?: string;
  minPrice?: number;
  maxPrice?: number;
  priceUnit?: PriceUnit;
  contactPhone?: string;
  contactEmail?: string;
  website?: string;
  isFeatured?: boolean;
  isVerified?: boolean;
  status?: ListingStatus;
  amenityIds?: string[];
  tagIds?: string[];
}

export interface UpdateListingParams extends Partial<CreateListingParams> {}

export interface UpdateListingStatusParams {
  status?: ListingStatus;
  isFeatured?: boolean;
  isVerified?: boolean;
  isBlocked?: boolean;
  reviewNotes?: string;
}

export const ListingsAPI = {
  /**
   * List listings with filters and pagination
   */
  listListings: async (params: ListListingsParams = {}): Promise<ListListingsResponse> => {
    const response = await apiClient.get<ListListingsResponse>('/admin/listings', { params });
    return response.data;
  },

  /**
   * Get listing by ID
   */
  getListingById: async (id: string): Promise<Listing> => {
    const response = await apiClient.get<Listing>(`/admin/listings/${id}`);
    return response.data;
  },

  /**
   * Create listing on behalf of merchant
   */
  createListing: async (data: CreateListingParams): Promise<Listing> => {
    const response = await apiClient.post<Listing>('/admin/listings', data);
    return response.data;
  },

  /**
   * Update listing content
   */
  updateListing: async (id: string, data: UpdateListingParams): Promise<Listing> => {
    const response = await apiClient.put<Listing>(`/admin/listings/${id}`, data);
    return response.data;
  },

  /**
   * Update listing status/moderation
   */
  updateListingStatus: async (id: string, data: UpdateListingStatusParams): Promise<Listing> => {
    const response = await apiClient.patch<Listing>(`/admin/listings/${id}/status`, data);
    return response.data;
  },

  /**
   * Soft delete listing
   */
  deleteListing: async (id: string): Promise<void> => {
    await apiClient.delete(`/admin/listings/${id}`);
  },

  /**
   * Restore soft-deleted listing
   */
  restoreListing: async (id: string): Promise<Listing> => {
    const response = await apiClient.patch<Listing>(`/admin/listings/${id}/restore`);
    return response.data;
  },
};

