'use client';

import Skeleton from './Skeleton';
import StatCardSkeleton from './StatCardSkeleton';

export default function DashboardSkeleton() {
  return (
    <div className="space-y-6">
      {/* Stat Cards */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
        {Array.from({ length: 4 }).map((_, index) => (
          <StatCardSkeleton key={index} />
        ))}
      </div>

      {/* Charts */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        <div className="card p-6">
          <Skeleton height={24} width={200} className="mb-4" />
          <Skeleton height={300} />
        </div>
        <div className="card p-6">
          <Skeleton height={24} width={200} className="mb-4" />
          <Skeleton height={300} />
        </div>
      </div>

      {/* Table */}
      <div className="card p-6">
        <Skeleton height={24} width={200} className="mb-4" />
        <Skeleton height={400} />
      </div>
    </div>
  );
}

