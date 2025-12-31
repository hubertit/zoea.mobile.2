import apiClient from './client';

export interface Country {
  id: string;
  name: string;
  code: string;
  isActive: boolean;
  createdAt: string;
  updatedAt: string;
}

export interface City {
  id: string;
  name: string;
  slug: string;
  countryId: string;
  isFeatured: boolean;
  createdAt: string;
  updatedAt: string;
  country?: Country;
}

export interface District {
  id: string;
  name: string;
  cityId: string;
  createdAt: string;
  updatedAt: string;
}

export const LocationsAPI = {
  /**
   * Get all countries
   */
  getCountries: async (): Promise<Country[]> => {
    const response = await apiClient.get<Country[]>('/countries');
    return response.data;
  },

  /**
   * Get all cities
   */
  getCities: async (countryId?: string): Promise<City[]> => {
    const params = countryId ? { countryId } : {};
    const response = await apiClient.get<City[]>('/cities', { params });
    return response.data;
  },

  /**
   * Get districts for a city
   */
  getDistricts: async (cityId: string): Promise<District[]> => {
    const response = await apiClient.get<District[]>(`/cities/${cityId}/districts`);
    return response.data;
  },
};

