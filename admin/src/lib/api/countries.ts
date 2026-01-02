import apiClient from './client';

export interface Country {
  id: string;
  name: string;
  code: string;
  dialCode?: string | null;
  currency?: string | null;
  isActive: boolean;
  createdAt: string;
  updatedAt: string;
}

export interface City {
  id: string;
  name: string;
  slug: string;
  countryId: string;
  isActive: boolean;
}

export const CountriesAPI = {
  /**
   * Get all active countries
   */
  getActiveCountries: async (): Promise<Country[]> => {
    const response = await apiClient.get<Country[]>('/countries/active');
    return response.data;
  },

  /**
   * Get country by ID
   */
  getCountryById: async (id: string): Promise<Country> => {
    const response = await apiClient.get<Country>(`/countries/${id}`);
    return response.data;
  },

  /**
   * Get country by code
   */
  getCountryByCode: async (code: string): Promise<Country> => {
    const response = await apiClient.get<Country>(`/countries/code/${code}`);
    return response.data;
  },

  /**
   * Get cities for a country
   */
  getCitiesByCountry: async (countryId: string): Promise<City[]> => {
    const response = await apiClient.get<City[]>(`/countries/${countryId}/cities`);
    return response.data;
  },
};

