'use client';

import { useState, useEffect } from 'react';
import { useRouter } from 'next/navigation';
import Link from 'next/link';
import { UsersAPI, type User, type UserRole, type VerificationStatus } from '@/src/lib/api';
import Icon, { faSearch, faPlus, faTimes, faUser } from '@/app/components/Icon';
import { toast } from '@/app/components/Toaster';
import { DataTable, Pagination, Button } from '@/app/components';
import PageSkeleton from '@/app/components/PageSkeleton';
import { useDebounce } from '@/src/hooks/useDebounce';

const STATUSES = [
  { value: '', label: 'All Status' },
  { value: 'active', label: 'Active' },
  { value: 'inactive', label: 'Inactive' },
];

const ROLES: { value: UserRole | ''; label: string }[] = [
  { value: '', label: 'All Roles' },
  { value: 'explorer', label: 'Explorer' },
  { value: 'merchant', label: 'Merchant' },
  { value: 'event_organizer', label: 'Event Organizer' },
  { value: 'tour_operator', label: 'Tour Operator' },
  { value: 'admin', label: 'Admin' },
  { value: 'super_admin', label: 'Super Admin' },
];

const VERIFICATION_STATUSES: { value: VerificationStatus | ''; label: string }[] = [
  { value: '', label: 'All Verification' },
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

const getVerificationBadgeColor = (status: VerificationStatus | null) => {
  switch (status) {
    case 'verified':
      return 'bg-green-100 text-green-800';
    case 'pending':
      return 'bg-yellow-100 text-yellow-800';
    case 'rejected':
      return 'bg-red-100 text-red-800';
    default:
      return 'bg-gray-100 text-gray-800';
  }
};

export default function UsersPage() {
  const router = useRouter();
  const [users, setUsers] = useState<User[]>([]);
  const [loading, setLoading] = useState(true);
  const [page, setPage] = useState(1);
  const [pageSize, setPageSize] = useState(10);
  const [total, setTotal] = useState(0);
  const [search, setSearch] = useState('');
  const debouncedSearch = useDebounce(search, 500);
  const [statusFilter, setStatusFilter] = useState('');
  const [roleFilter, setRoleFilter] = useState<UserRole | ''>('');
  const [verificationFilter, setVerificationFilter] = useState<VerificationStatus | ''>('');

  // Fetch users
  useEffect(() => {
    const fetchUsers = async () => {
      setLoading(true);
      try {
        const params: any = {
          page,
          limit: pageSize,
        };

        if (debouncedSearch.trim()) {
          params.search = debouncedSearch.trim();
        }

        if (statusFilter) {
          params.isActive = statusFilter === 'active';
        }

        if (roleFilter) {
          params.role = roleFilter;
        }

        if (verificationFilter) {
          params.verificationStatus = verificationFilter;
        }

        const response = await UsersAPI.listUsers(params);
        setUsers(response.data || []);
        setTotal(response.meta?.total || 0);
      } catch (error: any) {
        // Log comprehensive error details
        console.error('Failed to fetch users:', {
          error,
          message: error?.message,
          status: error?.status,
          response: error?.response,
          responseData: error?.response?.data,
          responseStatus: error?.response?.status,
          stack: error?.stack,
        });
        
        // Show user-friendly error message
        const errorMessage = 
          error?.response?.data?.message || 
          error?.message || 
          error?.response?.status === 403 ? 'Access denied. You do not have permission to view users.' :
          error?.response?.status === 401 ? 'Session expired. Please log in again.' :
          'Failed to load users. Please try again.';
        
        toast.error(errorMessage);
      } finally {
        setLoading(false);
      }
    };

    fetchUsers();
  }, [page, pageSize, debouncedSearch, statusFilter, roleFilter, verificationFilter]);

  const totalPages = Math.ceil(total / pageSize);

  const columns = [
    {
      key: 'name',
      label: 'Name',
      sortable: false,
      render: (_: any, row: User) => (
        <div className="flex items-center gap-3">
          <div className="w-10 h-10 bg-[#0e1a30]/10 rounded-full flex items-center justify-center">
            <Icon icon={faUser} className="text-[#0e1a30]" size="sm" />
          </div>
          <div>
            <p className="text-sm font-medium text-gray-900">{row?.fullName || '-'}</p>
            {row?.email && (
              <p className="text-xs text-gray-500">{row.email}</p>
            )}
          </div>
        </div>
      ),
    },
    {
      key: 'phone',
      label: 'Phone',
      sortable: false,
      render: (_: any, row: User) => (
        <span className="text-sm text-gray-900">{row?.phoneNumber || '-'}</span>
      ),
    },
    {
      key: 'roles',
      label: 'Roles',
      sortable: false,
      render: (_: any, row: User) => (
        <div className="flex flex-wrap gap-1">
          {row?.roles && row.roles.length > 0 ? (
            row.roles.map((role, index) => {
              const roleValue = typeof role === 'string' 
                ? role 
                : (typeof role === 'object' && role !== null && 'code' in role)
                  ? (role as any).code || (role as any).name || ''
                  : String(role);
              return (
                <span
                  key={index}
                  className="inline-flex items-center px-2 py-0.5 rounded text-xs font-medium bg-blue-100 text-blue-800"
                >
                  {String(roleValue).replace(/_/g, ' ')}
                </span>
              );
            })
          ) : (
            <span className="text-xs text-gray-400">No roles</span>
          )}
        </div>
      ),
    },
    {
      key: 'verification',
      label: 'Verification',
      sortable: false,
      render: (_: any, row: User) => (
        <span className={`inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium ${getVerificationBadgeColor(row?.verificationStatus || null)}`}>
          {row?.verificationStatus || 'unverified'}
        </span>
      ),
    },
    {
      key: 'status',
      label: 'Status',
      sortable: false,
      render: (_: any, row: User) => (
        <span className={`inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium ${getStatusBadgeColor(row?.isActive || false, row?.isBlocked || false)}`}>
          {getStatusLabel(row?.isActive || false, row?.isBlocked || false)}
        </span>
      ),
    },
  ];

  if (loading) {
    return <PageSkeleton />;
  }

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex items-center justify-between flex-wrap gap-4">
        <div>
          <h1 className="text-2xl font-bold text-gray-900">Users</h1>
          <p className="text-gray-600 mt-1">Manage system users and their roles</p>
        </div>
        <Link href="/dashboard/users/create">
          <Button variant="primary" size="md" icon={faPlus}>
            Create User
          </Button>
        </Link>
      </div>

      {/* Filters */}
      <div className="bg-white border border-gray-200 rounded-sm p-4">
        <div className="grid grid-cols-1 md:grid-cols-4 gap-4">
          {/* Search */}
          <div className="md:col-span-2">
            <div className="relative">
              <Icon
                icon={faSearch}
                className="absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400"
                size="sm"
              />
              <input
                type="text"
                placeholder="Search by name, email, or phone..."
                value={search}
                onChange={(e) => {
                  setSearch(e.target.value);
                  setPage(1);
                }}
                className="w-full pl-10 pr-4 py-2 border border-gray-200 rounded-sm focus:outline-none focus:ring-1 focus:ring-[#0e1a30] focus:border-[#0e1a30] text-sm"
              />
              {search && (
                <button
                  onClick={() => {
                    setSearch('');
                    setPage(1);
                  }}
                  className="absolute right-3 top-1/2 transform -translate-y-1/2 text-gray-400 hover:text-gray-600"
                >
                  <Icon icon={faTimes} size="xs" />
                </button>
              )}
            </div>
          </div>

          {/* Status Filter */}
          <div>
            <select
              value={statusFilter}
              onChange={(e) => {
                setStatusFilter(e.target.value);
                setPage(1);
              }}
              className="w-full px-3 py-2 border border-gray-200 rounded-sm focus:outline-none focus:ring-1 focus:ring-[#0e1a30] focus:border-[#0e1a30] text-sm"
            >
              {STATUSES.map((status) => (
                <option key={status.value} value={status.value}>
                  {status.label}
                </option>
              ))}
            </select>
          </div>

          {/* Role Filter */}
          <div>
            <select
              value={roleFilter}
              onChange={(e) => {
                setRoleFilter(e.target.value as UserRole | '');
                setPage(1);
              }}
              className="w-full px-3 py-2 border border-gray-200 rounded-sm focus:outline-none focus:ring-1 focus:ring-[#0e1a30] focus:border-[#0e1a30] text-sm"
            >
              {ROLES.map((role) => (
                <option key={role.value} value={role.value}>
                  {role.label}
                </option>
              ))}
            </select>
          </div>
        </div>
      </div>

      {/* Table */}
      <DataTable
        columns={columns}
        data={users}
        loading={loading}
        onRowClick={(row) => router.push(`/dashboard/users/${row.id}`)}
        emptyMessage="No users found"
        showNumbering={true}
        numberingStart={(page - 1) * pageSize + 1}
      />

      {/* Pagination */}
      {totalPages > 1 && (
        <Pagination
          currentPage={page}
          totalPages={totalPages}
          onPageChange={setPage}
        />
      )}
    </div>
  );
}

