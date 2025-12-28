'use client';

import { ReactNode } from 'react';
import Icon, { faSpinner } from './Icon';

interface ChartWrapperProps {
  title?: string;
  children: ReactNode;
  loading?: boolean;
  error?: string | null;
  emptyMessage?: string;
}

export default function ChartWrapper({
  title,
  children,
  loading = false,
  error = null,
  emptyMessage = 'No data available',
}: ChartWrapperProps) {
  if (loading) {
    return (
      <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-6">
        {title && <h3 className="text-base font-semibold text-gray-900 mb-4">{title}</h3>}
        <div className="flex items-center justify-center h-64">
          <Icon icon={faSpinner} spin className="text-primary" size="2x" />
        </div>
      </div>
    );
  }

  if (error) {
    return (
      <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-6">
        {title && <h3 className="text-base font-semibold text-gray-900 mb-4">{title}</h3>}
        <div className="flex items-center justify-center h-64">
          <div className="text-center">
            <p className="text-red-600 mb-2 text-sm">{error}</p>
            <p className="text-xs text-gray-500">Please try again later</p>
          </div>
        </div>
      </div>
    );
  }

  return (
    <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-6">
      {title && <h3 className="text-lg font-semibold text-gray-900 mb-4">{title}</h3>}
      {children}
    </div>
  );
}
