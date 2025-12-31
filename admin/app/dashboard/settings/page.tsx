'use client';

import { useState } from 'react';
import Card, { CardHeader, CardBody } from '@/app/components/Card';
import { Button, Input, Select, Textarea } from '@/app/components';
import Icon, { faCog, faSave, faInfoCircle } from '@/app/components/Icon';
import { toast } from '@/app/components/Toaster';

export default function SettingsPage() {
  const [saving, setSaving] = useState(false);
  const [settings, setSettings] = useState({
    siteName: 'Zoea',
    siteDescription: 'Discover amazing places and experiences',
    adminEmail: 'admin@zoea.africa',
    supportEmail: 'support@zoea.africa',
    defaultCurrency: 'RWF',
    defaultLanguage: 'en',
    timezone: 'Africa/Kigali',
    maintenanceMode: false,
    allowRegistration: true,
    requireEmailVerification: false,
  });

  const handleSave = async () => {
    setSaving(true);
    try {
      // TODO: Implement actual API call
      // await apiClient.put('/admin/settings', settings);
      
      // Simulate save
      await new Promise((resolve) => setTimeout(resolve, 1000));
      
      toast.success('Settings saved successfully');
    } catch (error: any) {
      console.error('Failed to save settings:', error);
      toast.error(error?.message || 'Failed to save settings');
    } finally {
      setSaving(false);
    }
  };

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex items-center justify-between flex-wrap gap-4">
        <div>
          <h1 className="text-2xl font-bold text-gray-900">Settings</h1>
          <p className="text-gray-600 mt-1">System settings and configuration</p>
        </div>
        <Button
          onClick={handleSave}
          disabled={saving}
          className="flex items-center gap-2"
        >
          <Icon icon={faSave} size="sm" />
          {saving ? 'Saving...' : 'Save Settings'}
        </Button>
      </div>

      {/* General Settings */}
      <Card>
        <CardHeader>
          <div className="flex items-center gap-2">
            <Icon icon={faCog} className="text-[#0e1a30]" size="sm" />
            <h2 className="text-lg font-semibold text-gray-900">General Settings</h2>
          </div>
        </CardHeader>
        <CardBody>
          <div className="space-y-4">
            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
              <Input
                label="Site Name"
                value={settings.siteName}
                onChange={(e) => setSettings({ ...settings, siteName: e.target.value })}
                placeholder="Enter site name"
              />
              <Input
                label="Admin Email"
                value={settings.adminEmail}
                onChange={(e) => setSettings({ ...settings, adminEmail: e.target.value })}
                placeholder="admin@example.com"
                type="email"
              />
            </div>
            <Textarea
              label="Site Description"
              value={settings.siteDescription}
              onChange={(e) => setSettings({ ...settings, siteDescription: e.target.value })}
              placeholder="Enter site description"
              rows={3}
            />
            <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
              <Input
                label="Support Email"
                value={settings.supportEmail}
                onChange={(e) => setSettings({ ...settings, supportEmail: e.target.value })}
                placeholder="support@example.com"
                type="email"
              />
              <Select
                label="Default Currency"
                value={settings.defaultCurrency}
                onChange={(e) => setSettings({ ...settings, defaultCurrency: e.target.value })}
                options={[
                  { value: 'RWF', label: 'RWF - Rwandan Franc' },
                  { value: 'USD', label: 'USD - US Dollar' },
                  { value: 'EUR', label: 'EUR - Euro' },
                ]}
              />
              <Select
                label="Default Language"
                value={settings.defaultLanguage}
                onChange={(e) => setSettings({ ...settings, defaultLanguage: e.target.value })}
                options={[
                  { value: 'en', label: 'English' },
                  { value: 'fr', label: 'Français' },
                  { value: 'rw', label: 'Kinyarwanda' },
                ]}
              />
            </div>
            <Input
              label="Timezone"
              value={settings.timezone}
              onChange={(e) => setSettings({ ...settings, timezone: e.target.value })}
              placeholder="Africa/Kigali"
            />
          </div>
        </CardBody>
      </Card>

      {/* System Settings */}
      <Card>
        <CardHeader>
          <h2 className="text-lg font-semibold text-gray-900">System Settings</h2>
        </CardHeader>
        <CardBody>
          <div className="space-y-4">
            <div className="flex items-center justify-between p-4 bg-gray-50 rounded-sm">
              <div>
                <p className="text-sm font-medium text-gray-900">Maintenance Mode</p>
                <p className="text-xs text-gray-500">Enable maintenance mode to restrict access</p>
              </div>
              <label className="relative inline-flex items-center cursor-pointer">
                <input
                  type="checkbox"
                  checked={settings.maintenanceMode}
                  onChange={(e) => setSettings({ ...settings, maintenanceMode: e.target.checked })}
                  className="sr-only peer"
                />
                <div className="w-11 h-6 bg-gray-200 peer-focus:outline-none peer-focus:ring-2 peer-focus:ring-[#0e1a30] rounded-full peer peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:left-[2px] after:bg-white after:border-gray-300 after:border after:rounded-full after:h-5 after:w-5 after:transition-all peer-checked:bg-[#0e1a30]"></div>
              </label>
            </div>
            <div className="flex items-center justify-between p-4 bg-gray-50 rounded-sm">
              <div>
                <p className="text-sm font-medium text-gray-900">Allow User Registration</p>
                <p className="text-xs text-gray-500">Enable or disable new user registrations</p>
              </div>
              <label className="relative inline-flex items-center cursor-pointer">
                <input
                  type="checkbox"
                  checked={settings.allowRegistration}
                  onChange={(e) => setSettings({ ...settings, allowRegistration: e.target.checked })}
                  className="sr-only peer"
                />
                <div className="w-11 h-6 bg-gray-200 peer-focus:outline-none peer-focus:ring-2 peer-focus:ring-[#0e1a30] rounded-full peer peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:left-[2px] after:bg-white after:border-gray-300 after:border after:rounded-full after:h-5 after:w-5 after:transition-all peer-checked:bg-[#0e1a30]"></div>
              </label>
            </div>
            <div className="flex items-center justify-between p-4 bg-gray-50 rounded-sm">
              <div>
                <p className="text-sm font-medium text-gray-900">Require Email Verification</p>
                <p className="text-xs text-gray-500">Require users to verify their email address</p>
              </div>
              <label className="relative inline-flex items-center cursor-pointer">
                <input
                  type="checkbox"
                  checked={settings.requireEmailVerification}
                  onChange={(e) => setSettings({ ...settings, requireEmailVerification: e.target.checked })}
                  className="sr-only peer"
                />
                <div className="w-11 h-6 bg-gray-200 peer-focus:outline-none peer-focus:ring-2 peer-focus:ring-[#0e1a30] rounded-full peer peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:left-[2px] after:bg-white after:border-gray-300 after:border after:rounded-full after:h-5 after:w-5 after:transition-all peer-checked:bg-[#0e1a30]"></div>
              </label>
            </div>
          </div>
        </CardBody>
      </Card>

      {/* Info Card */}
      <Card>
        <CardBody>
          <div className="flex items-start gap-3 p-4 bg-blue-50 rounded-sm">
            <Icon icon={faInfoCircle} className="text-blue-600 mt-0.5" size="sm" />
            <div>
              <p className="text-sm font-medium text-blue-900">Settings Management</p>
              <p className="text-xs text-blue-700 mt-1">
                System settings will be saved and applied immediately. Some settings may require a server restart to take full effect.
              </p>
            </div>
          </div>
        </CardBody>
      </Card>
    </div>
  );
}
