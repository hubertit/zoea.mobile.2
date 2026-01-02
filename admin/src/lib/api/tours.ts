import apiClient from './client';

export interface Tour {
  id: string;
  name: string;
  slug?: string | null;
  description?: string | null;
  shortDescription?: string | null;
  type?: string | null;
  status: 'draft' | 'active' | 'inactive';
  pricePerPerson?: number | null;
  currency?: string | null;
  operatorId?: string | null;
  categoryId?: string | null;
  cityId?: string | null;
  countryId?: string | null;
  createdAt: string;
  updatedAt: string;
  operator?: {
    id: string;
    companyName: string;
  };
  category?: {
    id: string;
    name: string;
  };
  city?: {
    id: string;
    name: string;
  };
  country?: {
    id: string;
    name: string;
  };
}

export interface TourOperatorProfile {
  id: string;
  userId: string;
  companyName?: string | null;
  description?: string | null;
  registrationStatus: 'pending' | 'approved' | 'rejected';
  isVerified: boolean;
  createdAt: string;
  updatedAt: string;
  _count?: {
    tours: number;
    bookings: number;
  };
}

export interface TourSchedule {
  id: string;
  tourId: string;
  date: string;
  startTime?: string | null;
  endTime?: string | null;
  availableSpots: number;
  maxSpots: number;
  isAvailable: boolean;
  price?: number | null;
}

export const ToursAPI = {
  /**
   * Get tour operator profiles for current user
   */
  getMyTourOperatorProfiles: async (): Promise<TourOperatorProfile[]> => {
    const response = await apiClient.get<TourOperatorProfile[]>('/users/me/tour-operator-profiles');
    return response.data;
  },

  /**
   * Get tours for an operator
   */
  getOperatorTours: async (
    operatorId: string,
    params?: {
      page?: number;
      limit?: number;
      status?: string;
    }
  ): Promise<{ data: Tour[]; meta: { total: number; page: number; limit: number; totalPages: number } }> => {
    const response = await apiClient.get(`/tours/operator/${operatorId}`, { params });
    return response.data;
  },

  /**
   * Get tour by ID
   */
  getTourById: async (tourId: string): Promise<Tour> => {
    const response = await apiClient.get<Tour>(`/tours/${tourId}`);
    return response.data;
  },

  /**
   * Create a new tour
   */
  createTour: async (data: {
    operatorId: string;
    name: string;
    slug?: string;
    description?: string;
    shortDescription?: string;
    type?: string;
    categoryId?: string;
    countryId?: string;
    cityId?: string;
    startLocationName?: string;
    endLocationName?: string;
    durationDays?: number;
    durationHours?: number;
    pricePerPerson?: number;
    currency?: string;
    groupDiscountPercentage?: number;
    minGroupSize?: number;
    maxGroupSize?: number;
    includes?: string[];
    excludes?: string[];
    requirements?: string[];
    difficultyLevel?: string;
    languages?: string[];
    itinerary?: any;
  }): Promise<Tour> => {
    const response = await apiClient.post<Tour>('/tours', data);
    return response.data;
  },

  /**
   * Update a tour
   */
  updateTour: async (tourId: string, data: Partial<{
    name: string;
    slug: string;
    description: string;
    shortDescription: string;
    type: string;
    categoryId: string;
    durationDays: number;
    durationHours: number;
    pricePerPerson: number;
    currency: string;
    groupDiscountPercentage: number;
    minGroupSize: number;
    maxGroupSize: number;
    includes: string[];
    excludes: string[];
    requirements: string[];
    difficultyLevel: string;
    languages: string[];
    itinerary: any;
  }>): Promise<Tour> => {
    const response = await apiClient.put<Tour>(`/tours/${tourId}`, data);
    return response.data;
  },

  /**
   * Delete a tour
   */
  deleteTour: async (tourId: string): Promise<void> => {
    await apiClient.delete(`/tours/${tourId}`);
  },

  /**
   * Get tour schedules
   */
  getTourSchedules: async (
    tourId: string,
    params?: {
      startDate?: string;
      endDate?: string;
      includeUnavailable?: boolean;
    }
  ): Promise<TourSchedule[]> => {
    const response = await apiClient.get(`/tours/${tourId}/schedules`, { params });
    return response.data;
  },

  /**
   * Create a tour schedule
   */
  createTourSchedule: async (
    tourId: string,
    data: {
      date: string;
      startTime?: string;
      availableSpots: number;
      priceOverride?: number;
      isAvailable?: boolean;
    }
  ): Promise<TourSchedule> => {
    const response = await apiClient.post<TourSchedule>(`/tours/${tourId}/schedules`, data);
    return response.data;
  },

  /**
   * Update a tour schedule
   */
  updateTourSchedule: async (
    scheduleId: string,
    data: Partial<{
      date: string;
      startTime: string;
      availableSpots: number;
      priceOverride: number;
      isAvailable: boolean;
    }>
  ): Promise<TourSchedule> => {
    const response = await apiClient.put<TourSchedule>(`/tours/schedules/${scheduleId}`, data);
    return response.data;
  },

  /**
   * Delete a tour schedule
   */
  deleteTourSchedule: async (scheduleId: string): Promise<void> => {
    await apiClient.delete(`/tours/schedules/${scheduleId}`);
  },
};

