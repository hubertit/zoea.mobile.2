'use client';

import { useState, useEffect } from 'react';
import Icon, { faUserShield, faUsers, faEnvelope, faPhone } from '../../../components/Icon';
import DataTable from '../../../components/DataTable';
import ChartWrapper from '../../../components/ChartWrapper';
import PieChart from '../../../components/charts/PieChart';

export default function UserAdminsPage() {
  const [loading, setLoading] = useState(true);
  const [admins, setAdmins] = useState<any[]>([]);

  useEffect(() => {
    setTimeout(() => {
      setAdmins([
        {
          id: 1,
          name: 'Admin User',
          email: 'admin@zoea.com',
          phone: '+250788123456',
          role: 'Super Admin',
          status: 'active',
          last_login: '2025-01-20',
        },
        {
          id: 2,
          name: 'John Admin',
          email: 'john.admin@zoea.com',
          phone: '+250788234567',
          role: 'Admin',
          status: 'active',
          last_login: '2025-01-19',
        },
        {
          id: 3,
          name: 'Jane Manager',
          email: 'jane.manager@zoea.com',
          phone: '+250788345678',
          role: 'Manager',
          status: 'active',
          last_login: '2025-01-18',
        },
      ]);
      setLoading(false);
    }, 500);
  }, []);

  const columns = [
    { key: 'name', label: 'Name', sortable: true },
    { key: 'email', label: 'Email', sortable: true },
    { key: 'phone', label: 'Phone', sortable: true },
    { key: 'role', label: 'Role', sortable: true },
    {
      key: 'status',
      label: 'Status',
      sortable: true,
      render: (value: string) => (
        <span className={`px-2 py-1 rounded-full text-xs font-medium ${
          value === 'active' ? 'bg-green-100 text-green-800' : 'bg-gray-100 text-gray-800'
        }`}>
          {value}
        </span>
      ),
    },
    { key: 'last_login', label: 'Last Login', sortable: true, render: (value: string) => new Date(value).toLocaleDateString() },
  ];

  const totalAdmins = admins.length;
  const activeAdmins = admins.filter(a => a.status === 'active').length;

  return (
    <div>
      <div className="mb-8">
        <h1 className="text-3xl font-bold text-gray-900 mb-2">Administrators</h1>
        <p className="text-gray-600">Manage and view all system administrators</p>
      </div>

      {/* Summary Stats */}
      <div className="grid grid-cols-1 md:grid-cols-3 gap-6 mb-6">
        <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-6">
          <div className="flex items-center gap-3 mb-2">
            <Icon icon={faUserShield} className="text-primary" />
            <p className="text-sm text-gray-500">Total Admins</p>
          </div>
          <p className="text-2xl font-bold text-gray-900">{totalAdmins}</p>
        </div>
        <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-6">
          <div className="flex items-center gap-3 mb-2">
            <Icon icon={faUsers} className="text-green-600" />
            <p className="text-sm text-gray-500">Active Admins</p>
          </div>
          <p className="text-2xl font-bold text-gray-900">{activeAdmins}</p>
        </div>
        <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-6">
          <div className="flex items-center gap-3 mb-2">
            <Icon icon={faUserShield} className="text-primary" />
            <p className="text-sm text-gray-500">Super Admins</p>
          </div>
          <p className="text-2xl font-bold text-gray-900">
            {admins.filter(a => a.role === 'Super Admin').length}
          </p>
        </div>
      </div>

      {/* Charts */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6 mb-6">
        <ChartWrapper title="Admins by Role" loading={loading}>
          <PieChart
            data={[
              { name: 'Super Admin', value: admins.filter(a => a.role === 'Super Admin').length },
              { name: 'Admin', value: admins.filter(a => a.role === 'Admin').length },
              { name: 'Manager', value: admins.filter(a => a.role === 'Manager').length },
            ]}
            height={300}
          />
        </ChartWrapper>

        <ChartWrapper title="Admin Status" loading={loading}>
          <PieChart
            data={[
              { name: 'Active', value: activeAdmins },
              { name: 'Inactive', value: totalAdmins - activeAdmins },
            ]}
            height={300}
          />
        </ChartWrapper>
      </div>

      {/* Data Table */}
      <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-6">
        <h2 className="text-lg font-semibold text-gray-900 mb-4">All Administrators</h2>
        <DataTable
          columns={columns}
          data={admins}
          loading={loading}
        />
      </div>
    </div>
  );
}

