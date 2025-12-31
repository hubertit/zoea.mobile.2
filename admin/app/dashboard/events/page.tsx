'use client';

import { useState, useEffect } from 'react';
import { useRouter } from 'next/navigation';
import { EventsAPI, UsersAPI, LocationsAPI, type Event, type EventStatus, type CreateEventParams, type User, type Country, type City } from '@/src/lib/api';
import Icon, { faSearch, faPlus, faTimes, faCalendar, faChevronDown, faChevronUp } from '@/app/components/Icon';
import { toast } from '@/app/components/Toaster';
import { DataTable, Pagination, Button, Modal, Input, Select, Textarea } from '@/app/components';
import PageSkeleton from '@/app/components/PageSkeleton';
import { useDebounce } from '@/src/hooks/useDebounce';

const STATUSES: { value: EventStatus | ''; label: string }[] = [
  { value: '', label: 'All Status' },
  { value: 'draft', label: 'Draft' },
  { value: 'pending_review', label: 'Pending Review' },
  { value: 'published', label: 'Published' },
  { value: 'ongoing', label: 'Ongoing' },
  { value: 'completed', label: 'Completed' },
  { value: 'cancelled', label: 'Cancelled' },
  { value: 'suspended', label: 'Suspended' },
];

const getStatusBadgeColor = (status: EventStatus) => {
  switch (status) {
    case 'published':
    case 'ongoing':
      return 'bg-green-100 text-green-800';
    case 'pending_review':
      return 'bg-yellow-100 text-yellow-800';
    case 'cancelled':
    case 'suspended':
      return 'bg-red-100 text-red-800';
    case 'completed':
      return 'bg-blue-100 text-blue-800';
    default:
      return 'bg-gray-100 text-gray-800';
  }
};

