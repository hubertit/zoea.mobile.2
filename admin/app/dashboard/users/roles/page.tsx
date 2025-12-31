'use client';

import { useState, useEffect } from 'react';
import { useRouter } from 'next/navigation';
import Link from 'next/link';
import { RolesAPI, type RoleInfo, type UserRole } from '@/src/lib/api/roles';
import { UsersAPI } from '@/src/lib/api/users';
import Icon, { faUsers, faShieldAlt, faUser, faBuilding, faCalendar, faRoute, faUserShield } from '@/app/components/Icon';
import { toast } from '@/app/components/Toaster';
import { DataTable, Pagination } from '@/app/components';
import Card, { CardHeader, CardBody } from '@/app/components/Card';
import PageSkeleton from '@/app/components/PageSkeleton';

const getRoleIcon = (role: UserRole) => {
  switch (role) {
    case 'explorer':
      return faUser;
    case 'merchant':
      return faBuilding;
    case 'event_organizer':
      return faCalendar;
    case 'tour_operator':
      return faRoute;
    case 'admin':
      return faShieldAlt;
    case 'super_admin':
      return faUserShield;
    default:
      return faUser;
  }
};

const getRoleColor = (role: UserRole) => {
  switch (role) {
    case 'explorer':
      return 'bg-blue-100 text-blue-800';
    case 'merchant':
      return 'bg-green-100 text-green-800';
    case 'event_organizer':
      return 'bg-purple-100 text-purple-800';
    case 'tour_operator':
      return 'bg-orange-100 text-orange-800';
    case 'admin':
      return 'bg-yellow-100 text-yellow-800';
    case 'super_admin':
      return 'bg-red-100 text-red-800';
    default:
      return 'bg-gray-100 text-gray-800';
  }
};

