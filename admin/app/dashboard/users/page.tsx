'use client';

import { useState, useEffect } from 'react';
import { useRouter } from 'next/navigation';
import { UsersAPI, type User, type UserRole, type VerificationStatus, type CreateUserParams } from '@/src/lib/api';
import Icon, { faSearch, faPlus, faTimes, faUser, faFilter, faChevronDown, faChevronUp } from '@/app/components/Icon';
import { toast } from '@/app/components/Toaster';
import { DataTable, Pagination, Button, Modal, Input, Breadcrumbs } from '@/app/components';
import PageSkeleton from '@/app/components/PageSkeleton';
import { useDebounce } from '@/src/hooks/useDebounce';
import { validateForm, type ValidationErrors, commonRules } from '@/src/lib/validation';

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
  const [showCreateModal, setShowCreateModal] = useState(false);
  const [showAdvancedFilters, setShowAdvancedFilters] = useState(false);
  const [dateFrom, setDateFrom] = useState('');
  const [dateTo, setDateTo] = useState('');
  const [isBlockedFilter, setIsBlockedFilter] = useState<'' | 'true' | 'false'>('');
  const [creating, setCreating] = useState(false);
  const [formData, setFormData] = useState<CreateUserParams & { confirmPassword: string }>({
    email: '',
    phoneNumber: '',
    password: '',
    confirmPassword: '',
    fullName: '',
    roles: [],
  });
  const [formErrors, setFormErrors] = useState<ValidationErrors>({});
  const [touched, setTouched] = useState<{ [key: string]: boolean }>({});

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

        if (isBlockedFilter !== '') {
          params.isBlocked = isBlockedFilter === 'true';
        }

        // Note: Backend may not support date range directly, so we'll filter client-side if needed
        // For now, we'll pass the params and let the backend handle what it can

        const response = await UsersAPI.listUsers(params);
        
        // Client-side date filtering if backend doesn't support it
        let filteredData = response.data || [];
        if (dateFrom || dateTo) {
          filteredData = filteredData.filter((user: User) => {
            if (!user.createdAt) return false;
            const userDate = new Date(user.createdAt);
            if (dateFrom && userDate < new Date(dateFrom)) return false;
            if (dateTo) {
              const toDate = new Date(dateTo);
              toDate.setHours(23, 59, 59, 999); // Include entire end date
              if (userDate > toDate) return false;
            }
            return true;
          });
        }
        
        setUsers(filteredData);
        setTotal(filteredData.length); // Update total for client-side filtered results
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
  }, [page, pageSize, debouncedSearch, statusFilter, roleFilter, verificationFilter, isBlockedFilter, dateFrom, dateTo]);

  const totalPages = Math.ceil(total / pageSize);

  const columns = [
    {
      key: 'fullName',
      label: 'Name',
      sortable: true,
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
      key: 'phoneNumber',
      label: 'Phone',
      sortable: true,
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
      <Breadcrumbs items={[{ label: 'Users' }]} />
      
      {/* Header */}
      <div className="flex items-center justify-between flex-wrap gap-4">
        <div>
          <h1 className="text-2xl font-bold text-gray-900">Users</h1>
          <p className="text-gray-600 mt-1">Manage system users and their roles</p>
        </div>
        <Button variant="primary" size="md" icon={faPlus} onClick={() => setShowCreateModal(true)}>
          Create User
        </Button>
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

          {/* Advanced Filters Toggle */}
          <div>
            <Button
              variant="outline"
              size="sm"
              onClick={() => setShowAdvancedFilters(!showAdvancedFilters)}
              className="w-full"
              icon={showAdvancedFilters ? faChevronUp : faChevronDown}
            >
              {showAdvancedFilters ? 'Hide' : 'Show'} Advanced Filters
            </Button>
          </div>
        </div>

        {/* Advanced Filters */}
        {showAdvancedFilters && (
          <div className="mt-4 p-4 bg-gray-50 rounded-sm border border-gray-200">
            <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
              {/* Date From */}
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  Created From
                </label>
                <input
                  type="date"
                  value={dateFrom}
                  onChange={(e) => {
                    setDateFrom(e.target.value);
                    setPage(1);
                  }}
                  className="w-full px-3 py-2 border border-gray-200 rounded-sm focus:outline-none focus:ring-1 focus:ring-[#0e1a30] focus:border-[#0e1a30] text-sm"
                />
              </div>

              {/* Date To */}
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  Created To
                </label>
                <input
                  type="date"
                  value={dateTo}
                  onChange={(e) => {
                    setDateTo(e.target.value);
                    setPage(1);
                  }}
                  className="w-full px-3 py-2 border border-gray-200 rounded-sm focus:outline-none focus:ring-1 focus:ring-[#0e1a30] focus:border-[#0e1a30] text-sm"
                />
              </div>

              {/* Blocked Status */}
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  Blocked Status
                </label>
                <select
                  value={isBlockedFilter}
                  onChange={(e) => {
                    setIsBlockedFilter(e.target.value as '' | 'true' | 'false');
                    setPage(1);
                  }}
                  className="w-full px-3 py-2 border border-gray-200 rounded-sm focus:outline-none focus:ring-1 focus:ring-[#0e1a30] focus:border-[#0e1a30] text-sm"
                >
                  <option value="">All</option>
                  <option value="false">Not Blocked</option>
                  <option value="true">Blocked</option>
                </select>
              </div>
            </div>

            {/* Clear Filters */}
            {(dateFrom || dateTo || isBlockedFilter) && (
              <div className="mt-4 flex justify-end">
                <Button
                  variant="ghost"
                  size="sm"
                  onClick={() => {
                    setDateFrom('');
                    setDateTo('');
                    setIsBlockedFilter('');
                    setPage(1);
                  }}
                >
                  Clear Date Filters
                </Button>
              </div>
            )}
          </div>
        )}
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
        enableClientSort={true}
        enableColumnVisibility={true}
      />

      {/* Pagination */}
      {totalPages > 1 && (
        <Pagination
          currentPage={page}
          totalPages={totalPages}
          onPageChange={setPage}
          pageSize={pageSize}
          onPageSizeChange={(size) => {
            setPageSize(size);
            setPage(1);
          }}
          totalItems={total}
        />
      )}

      {/* Create User Modal */}
      <Modal
        isOpen={showCreateModal}
        onClose={() => {
          setShowCreateModal(false);
          setFormData({
            email: '',
            phoneNumber: '',
            password: '',
            confirmPassword: '',
            fullName: '',
            roles: [],
          });
          setFormErrors({});
          setTouched({});
        }}
        title="Create New User"
        size="lg"
      >
        <div className="space-y-4">
          <div>
            <Input
              label="Full Name"
              value={formData.fullName || ''}
              onChange={(e) => {
                setFormData({ ...formData, fullName: e.target.value });
                if (touched.fullName) {
                  const errors = validateForm({ fullName: e.target.value }, {
                    fullName: { ...commonRules.name, required: false },
                  });
                  setFormErrors({ ...formErrors, fullName: errors.fullName || '' });
                }
              }}
              onBlur={() => {
                setTouched({ ...touched, fullName: true });
                const errors = validateForm({ fullName: formData.fullName }, {
                  fullName: { ...commonRules.name, required: false },
                });
                setFormErrors({ ...formErrors, fullName: errors.fullName || '' });
              }}
              placeholder="Enter full name"
              error={touched.fullName ? formErrors.fullName : undefined}
            />
          </div>

          <div>
            <Input
              label="Email"
              type="email"
              value={formData.email || ''}
              onChange={(e) => {
                setFormData({ ...formData, email: e.target.value });
                if (touched.email) {
                  const errors = validateForm({ email: e.target.value }, {
                    email: { ...commonRules.email, required: false },
                  });
                  setFormErrors({ ...formErrors, email: errors.email || '' });
                }
              }}
              onBlur={() => {
                setTouched({ ...touched, email: true });
                const errors = validateForm({ email: formData.email }, {
                  email: { ...commonRules.email, required: false },
                });
                setFormErrors({ ...formErrors, email: errors.email || '' });
              }}
              placeholder="Enter email"
              error={touched.email ? formErrors.email : undefined}
            />
          </div>

          <div>
            <Input
              label="Phone Number"
              type="tel"
              value={formData.phoneNumber || ''}
              onChange={(e) => {
                setFormData({ ...formData, phoneNumber: e.target.value });
                if (touched.phoneNumber) {
                  const errors = validateForm({ phoneNumber: e.target.value }, {
                    phoneNumber: { ...commonRules.phone, required: false },
                  });
                  setFormErrors({ ...formErrors, phoneNumber: errors.phoneNumber || '' });
                }
              }}
              onBlur={() => {
                setTouched({ ...touched, phoneNumber: true });
                const errors = validateForm({ phoneNumber: formData.phoneNumber }, {
                  phoneNumber: { ...commonRules.phone, required: false },
                });
                setFormErrors({ ...formErrors, phoneNumber: errors.phoneNumber || '' });
              }}
              placeholder="Enter phone number"
              error={touched.phoneNumber ? formErrors.phoneNumber : undefined}
            />
            <p className="text-xs text-gray-500 mt-1">At least one of email or phone is required</p>
          </div>

          <div>
            <Input
              label="Password"
              type="password"
              value={formData.password}
              onChange={(e) => {
                setFormData({ ...formData, password: e.target.value });
                if (touched.password) {
                  const errors = validateForm({ password: e.target.value }, {
                    password: commonRules.password,
                  });
                  setFormErrors({ ...formErrors, password: errors.password || '' });
                }
                // Also validate confirm password if it's been touched
                if (touched.confirmPassword) {
                  const confirmErrors = validateForm(
                    { confirmPassword: formData.confirmPassword, password: e.target.value },
                    {
                      confirmPassword: {
                        required: true,
                        match: { field: 'password', message: 'Passwords do not match' },
                      },
                    }
                  );
                  setFormErrors({ ...formErrors, confirmPassword: confirmErrors.confirmPassword || '' });
                }
              }}
              onBlur={() => {
                setTouched({ ...touched, password: true });
                const errors = validateForm({ password: formData.password }, {
                  password: commonRules.password,
                });
                setFormErrors({ ...formErrors, password: errors.password || '' });
              }}
              placeholder="Enter password (min 6 characters)"
              error={touched.password ? formErrors.password : undefined}
            />
          </div>

          <div>
            <Input
              label="Confirm Password"
              type="password"
              value={formData.confirmPassword}
              onChange={(e) => {
                setFormData({ ...formData, confirmPassword: e.target.value });
                if (touched.confirmPassword) {
                  const errors = validateForm(
                    { confirmPassword: e.target.value, password: formData.password },
                    {
                      confirmPassword: {
                        required: true,
                        match: { field: 'password', message: 'Passwords do not match' },
                      },
                    }
                  );
                  setFormErrors({ ...formErrors, confirmPassword: errors.confirmPassword || '' });
                }
              }}
              onBlur={() => {
                setTouched({ ...touched, confirmPassword: true });
                const errors = validateForm(
                  { confirmPassword: formData.confirmPassword, password: formData.password },
                  {
                    confirmPassword: {
                      required: true,
                      match: { field: 'password', message: 'Passwords do not match' },
                    },
                  }
                );
                setFormErrors({ ...formErrors, confirmPassword: errors.confirmPassword || '' });
              }}
              placeholder="Confirm password"
              error={touched.confirmPassword ? formErrors.confirmPassword : undefined}
            />
          </div>

          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">
              Roles
            </label>
            <div className="space-y-2">
              {ROLES.filter(r => r.value).map((role) => (
                <label key={role.value} className="flex items-center">
                  <input
                    type="checkbox"
                    checked={formData.roles?.includes(role.value as UserRole) || false}
                    onChange={(e) => {
                      const currentRoles = formData.roles || [];
                      if (e.target.checked) {
                        setFormData({ ...formData, roles: [...currentRoles, role.value as UserRole] });
                      } else {
                        setFormData({ ...formData, roles: currentRoles.filter(r => r !== role.value) });
                      }
                    }}
                    className="mr-2"
                  />
                  <span className="text-sm text-gray-700">{role.label}</span>
                </label>
              ))}
            </div>
          </div>

          <div className="flex justify-end gap-3 pt-4 border-t border-gray-200">
            <Button
              variant="outline"
              onClick={() => {
                setShowCreateModal(false);
                setFormData({
                  email: '',
                  phoneNumber: '',
                  password: '',
                  confirmPassword: '',
                  fullName: '',
                  roles: [],
                });
              }}
            >
              Cancel
            </Button>
            <Button
              variant="primary"
              onClick={async () => {
                // Mark all fields as touched
                const allTouched = {
                  email: true,
                  phoneNumber: true,
                  password: true,
                  confirmPassword: true,
                  fullName: true,
                };
                setTouched(allTouched);

                // Validate all fields
                const validationRules = {
                  email: { ...commonRules.email, required: false },
                  phoneNumber: { ...commonRules.phone, required: false },
                  password: commonRules.password,
                  confirmPassword: {
                    required: true,
                    match: { field: 'password', message: 'Passwords do not match' },
                  },
                  fullName: { ...commonRules.name, required: false },
                };

                const errors = validateForm(formData, validationRules);

                // Custom validation: at least one of email or phone
                if (!formData.email && !formData.phoneNumber) {
                  errors.email = 'Either email or phone number is required';
                  errors.phoneNumber = 'Either email or phone number is required';
                }

                setFormErrors(errors);

                if (Object.keys(errors).length > 0) {
                  toast.error('Please fix the errors in the form');
                  return;
                }
                
                setCreating(true);
                try {
                  await UsersAPI.createUser({
                    email: formData.email || undefined,
                    phoneNumber: formData.phoneNumber || undefined,
                    password: formData.password,
                    fullName: formData.fullName || undefined,
                    roles: formData.roles && formData.roles.length > 0 ? formData.roles : undefined,
                  });
                  toast.success('User created successfully');
                  setShowCreateModal(false);
                  setFormData({
                    email: '',
                    phoneNumber: '',
                    password: '',
                    confirmPassword: '',
                    fullName: '',
                    roles: [],
                  });
                  setFormErrors({});
                  setTouched({});
                  // Refresh users list
                  const response = await UsersAPI.listUsers({ page, limit: pageSize });
                  setUsers(response.data || []);
                  setTotal(response.meta?.total || 0);
                } catch (error: any) {
                  console.error('Failed to create user:', error);
                  toast.error(error?.response?.data?.message || error?.message || 'Failed to create user');
                } finally {
                  setCreating(false);
                }
              }}
              loading={creating}
            >
              Create User
            </Button>
          </div>
        </div>
      </Modal>
    </div>
  );
}

