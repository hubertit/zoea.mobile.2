'use client';

import Skeleton from './Skeleton';

interface ChartSkeletonProps {
  height?: number;
  showTitle?: boolean;
}

export default function ChartSkeleton({ height = 300, showTitle = true }: ChartSkeletonProps) {
  return (
    <div className="card p-6">
      {showTitle && <Skeleton height={24} width={200} className="mb-4" />}
      <Skeleton height={height} />
    </div>
  );
}

