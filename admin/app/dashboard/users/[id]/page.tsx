'use client';

import { useState, useEffect } from 'react';
import { useParams, useRouter } from 'next/navigation';
import Link from 'next/link';
import { UsersAPI, type User, type UserRole, type VerificationStatus } from '@/src/lib/api';
import Icon, { 
  faArrowLeft, 
  faEdit, 
  faShieldAlt,
  faEnvelope,
  faPhone,
  faCheck,
  faTimes,
} from '@/app/components/Icon';
import { toast } from '@/app/components/Toaster';
import { Button, Modal } from '@/app/components';
import Card, { CardHeader, CardBody } from '@/app/components/Card';
import Input from '@/app/components/Input';
import Select from '@/app/components/Select';
import StatusBadge from '@/app/components/StatusBadge';

const ROLES: { value: UserRole; label: string }[] = [
  { value: 'explorer', label: 'Explorer' },
  { value: 'merchant', label: 'Merchant' },
  { value: 'event_organizer', label: 'Event Organizer' },
  { value: 'tour_operator', label: 'Tour Operator' },
  { value: 'admin', label: 'Admin' },
  { value: 'super_admin', label: 'Super Admin' },
];

const VERIFICATION_STATUSES: { value: VerificationStatus; label: string }[] = [
  { value: 'unverified', label: 'Unverified' },
  { value: 'pending', label: 'Pending' },
  { value: 'verified', label: 'Verified' },
  { value: 'rejected', label: 'Rejected' },
];

const getStatusBadgeColor = (isActive: boolean, isBlocked: boolean) => {
  if (isBlocked) return 'bg-red-100 text-red-800';
  if (isActive) return 'bg-green-100 text-green-800';
  return 'bg-gray-100 text-gray-800';
};

const getStatusLabel = (isActive: boolean, isBlocked: boolean) => {
  if (isBlocked) return 'Blocked';
  if (isActive) return 'Active';
  return 'Inactive';
};

