import axios, { AxiosError } from 'axios';

const API_BASE_URL = process.env.NEXT_PUBLIC_API_URL || 'https://zoea-africa.qtsoftwareltd.com/api';
const HEALTH_ENDPOINT = '/health';
const TIMEOUT = 5000; // 5 seconds

export interface HealthStatus {
  status: 'ok' | 'error';
  timestamp?: string;
  uptime?: number;
  version?: string;
}

/**
 * Check if the backend API is available
 * Returns true if API is healthy, false otherwise
 */
export async function checkHealth(): Promise<boolean> {
  try {
    const response = await axios.get<HealthStatus>(
      `${API_BASE_URL}${HEALTH_ENDPOINT}`,
      {
        timeout: TIMEOUT,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        validateStatus: (status) => {
          // Only consider 200-299 as success
          return status >= 200 && status < 300;
        },
      }
    );

    // Verify the response has the expected structure
    const data = response.data;
    if (data && data.status === 'ok') {
      return true;
    }

    // If status code is 200-299 but structure is different, still consider healthy
    return true;
  } catch (error) {
    // Handle Axios errors (connection errors, timeouts, 404s, etc.)
    if (error instanceof AxiosError) {
      // Connection errors, timeouts, 404s, etc. all mean API is not available
      return false;
    }
    // Any other error means API is not available
    return false;
  }
}

/**
 * Check health with retry logic
 * @param maxRetries - Maximum number of retry attempts (default: 2)
 * @param retryDelay - Delay between retries in milliseconds (default: 1000)
 */
export async function checkHealthWithRetry(
  maxRetries: number = 2,
  retryDelay: number = 1000
): Promise<boolean> {
  for (let i = 0; i <= maxRetries; i++) {
    const isHealthy = await checkHealth();
    if (isHealthy) {
      return true;
    }

    // Wait before retry (except on last attempt)
    if (i < maxRetries) {
      await new Promise((resolve) => setTimeout(resolve, retryDelay));
    }
  }

  return false;
}

