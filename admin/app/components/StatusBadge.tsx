'use client';

import Badge from './Badge';

interface StatusBadgeProps {
  status: string;
  className?: string;
}

const statusVariantMap: Record<string, 'success' | 'warning' | 'error' | 'info' | 'neutral'> = {
  active: 'success',
  inactive: 'neutral',
  pending: 'warning',
  approved: 'success',
  rejected: 'error',
  completed: 'success',
  cancelled: 'error',
  new: 'info',
  open: 'warning',
  resolved: 'success',
  closed: 'neutral',
};

export default function StatusBadge({ status, className = '' }: StatusBadgeProps) {
  const variant = statusVariantMap[status.toLowerCase()] || 'neutral';
  
  return (
    <Badge variant={variant} className={className}>
      {status}
    </Badge>
  );
}

