import apiClient from './client';

export type BookingStatus = 'pending' | 'confirmed' | 'checked_in' | 'completed' | 'cancelled' | 'no_show' | 'refunded';
export type PaymentStatus = 'pending' | 'processing' | 'completed' | 'failed' | 'refunded' | 'partially_refunded';
export type BookingType = 'hotel' | 'restaurant' | 'tour' | 'event' | 'experience';

export interface BookingGuest {
  fullName: string;
  email?: string;
  phone?: string;
}

export interface Booking {
  id: string;
  bookingNumber: string;
  status: BookingStatus;
  paymentStatus: PaymentStatus;
  totalAmount: number;
  currency: string;
  bookingDate?: string | null;
  bookingTime?: string | null;
  checkInDate?: string | null;
  checkOutDate?: string | null;
  guestCount?: number | null;
  adults?: number | null;
  children?: number | null;
  specialRequests?: string | null;
  userId: string;
  merchantId?: string | null;
  listingId?: string | null;
  eventId?: string | null;
  createdAt: string;
  updatedAt: string;
  user?: { id: string; fullName: string; email: string } | null;
  listing?: { id: string; name: string } | null;
  merchant?: { id: string; businessName: string } | null;
}

export interface ListBookingsParams {
  page?: number;
  limit?: number;
  search?: string;
  status?: BookingStatus;
  paymentStatus?: PaymentStatus;
  merchantId?: string;
  userId?: string;
  startDate?: string; // ISO date string
  endDate?: string; // ISO date string
}

export interface ListBookingsResponse {
  data: Booking[];
  meta: {
    total: number;
    page: number;
    limit: number;
    totalPages: number;
  };
}

export interface CreateBookingParams {
  userId: string;
  bookingType: BookingType;
  listingId?: string;
  eventId?: string;
  tourId?: string;
  roomTypeId?: string;
  tableId?: string;
  ticketId?: string;
  ticketQuantity?: number;
  tourScheduleId?: string;
  checkInDate?: string;
  checkOutDate?: string;
  bookingDate?: string;
  bookingTime?: string;
  guestCount?: number;
  adults?: number;
  children?: number;
  specialRequests?: string;
  guests?: BookingGuest[];
}

export interface UpdateBookingDetailsParams {
  specialRequests?: string;
  guestCount?: number;
}

export interface UpdateBookingStatusParams {
  status?: BookingStatus;
  paymentStatus?: PaymentStatus;
  notes?: string;
  refundAmount?: number;
}

export const BookingsAPI = {
  /**
   * List bookings with filters and pagination
   */
  listBookings: async (params: ListBookingsParams = {}): Promise<ListBookingsResponse> => {
    const response = await apiClient.get<ListBookingsResponse>('/admin/bookings', { params });
    return response.data;
  },

  /**
   * Get booking by ID
   */
  getBookingById: async (id: string): Promise<Booking> => {
    const response = await apiClient.get<Booking>(`/admin/bookings/${id}`);
    return response.data;
  },

  /**
   * Create booking on behalf of user
   */
  createBooking: async (data: CreateBookingParams): Promise<Booking> => {
    const response = await apiClient.post<Booking>('/admin/bookings', data);
    return response.data;
  },

  /**
   * Update booking details (notes, guest counts)
   */
  updateBookingDetails: async (id: string, data: UpdateBookingDetailsParams): Promise<Booking> => {
    const response = await apiClient.put<Booking>(`/admin/bookings/${id}`, data);
    return response.data;
  },

  /**
   * Update booking status/payment state
   */
  updateBookingStatus: async (id: string, data: UpdateBookingStatusParams): Promise<Booking> => {
    const response = await apiClient.patch<Booking>(`/admin/bookings/${id}/status`, data);
    return response.data;
  },
};

