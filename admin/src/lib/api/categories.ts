import apiClient from './client';

export interface Category {
  id: string;
  name: string;
  slug: string;
  parentId?: string | null;
  icon?: string | null;
  imageId?: string | null;
  description?: string | null;
  sortOrder: number;
  isActive: boolean;
  createdAt: string;
  updatedAt: string;
  parent?: Category | null;
  children?: Category[];
  _count?: {
    listings: number;
    tours: number;
  };
}

export interface ListCategoriesParams {
  parentId?: string;
  flat?: boolean;
}

export interface CreateCategoryParams {
  name: string;
  slug: string;
  parentId?: string;
  icon?: string;
  description?: string;
  sortOrder?: number;
  isActive?: boolean;
}

export interface UpdateCategoryParams {
  name?: string;
  slug?: string;
  parentId?: string | null;
  icon?: string;
  description?: string;
  sortOrder?: number;
  isActive?: boolean;
}

export const CategoriesAPI = {
  /**
   * List all categories
   */
  listCategories: async (params: ListCategoriesParams = {}): Promise<Category[]> => {
    const response = await apiClient.get<Category[]>('/categories', { params });
    return response.data;
  },

  /**
   * Get category by ID
   */
  getCategoryById: async (id: string): Promise<Category> => {
    const response = await apiClient.get<Category>(`/categories/${id}`);
    return response.data;
  },

  /**
   * Get category by slug
   */
  getCategoryBySlug: async (slug: string): Promise<Category> => {
    const response = await apiClient.get<Category>(`/categories/slug/${slug}`);
    return response.data;
  },

  /**
   * Create category
   */
  createCategory: async (data: CreateCategoryParams): Promise<Category> => {
    const response = await apiClient.post<Category>('/categories', data);
    return response.data;
  },

  /**
   * Update category
   */
  updateCategory: async (id: string, data: UpdateCategoryParams): Promise<Category> => {
    const response = await apiClient.put<Category>(`/categories/${id}`, data);
    return response.data;
  },

  /**
   * Delete category
   */
  deleteCategory: async (id: string): Promise<void> => {
    await apiClient.delete(`/categories/${id}`);
  },
};

