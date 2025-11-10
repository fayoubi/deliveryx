import { ExclamationTriangleIcon } from '@heroicons/react/24/outline';
import Modal from './Modal';
import Button from './Button';

/**
 * Confirmation Dialog Component
 * Used for delete confirmations and other destructive actions
 */
const ConfirmDialog = ({
  isOpen,
  onClose,
  onConfirm,
  title = 'Confirm Action',
  message,
  confirmText = 'Confirm',
  cancelText = 'Cancel',
  loading = false,
  variant = 'danger',
}) => {
  return (
    <Modal isOpen={isOpen} onClose={onClose} size="sm" showCloseButton={false}>
      <div className="flex flex-col items-center text-center">
        {/* Warning Icon */}
        <div className={`flex items-center justify-center w-16 h-16 rounded-full mb-4 ${
          variant === 'danger' ? 'bg-danger-100' : 'bg-yellow-100'
        }`}>
          <ExclamationTriangleIcon className={`h-8 w-8 ${
            variant === 'danger' ? 'text-danger-600' : 'text-yellow-600'
          }`} />
        </div>

        {/* Title */}
        <h3 className="text-lg font-semibold text-secondary-900 mb-2">
          {title}
        </h3>

        {/* Message */}
        <p className="text-secondary-600 mb-6">
          {message}
        </p>

        {/* Actions */}
        <div className="flex gap-3 w-full">
          <Button
            variant="secondary"
            onClick={onClose}
            disabled={loading}
            className="flex-1"
          >
            {cancelText}
          </Button>
          <Button
            variant={variant}
            onClick={onConfirm}
            loading={loading}
            className="flex-1"
          >
            {confirmText}
          </Button>
        </div>
      </div>
    </Modal>
  );
};

export default ConfirmDialog;
