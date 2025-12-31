'use client';

import { useState, useEffect } from 'react';
import { useRouter, useSearchParams } from 'next/navigation';
import { MerchantPortalAPI, type Business } from '@/src/lib/api';
import { toast } from '@/app/components/Toaster';
import { DataTable, Pagination, Button, Breadcrumbs, StatusBadge } from '@/app/components';
import PageSkeleton from '@/app/components/PageSkeleton';
import Icon, { faSearch, faTags, faCheckCircle, faTimesCircle } from '@/app/components/Icon';
import { useDebounce } from '@/src/hooks/useDebounce';

export default function MyPromotionsPage() {
  const router = useRouter();
  const searchParams = useSearchParams();
  const [businesses, setBusinesses] = useState<Business[]>([]);
  const [selectedBusinessId, setSelectedBusinessId] = useState<string | null>(null);
  const [promotions, setPromotions] = useState<any[]>([]);
  const [availablePromotions, setAvailablePromotions] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);
  const [page, setPage] = useState(1);
  const [pageSize, setPageSize] = useState(10);
  const [total, setTotal] = useState(0);
  const [search, setSearch] = useState('');
  const debouncedSearch = useDebounce(search, 500);
  const [activeTab, setActiveTab] = useState<'active' | 'available'>('active');

  // Fetch businesses
  useEffect(() => {
    const fetchBusinesses = async () => {
      try {
        const data = await MerchantPortalAPI.getMyBusinesses();
        setBusinesses(data);
        const businessId = searchParams.get('businessId');
        if (businessId && data.find(b => b.id === businessId)) {
          setSelectedBusinessId(businessId);
        } else if (data.length > 0) {
          setSelectedBusinessId(data[0].id);
        }
      } catch (error: any) {
        console.error('Failed to fetch businesses:', error);
        toast.error(error?.response?.data?.message || error?.message || 'Failed to load businesses');
      }
    };
    fetchBusinesses();
  }, []);

  // Fetch promotions
  useEffect(() => {
    if (!selectedBusinessId) return;

    const fetchPromotions = async () => {
      setLoading(true);
      try {
        if (activeTab === 'active') {
          // Fetch active promotions - this endpoint may not exist yet, so we'll handle gracefully
          try {
            const response = await MerchantPortalAPI.getPromotions(selectedBusinessId, {
              page,
              limit: pageSize,
              active: true,
            });
            let filtered = response.data || [];
            if (debouncedSearch) {
              filtered = filtered.filter((p: any) =>
                p.name?.toLowerCase().includes(debouncedSearch.toLowerCase()) ||
                p.description?.toLowerCase().includes(debouncedSearch.toLowerCase())
              );
            }
            setPromotions(filtered);
            setTotal(response.meta?.total || 0);
          } catch (error) {
            // Endpoint might not exist yet
            console.warn('Promotions endpoint not available:', error);
            setPromotions([]);
            setTotal(0);
          }
        } else {
          // Fetch available promotions
          try {
            const data = await MerchantPortalAPI.getAvailablePromotions(selectedBusinessId);
            let filtered = data || [];
            if (debouncedSearch) {
              filtered = filtered.filter((p: any) =>
                p.name?.toLowerCase().includes(debouncedSearch.toLowerCase()) ||
                p.description?.toLowerCase().includes(debouncedSearch.toLowerCase())
              );
            }
            setAvailablePromotions(filtered);
          } catch (error) {
            console.warn('Available promotions endpoint not available:', error);
            setAvailablePromotions([]);
          }
        }
      } catch (error: any) {
        console.error('Failed to fetch promotions:', error);
        toast.error(error?.response?.data?.message || error?.message || 'Failed to load promotions');
      } finally {
        setLoading(false);
      }
    };

    fetchPromotions();
  }, [page, pageSize, selectedBusinessId, activeTab, debouncedSearch]);

  const handleJoinPromotion = async (promotionId: string) => {
    if (!selectedBusinessId) return;
    try {
      await MerchantPortalAPI.joinPromotion(selectedBusinessId, promotionId);
      toast.success('Successfully joined promotion');
      // Refresh available promotions
      const data = await MerchantPortalAPI.getAvailablePromotions(selectedBusinessId);
      setAvailablePromotions(data || []);
    } catch (error: any) {
      console.error('Failed to join promotion:', error);
      toast.error(error?.response?.data?.message || error?.message || 'Failed to join promotion');
    }
  };

  const handleLeavePromotion = async (promotionId: string) => {
    if (!selectedBusinessId) return;
    try {
      await MerchantPortalAPI.leavePromotion(selectedBusinessId, promotionId);
      toast.success('Successfully left promotion');
      // Refresh active promotions
      const response = await MerchantPortalAPI.getPromotions(selectedBusinessId, {
        page,
        limit: pageSize,
        active: true,
      });
      setPromotions(response.data || []);
      setTotal(response.meta?.total || 0);
    } catch (error: any) {
      console.error('Failed to leave promotion:', error);
      toast.error(error?.response?.data?.message || error?.message || 'Failed to leave promotion');
    }
  };

  const activeColumns = [
    {
      key: 'name',
      label: 'Promotion Name',
      sortable: true,
      render: (value: string, row: any) => (
        <div className="flex items-center gap-3">
          <div className="w-10 h-10 bg-gray-100 rounded-sm flex items-center justify-center flex-shrink-0">
            <Icon icon={faTags} className="text-gray-600" size="sm" />
          </div>
          <div>
            <div className="font-medium text-gray-900">{value || 'N/A'}</div>
            {row.description && (
              <div className="text-xs text-gray-500 line-clamp-1">{row.description}</div>
            )}
          </div>
        </div>
      ),
    },
    {
      key: 'status',
      label: 'Status',
      render: (value: any) => (
        <StatusBadge status="active" />
      ),
    },
    {
      key: 'startDate',
      label: 'Start Date',
      render: (value: string) => (
        <span className="text-sm text-gray-700">
          {value ? new Date(value).toLocaleDateString() : 'N/A'}
        </span>
      ),
    },
    {
      key: 'endDate',
      label: 'End Date',
      render: (value: string) => (
        <span className="text-sm text-gray-700">
          {value ? new Date(value).toLocaleDateString() : 'N/A'}
        </span>
      ),
    },
    {
      key: 'actions',
      label: 'Actions',
      render: (_: any, row: any) => (
        <Button
          variant="ghost"
          size="sm"
          icon={faTimesCircle}
          onClick={() => handleLeavePromotion(row.id)}
        >
          Leave
        </Button>
      ),
    },
  ];

  const availableColumns = [
    {
      key: 'name',
      label: 'Promotion Name',
      sortable: true,
      render: (value: string, row: any) => (
        <div className="flex items-center gap-3">
          <div className="w-10 h-10 bg-gray-100 rounded-sm flex items-center justify-center flex-shrink-0">
            <Icon icon={faTags} className="text-gray-600" size="sm" />
          </div>
          <div>
            <div className="font-medium text-gray-900">{value || 'N/A'}</div>
            {row.description && (
              <div className="text-xs text-gray-500 line-clamp-1">{row.description}</div>
            )}
          </div>
        </div>
      ),
    },
    {
      key: 'startDate',
      label: 'Start Date',
      render: (value: string) => (
        <span className="text-sm text-gray-700">
          {value ? new Date(value).toLocaleDateString() : 'N/A'}
        </span>
      ),
    },
    {
      key: 'endDate',
      label: 'End Date',
      render: (value: string) => (
        <span className="text-sm text-gray-700">
          {value ? new Date(value).toLocaleDateString() : 'N/A'}
        </span>
      ),
    },
    {
      key: 'actions',
      label: 'Actions',
      render: (_: any, row: any) => (
        <Button
          variant="primary"
          size="sm"
          icon={faCheckCircle}
          onClick={() => handleJoinPromotion(row.id)}
        >
          Join
        </Button>
      ),
    },
  ];

  if (businesses.length === 0) {
    return (
      <div className="space-y-6">
        <Breadcrumbs items={[
          { label: 'Dashboard', href: '/dashboard/my-dashboard' },
          { label: 'Promotions' }
        ]} />
        <div className="flex items-center justify-center min-h-[400px]">
          <div className="text-center">
            <p className="text-gray-600">No businesses found.</p>
          </div>
        </div>
      </div>
    );
  }

  if (!selectedBusinessId) {
    return <PageSkeleton />;
  }

  return (
    <div className="space-y-6">
      <Breadcrumbs items={[
        { label: 'Dashboard', href: '/dashboard/my-dashboard' },
        { label: 'Promotions' }
      ]} />

      {/* Business Selector */}
      <div className="bg-white border border-gray-200 rounded-sm p-4">
        <div className="flex items-center justify-between flex-wrap gap-4">
          <div className="flex-1 min-w-0">
            <label className="block text-sm font-medium text-gray-700 mb-2">
              Select Business
            </label>
            <select
              value={selectedBusinessId}
              onChange={(e) => {
                setSelectedBusinessId(e.target.value);
                setPage(1);
              }}
              className="w-full md:w-auto px-3 py-2 border border-gray-200 rounded-sm focus:outline-none focus:ring-1 focus:ring-[#0e1a30] focus:border-[#0e1a30] text-sm"
            >
              {businesses.map((business) => (
                <option key={business.id} value={business.id}>
                  {business.businessName}
                </option>
              ))}
            </select>
          </div>
        </div>
      </div>

      {/* Tabs */}
      <div className="bg-white border border-gray-200 rounded-sm">
        <div className="flex border-b border-gray-200">
          <button
            onClick={() => {
              setActiveTab('active');
              setPage(1);
            }}
            className={`px-6 py-3 font-medium text-sm ${
              activeTab === 'active'
                ? 'border-b-2 border-[#0e1a30] text-[#0e1a30]'
                : 'text-gray-600 hover:text-gray-900'
            }`}
          >
            Active Promotions
          </button>
          <button
            onClick={() => {
              setActiveTab('available');
              setPage(1);
            }}
            className={`px-6 py-3 font-medium text-sm ${
              activeTab === 'available'
                ? 'border-b-2 border-[#0e1a30] text-[#0e1a30]'
                : 'text-gray-600 hover:text-gray-900'
            }`}
          >
            Available Promotions
          </button>
        </div>

        {/* Search */}
        <div className="p-4 border-b border-gray-200">
          <div className="relative">
            <Icon
              icon={faSearch}
              className="absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400"
              size="sm"
            />
            <input
              type="text"
              placeholder="Search promotions..."
              value={search}
              onChange={(e) => {
                setSearch(e.target.value);
                setPage(1);
              }}
              className="w-full pl-10 pr-4 py-2 border border-gray-200 rounded-sm focus:outline-none focus:ring-1 focus:ring-[#0e1a30] focus:border-[#0e1a30] text-sm"
            />
          </div>
        </div>

        {/* Table */}
        {activeTab === 'active' ? (
          <>
            <DataTable
              columns={activeColumns}
              data={promotions}
              loading={loading}
              emptyMessage="No active promotions found."
              showNumbering={true}
              numberingStart={(page - 1) * pageSize + 1}
              enableClientSort={true}
              enableColumnVisibility={true}
            />
            {total > pageSize && (
              <div className="p-4 border-t border-gray-200">
                <Pagination
                  currentPage={page}
                  totalPages={Math.ceil(total / pageSize)}
                  onPageChange={setPage}
                  pageSize={pageSize}
                  onPageSizeChange={(size) => {
                    setPageSize(size);
                    setPage(1);
                  }}
                  totalItems={total}
                />
              </div>
            )}
          </>
        ) : (
          <DataTable
            columns={availableColumns}
            data={availablePromotions}
            loading={loading}
            emptyMessage="No available promotions found."
            showNumbering={true}
            enableClientSort={true}
            enableColumnVisibility={true}
          />
        )}
      </div>
    </div>
  );
}

