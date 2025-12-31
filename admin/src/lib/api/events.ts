import apiClient from './client';

export type EventStatus = 'draft' | 'pending_review' | 'published' | 'ongoing' | 'completed' | 'cancelled' | 'suspended';
export type EventPrivacy = 'public' | 'private' | 'invite_only';
export type EventSetup = 'in_person' | 'virtual' | 'hybrid';

export interface Event {
  id: string;
  name: string;
  slug?: string | null;
  description?: string | null;
  privacy?: EventPrivacy | null;
  setup?: EventSetup | null;
  status: EventStatus;
  isBlocked: boolean;
  startDate?: string | null;
  endDate?: string | null;
  maxAttendance?: number | null;
  organizerId: string;
  countryId?: string | null;
  cityId?: string | null;
  address?: string | null;
  createdAt: string;
  updatedAt: string;
  organizer?: { id: string; organizationName: string } | null;
  city?: { id: string; name: string } | null;
}

export interface ListEventsParams {
  page?: number;
  limit?: number;
  search?: string;
  status?: EventStatus;
  organizerId?: string;
  cityId?: string;
}

export interface ListEventsResponse {
  data: Event[];
  meta: {
    total: number;
    page: number;
    limit: number;
    totalPages: number;
  };
}

export interface CreateEventParams {
  organizerId: string;
  name: string;
  slug?: string;
  description?: string;
  privacy?: EventPrivacy;
  setup?: EventSetup;
  countryId?: string;
  cityId?: string;
  address?: string;
  startDate?: string;
  endDate?: string;
  maxAttendance?: number;
  isBlocked?: boolean;
}

export interface UpdateEventParams extends Partial<CreateEventParams> {}

export interface UpdateEventStatusParams {
  status?: EventStatus;
  isBlocked?: boolean;
}

export const EventsAPI = {
  /**
   * List events with filters and pagination
   */
  listEvents: async (params: ListEventsParams = {}): Promise<ListEventsResponse> => {
    const response = await apiClient.get<ListEventsResponse>('/admin/events', { params });
    return response.data;
  },

  /**
   * Get event by ID
   */
  getEventById: async (id: string): Promise<Event> => {
    const response = await apiClient.get<Event>(`/admin/events/${id}`);
    return response.data;
  },

  /**
   * Create event on behalf of organizer
   */
  createEvent: async (data: CreateEventParams): Promise<Event> => {
    const response = await apiClient.post<Event>('/admin/events', data);
    return response.data;
  },

  /**
   * Update event content
   */
  updateEvent: async (id: string, data: UpdateEventParams): Promise<Event> => {
    const response = await apiClient.put<Event>(`/admin/events/${id}`, data);
    return response.data;
  },

  /**
   * Update event status/moderation
   */
  updateEventStatus: async (id: string, data: UpdateEventStatusParams): Promise<Event> => {
    const response = await apiClient.patch<Event>(`/admin/events/${id}/status`, data);
    return response.data;
  },

  /**
   * Soft delete event
   */
  deleteEvent: async (id: string): Promise<void> => {
    await apiClient.delete(`/admin/events/${id}`);
  },

  /**
   * Restore soft-deleted event
   */
  restoreEvent: async (id: string): Promise<Event> => {
    const response = await apiClient.patch<Event>(`/admin/events/${id}/restore`);
    return response.data;
  },
};