export default function RolesPage() {
  const router = useRouter();
  const [roleStats, setRoleStats] = useState<{ roles: RoleInfo[]; totalRoles: number; totalUsers: number } | null>(null);
  const [selectedRole, setSelectedRole] = useState<UserRole | null>(null);
  const [users, setUsers] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);
  const [usersLoading, setUsersLoading] = useState(false);
  const [page, setPage] = useState(1);
  const [pageSize, setPageSize] = useState(10);
  const [total, setTotal] = useState(0);

  useEffect(() => {
    const fetchRoleStats = async () => {
      setLoading(true);
      try {
        const stats = await RolesAPI.getRoleStats();
        setRoleStats(stats);
      } catch (error: any) {
        console.error('Failed to fetch role stats:', error);
        toast.error(error?.message || 'Failed to load role statistics');
      } finally {
        setLoading(false);
      }
    };

    fetchRoleStats();
  }, []);

  useEffect(() => {
    if (!selectedRole) {
      setUsers([]);
      setTotal(0);
      return;
    }

    const fetchUsers = async () => {
      setUsersLoading(true);
      try {
        const response = await UsersAPI.listUsers({
          page,
          limit: pageSize,
          role: selectedRole,
        });
        
        setUsers(response.data || []);
        setTotal(response.meta?.total || 0);
      } catch (error: any) {
        console.error('Failed to fetch users:', error);
        toast.error(error?.message || 'Failed to load users');
      } finally {
        setUsersLoading(false);
      }
    };

    fetchUsers();
  }, [selectedRole, page, pageSize]);

  if (loading) {
    return <PageSkeleton />;
  }

  const totalPages = Math.ceil(total / pageSize);

  const userColumns = [
    {
      key: 'user',
      label: 'User',
      sortable: false,
      render: (_: any, row: any) => (
        <div>
          <Link href={`/dashboard/users/${row.id}`} className="text-sm font-medium text-[#0e1a30] hover:underline">
            {row.fullName || row.name || row.email || 'N/A'}
          </Link>
          <p className="text-xs text-gray-500">{row.email || row.phoneNumber || ''}</p>
        </div>
      ),
    },
    {
      key: 'roles',
      label: 'Roles',
      sortable: false,
      render: (_: any, row: any) => {
        const roles = row.roles || [];
        return (
          <div className="flex flex-wrap gap-1">
            {roles.map((role: any, idx: number) => {
              const roleCode = typeof role === 'string' ? role : (role.code || role.name || '').toLowerCase();
              return (
                <span
                  key={idx}
                  className={`inline-flex items-center px-2 py-0.5 rounded-full text-xs font-medium ${getRoleColor(roleCode as UserRole)}`}
                >
                  {typeof role === 'string' ? role.replace(/_/g, ' ') : (role.name || roleCode).replace(/_/g, ' ')}
                </span>
              );
            })}
          </div>
        );
      },
    },
    {
      key: 'status',
      label: 'Status',
      sortable: false,
      render: (_: any, row: any) => (
        <div className="flex flex-col gap-1">
          <span className={`inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium w-fit ${
            row.isActive ? 'bg-green-100 text-green-800' : 'bg-gray-100 text-gray-800'
          }`}>
            {row.isActive ? 'Active' : 'Inactive'}
          </span>
          {row.isBlocked && (
            <span className="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium w-fit bg-red-100 text-red-800">
              Blocked
            </span>
          )}
        </div>
      ),
    },
    {
      key: 'joined',
      label: 'Joined',
      sortable: false,
      render: (_: any, row: any) => (
        <p className="text-sm text-gray-900">
          {row.createdAt ? new Date(row.createdAt).toLocaleDateString('en-US', {
            month: 'short',
            day: 'numeric',
            year: 'numeric',
          }) : '-'}
        </p>
      ),
    },
  ];

  return (
    <div className="space-y-6">
      {/* Header */}
      <div>
        <h1 className="text-2xl font-bold text-gray-900">Roles & Permissions</h1>
        <p className="text-gray-600 mt-1">Manage user roles and view role assignments</p>
      </div>

      {/* Role Statistics */}
      {roleStats && (
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
          {roleStats.roles.map((roleInfo) => (
            <Card
              key={roleInfo.role}
              className={`cursor-pointer transition-all hover:border-[#0e1a30] ${
                selectedRole === roleInfo.role ? 'border-2 border-[#0e1a30]' : ''
              }`}
              onClick={() => {
                setSelectedRole(selectedRole === roleInfo.role ? null : roleInfo.role);
                setPage(1);
              }}
            >
              <CardHeader>
                <div className="flex items-center justify-between">
                  <div className="flex items-center gap-3">
                    <div className={`w-10 h-10 rounded-full flex items-center justify-center ${getRoleColor(roleInfo.role)}`}>
                      <Icon icon={getRoleIcon(roleInfo.role)} className="text-white" size="sm" />
                    </div>
                    <div>
                      <h3 className="text-lg font-semibold text-gray-900">{roleInfo.name}</h3>
                      <p className="text-sm text-gray-500">{roleInfo.userCount} users</p>
                    </div>
                  </div>
                </div>
              </CardHeader>
              <CardBody>
                <p className="text-sm text-gray-600 mb-3">{roleInfo.description}</p>
                <div className="space-y-2">
                  <p className="text-xs font-medium text-gray-700">Permissions:</p>
                  <ul className="text-xs text-gray-600 space-y-1">
                    {roleInfo.permissions.slice(0, 3).map((permission, idx) => (
                      <li key={idx} className="flex items-center gap-2">
                        <span className="w-1 h-1 rounded-full bg-[#0e1a30]"></span>
                        {permission}
                      </li>
                    ))}
                    {roleInfo.permissions.length > 3 && (
                      <li className="text-gray-400">+{roleInfo.permissions.length - 3} more</li>
                    )}
                  </ul>
                </div>
              </CardBody>
            </Card>
          ))}
        </div>
      )}

      {/* Users with Selected Role */}
      {selectedRole && roleStats && (
        <Card>
          <CardHeader>
            <div className="flex items-center justify-between">
              <div className="flex items-center gap-3">
                <div className={`w-10 h-10 rounded-full flex items-center justify-center ${getRoleColor(selectedRole)}`}>
                  <Icon icon={getRoleIcon(selectedRole)} className="text-white" size="sm" />
                </div>
                <div>
                  <h2 className="text-lg font-semibold text-gray-900">
                    Users with {roleStats.roles.find(r => r.role === selectedRole)?.name} Role
                  </h2>
                  <p className="text-sm text-gray-500">
                    {total} {total === 1 ? 'user' : 'users'} found
                  </p>
                </div>
              </div>
              <button
                onClick={() => {
                  setSelectedRole(null);
                  setPage(1);
                }}
                className="text-sm text-gray-600 hover:text-gray-900"
              >
                Clear Filter
              </button>
            </div>
          </CardHeader>
          <CardBody>
            <DataTable
              columns={userColumns}
              data={users}
              loading={usersLoading}
              onRowClick={(row) => router.push(`/dashboard/users/${row.id}`)}
              emptyMessage="No users found with this role"
              showNumbering={true}
              numberingStart={(page - 1) * pageSize + 1}
            />

            {totalPages > 1 && (
              <div className="mt-4">
                <Pagination
                  currentPage={page}
                  totalPages={totalPages}
                  onPageChange={setPage}
                />
              </div>
            )}
          </CardBody>
        </Card>
      )}

      {/* Summary Stats */}
      {roleStats && !selectedRole && (
        <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
          <Card>
            <CardBody>
              <div className="flex items-center gap-3">
                <div className="w-12 h-12 bg-[#0e1a30]/10 rounded-full flex items-center justify-center">
                  <Icon icon={faUsers} className="text-[#0e1a30]" size="lg" />
                </div>
                <div>
                  <p className="text-sm text-gray-600">Total Users</p>
                  <p className="text-2xl font-bold text-gray-900">{roleStats.totalUsers}</p>
                </div>
              </div>
            </CardBody>
          </Card>
          <Card>
            <CardBody>
              <div className="flex items-center gap-3">
                <div className="w-12 h-12 bg-[#0e1a30]/10 rounded-full flex items-center justify-center">
                  <Icon icon={faShieldAlt} className="text-[#0e1a30]" size="lg" />
                </div>
                <div>
                  <p className="text-sm text-gray-600">Total Roles</p>
                  <p className="text-2xl font-bold text-gray-900">{roleStats.totalRoles}</p>
                </div>
              </div>
            </CardBody>
          </Card>
          <Card>
            <CardBody>
              <div className="flex items-center gap-3">
                <div className="w-12 h-12 bg-[#0e1a30]/10 rounded-full flex items-center justify-center">
                  <Icon icon={faUserShield} className="text-[#0e1a30]" size="lg" />
                </div>
                <div>
                  <p className="text-sm text-gray-600">Admin Users</p>
                  <p className="text-2xl font-bold text-gray-900">
                    {roleStats.roles
                      .filter(r => r.role === 'admin' || r.role === 'super_admin')
                      .reduce((sum, r) => sum + r.userCount, 0)}
                  </p>
                </div>
              </div>
            </CardBody>
          </Card>
        </div>
      )}
    </div>
  );
}
