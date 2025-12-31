'use client';

import { useEffect, useState } from 'react';
import Toast, { Toast as ToastType } from './Toast';

let toastIdCounter = 0;
let toastListeners: Array<(toasts: ToastType[]) => void> = [];
let toasts: ToastType[] = [];

const toast = {
  success: (message: string, duration = 3000) => {
    const id = `toast-${toastIdCounter++}`;
    toasts = [...toasts, { id, type: 'success', message, duration }];
    toastListeners.forEach((listener) => listener([...toasts]));
  },
  error: (message: string, duration = 5000) => {
    const id = `toast-${toastIdCounter++}`;
    toasts = [...toasts, { id, type: 'error', message, duration }];
    toastListeners.forEach((listener) => listener([...toasts]));
  },
  info: (message: string, duration = 3000) => {
    const id = `toast-${toastIdCounter++}`;
    toasts = [...toasts, { id, type: 'info', message, duration }];
    toastListeners.forEach((listener) => listener([...toasts]));
  },
  warning: (message: string, duration = 4000) => {
    const id = `toast-${toastIdCounter++}`;
    toasts = [...toasts, { id, type: 'warning', message, duration }];
    toastListeners.forEach((listener) => listener([...toasts]));
  },
};

export default function Toaster() {
  const [currentToasts, setCurrentToasts] = useState<ToastType[]>([]);

  useEffect(() => {
    const listener = (newToasts: ToastType[]) => {
      setCurrentToasts(newToasts);
    };
    toastListeners.push(listener);
    setCurrentToasts([...toasts]);

    return () => {
      toastListeners = toastListeners.filter((l) => l !== listener);
    };
  }, []);

  const handleClose = (id: string) => {
    toasts = toasts.filter((t) => t.id !== id);
    toastListeners.forEach((listener) => listener([...toasts]));
  };

  if (currentToasts.length === 0) return null;

  return (
    <div className="fixed top-4 right-4 z-50 flex flex-col items-end">
      {currentToasts.map((toast) => (
        <Toast key={toast.id} toast={toast} onClose={handleClose} />
      ))}
    </div>
  );
}

export { toast };

