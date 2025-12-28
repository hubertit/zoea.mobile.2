'use client';

import { useState } from 'react';
import FormInput from '../../components/FormInput';
import Icon, { faSave, faCog, faUser, faBell, faShield, faPalette } from '../../components/Icon';

export default function SettingsPage() {
  const [activeTab, setActiveTab] = useState('general');
  const [loading, setLoading] = useState(false);
  const [settings, setSettings] = useState({
    siteName: 'Zoea Admin',
    siteUrl: 'https://admin.zoea.africa',
    adminEmail: 'admin@zoea.africa',
    timezone: 'Africa/Kigali',
    language: 'en',
    dateFormat: 'YYYY-MM-DD',
    itemsPerPage: '25',
    enableNotifications: true,
    emailNotifications: true,
    pushNotifications: false,
    theme: 'light',
    primaryColor: '#181E29',
  });

  const handleChange = (e: React.ChangeEvent<HTMLInputElement | HTMLTextAreaElement | HTMLSelectElement>) => {
    const { name, value, type } = e.target;
    setSettings({
      ...settings,
      [name]: type === 'checkbox' ? (e.target as HTMLInputElement).checked : value,
    });
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);
    setTimeout(() => {
      console.log('Saving settings:', settings);
      setLoading(false);
      alert('Settings saved successfully!');
    }, 1000);
  };

  const tabs = [
    { id: 'general', label: 'General', icon: faCog },
    { id: 'profile', label: 'Profile', icon: faUser },
    { id: 'notifications', label: 'Notifications', icon: faBell },
    { id: 'security', label: 'Security', icon: faShield },
    { id: 'appearance', label: 'Appearance', icon: faPalette },
  ];

  return (
    <div>
      <div className="mb-8">
        <h1 className="text-3xl font-bold text-gray-900 mb-2">Settings</h1>
        <p className="text-gray-600">Manage your admin panel settings and preferences.</p>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-4 gap-6">
        {/* Sidebar Tabs */}
        <div className="lg:col-span-1">
          <div className="bg-white rounded-sm shadow-sm border border-gray-200 p-2">
            {tabs.map((tab) => (
              <button
                key={tab.id}
                onClick={() => setActiveTab(tab.id)}
                className={`w-full flex items-center gap-3 px-4 py-3 rounded-sm transition-colors mb-1 ${
                  activeTab === tab.id
                    ? 'bg-primary/10 text-primary'
                    : 'text-gray-700 hover:bg-gray-50'
                }`}
              >
                <Icon icon={tab.icon} size="sm" />
                <span className="font-medium">{tab.label}</span>
              </button>
            ))}
          </div>
        </div>

        {/* Content */}
        <div className="lg:col-span-3">
          <form onSubmit={handleSubmit} className="bg-white rounded-sm shadow-sm border border-gray-200 p-6">
            {activeTab === 'general' && (
              <div className="space-y-6">
                <h2 className="text-xl font-semibold text-gray-900 mb-4">General Settings</h2>
                <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                  <FormInput
                    label="Site Name"
                    name="siteName"
                    value={settings.siteName}
                    onChange={handleChange}
                  />
                  <FormInput
                    label="Site URL"
                    name="siteUrl"
                    value={settings.siteUrl}
                    onChange={handleChange}
                  />
                  <FormInput
                    label="Admin Email"
                    name="adminEmail"
                    type="email"
                    value={settings.adminEmail}
                    onChange={handleChange}
                  />
                  <FormInput
                    label="Timezone"
                    name="timezone"
                    type="select"
                    value={settings.timezone}
                    onChange={handleChange}
                    options={[
                      { value: 'Africa/Kigali', label: 'Africa/Kigali (GMT+2)' },
                      { value: 'UTC', label: 'UTC (GMT+0)' },
                    ]}
                  />
                  <FormInput
                    label="Language"
                    name="language"
                    type="select"
                    value={settings.language}
                    onChange={handleChange}
                    options={[
                      { value: 'en', label: 'English' },
                      { value: 'fr', label: 'French' },
                      { value: 'rw', label: 'Kinyarwanda' },
                    ]}
                  />
                  <FormInput
                    label="Items Per Page"
                    name="itemsPerPage"
                    type="select"
                    value={settings.itemsPerPage}
                    onChange={handleChange}
                    options={[
                      { value: '10', label: '10' },
                      { value: '25', label: '25' },
                      { value: '50', label: '50' },
                      { value: '100', label: '100' },
                    ]}
                  />
                </div>
              </div>
            )}

            {activeTab === 'profile' && (
              <div className="space-y-6">
                <h2 className="text-xl font-semibold text-gray-900 mb-4">Profile Settings</h2>
                <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                  <FormInput
                    label="Display Name"
                    name="displayName"
                    value="Administrator"
                    onChange={handleChange}
                  />
                  <FormInput
                    label="Email"
                    name="email"
                    type="email"
                    value={settings.adminEmail}
                    onChange={handleChange}
                  />
                </div>
              </div>
            )}

            {activeTab === 'notifications' && (
              <div className="space-y-6">
                <h2 className="text-xl font-semibold text-gray-900 mb-4">Notification Settings</h2>
                <div className="space-y-4">
                  <label className="flex items-center gap-3 cursor-pointer">
                    <input
                      type="checkbox"
                      name="enableNotifications"
                      checked={settings.enableNotifications}
                      onChange={handleChange}
                      className="w-5 h-5 text-primary rounded focus:ring-primary"
                    />
                    <span className="text-gray-900">Enable Notifications</span>
                  </label>
                  <label className="flex items-center gap-3 cursor-pointer">
                    <input
                      type="checkbox"
                      name="emailNotifications"
                      checked={settings.emailNotifications}
                      onChange={handleChange}
                      className="w-5 h-5 text-primary rounded focus:ring-primary"
                    />
                    <span className="text-gray-900">Email Notifications</span>
                  </label>
                  <label className="flex items-center gap-3 cursor-pointer">
                    <input
                      type="checkbox"
                      name="pushNotifications"
                      checked={settings.pushNotifications}
                      onChange={handleChange}
                      className="w-5 h-5 text-primary rounded focus:ring-primary"
                    />
                    <span className="text-gray-900">Push Notifications</span>
                  </label>
                </div>
              </div>
            )}

            {activeTab === 'security' && (
              <div className="space-y-6">
                <h2 className="text-xl font-semibold text-gray-900 mb-4">Security Settings</h2>
                <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                  <FormInput
                    label="Current Password"
                    name="currentPassword"
                    type="password"
                    value=""
                    onChange={handleChange}
                    placeholder="Enter current password"
                  />
                  <FormInput
                    label="New Password"
                    name="newPassword"
                    type="password"
                    value=""
                    onChange={handleChange}
                    placeholder="Enter new password"
                  />
                </div>
                <div className="bg-yellow-50 border border-yellow-200 rounded-sm p-4">
                  <p className="text-sm text-yellow-800">
                    <strong>Security Tip:</strong> Use a strong password with at least 8 characters, including uppercase, lowercase, numbers, and special characters.
                  </p>
                </div>
              </div>
            )}

            {activeTab === 'appearance' && (
              <div className="space-y-6">
                <h2 className="text-xl font-semibold text-gray-900 mb-4">Appearance Settings</h2>
                <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                  <FormInput
                    label="Theme"
                    name="theme"
                    type="select"
                    value={settings.theme}
                    onChange={handleChange}
                    options={[
                      { value: 'light', label: 'Light' },
                      { value: 'dark', label: 'Dark' },
                      { value: 'auto', label: 'Auto' },
                    ]}
                  />
                  <FormInput
                    label="Primary Color"
                    name="primaryColor"
                    type="color"
                    value={settings.primaryColor}
                    onChange={handleChange}
                  />
                </div>
              </div>
            )}

            <div className="flex items-center gap-4 pt-6 mt-6 border-t border-gray-200">
              <button
                type="submit"
                disabled={loading}
                className="flex items-center gap-2 bg-primary text-white px-6 py-3 rounded-sm hover:bg-primary-600 transition-colors disabled:opacity-50 disabled:cursor-not-allowed"
              >
                <Icon icon={faSave} />
                <span>{loading ? 'Saving...' : 'Save Settings'}</span>
              </button>
            </div>
          </form>
        </div>
      </div>
    </div>
  );
}

