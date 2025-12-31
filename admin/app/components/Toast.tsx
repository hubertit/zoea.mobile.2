'use client';

import { useEffect } from 'react';
import Icon, { faCheckCircle, faExclamationCircle, faInfoCircle, faTimesCircle, faTimes } from './Icon';

export type ToastType = 'success' | 'error' | 'info' | 'warning';

export interface Toast {
  id: string;
  type: ToastType;
  message: string;
  duration?: number;
}

interface ToastProps {
  toast: Toast;
  onClose: (id: string) => void;
}

const typeConfig = {
  success: {
    icon: faCheckCircle,
    bgColor: 'bg-green-50',
    borderColor: 'border-green-200',
    textColor: 'text-green-800',
    iconColor: 'text-green-400',
  },
  error: {
    icon: faTimesCircle,
    bgColor: 'bg-red-50',
    borderColor: 'border-red-200',
    textColor: 'text-red-800',
    iconColor: 'text-red-400',
  },
  info: {
    icon: faInfoCircle,
    bgColor: 'bg-blue-50',
    borderColor: 'border-blue-200',
    textColor: 'text-blue-800',
    iconColor: 'text-blue-400',
  },
  warning: {
    icon: faExclamationCircle,
    bgColor: 'bg-yellow-50',
    borderColor: 'border-yellow-200',
    textColor: 'text-yellow-800',
    iconColor: 'text-yellow-400',
  },
};

export default function Toast({ toast, onClose }: ToastProps) {
  const config = typeConfig[toast.type];

  useEffect(() => {
    if (toast.duration && toast.duration > 0) {
      const timer = setTimeout(() => {
        onClose(toast.id);
      }, toast.duration);

      return () => clearTimeout(timer);
    }
  }, [toast.id, toast.duration, onClose]);

  return (
    <div
      className={`
        ${config.bgColor} ${config.borderColor} ${config.textColor}
        border rounded-sm p-4 mb-3 min-w-[300px] max-w-[500px]
        animate-slideIn
      `}
      role="alert"
    >
      <div className="flex items-start gap-3">
        <Icon icon={config.icon} className={config.iconColor} size="lg" />
        <div className="flex-1">
          <p className="text-sm font-medium">{toast.message}</p>
        </div>
        <button
          onClick={() => onClose(toast.id)}
          className={`${config.textColor} hover:opacity-70 transition-opacity`}
          aria-label="Close notification"
        >
          <Icon icon={faTimes} size="sm" />
        </button>
      </div>
    </div>
  );
}

