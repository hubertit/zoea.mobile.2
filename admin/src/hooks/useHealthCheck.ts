import { useEffect, useState } from 'react';
import { useRouter, usePathname } from 'next/navigation';
import { checkHealth, checkHealthWithRetry } from '@/src/lib/services/health-check';

const HEALTH_CHECK_INTERVAL = 30000; // Check every 30 seconds
const RETRY_DELAY = 5000; // Wait 5 seconds before redirecting

/**
 * Hook to monitor API health and redirect to maintenance page when API is down
 */
export function useHealthCheck() {
  const router = useRouter();
  const pathname = usePathname();
  const [isHealthy, setIsHealthy] = useState<boolean | null>(null);
  const [isChecking, setIsChecking] = useState(false);

  useEffect(() => {
    // Don't check health on maintenance page
    if (pathname === '/maintenance') {
      return;
    }

    let healthCheckInterval: NodeJS.Timeout;
    let retryTimeout: NodeJS.Timeout;

    const performHealthCheck = async () => {
      if (isChecking) return;
      
      setIsChecking(true);
      try {
        const healthy = await checkHealth();
        setIsHealthy(healthy);

        if (!healthy) {
          // API is down, wait a bit then redirect
          retryTimeout = setTimeout(() => {
            // Double-check before redirecting
            checkHealthWithRetry(1, 1000).then((stillDown) => {
              if (!stillDown && pathname !== '/maintenance') {
                router.push('/maintenance');
              }
            });
          }, RETRY_DELAY);
        } else {
          // Clear any pending redirect
          if (retryTimeout) {
            clearTimeout(retryTimeout);
          }
        }
      } catch (error) {
        setIsHealthy(false);
      } finally {
        setIsChecking(false);
      }
    };

    // Initial health check
    performHealthCheck();

    // Set up periodic health checks
    healthCheckInterval = setInterval(performHealthCheck, HEALTH_CHECK_INTERVAL);

    return () => {
      if (healthCheckInterval) {
        clearInterval(healthCheckInterval);
      }
      if (retryTimeout) {
        clearTimeout(retryTimeout);
      }
    };
  }, [router, pathname, isChecking]);

  return { isHealthy, isChecking };
}

