'use client';

import Skeleton from './Skeleton';

export default function PageSkeleton() {
  return (
    <div className="space-y-6">
      {/* Page Header */}
      <div className="flex items-center justify-between">
        <Skeleton height={32} width={200} />
        <Skeleton height={40} width={120} />
      </div>

      {/* Content */}
      <div className="card p-6">
        <Skeleton height={400} />
      </div>
    </div>
  );
}

