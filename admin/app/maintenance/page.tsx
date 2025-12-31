'use client';

import { useState, useEffect } from 'react';
import { useRouter } from 'next/navigation';
import { checkHealthWithRetry } from '@/src/lib/services/health-check';
import Icon, { faCloud, faRedo, faHeart } from '@/app/components/Icon';
import { Button } from '@/app/components';

export default function MaintenancePage() {
  const router = useRouter();
  const [isRetrying, setIsRetrying] = useState(false);
  const [fadeIn, setFadeIn] = useState(false);

  useEffect(() => {
    // Trigger fade-in animation
    setFadeIn(true);
  }, []);

  const handleRetry = async () => {
    setIsRetrying(true);

    try {
      // Check health with retry
      const isHealthy = await checkHealthWithRetry(2, 1000);

      if (isHealthy) {
        // Backend is back online, redirect to dashboard
        router.push('/dashboard');
        router.refresh();
      } else {
        // Still down, show error message
        setIsRetrying(false);
        // You could show a toast here if needed
      }
    } catch (error) {
      setIsRetrying(false);
    }
  };

  return (
    <div className="min-h-screen bg-white flex items-center justify-center p-6">
      <div
        className={`max-w-md w-full text-center transition-all duration-1000 ${
          fadeIn ? 'opacity-100 scale-100' : 'opacity-0 scale-95'
        }`}
      >
        {/* Icon with gradient background */}
        <div className="flex justify-center mb-8">
          <div className="w-32 h-32 rounded-full bg-gradient-to-br from-[#0e1a30]/20 to-[#0e1a30]/10 flex items-center justify-center">
            <Icon icon={faCloud} className="text-[#0e1a30]" size="2x" />
          </div>
        </div>

        {/* Title */}
        <h1 className="text-3xl font-bold text-gray-900 mb-4">
          We&apos;ll Be Right Back!
        </h1>

        {/* Message */}
        <p className="text-gray-600 mb-8 leading-relaxed">
          Our systems are currently undergoing maintenance to serve you better.
          We&apos;ll be back online shortly.
        </p>

        {/* Decorative divider */}
        <div className="flex items-center justify-center mb-8">
          <div className="flex-1 border-t border-gray-200"></div>
          <Icon icon={faHeart} className="mx-4 text-[#0e1a30]/50 text-sm" />
          <div className="flex-1 border-t border-gray-200"></div>
        </div>

        {/* Retry button */}
        <Button
          onClick={handleRetry}
          variant="primary"
          size="lg"
          icon={faRedo}
          loading={isRetrying}
          className="w-full mb-6"
        >
          {isRetrying ? 'Checking...' : 'Try Again'}
        </Button>

        {/* Support info */}
        <p className="text-sm text-gray-500">
          Need help? Contact us at{' '}
          <a
            href="mailto:support@zoea.africa"
            className="text-[#0e1a30] hover:underline"
          >
            support@zoea.africa
          </a>
        </p>
      </div>
    </div>
  );
}

