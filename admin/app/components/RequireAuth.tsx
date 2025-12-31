'use client';

import { useEffect, useState } from 'react';
import { useRouter } from 'next/navigation';
import { useAuthStore } from '@/src/store/auth';

interface RequireAuthProps {
  children: React.ReactNode;
  roles?: string[];
}

export default function RequireAuth({ children, roles }: RequireAuthProps) {
  const router = useRouter();
  const { isAuthenticated, isLoading, user, checkAuth } = useAuthStore();
  const [isChecking, setIsChecking] = useState(true);

  useEffect(() => {
    const verifyAuth = async () => {
      if (!isAuthenticated) {
        await checkAuth();
      }
      setIsChecking(false);
    };

    verifyAuth();
  }, [isAuthenticated, checkAuth]);

  useEffect(() => {
    if (!isChecking && !isLoading) {
      if (!isAuthenticated) {
        router.push('/auth/login');
        return;
      }

      // Check role-based access
      if (roles && roles.length > 0 && user) {
        const userRoles = user.roles || [];
        const userRoleCodes = userRoles.map((r) => (r.code || r.name || '').toUpperCase());
        const hasRequiredRole = roles.some((role) =>
          userRoleCodes.includes(role.toUpperCase())
        );

        if (!hasRequiredRole) {
          router.push('/dashboard');
          return;
        }
      }
    }
  }, [isChecking, isLoading, isAuthenticated, user, roles, router]);

  if (isChecking || isLoading) {
    return (
      <div className="flex items-center justify-center min-h-screen bg-gray-50">
        <div className="text-center">
          <div className="inline-block animate-spin rounded-full h-12 w-12 border-b-2 border-[#0e1a30] mb-4"></div>
          <p className="text-gray-600">Loading...</p>
        </div>
      </div>
    );
  }

  if (!isAuthenticated) {
    return null;
  }

  return <>{children}</>;
}

