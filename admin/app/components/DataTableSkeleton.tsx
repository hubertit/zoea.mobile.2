'use client';

import Skeleton from './Skeleton';

interface DataTableSkeletonProps {
  rows?: number;
  columns?: number;
  showHeader?: boolean;
  showActions?: boolean;
}

export default function DataTableSkeleton({
  rows = 5,
  columns = 5,
  showHeader = true,
  showActions = false,
}: DataTableSkeletonProps) {
  const totalColumns = columns + (showActions ? 1 : 0);

  return (
    <div className="bg-white rounded-sm border border-gray-200 overflow-hidden">
      <div className="overflow-x-auto">
        <table className="w-full">
          {showHeader && (
            <thead className="bg-gray-50 border-b border-gray-200">
              <tr>
                {Array.from({ length: totalColumns }).map((_, index) => (
                  <th key={index} className="px-6 py-3">
                    <Skeleton height={16} width={80} />
                  </th>
                ))}
              </tr>
            </thead>
          )}
          <tbody className="bg-white divide-y divide-gray-200">
            {Array.from({ length: rows }).map((_, rowIndex) => (
              <tr key={rowIndex}>
                {Array.from({ length: totalColumns }).map((_, colIndex) => (
                  <td key={colIndex} className="px-6 py-4">
                    <Skeleton height={16} width={colIndex === 0 ? 120 : 80} />
                  </td>
                ))}
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  );
}

