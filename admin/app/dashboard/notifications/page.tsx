'use client';

import { useState, useEffect } from 'react';
import { useRouter } from 'next/navigation';
import { NotificationsAPI, type NotificationRequest, type ApprovalStatus } from '@/src/lib/api';
import Icon, { faSearch, faPlus, faTimes, faPaperPlane } from '@/app/components/Icon';
import { toast } from '@/app/components/Toaster';
import { DataTable, Pagination, Button, Modal } from '@/app/components';
import PageSkeleton from '@/app/components/PageSkeleton';
import Input from '@/app/components/Input';
import Textarea from '@/app/components/Textarea';
import Select from '@/app/components/Select';
import { useDebounce } from '@/src/hooks/useDebounce';

const STATUSES: { value: ApprovalStatus | ''; label: string }[] = [
  { value: '', label: 'All Status' },
  { value: 'pending', label: 'Pending' },
  { value: 'approved', label: 'Approved' },
  { value: 'rejected', label: 'Rejected' },
  { value: 'revision_requested', label: 'Revision Requested' },
];

const getStatusBadgeColor = (status: ApprovalStatus) => {
  switch (status) {
    case 'approved':
      return 'bg-green-100 text-green-800';
    case 'pending':
    case 'revision_requested':
      return 'bg-yellow-100 text-yellow-800';
    case 'rejected':
      return 'bg-red-100 text-red-800';
    default:
      return 'bg-gray-100 text-gray-800';
  }
};

