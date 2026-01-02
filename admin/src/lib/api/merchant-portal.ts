import apiClient from './client';

// ============ TYPES ============
export type ApprovalStatus = 'pending' | 'approved' | 'rejected' | 'revision_requested';
export type ListingStatus = 'draft' | 'pending_review' | 'active' | 'inactive' | 'suspended';
export type BookingStatus = 'pending' | 'confirmed' | 'checked_in' | 'completed' | 'cancelled' | 'no_show' | 'refunded';

export interface Business {
  id: string;
  userId: string;
  businessName: string;
  businessType?: string | null;
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
  _count?: {
    listings: number;
    bookings: number;
  };
}

export interface MerchantListing {
  id: string;
  name: string;
  slug?: string | null;
  description?: string | null;
  shortDescription?: string | null;
  type?: string | null;
  status: ListingStatus;
  isFeatured: boolean;
  isVerified: boolean;
  isShopEnabled?: boolean | null;
  shopSettings?: {
    acceptsOnlineOrders?: boolean;
    deliveryEnabled?: boolean;
    pickupEnabled?: boolean;
    dineInEnabled?: boolean;
    deliveryZones?: any;
    paymentMethods?: string[];
  } | null;
  minPrice?: number | null;
  maxPrice?: number | null;
  priceUnit?: string | null;
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
  images?: Array<{
    id: string;
    mediaId: string;
    isPrimary: boolean;
    sortOrder: number;
    media: {
      id: string;
      url: string;
      thumbnailUrl?: string | null;
    };
  }>;
  roomTypes?: Array<{
    id: string;
    name: string;
    description?: string | null;
    maxOccupancy: number;
    bedType?: string | null;
    bedCount?: number | null;
    roomSize?: number | null;
    basePrice: number;
    amenities?: string[];
    isActive: boolean;
  }>;
  restaurantTables?: Array<{
    id: string;
    tableNumber: string;
    capacity: number;
    location?: string | null;
    isAvailable: boolean;
    isActive: boolean;
  }>;
}

export interface MerchantBooking {
  id: string;
  bookingNumber: string;
  status: BookingStatus;
  bookingType: string;
  checkInDate?: string | null;
  checkOutDate?: string | null;
  bookingDate?: string | null;
  bookingTime?: string | null;
  partySize?: number | null;
  totalAmount: number;
  currency: string;
  notes?: string | null;
  userId: string;
  listingId: string;
  merchantId: string;
  createdAt: string;
  updatedAt: string;
  user?: {
    id: string;
    fullName: string;
    email: string;
    phoneNumber?: string;
  };
  listing?: {
    id: string;
    name: string;
    type?: string;
  };
}

export interface MerchantReview {
  id: string;
  rating: number;
  comment?: string | null;
  response?: string | null;
  responseDate?: string | null;
  listingId: string;
  userId: string;
  createdAt: string;
  updatedAt: string;
  user?: {
    id: string;
    fullName: string;
  };
  listing?: {
    id: string;
    name: string;
  };
}

export interface DashboardData {
  overview: {
    totalRevenue: number;
    totalBookings: number;
    averageRating: number;
    totalListings: number;
    activeListings: number;
  };
  thisMonth: {
    bookings: number;
    revenue: number;
    bookingsChange: string;
    revenueChange: string;
  };
  pendingBookings: number;
  recentBookings: MerchantBooking[];
  topListings: Array<{
    id: string;
    name: string;
    bookingCount: number;
    rating: number;
  }>;
  reviews: {
    averageRating: number;
    totalReviews: number;
  };
}