export default function UserDetailPage() {
  const params = useParams();
  const router = useRouter();
  const userId = params?.id as string | undefined;

  const [user, setUser] = useState<User | null>(null);
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);
  const [assigningRoles, setAssigningRoles] = useState(false);
  const [editMode, setEditMode] = useState(false);
  const [roleModalOpen, setRoleModalOpen] = useState(false);
  const [statusModalOpen, setStatusModalOpen] = useState(false);

  const [formData, setFormData] = useState({
    isActive: true,
    isBlocked: false,
    verificationStatus: 'unverified' as VerificationStatus,
  });

  const [selectedRoles, setSelectedRoles] = useState<UserRole[]>([]);

  useEffect(() => {
    if (!userId) {
      setLoading(false);
      return;
    }

    const fetchUser = async () => {
      setLoading(true);
      try {
        const userData = await UsersAPI.getUserById(userId);
        setUser(userData);
        setFormData({
          isActive: userData.isActive || false,
          isBlocked: userData.isBlocked || false,
          verificationStatus: userData.verificationStatus || 'unverified',
        });
        // Extract roles from user data
        const roles = userData.roles || [];
        const roleValues = roles.map((role) => 
          typeof role === 'string' ? role : (role as any).code || role
        ).filter(Boolean) as UserRole[];
        setSelectedRoles(roleValues);
      } catch (error: any) {
        console.error('Failed to fetch user:', error);
        toast.error(error?.message || 'Failed to load user');
        router.push('/dashboard/users');
      } finally {
        setLoading(false);
      }
    };

    fetchUser();
  }, [userId, router]);

  const handleSaveStatus = async () => {
    if (!userId) return;

    setSaving(true);
    try {
      await UsersAPI.updateUserStatus(userId, {
        isActive: formData.isActive,
        isBlocked: formData.isBlocked,
        verificationStatus: formData.verificationStatus,
      });
      
      // Refresh user data
      const updatedUser = await UsersAPI.getUserById(userId);
      setUser(updatedUser);
      setStatusModalOpen(false);
      setEditMode(false);
      toast.success('User status updated successfully');
    } catch (error: any) {
      console.error('Failed to update user status:', error);
      toast.error(error?.message || 'Failed to update user status');
    } finally {
      setSaving(false);
    }
  };

  const handleAssignRoles = async () => {
    if (!userId) return;

    if (selectedRoles.length === 0) {
      toast.error('Please select at least one role');
      return;
    }

    setAssigningRoles(true);
    try {
      await UsersAPI.updateUserRoles(userId, { roles: selectedRoles });
      
      // Refresh user data
      const updatedUser = await UsersAPI.getUserById(userId);
      setUser(updatedUser);
      setRoleModalOpen(false);
      toast.success('Roles updated successfully');
    } catch (error: any) {
      console.error('Failed to assign roles:', error);
      toast.error(error?.message || 'Failed to assign roles');
    } finally {
      setAssigningRoles(false);
    }
  };

  const handleRoleToggle = (role: UserRole) => {
    setSelectedRoles((prev) =>
      prev.includes(role)
        ? prev.filter((r) => r !== role)
        : [...prev, role]
    );
  };

  if (loading) {
    return (
      <div className="flex items-center justify-center min-h-[400px]">
        <div className="text-center">
          <div className="inline-block animate-spin rounded-full h-12 w-12 border-b-2 border-[#0e1a30] mb-4"></div>
          <p className="text-gray-600">Loading user...</p>
        </div>
      </div>
    );
  }

  if (!user) {
    return null;
  }

  const currentRoles = user.roles || [];
  const currentRoleValues = currentRoles.map((role) => 
    typeof role === 'string' ? role : (role as any).code || role
  ).filter(Boolean) as UserRole[];

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex items-center justify-between flex-wrap gap-4">
        <div className="flex items-center gap-4">
          <Link href="/dashboard/users">
            <Button variant="ghost" size="sm" icon={faArrowLeft}>
              Back
            </Button>
          </Link>
          <div>
            <h1 className="text-2xl font-bold text-gray-900">User Details</h1>
            <p className="text-gray-600 mt-1">
              {user.fullName || 'N/A'} • {user.phoneNumber || 'N/A'}
            </p>
          </div>
        </div>
        <div className="flex items-center gap-2">
          <Button
            onClick={() => {
              setSelectedRoles([...currentRoleValues]);
              setRoleModalOpen(true);
            }}
            variant="secondary"
            size="sm"
            icon={faShieldAlt}
          >
            Manage Roles
          </Button>
          <Button
            onClick={() => {
              setEditMode(true);
              setStatusModalOpen(true);
            }}
            variant="primary"
            size="sm"
            icon={faEdit}
          >
            Update Status
          </Button>
        </div>
      </div>

      {/* User Info */}
      <Card>
        <CardHeader>
          <h2 className="text-lg font-semibold text-gray-900">User Information</h2>
        </CardHeader>
        <CardBody>
          <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
            {/* Name */}
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Full Name
              </label>
              <p className="text-sm text-gray-900">{user.fullName || 'N/A'}</p>
            </div>

            {/* Email */}
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Email
              </label>
              <div className="flex items-center gap-2">
                <Icon icon={faEnvelope} className="text-gray-400" size="sm" />
                <p className="text-sm text-gray-900">{user.email || 'N/A'}</p>
              </div>
            </div>

            {/* Phone */}
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Phone Number
              </label>
              <div className="flex items-center gap-2">
                <Icon icon={faPhone} className="text-gray-400" size="sm" />
                <p className="text-sm text-gray-900">{user.phoneNumber || 'N/A'}</p>
              </div>
            </div>

            {/* Status */}
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Status
              </label>
              <span className={`inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium ${getStatusBadgeColor(user.isActive || false, user.isBlocked || false)}`}>
                {getStatusLabel(user.isActive || false, user.isBlocked || false)}
              </span>
            </div>

            {/* Verification Status */}
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Verification Status
              </label>
              <StatusBadge status={user.verificationStatus || 'unverified'} />
            </div>

            {/* Created At */}
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Created At
              </label>
              <p className="text-sm text-gray-900">
                {user.createdAt ? new Date(user.createdAt).toLocaleDateString('en-US', {
                  year: 'numeric',
                  month: 'long',
                  day: 'numeric',
                }) : 'N/A'}
              </p>
            </div>

            {/* Country/City */}
            {user.country && (
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  Location
                </label>
                <p className="text-sm text-gray-900">
                  {user.city?.name || ''} {user.city?.name && user.country?.name ? ', ' : ''}
                  {user.country?.name || ''}
                </p>
              </div>
            )}
          </div>
        </CardBody>
      </Card>

      {/* Roles */}
      <Card>
        <CardHeader>
          <div className="flex items-center justify-between">
            <h2 className="text-lg font-semibold text-gray-900">Roles</h2>
          </div>
        </CardHeader>
        <CardBody>
          <div className="flex flex-wrap gap-2">
            {currentRoleValues.length > 0 ? (
              currentRoleValues.map((role, index) => (
                <span
                  key={index}
                  className="inline-flex items-center px-3 py-1 rounded-full text-sm font-medium bg-blue-100 text-blue-800"
                >
                  {role.replace(/_/g, ' ')}
                </span>
              ))
            ) : (
              <p className="text-sm text-gray-500">No roles assigned</p>
            )}
          </div>
        </CardBody>
      </Card>

      {/* Status Update Modal */}
      <Modal
        isOpen={statusModalOpen}
        onClose={() => {
          setStatusModalOpen(false);
          setEditMode(false);
          setFormData({
            isActive: user.isActive || false,
            isBlocked: user.isBlocked || false,
            verificationStatus: user.verificationStatus || 'unverified',
          });
        }}
        title="Update User Status"
        size="md"
      >
        <div className="space-y-4">
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">
              Active Status
            </label>
            <div className="flex items-center gap-4">
              <label className="flex items-center gap-2">
                <input
                  type="checkbox"
                  checked={formData.isActive}
                  onChange={(e) => setFormData({ ...formData, isActive: e.target.checked })}
                  className="w-4 h-4 text-[#0e1a30] border-gray-300 rounded focus:ring-[#0e1a30]"
                />
                <span className="text-sm text-gray-700">Active</span>
              </label>
              <label className="flex items-center gap-2">
                <input
                  type="checkbox"
                  checked={formData.isBlocked}
                  onChange={(e) => setFormData({ ...formData, isBlocked: e.target.checked })}
                  className="w-4 h-4 text-[#0e1a30] border-gray-300 rounded focus:ring-[#0e1a30]"
                />
                <span className="text-sm text-gray-700">Blocked</span>
              </label>
            </div>
          </div>

          <div>
            <Select
              label="Verification Status"
              value={formData.verificationStatus}
              onChange={(e) => setFormData({ ...formData, verificationStatus: e.target.value as VerificationStatus })}
              options={VERIFICATION_STATUSES.map((s) => ({ value: s.value, label: s.label }))}
            />
          </div>

          <div className="flex items-center gap-2 justify-end pt-4 border-t border-gray-200">
            <Button
              variant="secondary"
              size="md"
              onClick={() => {
                setStatusModalOpen(false);
                setEditMode(false);
                setFormData({
                  isActive: user.isActive || false,
                  isBlocked: user.isBlocked || false,
                  verificationStatus: user.verificationStatus || 'unverified',
                });
              }}
              disabled={saving}
            >
              Cancel
            </Button>
            <Button
              variant="primary"
              size="md"
              onClick={handleSaveStatus}
              loading={saving}
            >
              Save Changes
            </Button>
          </div>
        </div>
      </Modal>

      {/* Role Assignment Modal */}
      <Modal
        isOpen={roleModalOpen}
        onClose={() => {
          setRoleModalOpen(false);
          setSelectedRoles([...currentRoleValues]);
        }}
        title="Manage Roles"
        size="lg"
      >
        <div className="space-y-4">
          <p className="text-sm text-gray-600 mb-4">
            Select roles to assign to {user.fullName || 'this user'}
          </p>
          <div className="grid grid-cols-2 md:grid-cols-3 gap-3">
            {ROLES.map((role) => (
              <label
                key={role.value}
                className={`flex items-center gap-2 p-3 border-2 rounded-sm cursor-pointer transition-all ${
                  selectedRoles.includes(role.value)
                    ? 'border-[#0e1a30] bg-[#0e1a30]/5'
                    : 'border-gray-200 hover:border-gray-300'
                }`}
              >
                <input
                  type="checkbox"
                  checked={selectedRoles.includes(role.value)}
                  onChange={() => handleRoleToggle(role.value)}
                  className="w-4 h-4 text-[#0e1a30] border-gray-300 rounded focus:ring-[#0e1a30]"
                />
                <span className="text-sm font-medium text-gray-700">{role.label}</span>
              </label>
            ))}
          </div>
          <div className="flex items-center gap-2 justify-end pt-4 border-t border-gray-200">
            <Button
              variant="secondary"
              size="md"
              onClick={() => {
                setRoleModalOpen(false);
                setSelectedRoles([...currentRoleValues]);
              }}
              disabled={assigningRoles}
            >
              Cancel
            </Button>
            <Button
              variant="primary"
              size="md"
              onClick={handleAssignRoles}
              disabled={assigningRoles || selectedRoles.length === 0}
              loading={assigningRoles}
            >
              Assign Roles
            </Button>
          </div>
        </div>
      </Modal>
    </div>
  );
}