export default function EventsPage() {
  const router = useRouter();
  const [events, setEvents] = useState<Event[]>([]);
  const [loading, setLoading] = useState(true);
  const [page, setPage] = useState(1);
  const [pageSize, setPageSize] = useState(10);
  const [total, setTotal] = useState(0);
  const [search, setSearch] = useState('');
  const debouncedSearch = useDebounce(search, 500);
  const [statusFilter, setStatusFilter] = useState<EventStatus | ''>('');
  const [showCreateModal, setShowCreateModal] = useState(false);
  const [creating, setCreating] = useState(false);
  const [organizerUsers, setOrganizerUsers] = useState<User[]>([]);
  const [countries, setCountries] = useState<Country[]>([]);
  const [cities, setCities] = useState<City[]>([]);
  const [showAdvancedFilters, setShowAdvancedFilters] = useState(false);
  const [organizerFilter, setOrganizerFilter] = useState<string>('');
  const [countryFilter, setCountryFilter] = useState<string>('');
  const [cityFilter, setCityFilter] = useState<string>('');
  const [dateFrom, setDateFrom] = useState('');
  const [dateTo, setDateTo] = useState('');
  const [filterCities, setFilterCities] = useState<City[]>([]);
  const [allOrganizers, setAllOrganizers] = useState<User[]>([]);
  const [formData, setFormData] = useState<Partial<CreateEventParams>>({
    organizerId: '',
    name: '',
    description: '',
    privacy: undefined,
    setup: undefined,
    countryId: '',
    cityId: '',
    address: '',
    startDate: '',
    endDate: '',
    maxAttendance: undefined,
  });

  useEffect(() => {
    const fetchEvents = async () => {
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

        const response = await EventsAPI.listEvents(params);
        
        // Client-side filtering for location, organizer, and date
        let filteredData = response.data || [];
        
        if (organizerFilter) {
          filteredData = filteredData.filter((event: Event) => event.organizerId === organizerFilter);
        }
        
        if (countryFilter) {
          filteredData = filteredData.filter((event: Event) => event.countryId === countryFilter);
        }
        
        if (cityFilter) {
          filteredData = filteredData.filter((event: Event) => event.cityId === cityFilter);
        }
        
        if (dateFrom || dateTo) {
          filteredData = filteredData.filter((event: Event) => {
            if (!event.startDate) return false;
            const eventDate = new Date(event.startDate);
            if (dateFrom && eventDate < new Date(dateFrom)) return false;
            if (dateTo) {
              const toDate = new Date(dateTo);
              toDate.setHours(23, 59, 59, 999);
              if (eventDate > toDate) return false;
            }
            return true;
          });
        }
        
        setEvents(filteredData);
        setTotal(filteredData.length);
      } catch (error: any) {
        console.error('Failed to fetch events:', error);
        toast.error(error?.message || 'Failed to load events');
      } finally {
        setLoading(false);
      }
    };

    fetchEvents();
  }, [page, pageSize, debouncedSearch, statusFilter, organizerFilter, countryFilter, cityFilter, dateFrom, dateTo]);

  // Fetch organizers, countries for filters and create modal
  useEffect(() => {
    const fetchData = async () => {
      try {
        const [organizersRes, countriesRes] = await Promise.all([
          UsersAPI.listUsers({ role: 'event_organizer', limit: 100, page: 1 }),
          LocationsAPI.getCountries(),
        ]);
        setAllOrganizers(organizersRes.data || []);
        setOrganizerUsers(organizersRes.data || []);
        setCountries(countriesRes || []);
      } catch (error: any) {
        console.error('Failed to fetch data:', error);
      }
    };
    fetchData();
  }, []);

  // Fetch cities when country filter changes
  useEffect(() => {
    if (countryFilter) {
      LocationsAPI.getCities(countryFilter).then(setFilterCities).catch(console.error);
    } else {
      setFilterCities([]);
      setCityFilter('');
    }
  }, [countryFilter]);

  // Fetch cities when country changes
  useEffect(() => {
    if (formData.countryId) {
      LocationsAPI.getCities(formData.countryId).then(setCities).catch(console.error);
    } else {
      setCities([]);
    }
  }, [formData.countryId]);

  const totalPages = Math.ceil(total / pageSize);

  const columns = [
    {
      key: 'name',
      label: 'Event Name',
      sortable: true,
      render: (_: any, row: Event) => (
        <div className="flex items-center gap-3">
          <div className="w-10 h-10 bg-[#0e1a30]/10 rounded-full flex items-center justify-center">
            <Icon icon={faCalendar} className="text-[#0e1a30]" size="sm" />
          </div>
          <div>
            <p className="text-sm font-medium text-gray-900">{row?.name || '-'}</p>
            {row?.organizer && (
              <p className="text-xs text-gray-500">{row.organizer.organizationName}</p>
            )}
          </div>
        </div>
      ),
    },
    {
      key: 'startDate',
      label: 'Dates',
      sortable: true,
      render: (_: any, row: Event) => (
        <div>
          {row?.startDate && (
            <p className="text-sm text-gray-900">
              {new Date(row.startDate).toLocaleDateString('en-US', {
                month: 'short',
                day: 'numeric',
                year: 'numeric',
              })}
            </p>
          )}
          {row?.endDate && row.endDate !== row.startDate && (
            <p className="text-xs text-gray-500">
              to {new Date(row.endDate).toLocaleDateString('en-US', {
                month: 'short',
                day: 'numeric',
              })}
            </p>
          )}
          {!row?.startDate && <span className="text-sm text-gray-400">-</span>}
        </div>
      ),
    },
    {
      key: 'location',
      label: 'Location',
      sortable: false,
      render: (_: any, row: Event) => (
        <div>
          {row?.city?.name && (
            <p className="text-sm text-gray-900">{row.city.name}</p>
          )}
          {row?.address && (
            <p className="text-xs text-gray-500">{row.address}</p>
          )}
          {!row?.city && !row?.address && (
            <span className="text-sm text-gray-400">-</span>
          )}
        </div>
      ),
    },
    {
      key: 'status',
      label: 'Status',
      sortable: false,
      render: (_: any, row: Event) => (
        <span className={`inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium ${getStatusBadgeColor(row?.status || 'draft')}`}>
          {row?.status?.replace(/_/g, ' ') || '-'}
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
          <h1 className="text-2xl font-bold text-gray-900">Events</h1>
          <p className="text-gray-600 mt-1">Manage events and activities</p>
        </div>
        <Button variant="primary" size="md" icon={faPlus} onClick={() => setShowCreateModal(true)}>
          Create Event
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
                placeholder="Search by name or organizer..."
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
                setStatusFilter(e.target.value as EventStatus | '');
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
            <div className="grid grid-cols-1 md:grid-cols-5 gap-4">
              {/* Organizer Filter */}
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  Organizer
                </label>
                <select
                  value={organizerFilter}
                  onChange={(e) => {
                    setOrganizerFilter(e.target.value);
                    setPage(1);
                  }}
                  className="w-full px-3 py-2 border border-gray-200 rounded-sm focus:outline-none focus:ring-1 focus:ring-[#0e1a30] focus:border-[#0e1a30] text-sm"
                >
                  <option value="">All Organizers</option>
                  {allOrganizers.map((organizer) => (
                    <option key={organizer.id} value={organizer.id}>
                      {organizer.fullName || organizer.email || organizer.phoneNumber}
                    </option>
                  ))}
                </select>
              </div>

              {/* Country Filter */}
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  Country
                </label>
                <select
                  value={countryFilter}
                  onChange={(e) => {
                    setCountryFilter(e.target.value);
                    setPage(1);
                  }}
                  className="w-full px-3 py-2 border border-gray-200 rounded-sm focus:outline-none focus:ring-1 focus:ring-[#0e1a30] focus:border-[#0e1a30] text-sm"
                >
                  <option value="">All Countries</option>
                  {countries.map((country) => (
                    <option key={country.id} value={country.id}>
                      {country.name}
                    </option>
                  ))}
                </select>
              </div>

              {/* City Filter */}
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  City
                </label>
                <select
                  value={cityFilter}
                  onChange={(e) => {
                    setCityFilter(e.target.value);
                    setPage(1);
                  }}
                  disabled={!countryFilter}
                  className="w-full px-3 py-2 border border-gray-200 rounded-sm focus:outline-none focus:ring-1 focus:ring-[#0e1a30] focus:border-[#0e1a30] text-sm disabled:bg-gray-100 disabled:cursor-not-allowed"
                >
                  <option value="">All Cities</option>
                  {filterCities.map((city) => (
                    <option key={city.id} value={city.id}>
                      {city.name}
                    </option>
                  ))}
                </select>
              </div>

              {/* Start Date From */}
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  Start Date From
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

              {/* Start Date To */}
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  Start Date To
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
            </div>

            {/* Clear Filters */}
            {(organizerFilter || countryFilter || cityFilter || dateFrom || dateTo) && (
              <div className="mt-4 flex justify-end">
                <Button
                  variant="ghost"
                  size="sm"
                  onClick={() => {
                    setOrganizerFilter('');
                    setCountryFilter('');
                    setCityFilter('');
                    setDateFrom('');
                    setDateTo('');
                    setPage(1);
                  }}
                >
                  Clear Advanced Filters
                </Button>
              </div>
            )}
          </div>
        )}
      </div>

      {/* Table */}
      <DataTable
        columns={columns}
        data={events}
        loading={loading}
        onRowClick={(row) => router.push(`/dashboard/events/${row.id}`)}
        emptyMessage="No events found"
        showNumbering={true}
        numberingStart={(page - 1) * pageSize + 1}
        enableClientSort={true}
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

      {/* Create Event Modal */}
      <Modal
        isOpen={showCreateModal}
        onClose={() => {
          setShowCreateModal(false);
          setFormData({
            organizerId: '',
            name: '',
            description: '',
            privacy: undefined,
            setup: undefined,
            countryId: '',
            cityId: '',
            address: '',
            startDate: '',
            endDate: '',
            maxAttendance: undefined,
          });
        }}
        title="Create New Event"
        size="lg"
      >
        <div className="space-y-4 max-h-[70vh] overflow-y-auto">
          <div className="grid grid-cols-2 gap-4">
            <div className="col-span-2">
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Organizer (User) <span className="text-red-500">*</span>
              </label>
              <Select
                value={formData.organizerId || ''}
                onChange={(e) => setFormData({ ...formData, organizerId: e.target.value })}
                options={[
                  { value: '', label: 'Select organizer user' },
                  ...organizerUsers.map(u => ({ value: u.id, label: `${u.fullName || u.email || u.phoneNumber} (${u.email || u.phoneNumber})` })),
                ]}
              />
              <p className="text-xs text-gray-500 mt-1">Note: The user must have an organizer profile. If not, create one first.</p>
            </div>

            <div className="col-span-2">
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Event Name <span className="text-red-500">*</span>
              </label>
              <Input
                value={formData.name || ''}
                onChange={(e) => setFormData({ ...formData, name: e.target.value })}
                placeholder="Enter event name"
              />
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Privacy
              </label>
              <Select
                value={formData.privacy || ''}
                onChange={(e) => setFormData({ ...formData, privacy: e.target.value as any || undefined })}
                options={[
                  { value: '', label: 'Select privacy' },
                  { value: 'public', label: 'Public' },
                  { value: 'private', label: 'Private' },
                  { value: 'invite_only', label: 'Invite Only' },
                ]}
              />
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Setup
              </label>
              <Select
                value={formData.setup || ''}
                onChange={(e) => setFormData({ ...formData, setup: e.target.value as any || undefined })}
                options={[
                  { value: '', label: 'Select setup' },
                  { value: 'in_person', label: 'In Person' },
                  { value: 'virtual', label: 'Virtual' },
                  { value: 'hybrid', label: 'Hybrid' },
                ]}
              />
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Country
              </label>
              <Select
                value={formData.countryId || ''}
                onChange={(e) => setFormData({ ...formData, countryId: e.target.value || undefined, cityId: '' })}
                options={[
                  { value: '', label: 'Select country' },
                  ...countries.map(c => ({ value: c.id, label: c.name })),
                ]}
              />
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                City
              </label>
              <Select
                value={formData.cityId || ''}
                onChange={(e) => setFormData({ ...formData, cityId: e.target.value || undefined })}
                options={[
                  { value: '', label: 'Select city' },
                  ...cities.map(c => ({ value: c.id, label: c.name })),
                ]}
                disabled={!formData.countryId}
              />
            </div>

            <div className="col-span-2">
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Address
              </label>
              <Input
                value={formData.address || ''}
                onChange={(e) => setFormData({ ...formData, address: e.target.value || undefined })}
                placeholder="Enter address"
              />
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Start Date
              </label>
              <Input
                type="datetime-local"
                value={formData.startDate || ''}
                onChange={(e) => setFormData({ ...formData, startDate: e.target.value || undefined })}
              />
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                End Date
              </label>
              <Input
                type="datetime-local"
                value={formData.endDate || ''}
                onChange={(e) => setFormData({ ...formData, endDate: e.target.value || undefined })}
              />
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Max Attendance
              </label>
              <Input
                type="number"
                value={formData.maxAttendance || ''}
                onChange={(e) => setFormData({ ...formData, maxAttendance: e.target.value ? parseInt(e.target.value) : undefined })}
                placeholder="0"
              />
            </div>

            <div className="col-span-2">
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Description
              </label>
              <Textarea
                value={formData.description || ''}
                onChange={(e) => setFormData({ ...formData, description: e.target.value || undefined })}
                placeholder="Enter event description"
                rows={4}
              />
            </div>
          </div>

          <div className="flex justify-end gap-3 pt-4 border-t border-gray-200">
            <Button
              variant="outline"
              onClick={() => {
                setShowCreateModal(false);
                setFormData({
                  organizerId: '',
                  name: '',
                  description: '',
                  privacy: undefined,
                  setup: undefined,
                  countryId: '',
                  cityId: '',
                  address: '',
                  startDate: '',
                  endDate: '',
                  maxAttendance: undefined,
                });
              }}
            >
              Cancel
            </Button>
            <Button
              variant="primary"
              onClick={async () => {
                if (!formData.organizerId || !formData.name) {
                  toast.error('Please provide organizer and event name');
                  return;
                }
                
                setCreating(true);
                try {
                  await EventsAPI.createEvent(formData as CreateEventParams);
                  toast.success('Event created successfully');
                  setShowCreateModal(false);
                  setFormData({
                    organizerId: '',
                    name: '',
                    description: '',
                    privacy: undefined,
                    setup: undefined,
                    countryId: '',
                    cityId: '',
                    address: '',
                    startDate: '',
                    endDate: '',
                    maxAttendance: undefined,
                  });
                  // Refresh events
                  const response = await EventsAPI.listEvents({ page, limit: pageSize });
                  setEvents(response.data || []);
                  setTotal(response.meta?.total || 0);
                } catch (error: any) {
                  console.error('Failed to create event:', error);
                  toast.error(error?.response?.data?.message || error?.message || 'Failed to create event');
                } finally {
                  setCreating(false);
                }
              }}
              loading={creating}
            >
              Create Event
            </Button>
          </div>
        </div>
      </Modal>
    </div>
  );
}