// ============ API ============
export const MerchantPortalAPI = {
  // ============ BUSINESSES ============
  getMyBusinesses: async (): Promise<Business[]> => {
    const response = await apiClient.get<Business[]>('/merchants/businesses');
    return response.data;
  },

  getBusiness: async (businessId: string): Promise<Business> => {
    const response = await apiClient.get<Business>(`/merchants/businesses/${businessId}`);
    return response.data;
  },

  createBusiness: async (data: {
    businessName: string;
    businessType: string;
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
    logoId?: string;
  }): Promise<Business> => {
    const response = await apiClient.post<Business>('/merchants/businesses', data);
    return response.data;
  },

  updateBusiness: async (businessId: string, data: Partial<{
    businessName: string;
    businessType: string;
    description: string;
    businessEmail: string;
    businessPhone: string;
    website: string;
    socialLinks: Record<string, any>;
    countryId: string;
    cityId: string;
    districtId: string;
    address: string;
  }>): Promise<Business> => {
    const response = await apiClient.put<Business>(`/merchants/businesses/${businessId}`, data);
    return response.data;
  },

  deleteBusiness: async (businessId: string): Promise<void> => {
    await apiClient.delete(`/merchants/businesses/${businessId}`);
  },

  // ============ LISTINGS ============
  getListings: async (
    businessId: string,
    params?: {
      page?: number;
      limit?: number;
      status?: ListingStatus;
    }
  ): Promise<{ data: MerchantListing[]; meta: { total: number; page: number; limit: number; totalPages: number } }> => {
    const response = await apiClient.get(`/merchants/businesses/${businessId}/listings`, { params });
    return response.data;
  },

  getListing: async (businessId: string, listingId: string): Promise<MerchantListing> => {
    const response = await apiClient.get<MerchantListing>(`/merchants/businesses/${businessId}/listings/${listingId}`);
    return response.data;
  },

  createListing: async (businessId: string, data: {
    name: string;
    slug?: string;
    description?: string;
    shortDescription?: string;
    type?: string;
    categoryId?: string;
    countryId?: string;
    cityId?: string;
    districtId?: string;
    address?: string;
    minPrice?: number;
    maxPrice?: number;
    priceUnit?: string;
    contactPhone?: string;
    contactEmail?: string;
    website?: string;
    status?: ListingStatus;
  }): Promise<MerchantListing> => {
    const response = await apiClient.post<MerchantListing>(`/merchants/businesses/${businessId}/listings`, data);
    return response.data;
  },

  updateListing: async (businessId: string, listingId: string, data: Partial<{
    name: string;
    description: string;
    shortDescription: string;
    type: string;
    categoryId: string;
    countryId: string;
    cityId: string;
    districtId: string;
    address: string;
    minPrice: number;
    maxPrice: number;
    priceUnit: string;
    contactPhone: string;
    contactEmail: string;
    website: string;
  }>): Promise<MerchantListing> => {
    const response = await apiClient.put<MerchantListing>(`/merchants/businesses/${businessId}/listings/${listingId}`, data);
    return response.data;
  },

  deleteListing: async (businessId: string, listingId: string): Promise<void> => {
    await apiClient.delete(`/merchants/businesses/${businessId}/listings/${listingId}`);
  },

  submitListing: async (businessId: string, listingId: string): Promise<MerchantListing> => {
    const response = await apiClient.post<MerchantListing>(`/merchants/businesses/${businessId}/listings/${listingId}/submit`);
    return response.data;
  },

  // ============ LISTING IMAGES ============
  addListingImage: async (businessId: string, listingId: string, data: { mediaId: string; isPrimary?: boolean }): Promise<any> => {
    const response = await apiClient.post(`/merchants/businesses/${businessId}/listings/${listingId}/images`, data);
    return response.data;
  },

  removeListingImage: async (businessId: string, listingId: string, imageId: string): Promise<void> => {
    await apiClient.delete(`/merchants/businesses/${businessId}/listings/${listingId}/images/${imageId}`);
  },

  // ============ ROOM TYPES (Hotels) ============
  getRoomTypes: async (businessId: string, listingId: string): Promise<any[]> => {
    const response = await apiClient.get<any[]>(`/merchants/businesses/${businessId}/listings/${listingId}/rooms`);
    return response.data;
  },

  createRoomType: async (businessId: string, listingId: string, data: {
    name: string;
    description?: string;
    maxOccupancy: number;
    pricePerNight: number;
    amenities?: string[];
  }): Promise<any> => {
    const response = await apiClient.post(`/merchants/businesses/${businessId}/listings/${listingId}/rooms`, data);
    return response.data;
  },

  updateRoomType: async (businessId: string, roomTypeId: string, data: Partial<{
    name: string;
    description: string;
    maxOccupancy: number;
    pricePerNight: number;
    amenities: string[];
  }>): Promise<any> => {
    const response = await apiClient.put(`/merchants/businesses/${businessId}/rooms/${roomTypeId}`, data);
    return response.data;
  },

  deleteRoomType: async (businessId: string, roomTypeId: string): Promise<void> => {
    await apiClient.delete(`/merchants/businesses/${businessId}/rooms/${roomTypeId}`);
  },

  // ============ TABLES (Restaurants) ============
  getTables: async (businessId: string, listingId: string): Promise<any[]> => {
    const response = await apiClient.get<any[]>(`/merchants/businesses/${businessId}/listings/${listingId}/tables`);
    return response.data;
  },

  createTable: async (businessId: string, listingId: string, data: {
    tableNumber: string;
    capacity: number;
    location?: string;
    isAvailable?: boolean;
  }): Promise<any> => {
    const response = await apiClient.post(`/merchants/businesses/${businessId}/listings/${listingId}/tables`, data);
    return response.data;
  },

  updateTable: async (businessId: string, tableId: string, data: Partial<{
    tableNumber: string;
    capacity: number;
    location: string;
    isAvailable: boolean;
  }>): Promise<any> => {
    const response = await apiClient.put(`/merchants/businesses/${businessId}/tables/${tableId}`, data);
    return response.data;
  },

  deleteTable: async (businessId: string, tableId: string): Promise<void> => {
    await apiClient.delete(`/merchants/businesses/${businessId}/tables/${tableId}`);
  },

  // ============ BOOKINGS ============
  getBookings: async (
    businessId: string,
    params?: {
      page?: number;
      limit?: number;
      status?: BookingStatus;
      listingId?: string;
      startDate?: string;
      endDate?: string;
    }
  ): Promise<{ data: MerchantBooking[]; meta: { total: number; page: number; limit: number; totalPages: number } }> => {
    const response = await apiClient.get(`/merchants/businesses/${businessId}/bookings`, { params });
    return response.data;
  },

  getBooking: async (businessId: string, bookingId: string): Promise<MerchantBooking> => {
    const response = await apiClient.get<MerchantBooking>(`/merchants/businesses/${businessId}/bookings/${bookingId}`);
    return response.data;
  },

  updateBookingStatus: async (
    businessId: string,
    bookingId: string,
    data: {
      status: BookingStatus;
      notes?: string;
      cancellationReason?: string;
    }
  ): Promise<MerchantBooking> => {
    const response = await apiClient.put<MerchantBooking>(`/merchants/businesses/${businessId}/bookings/${bookingId}/status`, data);
    return response.data;
  },

  // ============ REVIEWS ============
  getReviews: async (
    businessId: string,
    params?: {
      page?: number;
      limit?: number;
      listingId?: string;
      rating?: number;
    }
  ): Promise<{ data: MerchantReview[]; meta: { total: number; page: number; limit: number; totalPages: number } }> => {
    const response = await apiClient.get(`/merchants/businesses/${businessId}/reviews`, { params });
    return response.data;
  },

  respondToReview: async (businessId: string, reviewId: string, response: string): Promise<MerchantReview> => {
    const result = await apiClient.post<MerchantReview>(`/merchants/businesses/${businessId}/reviews/${reviewId}/respond`, { response });
    return result.data;
  },

  // ============ DASHBOARD ============
  getDashboard: async (businessId: string): Promise<DashboardData> => {
    const response = await apiClient.get<DashboardData>(`/merchants/businesses/${businessId}/dashboard`);
    return response.data;
  },

  // ============ ANALYTICS ============
  getRevenueAnalytics: async (
    businessId: string,
    params?: {
      startDate?: string;
      endDate?: string;
      groupBy?: 'day' | 'week' | 'month' | 'year';
    }
  ): Promise<{
    totalRevenue: number;
    periodData: Array<{
      period: string;
      revenue: number;
      bookingCount: number;
    }>;
  }> => {
    const response = await apiClient.get(`/merchants/businesses/${businessId}/analytics/revenue`, { params });
    return response.data;
  },

  getBookingAnalytics: async (
    businessId: string,
    params?: {
      startDate?: string;
      endDate?: string;
    }
  ): Promise<any> => {
    const response = await apiClient.get(`/merchants/businesses/${businessId}/analytics/bookings`, { params });
    return response.data;
  },

  // ============ PROMOTIONS ============
  getPromotions: async (
    businessId: string,
    params?: {
      page?: number;
      limit?: number;
      active?: boolean;
    }
  ): Promise<{ data: any[]; meta: { total: number; page: number; limit: number; totalPages: number } }> => {
    const response = await apiClient.get(`/merchants/businesses/${businessId}/promotions`, { params });
    return response.data;
  },

  getAvailablePromotions: async (businessId: string): Promise<any[]> => {
    const response = await apiClient.get<any[]>(`/merchants/businesses/${businessId}/promotions/available`);
    return response.data;
  },

  joinPromotion: async (businessId: string, promotionId: string): Promise<void> => {
    await apiClient.post(`/merchants/businesses/${businessId}/promotions/${promotionId}/join`);
  },

  leavePromotion: async (businessId: string, promotionId: string): Promise<void> => {
    await apiClient.delete(`/merchants/businesses/${businessId}/promotions/${promotionId}/leave`);
  },

  // ============ PRODUCTS ============
  getProducts: async (
    listingId: string,
    params?: {
      page?: number;
      limit?: number;
      status?: string;
      search?: string;
      category?: string;
    }
  ): Promise<{ data: any[]; meta: { total: number; page: number; limit: number; totalPages: number } }> => {
    const response = await apiClient.get('/products', { params: { listingId, ...params } });
    return response.data;
  },

  getProduct: async (productId: string): Promise<any> => {
    const response = await apiClient.get(`/products/${productId}`);
    return response.data;
  },

  createProduct: async (data: {
    listingId: string;
    name: string;
    slug?: string;
    description?: string;
    shortDescription?: string;
    basePrice: number;
    compareAtPrice?: number;
    currency?: string;
    costPrice?: number;
    sku?: string;
    trackInventory?: boolean;
    inventoryQuantity?: number;
    lowStockThreshold?: number;
    allowBackorders?: boolean;
    weight?: number;
    dimensions?: any;
    category?: string;
    tags?: string[];
    hasVariants?: boolean;
    variantOptions?: any;
    status?: string;
    isFeatured?: boolean;
    images?: string[];
  }): Promise<any> => {
    const response = await apiClient.post('/products', data);
    return response.data;
  },

  updateProduct: async (productId: string, data: Partial<{
    name: string;
    description: string;
    shortDescription: string;
    basePrice: number;
    compareAtPrice: number;
    currency: string;
    costPrice: number;
    sku: string;
    trackInventory: boolean;
    inventoryQuantity: number;
    lowStockThreshold: number;
    allowBackorders: boolean;
    weight: number;
    dimensions: any;
    category: string;
    tags: string[];
    hasVariants: boolean;
    variantOptions: any;
    status: string;
    isFeatured: boolean;
    images: string[];
  }>): Promise<any> => {
    const response = await apiClient.put(`/products/${productId}`, data);
    return response.data;
  },

  deleteProduct: async (productId: string): Promise<void> => {
    await apiClient.delete(`/products/${productId}`);
  },

  // ============ SERVICES ============
  getServices: async (
    listingId: string,
    params?: {
      page?: number;
      limit?: number;
      status?: string;
      search?: string;
      category?: string;
    }
  ): Promise<{ data: any[]; meta: { total: number; page: number; limit: number; totalPages: number } }> => {
    const response = await apiClient.get('/services', { params: { listingId, ...params } });
    return response.data;
  },

  getService: async (serviceId: string): Promise<any> => {
    const response = await apiClient.get(`/services/${serviceId}`);
    return response.data;
  },

  createService: async (data: {
    listingId: string;
    name: string;
    slug?: string;
    description?: string;
    shortDescription?: string;
    basePrice: number;
    priceUnit?: string;
    currency?: string;
    duration?: number;
    durationUnit?: string;
    category?: string;
    tags?: string[];
    isAvailable?: boolean;
    maxConcurrentBookings?: number;
    requiresApproval?: boolean;
    status?: string;
    isFeatured?: boolean;
    images?: string[];
  }): Promise<any> => {
    const response = await apiClient.post('/services', data);
    return response.data;
  },

  updateService: async (serviceId: string, data: Partial<{
    name: string;
    description: string;
    shortDescription: string;
    basePrice: number;
    priceUnit: string;
    currency: string;
    duration: number;
    durationUnit: string;
    category: string;
    tags: string[];
    isAvailable: boolean;
    maxConcurrentBookings: number;
    requiresApproval: boolean;
    status: string;
    isFeatured: boolean;
    images: string[];
  }>): Promise<any> => {
    const response = await apiClient.put(`/services/${serviceId}`, data);
    return response.data;
  },

  deleteService: async (serviceId: string): Promise<void> => {
    await apiClient.delete(`/services/${serviceId}`);
  },

  // ============ MENUS ============
  getMenus: async (listingId: string): Promise<any[]> => {
    const response = await apiClient.get('/menus', { params: { listingId } });
    return response.data;
  },

  getMenu: async (menuId: string): Promise<any> => {
    const response = await apiClient.get(`/menus/${menuId}`);
    return response.data;
  },

  createMenu: async (data: {
    listingId: string;
    name: string;
    description?: string;
    availableDays?: string[];
    startTime?: string;
    endTime?: string;
    isActive?: boolean;
    isDefault?: boolean;
    sortOrder?: number;
  }): Promise<any> => {
    const response = await apiClient.post('/menus', data);
    return response.data;
  },

  updateMenu: async (menuId: string, data: Partial<{
    name: string;
    description: string;
    availableDays: string[];
    startTime: string;
    endTime: string;
    isActive: boolean;
    isDefault: boolean;
    sortOrder: number;
  }>): Promise<any> => {
    const response = await apiClient.put(`/menus/${menuId}`, data);
    return response.data;
  },

  deleteMenu: async (menuId: string): Promise<void> => {
    await apiClient.delete(`/menus/${menuId}`);
  },

  // ============ MENU CATEGORIES ============
  getMenuCategories: async (menuId: string): Promise<any[]> => {
    const response = await apiClient.get(`/menus/${menuId}/categories`);
    return response.data;
  },

  createMenuCategory: async (menuId: string, data: {
    name: string;
    description?: string;
    sortOrder?: number;
  }): Promise<any> => {
    const response = await apiClient.post(`/menus/${menuId}/categories`, data);
    return response.data;
  },

  updateMenuCategory: async (menuId: string, categoryId: string, data: Partial<{
    name: string;
    description: string;
    sortOrder: number;
  }>): Promise<any> => {
    const response = await apiClient.put(`/menus/${menuId}/categories/${categoryId}`, data);
    return response.data;
  },

  deleteMenuCategory: async (menuId: string, categoryId: string): Promise<void> => {
    await apiClient.delete(`/menus/${menuId}/categories/${categoryId}`);
  },

  // ============ MENU ITEMS ============
  createMenuItem: async (menuId: string, data: {
    categoryId: string;
    name: string;
    description?: string;
    shortDescription?: string;
    price: number;
    currency?: string;
    isAvailable?: boolean;
    isVegetarian?: boolean;
    isVegan?: boolean;
    isGlutenFree?: boolean;
    allergens?: string[];
    calories?: number;
    images?: string[];
    sortOrder?: number;
  }): Promise<any> => {
    const response = await apiClient.post(`/menus/${menuId}/items`, data);
    return response.data;
  },

  updateMenuItem: async (menuId: string, itemId: string, data: Partial<{
    categoryId: string;
    name: string;
    description: string;
    shortDescription: string;
    price: number;
    currency: string;
    isAvailable: boolean;
    isVegetarian: boolean;
    isVegan: boolean;
    isGlutenFree: boolean;
    allergens: string[];
    calories: number;
    images: string[];
    sortOrder: number;
  }>): Promise<any> => {
    const response = await apiClient.put(`/menus/${menuId}/items/${itemId}`, data);
    return response.data;
  },

  deleteMenuItem: async (menuId: string, itemId: string): Promise<void> => {
    await apiClient.delete(`/menus/${menuId}/items/${itemId}`);
  },

  // ============ ORDERS ============
  getOrders: async (
    businessId: string,
    params?: {
      page?: number;
      limit?: number;
      status?: string;
      fulfillmentType?: string;
      listingId?: string;
      orderNumber?: string;
    }
  ): Promise<{ data: any[]; meta: { total: number; page: number; limit: number; totalPages: number } }> => {
    const response = await apiClient.get(`/orders/merchant/${businessId}`, { params });
    return response.data;
  },

  getOrder: async (orderId: string): Promise<any> => {
    const response = await apiClient.get(`/orders/${orderId}`);
    return response.data;
  },

  updateOrderStatus: async (orderId: string, data: {
    status?: string;
    fulfillmentStatus?: string;
    internalNotes?: string;
  }): Promise<any> => {
    const response = await apiClient.patch(`/orders/${orderId}/status`, data);
    return response.data;
  },

  cancelOrder: async (orderId: string, data?: { reason?: string }): Promise<any> => {
    const response = await apiClient.post(`/orders/${orderId}/cancel`, data || {});
    return response.data;
  },

  // ============ SHOP SETTINGS ============
  updateShopSettings: async (businessId: string, listingId: string, data: {
    isShopEnabled?: boolean;
    shopSettings?: {
      acceptsOnlineOrders?: boolean;
      deliveryEnabled?: boolean;
      pickupEnabled?: boolean;
      dineInEnabled?: boolean;
      deliveryZones?: any;
      paymentMethods?: string[];
    };
  }): Promise<MerchantListing> => {
    const response = await apiClient.put<MerchantListing>(`/merchants/businesses/${businessId}/listings/${listingId}`, data);
    return response.data;
  },
};

