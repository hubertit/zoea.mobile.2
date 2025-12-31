import apiClient from './client';

export type ApprovalStatus = 'pending' | 'approved' | 'rejected' | 'revision_requested';

export interface NotificationRequest {
  id: string;
  title: string;
  body: string;
  targetType: string;
  segments?: string[] | null;
  actionUrl?: string | null;
  status: ApprovalStatus;
  requesterId: string;
  rejectionReason?: string | null;
  revisionNotes?: string | null;
  scheduleAt?: string | null;
  createdAt: string;
  updatedAt: string;
  requester?: { id: string; fullName: string; email: string } | null;
}

export interface ListNotificationRequestsParams {
  page?: number;
  limit?: number;
  status?: ApprovalStatus;
  type?: string;
  requesterId?: string;
  search?: string;
  startDate?: string; // ISO date string
  endDate?: string; // ISO date string
}

export interface ListNotificationRequestsResponse {
  data: NotificationRequest[];
  meta: {
    total: number;
    page: number;
    limit: number;
    totalPages: number;
  };
}

export interface UpdateNotificationRequestParams {
  status?: ApprovalStatus;
  rejectionReason?: string;
  revisionNotes?: string;
}

export interface CreateBroadcastParams {
  title: string;
  body: string;
  targetType: string;
  segments?: string[];
  actionUrl?: string;
  scheduleAt?: string; // ISO date string
}

export const NotificationsAPI = {
  /**
   * List notification/broadcast requests
   */
  listNotificationRequests: async (params: ListNotificationRequestsParams = {}): Promise<ListNotificationRequestsResponse> => {
    const response = await apiClient.get<ListNotificationRequestsResponse>('/admin/notifications/requests', { params });
    return response.data;
  },

  /**
   * Approve or reject notification request
   */
  updateNotificationRequest: async (id: string, data: UpdateNotificationRequestParams): Promise<NotificationRequest> => {
    const response = await apiClient.patch<NotificationRequest>(`/admin/notifications/requests/${id}/status`, data);
    return response.data;
  },

  /**
   * Create immediate/scheduled broadcast message
   */
  createBroadcast: async (data: CreateBroadcastParams): Promise<NotificationRequest> => {
    const response = await apiClient.post<NotificationRequest>('/admin/notifications/broadcast', data);
    return response.data;
  },
};

