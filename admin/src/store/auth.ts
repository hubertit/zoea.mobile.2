import { create } from 'zustand';
import { persist } from 'zustand/middleware';
import apiClient from '@/src/lib/api/client';

interface User {
  id: string;
  email: string;
  phoneNumber?: string;
  name?: string;
  fullName?: string;
  roles?: Array<{ id: string; name: string; code: string }>;
  profileImageId?: string;
}

interface AuthState {
  user: User | null;
  token: string | null;
  refreshToken: string | null;
  isAuthenticated: boolean;
  isLoading: boolean;
  error: string | null;
  
  // Actions
  login: (email: string, password: string) => Promise<void>;
  logout: () => void;
  setUser: (user: User | null) => void;
  setToken: (token: string | null) => void;
  clearError: () => void;
  checkAuth: () => Promise<void>;
}

export const useAuthStore = create<AuthState>()(
  persist(
    (set, get) => ({
      user: null,
      token: null,
      refreshToken: null,
      isAuthenticated: false,
      isLoading: false,
      error: null,

      login: async (identifier: string, password: string) => {
        set({ isLoading: true, error: null });
        try {
          const response = await apiClient.post('/auth/login', {
            identifier: identifier, // Backend expects 'identifier' which can be email or phone
            password,
          });

          const data = response.data;
          
          set({
            user: {
              id: data.user.id,
              email: data.user.email,
              phoneNumber: data.user.phoneNumber,
              fullName: data.user.fullName,
              name: data.user.fullName,
              roles: data.user.roles || [],
            },
            token: data.accessToken,
            refreshToken: data.refreshToken,
            isAuthenticated: true,
            isLoading: false,
            error: null,
          });
        } catch (error: any) {
          const errorMessage = error?.response?.data?.message || 
                              error?.message || 
                              'Login failed. Please check your credentials.';
          
          set({
            isLoading: false,
            error: errorMessage,
            isAuthenticated: false,
          });
          throw new Error(errorMessage);
        }
      },

      logout: () => {
        set({
          user: null,
          token: null,
          refreshToken: null,
          isAuthenticated: false,
          error: null,
        });
        // Clear persisted state
        if (typeof window !== 'undefined') {
          localStorage.removeItem('auth-storage');
        }
      },

      setUser: (user: User | null) => {
        set({ user, isAuthenticated: !!user });
      },

      setToken: (token: string | null) => {
        set({ token, isAuthenticated: !!token });
      },

      clearError: () => {
        set({ error: null });
      },

      checkAuth: async () => {
        const { token } = get();
        if (!token) {
          set({ isAuthenticated: false, user: null });
          return;
        }

        set({ isLoading: true });
        try {
          const response = await apiClient.get('/users/me');

          const userData = response.data;
          set({
            user: {
              id: userData.id,
              email: userData.email,
              phoneNumber: userData.phoneNumber,
              fullName: userData.fullName,
              name: userData.fullName,
              roles: userData.roles || [],
            },
            isAuthenticated: true,
            isLoading: false,
          });
        } catch (error) {
          set({
            isAuthenticated: false,
            user: null,
            token: null,
            refreshToken: null,
            isLoading: false,
          });
          if (typeof window !== 'undefined') {
            localStorage.removeItem('auth-storage');
          }
        }
      },
    }),
    {
      name: 'auth-storage',
      partialize: (state) => ({
        user: state.user,
        token: state.token,
        refreshToken: state.refreshToken,
        isAuthenticated: state.isAuthenticated,
      }),
    }
  )
);