export default function NotificationsPage() {
  const router = useRouter();
  const [notifications, setNotifications] = useState<NotificationRequest[]>([]);
  const [loading, setLoading] = useState(true);
  const [page, setPage] = useState(1);
  const [pageSize, setPageSize] = useState(10);
  const [total, setTotal] = useState(0);
  const [search, setSearch] = useState('');
  const debouncedSearch = useDebounce(search, 500);
  const [statusFilter, setStatusFilter] = useState<ApprovalStatus | ''>('');
  const [broadcastModalOpen, setBroadcastModalOpen] = useState(false);
  const [creating, setCreating] = useState(false);

  const [broadcastData, setBroadcastData] = useState({
    title: '',
    body: '',
    targetType: 'all',
    segments: [] as string[],
    actionUrl: '',
  });

  useEffect(() => {
    const fetchNotifications = async () => {
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
          params.status = statusFilter;
        }

        const response = await NotificationsAPI.listNotificationRequests(params);
        setNotifications(response.data || []);
        setTotal(response.meta?.total || 0);
      } catch (error: any) {
        console.error('Failed to fetch notifications:', error);
        toast.error(error?.message || 'Failed to load notifications');
      } finally {
        setLoading(false);
      }
    };

    fetchNotifications();
  }, [page, pageSize, debouncedSearch, statusFilter]);

  const handleCreateBroadcast = async () => {
    if (!broadcastData.title.trim() || !broadcastData.body.trim()) {
      toast.error('Title and body are required');
      return;
    }

    setCreating(true);
    try {
      await NotificationsAPI.createBroadcast({
        title: broadcastData.title.trim(),
        body: broadcastData.body.trim(),
        targetType: broadcastData.targetType,
        segments: broadcastData.segments.length > 0 ? broadcastData.segments : undefined,
        actionUrl: broadcastData.actionUrl.trim() || undefined,
      });
      
      toast.success('Broadcast created successfully');
      setBroadcastModalOpen(false);
      setBroadcastData({
        title: '',
        body: '',
        targetType: 'all',
        segments: [],
        actionUrl: '',
      });
      
      // Refresh list
      const response = await NotificationsAPI.listNotificationRequests({
        page,
        limit: pageSize,
        status: statusFilter || undefined,
        search: search.trim() || undefined,
      });
      setNotifications(response.data || []);
      setTotal(response.meta?.total || 0);
    } catch (error: any) {
      console.error('Failed to create broadcast:', error);
      toast.error(error?.message || 'Failed to create broadcast');
    } finally {
      setCreating(false);
    }
  };

  const totalPages = Math.ceil(total / pageSize);

  const columns = [
    {
      key: 'title',
      label: 'Notification',
      sortable: false,
      render: (_: any, row: NotificationRequest) => (
        <div className="flex items-center gap-3">
          <div className="w-10 h-10 bg-[#0e1a30]/10 rounded-full flex items-center justify-center">
            <Icon icon={faPaperPlane} className="text-[#0e1a30]" size="sm" />
          </div>
          <div>
            <p className="text-sm font-medium text-gray-900">{row?.title || '-'}</p>
            <p className="text-xs text-gray-500 line-clamp-1">{row?.body || ''}</p>
          </div>
        </div>
      ),
    },
    {
      key: 'requester',
      label: 'Requester',
      sortable: false,
      render: (_: any, row: NotificationRequest) => (
        <span className="text-sm text-gray-900">
          {row?.requester?.fullName || row?.requester?.email || '-'}
        </span>
      ),
    },
    {
      key: 'targetType',
      label: 'Target',
      sortable: false,
      render: (_: any, row: NotificationRequest) => (
        <span className="text-sm text-gray-900">{row?.targetType || '-'}</span>
      ),
    },
    {
      key: 'status',
      label: 'Status',
      sortable: false,
      render: (_: any, row: NotificationRequest) => (
        <span className={`inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium ${getStatusBadgeColor(row?.status || 'pending')}`}>
          {row?.status?.replace(/_/g, ' ') || '-'}
        </span>
      ),
    },
    {
      key: 'date',
      label: 'Date',
      sortable: false,
      render: (_: any, row: NotificationRequest) => (
        <p className="text-sm text-gray-900">
          {row?.createdAt ? new Date(row.createdAt).toLocaleDateString('en-US', {
            month: 'short',
            day: 'numeric',
            year: 'numeric',
          }) : '-'}
        </p>
      ),
    },
  ];

  if (loading && notifications.length === 0) {
    return <PageSkeleton />;
  }

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex items-center justify-between flex-wrap gap-4">
        <div>
          <h1 className="text-2xl font-bold text-gray-900">Notifications</h1>
          <p className="text-gray-600 mt-1">Manage notification requests and broadcasts</p>
        </div>
        <Button
          variant="primary"
          size="md"
          icon={faPlus}
          onClick={() => setBroadcastModalOpen(true)}
        >
          Create Broadcast
        </Button>
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
                placeholder="Search by title/body..."
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
                setStatusFilter(e.target.value as ApprovalStatus | '');
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
        </div>
      </div>

      {/* Table */}
      <DataTable
        columns={columns}
        data={notifications}
        loading={loading}
        onRowClick={(row) => router.push(`/dashboard/notifications/${row.id}`)}
        emptyMessage="No notifications found"
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

      {/* Create Broadcast Modal */}
      <Modal
        isOpen={broadcastModalOpen}
        onClose={() => {
          setBroadcastModalOpen(false);
          setBroadcastData({
            title: '',
            body: '',
            targetType: 'all',
            segments: [],
            actionUrl: '',
          });
        }}
        title="Create Broadcast"
        size="lg"
      >
        <div className="space-y-4">
          <Input
            label="Title"
            value={broadcastData.title}
            onChange={(e) => setBroadcastData({ ...broadcastData, title: e.target.value })}
            placeholder="Enter notification title"
            required
          />
          <Textarea
            label="Body"
            value={broadcastData.body}
            onChange={(e) => setBroadcastData({ ...broadcastData, body: e.target.value })}
            placeholder="Enter notification message"
            rows={4}
            required
          />
          <Select
            label="Target Type"
            value={broadcastData.targetType}
            onChange={(e) => setBroadcastData({ ...broadcastData, targetType: e.target.value })}
            options={[
              { value: 'all', label: 'All Users' },
              { value: 'explorers', label: 'Explorers' },
              { value: 'merchants', label: 'Merchants' },
              { value: 'event_organizers', label: 'Event Organizers' },
            ]}
          />
          <Input
            label="Action URL (optional)"
            value={broadcastData.actionUrl}
            onChange={(e) => setBroadcastData({ ...broadcastData, actionUrl: e.target.value })}
            placeholder="https://..."
          />
          <div className="flex items-center gap-2 justify-end pt-4 border-t border-gray-200">
            <Button
              variant="secondary"
              size="md"
              onClick={() => {
                setBroadcastModalOpen(false);
                setBroadcastData({
                  title: '',
                  body: '',
                  targetType: 'all',
                  segments: [],
                  actionUrl: '',
                });
              }}
              disabled={creating}
            >
              Cancel
            </Button>
            <Button
              variant="primary"
              size="md"
              onClick={handleCreateBroadcast}
              loading={creating}
            >
              Create Broadcast
            </Button>
          </div>
        </div>
      </Modal>
    </div>
  );
}

