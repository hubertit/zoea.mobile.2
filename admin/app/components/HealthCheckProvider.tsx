'use client';

import { useEffect } from 'react';
import { useRouter, usePathname } from 'next/navigation';
import { checkHealthWithRetry } from '@/src/lib/services/health-check';

/**
 * Provider component that monitors API health and redirects to maintenance page when API is down
 */
export default function HealthCheckProvider({
  children,
}: {
  children: React.ReactNode;
}) {
  const router = useRouter();
  const pathname = usePathname();

  useEffect(() => {
    // Don't check health on maintenance page or auth pages
    if (pathname === '/maintenance' || pathname?.startsWith('/auth')) {
      return;
    }

    // Initial health check on app load
    const checkInitialHealth = async () => {
      const isHealthy = await checkHealthWithRetry(2, 1000);
      if (!isHealthy && pathname !== '/maintenance') {
        router.push('/maintenance');
      }
    };

    checkInitialHealth();

    // Set up periodic health checks (every 30 seconds)
    const healthCheckInterval = setInterval(async () => {
      if (pathname === '/maintenance' || pathname?.startsWith('/auth')) {
        return;
      }

      const isHealthy = await checkHealthWithRetry(1, 1000);
      if (!isHealthy && pathname !== '/maintenance') {
        router.push('/maintenance');
      }
    }, 30000);

    return () => {
      clearInterval(healthCheckInterval);
    };
  }, [router, pathname]);

  return <>{children}</>;
}

