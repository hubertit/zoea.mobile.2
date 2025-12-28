// Authentication utilities

export interface AuthUser {
  role: string;
  name?: string;
  email?: string;
  id?: number;
}

export function getAuth(): AuthUser | null {
  if (typeof window === 'undefined') return null;
  
  try {
    const authRaw = sessionStorage.getItem('zoeaAdminAuth');
    if (!authRaw) return null;
    
    return JSON.parse(authRaw) as AuthUser;
  } catch (error) {
    console.error('Failed to parse auth data', error);
    return null;
  }
}

export function setAuth(auth: AuthUser): void {
  if (typeof window === 'undefined') return;
  
  sessionStorage.setItem('zoeaAdminAuth', JSON.stringify(auth));
  sessionStorage.setItem('zoeaAdminRole', auth.role);
  
  if (auth.name) {
    sessionStorage.setItem('adminName', auth.name);
  }
}

export function clearAuth(): void {
  if (typeof window === 'undefined') return;
  
  sessionStorage.removeItem('zoeaAdminAuth');
  sessionStorage.removeItem('zoeaAdminRole');
  sessionStorage.removeItem('adminName');
  
  // Clear cookies
  document.cookie = 'zoeaAdminAuth=; path=/; expires=Thu, 01 Jan 1970 00:00:00 GMT';
}

export function isAuthenticated(): boolean {
  return getAuth() !== null;
}

export function isAdmin(): boolean {
  const auth = getAuth();
  return auth?.role === 'admin';
}

