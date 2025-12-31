import axios, { AxiosInstance, AxiosError, InternalAxiosRequestConfig } from 'axios';

const API_BASE_URL = process.env.NEXT_PUBLIC_API_URL || 'https://zoea-africa.qtsoftwareltd.com/api';

class ApiClient {
  private client: AxiosInstance;

  constructor() {
    this.client = axios.create({
      baseURL: API_BASE_URL,
      timeout: 30000,
      headers: {
        'Content-Type': 'application/json',
      },
    });

    this.setupInterceptors();
  }

  private setupInterceptors() {
    // Request interceptor - Add auth token
    this.client.interceptors.request.use(
      (config: InternalAxiosRequestConfig) => {
        const token = this.getToken();
        if (token && config.headers) {
          config.headers.Authorization = `Bearer ${token}`;
        }
        return config;
      },
      (error: AxiosError) => {
        return Promise.reject(error);
      }
    );

    // Response interceptor - Handle errors
    this.client.interceptors.response.use(
      (response) => response,
      (error: AxiosError) => {
        if (error.response) {
          const status = error.response.status;
          const data = error.response.data as any;

          // Handle 401 Unauthorized
          if (status === 401) {
            this.handleUnauthorized();
          }

          // Handle 403 Forbidden
          if (status === 403) {
            // TODO: Show access denied message
            console.error('Access denied');
          }

          // Handle 404 Not Found
          if (status === 404) {
            // TODO: Show not found message
            console.error('Resource not found');
          }

          // Handle 500 Server Error
          if (status >= 500) {
            // TODO: Show server error message
            console.error('Server error');
          }

          // Return a formatted error
          return Promise.reject({
            message: data?.message || error.message || 'An error occurred',
            status,
            data: data,
          });
        }

        // Network error
        if (error.request) {
          return Promise.reject({
            message: 'Network error. Please check your connection.',
            status: 0,
          });
        }

        return Promise.reject(error);
      }
    );
  }

  private getToken(): string | null {
    if (typeof window === 'undefined') return null;
    
    try {
      const authStorage = localStorage.getItem('auth-storage');
      if (authStorage) {
        const parsed = JSON.parse(authStorage);
        return parsed.state?.token || null;
      }
    } catch (error) {
      console.error('Error reading token from storage:', error);
    }
    
    return null;
  }

  private handleUnauthorized() {
    // Clear auth state
    if (typeof window !== 'undefined') {
      localStorage.removeItem('auth-storage');
      // Redirect to login
      window.location.href = '/auth/login';
    }
  }

  // Public methods
  get<T = any>(url: string, config?: any) {
    return this.client.get<T>(url, config);
  }

  post<T = any>(url: string, data?: any, config?: any) {
    return this.client.post<T>(url, data, config);
  }

  put<T = any>(url: string, data?: any, config?: any) {
    return this.client.put<T>(url, data, config);
  }

  patch<T = any>(url: string, data?: any, config?: any) {
    return this.client.patch<T>(url, data, config);
  }

  delete<T = any>(url: string, config?: any) {
    return this.client.delete<T>(url, config);
  }
}

export const apiClient = new ApiClient();
export default apiClient;

