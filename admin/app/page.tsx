'use client';

import { useEffect, useState } from 'react';
import { useRouter } from 'next/navigation';
import { useAuthStore } from '@/src/store/auth';
import { checkHealthWithRetry } from '@/src/lib/services/health-check';

export default function HomePage() {
  const router = useRouter();
  const { isAuthenticated } = useAuthStore();
  const [isChecking, setIsChecking] = useState(true);

  useEffect(() => {
    const checkAndRedirect = async () => {
      // First, check backend health
      const isHealthy = await checkHealthWithRetry(2, 1000);

      if (!isHealthy) {
        // Backend is down, redirect to maintenance page
        router.push('/maintenance');
        return;
      }

      setIsChecking(false);

      // Backend is healthy, proceed with normal redirect
      if (isAuthenticated) {
        router.push('/dashboard');
      } else {
        router.push('/auth/login');
      }
    };

    checkAndRedirect();
  }, [isAuthenticated, router]);

  return (
    <div className="flex items-center justify-center min-h-screen bg-gray-50">
      <div className="text-center">
        <div className="inline-block animate-spin rounded-full h-12 w-12 border-b-2 border-[#0e1a30] mb-4"></div>
        <p className="text-gray-600">
          {isChecking ? 'Checking system status...' : 'Loading...'}
        </p>
      </div>
    </div>
  );
}
