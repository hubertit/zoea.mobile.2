'use client';

import Skeleton from './Skeleton';

export default function StatCardSkeleton() {
  return (
    <div className="bg-white rounded-sm border border-gray-200 p-4">
      <div className="flex items-center justify-between">
        <div className="flex-1">
          <Skeleton height={12} width={80} className="mb-2" />
          <Skeleton height={28} width={100} className="mb-2" />
          <Skeleton height={12} width={60} />
        </div>
        <Skeleton width={48} height={48} className="rounded-lg" />
      </div>
    </div>
  );
}

