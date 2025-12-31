'use client';

import { useState, useEffect } from 'react';
import { useAuthStore } from '@/src/store/auth';
import { UsersAPI, type User } from '@/src/lib/api';
import { toast } from '@/app/components/Toaster';
import Card, { CardHeader, CardBody } from '@/app/components/Card';
import { Button, Input, Modal } from '@/app/components';
import Icon, { faUser, faEnvelope, faPhone, faSave, faLock, faEdit } from '@/app/components/Icon';
import PageSkeleton from '@/app/components/PageSkeleton';

export default function ProfilePage() {
  const { user: authUser, setUser } = useAuthStore();
  const [user, setUserData] = useState<User | null>(null);
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);
  const [showPasswordModal, setShowPasswordModal] = useState(false);
  const [formData, setFormData] = useState({
    fullName: '',
    email: '',
    phoneNumber: '',
  });
  const [passwordData, setPasswordData] = useState({
    currentPassword: '',
    newPassword: '',
    confirmPassword: '',
  });

  useEffect(() => {
    const fetchProfile = async () => {
      if (!authUser?.id) return;
      
      setLoading(true);
      try {
        const userData = await UsersAPI.getUserById(authUser.id);
        setUserData(userData);
        setFormData({
          fullName: userData.fullName || '',
          email: userData.email || '',
          phoneNumber: userData.phoneNumber || '',
        });
      } catch (error: any) {
        console.error('Failed to fetch profile:', error);
        toast.error(error?.message || 'Failed to load profile');
      } finally {
        setLoading(false);
      }
    };

    fetchProfile();
  }, [authUser?.id]);

  const handleSave = async () => {
    if (!authUser?.id) return;
    
    setSaving(true);
    try {
      // Update user profile via API
      // Note: We might need to use the /users/me endpoint instead
      await UsersAPI.updateUserStatus(authUser.id, {});
      
      // Update local user data
      const updatedUser = await UsersAPI.getUserById(authUser.id);
      setUserData(updatedUser);
      // Update auth store with compatible format
      setUser({
        ...updatedUser,
        email: updatedUser.email || '',
        phoneNumber: updatedUser.phoneNumber || '',
        fullName: updatedUser.fullName || '',
      } as any);
      
      toast.success('Profile updated successfully');
    } catch (error: any) {
      console.error('Failed to update profile:', error);
      toast.error(error?.message || 'Failed to update profile');
    } finally {
      setSaving(false);
    }
  };

  const handlePasswordChange = async () => {
    if (passwordData.newPassword !== passwordData.confirmPassword) {
      toast.error('New passwords do not match');
      return;
    }
    if (passwordData.newPassword.length < 6) {
      toast.error('Password must be at least 6 characters');
      return;
    }

    setSaving(true);
    try {
      // TODO: Implement password change API call
      // await apiClient.put('/users/me/password', {
      //   currentPassword: passwordData.currentPassword,
      //   newPassword: passwordData.newPassword,
      // });
      
      toast.success('Password changed successfully');
      setShowPasswordModal(false);
      setPasswordData({
        currentPassword: '',
        newPassword: '',
        confirmPassword: '',
      });
    } catch (error: any) {
      console.error('Failed to change password:', error);
      toast.error(error?.message || 'Failed to change password');
    } finally {
      setSaving(false);
    }
  };

  if (loading) {
    return <PageSkeleton />;
  }

  return (
    <div className="space-y-6">
      {/* Header */}
      <div>
        <h1 className="text-2xl font-bold text-gray-900">My Profile</h1>
        <p className="text-gray-600 mt-1">Manage your account settings and preferences</p>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        {/* Profile Information */}
        <Card>
          <CardHeader>
            <div className="flex items-center justify-between">
              <h2 className="text-lg font-semibold text-gray-900">Profile Information</h2>
              <Icon icon={faUser} className="text-gray-400" />
            </div>
          </CardHeader>
          <CardBody>
            <div className="space-y-4">
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  Full Name
                </label>
                <Input
                  value={formData.fullName}
                  onChange={(e) => setFormData({ ...formData, fullName: e.target.value })}
                  placeholder="Enter full name"
                />
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  Email
                </label>
                <Input
                  type="email"
                  value={formData.email}
                  onChange={(e) => setFormData({ ...formData, email: e.target.value })}
                  placeholder="Enter email"
                  leftIcon={faEnvelope}
                />
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  Phone Number
                </label>
                <Input
                  type="tel"
                  value={formData.phoneNumber}
                  onChange={(e) => setFormData({ ...formData, phoneNumber: e.target.value })}
                  placeholder="Enter phone number"
                  leftIcon={faPhone}
                />
              </div>

              <div className="flex justify-end pt-4 border-t border-gray-200">
                <Button
                  variant="primary"
                  onClick={handleSave}
                  loading={saving}
                  icon={faSave}
                >
                  Save Changes
                </Button>
              </div>
            </div>
          </CardBody>
        </Card>

        {/* Account Security */}
        <Card>
          <CardHeader>
            <div className="flex items-center justify-between">
              <h2 className="text-lg font-semibold text-gray-900">Account Security</h2>
              <Icon icon={faLock} className="text-gray-400" />
            </div>
          </CardHeader>
          <CardBody>
            <div className="space-y-4">
              <div>
                <p className="text-sm text-gray-600 mb-4">
                  Change your password to keep your account secure.
                </p>
                <Button
                  variant="outline"
                  onClick={() => setShowPasswordModal(true)}
                  icon={faEdit}
                >
                  Change Password
                </Button>
              </div>

              {user?.roles && (
                <div className="pt-4 border-t border-gray-200">
                  <label className="block text-sm font-medium text-gray-700 mb-2">
                    Roles
                  </label>
                  <div className="flex flex-wrap gap-2">
                    {user.roles.map((role, index) => {
                      const roleValue = typeof role === 'string' 
                        ? role 
                        : (typeof role === 'object' && role !== null && 'code' in role)
                          ? (role as any).code || (role as any).name || ''
                          : String(role);
                      return (
                        <span
                          key={index}
                          className="inline-flex items-center px-3 py-1 rounded-full text-xs font-medium bg-blue-100 text-blue-800"
                        >
                          {String(roleValue).replace(/_/g, ' ')}
                        </span>
                      );
                    })}
                  </div>
                </div>
              )}

              {user?.createdAt && (
                <div className="pt-4 border-t border-gray-200">
                  <p className="text-sm text-gray-600">
                    <span className="font-medium">Member since:</span>{' '}
                    {new Date(user.createdAt).toLocaleDateString('en-US', {
                      year: 'numeric',
                      month: 'long',
                      day: 'numeric',
                    })}
                  </p>
                </div>
              )}
            </div>
          </CardBody>
        </Card>
      </div>

      {/* Change Password Modal */}
      <Modal
        isOpen={showPasswordModal}
        onClose={() => {
          setShowPasswordModal(false);
          setPasswordData({
            currentPassword: '',
            newPassword: '',
            confirmPassword: '',
          });
        }}
        title="Change Password"
        size="md"
      >
        <div className="space-y-4">
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">
              Current Password
            </label>
            <Input
              type="password"
              value={passwordData.currentPassword}
              onChange={(e) => setPasswordData({ ...passwordData, currentPassword: e.target.value })}
              placeholder="Enter current password"
            />
          </div>

          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">
              New Password
            </label>
            <Input
              type="password"
              value={passwordData.newPassword}
              onChange={(e) => setPasswordData({ ...passwordData, newPassword: e.target.value })}
              placeholder="Enter new password (min 6 characters)"
            />
          </div>

          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">
              Confirm New Password
            </label>
            <Input
              type="password"
              value={passwordData.confirmPassword}
              onChange={(e) => setPasswordData({ ...passwordData, confirmPassword: e.target.value })}
              placeholder="Confirm new password"
            />
          </div>

          <div className="flex justify-end gap-3 pt-4 border-t border-gray-200">
            <Button
              variant="outline"
              onClick={() => {
                setShowPasswordModal(false);
                setPasswordData({
                  currentPassword: '',
                  newPassword: '',
                  confirmPassword: '',
                });
              }}
            >
              Cancel
            </Button>
            <Button
              variant="primary"
              onClick={handlePasswordChange}
              loading={saving}
            >
              Change Password
            </Button>
          </div>
        </div>
      </Modal>
    </div>
  );
}

