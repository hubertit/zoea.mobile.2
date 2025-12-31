'use client';

import { useState, useEffect } from 'react';
import { useRouter } from 'next/navigation';
import Link from 'next/link';
import { UsersAPI, type User } from '@/src/lib/api';
import Icon, { faSearch, faTimes, faRoute, faUser, faCheckCircle, faTimesCircle } from '@/app/components/Icon';
import { toast } from '@/app/components/Toaster';
import { DataTable, Pagination } from '@/app/components';
import PageSkeleton from '@/app/components/PageSkeleton';

export default function TourOperatorsPage() {
  const router = useRouter();
  const [operators, setOperators] = useState<User[]>([]);
  const [loading, setLoading] = useState(true);
  const [page, setPage] = useState(1);
  const [pageSize, setPageSize] = useState(10);
  const [total, setTotal] = useState(0);
  const [search, setSearch] = useState('');
  const [statusFilter, setStatusFilter] = useState<'all' | 'active' | 'inactive' | 'blocked'>('all');

  useEffect(() => {
    const fetchOperators = async () => {
      setLoading(true);
      try {
        const params: any = {
          page,
          limit: pageSize,
          role: 'tour_operator', // Filter by tour operator role
        };

        if (statusFilter !== 'all') {
          if (statusFilter === 'active') {
            params.isActive = true;
            params.isBlocked = false;
          } else if (statusFilter === 'inactive') {
            params.isActive = false;
          } else if (statusFilter === 'blocked') {
            params.isBlocked = true;
          }
        }

        const response = await UsersAPI.listUsers(params);
        
        // Client-side search filtering
        let filteredData = response.data || [];
        if (search.trim()) {
          const searchLower = search.toLowerCase();
          filteredData = filteredData.filter((operator) => {
            const name = operator.fullName?.toLowerCase() || '';
            const email = operator.email?.toLowerCase() || '';
            const phone = operator.phoneNumber?.toLowerCase() || '';
            
            return name.includes(searchLower) ||
                   email.includes(searchLower) ||
                   phone.includes(searchLower);
          });
        }
        
        setOperators(filteredData);
        setTotal(response.meta?.total || 0);
      } catch (error: any) {
        console.error('Failed to fetch tour operators:', error);
        toast.error(error?.message || 'Failed to load tour operators');
      } finally {
        setLoading(false);
      }
    };

    fetchOperators();
  }, [page, pageSize, statusFilter, search]);

  const totalPages = Math.ceil(total / pageSize);

  const columns = [
    {
      key: 'operator',
      label: 'Operator',
      sortable: false,
      render: (_: any, row: User) => (
        <div className="flex items-center gap-3">
          <div className="w-10 h-10 bg-orange-100 rounded-full flex items-center justify-center">
            <Icon icon={faRoute} className="text-orange-600" size="sm" />
          </div>
          <div>
            <Link href={`/dashboard/users/${row.id}`} className="text-sm font-medium text-[#0e1a30] hover:underline">
              {row.fullName || row.email || 'N/A'}
            </Link>
            <p className="text-xs text-gray-500">{row.email || row.phoneNumber || ''}</p>
          </div>
        </div>
      ),
    },
    {
      key: 'contact',
      label: 'Contact',
      sortable: false,
      render: (_: any, row: User) => (
        <div>
          {row.email && (
            <p className="text-sm text-gray-900">{row.email}</p>
          )}
          {row.phoneNumber && (
            <p className="text-xs text-gray-500">{row.phoneNumber}</p>
          )}
        </div>
      ),
    },
    {
      key: 'location',
      label: 'Location',
      sortable: false,
      render: (_: any, row: User) => (
        <div>
          {row.city && (
            <p className="text-sm text-gray-900">{row.city.name}</p>
          )}
          {row.country && (
            <p className="text-xs text-gray-500">{row.country.name}</p>
          )}
          {!row.city && !row.country && (
            <span className="text-sm text-gray-400">-</span>
          )}
        </div>
      ),
    },
    {
      key: 'verification',
      label: 'Verification',
      sortable: false,
      render: (_: any, row: User) => (
        <span className={`inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium w-fit ${
          row.verificationStatus === 'verified'
            ? 'bg-green-100 text-green-800'
            : row.verificationStatus === 'pending'
            ? 'bg-yellow-100 text-yellow-800'
            : row.verificationStatus === 'rejected'
            ? 'bg-red-100 text-red-800'
            : 'bg-gray-100 text-gray-800'
        }`}>
          {row.verificationStatus?.replace(/_/g, ' ') || 'unverified'}
        </span>
      ),
    },
    {
      key: 'status',
      label: 'Status',
      sortable: false,
      render: (_: any, row: User) => (
        <div className="flex flex-col gap-1">
          <span className={`inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium w-fit ${
            row.isActive ? 'bg-green-100 text-green-800' : 'bg-gray-100 text-gray-800'
          }`}>
            {row.isActive ? 'Active' : 'Inactive'}
          </span>
          {row.isBlocked && (
            <span className="inline-flex items-center gap-1 text-xs text-red-600">
              <Icon icon={faTimesCircle} size="xs" />
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
      render: (_: any, row: User) => (
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

  if (loading) {
    return <PageSkeleton />;
  }

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex items-center justify-between flex-wrap gap-4">
        <div>
          <h1 className="text-2xl font-bold text-gray-900">Tour Operators</h1>
          <p className="text-gray-600 mt-1">Manage tour operators and their profiles</p>
        </div>
      </div>

      {/* Filters */}
      <div className="bg-white border border-gray-200 rounded-sm p-4">
        <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
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
                placeholder="Search by name, email, phone..."
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
                setStatusFilter(e.target.value as 'all' | 'active' | 'inactive' | 'blocked');
                setPage(1);
              }}
              className="w-full px-3 py-2 border border-gray-200 rounded-sm focus:outline-none focus:ring-1 focus:ring-[#0e1a30] focus:border-[#0e1a30] text-sm"
            >
              <option value="all">All Status</option>
              <option value="active">Active</option>
              <option value="inactive">Inactive</option>
              <option value="blocked">Blocked</option>
            </select>
          </div>
        </div>
      </div>

      {/* Table */}
      <DataTable
        columns={columns}
        data={operators}
        loading={loading}
        onRowClick={(row) => router.push(`/dashboard/users/${row.id}`)}
        emptyMessage="No tour operators found"
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
