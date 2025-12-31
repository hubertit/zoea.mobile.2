import apiClient from './client';

export type TransactionType = 'deposit' | 'withdrawal' | 'payment' | 'refund' | 'commission' | 'bonus' | 'payout' | 'subscription';
export type TransactionStatus = 'pending' | 'completed' | 'failed' | 'cancelled';
export type PaymentStatus = 'pending' | 'processing' | 'completed' | 'failed' | 'refunded' | 'partially_refunded';

export interface Transaction {
  id: string;
  type: TransactionType;
  status: TransactionStatus;
  amount: number;
  currency: string;
  reference?: string | null;
  description?: string | null;
  userId?: string | null;
  merchantId?: string | null;
  bookingId?: string | null;
  paymentMethod?: string | null;
  createdAt: string;
  updatedAt: string;
  user?: { id: string; fullName: string; email: string } | null;
  merchant?: { id: string; businessName: string } | null;
  booking?: { id: string; bookingNumber: string } | null;
}

export interface Payout {
  id: string;
  merchantId: string;
  amount: number;
  currency: string;
  status: PaymentStatus;
  reference?: string | null;
  bankAccountInfo?: Record<string, any> | null;
  processedAt?: string | null;
  createdAt: string;
  updatedAt: string;
  merchant?: { id: string; businessName: string } | null;
}

export interface ListTransactionsParams {
  page?: number;
  limit?: number;
  search?: string;
  type?: TransactionType;
  status?: TransactionStatus;
  paymentMethod?: string;
  userId?: string;
  merchantId?: string;
  startDate?: string; // ISO date string
  endDate?: string; // ISO date string
}

export interface ListTransactionsResponse {
  data: Transaction[];
  meta: {
    total: number;
    page: number;
    limit: number;
    totalPages: number;
  };
}

export interface ListPayoutsParams {
  page?: number;
  limit?: number;
  search?: string;
  status?: PaymentStatus;
  merchantId?: string;
  startDate?: string; // ISO date string
  endDate?: string; // ISO date string
}

export interface ListPayoutsResponse {
  data: Payout[];
  meta: {
    total: number;
    page: number;
    limit: number;
    totalPages: number;
  };
}

export interface UpdateTransactionStatusParams {
  status?: TransactionStatus;
  notes?: string;
}

export interface UpdatePayoutStatusParams {
  status?: PaymentStatus;
  reference?: string;
  notes?: string;
}

export const PaymentsAPI = {
  /**
   * List financial transactions
   */
  listTransactions: async (params: ListTransactionsParams = {}): Promise<ListTransactionsResponse> => {
    const response = await apiClient.get<ListTransactionsResponse>('/admin/payments/transactions', { params });
    return response.data;
  },

  /**
   * Get transaction by ID
   */
  getTransactionById: async (id: string): Promise<Transaction> => {
    const response = await apiClient.get<Transaction>(`/admin/payments/transactions/${id}`);
    return response.data;
  },

  /**
   * Update transaction status
   */
  updateTransactionStatus: async (id: string, data: UpdateTransactionStatusParams): Promise<Transaction> => {
    const response = await apiClient.patch<Transaction>(`/admin/payments/transactions/${id}/status`, data);
    return response.data;
  },

  /**
   * List merchant payouts
   */
  listPayouts: async (params: ListPayoutsParams = {}): Promise<ListPayoutsResponse> => {
    const response = await apiClient.get<ListPayoutsResponse>('/admin/payments/payouts', { params });
    return response.data;
  },

  /**
   * Get payout by ID
   */
  getPayoutById: async (id: string): Promise<Payout> => {
    const response = await apiClient.get<Payout>(`/admin/payments/payouts/${id}`);
    return response.data;
  },

  /**
   * Update payout status / reference
   */
  updatePayoutStatus: async (id: string, data: UpdatePayoutStatusParams): Promise<Payout> => {
    const response = await apiClient.patch<Payout>(`/admin/payments/payouts/${id}/status`, data);
    return response.data;
  },
};

