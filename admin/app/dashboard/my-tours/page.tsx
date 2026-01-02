'use client';

import { useState, useEffect } from 'react';
import { useRouter } from 'next/navigation';
import { ToursAPI, type Tour, type TourOperatorProfile } from '@/src/lib/api';
import { toast } from '@/app/components/Toaster';
import { Button, Select, Breadcrumbs, StatusBadge, DataTable, Pagination } from '@/app/components';
import PageSkeleton from '@/app/components/PageSkeleton';
import Icon, { faRoute, faPlus } from '@/app/components/Icon';
import Link from 'next/link';

export default function MyToursPage() {
  const router = useRouter();
  const [operators, setOperators] = useState<TourOperatorProfile[]>([]);
  const [selectedOperatorId, setSelectedOperatorId] = useState<string | null>(null);
  const [tours, setTours] = useState<Tour[]>([]);
  const [loading, setLoading] = useState(true);
  const [toursLoading, setToursLoading] = useState(false);
  const [page, setPage] = useState(1);
  const [pageSize, setPageSize] = useState(20);
  const [total, setTotal] = useState(0);
  const [statusFilter, setStatusFilter] = useState<string>('all');

  useEffect(() => {
    fetchOperators();
  }, []);

  useEffect(() => {
    if (selectedOperatorId) {
      fetchTours();
    }
  }, [selectedOperatorId, page, pageSize, statusFilter]);

  const fetchOperators = async () => {
    setLoading(true);
    try {
      const data = await ToursAPI.getMyTourOperatorProfiles();
      setOperators(data || []);
      if (data && data.length > 0 && !selectedOperatorId) {
        setSelectedOperatorId(data[0].id);
      }
    } catch (error: any) {
      console.error('Failed to fetch operators:', error);
      toast.error(error?.response?.data?.message || error?.message || 'Failed to load tour operators');
    } finally {
      setLoading(false);
    }
  };

  const fetchTours = async () => {
    if (!selectedOperatorId) return;
    setToursLoading(true);
    try {
      const params: any = {
        page,
        limit: pageSize,
      };
      if (statusFilter !== 'all') params.status = statusFilter;

      const response = await ToursAPI.getOperatorTours(selectedOperatorId, params);
      setTours(response.data || []);
      setTotal(response.meta?.total || 0);
    } catch (error: any) {
      console.error('Failed to fetch tours:', error);
      toast.error(error?.response?.data?.message || error?.message || 'Failed to load tours');
    } finally {
      setToursLoading(false);
    }
  };

  const columns = [
    {
      key: 'name',
      label: 'Tour',
      sortable: false,
      render: (_: any, row: Tour) => (
        <Link
          href={`/dashboard/my-tours/${row.id}?operatorId=${selectedOperatorId}`}
          className="text-[#0e1a30] hover:underline font-medium"
        >
          {row.name}
        </Link>
      ),
    },
    {
      key: 'category',
      label: 'Category',
      sortable: false,
      render: (_: any, row: Tour) => (
        <div>
          <p className="text-sm text-gray-900">{row.category?.name || 'N/A'}</p>
        </div>
      ),
    },
    {
      key: 'location',
      label: 'Location',
      sortable: false,
      render: (_: any, row: Tour) => (
        <div>
          <p className="text-sm text-gray-900">
            {row.city?.name || ''}{row.country?.name ? `, ${row.country.name}` : ''}
          </p>
        </div>
      ),
    },
    {
      key: 'price',
      label: 'Price',
      sortable: false,
      render: (_: any, row: Tour) => (
        <div>
          {row.pricePerPerson ? (
            <p className="font-medium text-gray-900">
              {row.pricePerPerson.toLocaleString()} {row.currency || 'USD'} / person
            </p>
          ) : (
            <p className="text-sm text-gray-500">Not set</p>
          )}
        </div>
      ),
    },
    {
      key: 'status',
      label: 'Status',
      sortable: false,
      render: (_: any, row: Tour) => (
        <StatusBadge
          status={
            row.status === 'active' ? 'active' :
            row.status === 'draft' ? 'pending' : 'inactive'
          }
        />
      ),
    },
    {
      key: 'date',
      label: 'Created',
      sortable: false,
      render: (_: any, row: Tour) => (
        <div>
          <p className="text-sm text-gray-900">
            {new Date(row.createdAt).toLocaleDateString()}
          </p>
        </div>
      ),
    },
  ];

  if (loading) {
    return <PageSkeleton />;
  }

  if (operators.length === 0) {
    return (
      <div className="space-y-6">
        <Breadcrumbs items={[
          { label: 'Dashboard', href: '/dashboard/my-dashboard' },
          { label: 'My Tours' }
        ]} />
        <div className="bg-white border border-gray-200 rounded-sm p-12 text-center">
          <Icon icon={faRoute} className="text-gray-400 text-4xl mb-4" />
          <h2 className="text-xl font-semibold text-gray-900 mb-2">No Tour Operator Profile</h2>
          <p className="text-gray-600 mb-6">You need to create a tour operator profile first to manage tours.</p>
          <Button
            variant="primary"
            onClick={() => router.push('/dashboard/profile')}
          >
            Create Tour Operator Profile
          </Button>
        </div>
      </div>
    );
  }

  return (
    <div className="space-y-6">
      <Breadcrumbs items={[
        { label: 'Dashboard', href: '/dashboard/my-dashboard' },
        { label: 'My Tours' }
      ]} />

      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-bold text-gray-900">My Tours</h1>
          <p className="text-gray-600 mt-1">Manage your tour packages</p>
        </div>
        {selectedOperatorId && (
          <Button
            variant="primary"
            icon={faPlus}
            onClick={() => router.push(`/dashboard/my-tours/create?operatorId=${selectedOperatorId}`)}
          >
            Add Tour
          </Button>
        )}
      </div>

      {/* Operator Selector */}
      {operators.length > 1 && (
        <div className="bg-white border border-gray-200 rounded-sm p-4">
          <Select
            label="Select Tour Operator"
            value={selectedOperatorId || ''}
            onChange={(e) => {
              setSelectedOperatorId(e.target.value);
              setPage(1);
            }}
            options={[
              { value: '', label: 'Select operator' },
              ...operators.map(op => ({ value: op.id, label: op.companyName || 'Unnamed Operator' })),
            ]}
          />
        </div>
      )}

      {selectedOperatorId && (
        <>
          {/* Filters */}
          <div className="bg-white border border-gray-200 rounded-sm p-4">
            <Select
              label="Status"
              value={statusFilter}
              onChange={(e) => {
                setStatusFilter(e.target.value);
                setPage(1);
              }}
              options={[
                { value: 'all', label: 'All Statuses' },
                { value: 'draft', label: 'Draft' },
                { value: 'active', label: 'Active' },
                { value: 'inactive', label: 'Inactive' },
              ]}
            />
          </div>

          <div className="bg-white border border-gray-200 rounded-sm">
            <DataTable
              data={tours}
              columns={columns}
              loading={toursLoading}
            />
            {total > pageSize && (
              <div className="p-4 border-t border-gray-200">
                <Pagination
                  currentPage={page}
                  totalPages={Math.ceil(total / pageSize)}
                  onPageChange={setPage}
                />
              </div>
            )}
          </div>
        </>
      )}
    </div>
  );
}

