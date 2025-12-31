'use client';

import Modal from './Modal';
import Button from './Button';
import Icon, { faExclamationTriangle } from './Icon';

interface ConfirmDialogProps {
  isOpen: boolean;
  onClose: () => void;
  onConfirm: () => void;
  title: string;
  message: string;
  confirmText?: string;
  cancelText?: string;
  variant?: 'danger' | 'warning' | 'info';
  loading?: boolean;
  warningMessage?: string;
}

export default function ConfirmDialog({
  isOpen,
  onClose,
  onConfirm,
  title,
  message,
  confirmText = 'Confirm',
  cancelText = 'Cancel',
  variant = 'danger',
  loading = false,
  warningMessage,
}: ConfirmDialogProps) {
  const variantClasses = {
    danger: 'text-red-600',
    warning: 'text-yellow-600',
    info: 'text-blue-600',
  };

  const buttonVariants = {
    danger: 'danger' as const,
    warning: 'primary' as const,
    info: 'primary' as const,
  };

  return (
    <Modal
      isOpen={isOpen}
      onClose={onClose}
      title={title}
      size="md"
    >
      <div className="space-y-4">
        <div className="flex items-start gap-4">
          <div className={`flex-shrink-0 ${variantClasses[variant]}`}>
            <Icon icon={faExclamationTriangle} size="lg" />
          </div>
          <div className="flex-1">
            <p className="text-sm text-gray-700">{message}</p>
            {warningMessage && (
              <div className="mt-3 bg-yellow-50 border border-yellow-200 rounded-sm p-3">
                <p className="text-sm text-yellow-800">{warningMessage}</p>
              </div>
            )}
          </div>
        </div>

        <div className="flex items-center gap-3 justify-end pt-4 border-t border-gray-200">
          <Button
            variant="outline"
            onClick={onClose}
            disabled={loading}
          >
            {cancelText}
          </Button>
          <Button
            variant={buttonVariants[variant]}
            onClick={onConfirm}
            loading={loading}
          >
            {confirmText}
          </Button>
        </div>
      </div>
    </Modal>
  );
}

