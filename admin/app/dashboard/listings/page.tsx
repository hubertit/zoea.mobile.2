'use client';

import { useState, useEffect } from 'react';
import { useRouter, useSearchParams } from 'next/navigation';
import Link from 'next/link';
import { ListingsAPI, CategoriesAPI, MerchantsAPI, LocationsAPI, UsersAPI, MediaAPI, CountriesAPI, type Listing, type ListingStatus, type ListingType, type Category, type CreateListingParams, type Merchant, type Country, type City, type User } from '@/src/lib/api';
import apiClient from '@/src/lib/api/client';
import Icon, { faSearch, faPlus, faTimes, faBox, faTags, faChevronDown, faChevronUp, faImage } from '@/app/components/Icon';
import { toast } from '@/app/components/Toaster';
import { DataTable, Pagination, Button, Modal, Input, Select, Textarea, Breadcrumbs } from '@/app/components';
import PageSkeleton from '@/app/components/PageSkeleton';
import { useDebounce } from '@/src/hooks/useDebounce';

const STATUSES: { value: ListingStatus | ''; label: string }[] = [
  { value: '', label: 'All Status' },
  { value: 'draft', label: 'Draft' },
  { value: 'pending_review', label: 'Pending Review' },
  { value: 'active', label: 'Active' },
  { value: 'inactive', label: 'Inactive' },
  { value: 'suspended', label: 'Suspended' },
];

const TYPES: { value: ListingType | ''; label: string }[] = [
  { value: '', label: 'All Types' },
  { value: 'hotel', label: 'Hotel' },
  { value: 'restaurant', label: 'Restaurant' },
  { value: 'tour', label: 'Tour' },
  { value: 'event', label: 'Event' },
  { value: 'attraction', label: 'Attraction' },
  { value: 'bar', label: 'Bar' },
  { value: 'club', label: 'Club' },
  { value: 'lounge', label: 'Lounge' },
  { value: 'cafe', label: 'Cafe' },
  { value: 'fast_food', label: 'Fast Food' },
  { value: 'mall', label: 'Mall' },
  { value: 'market', label: 'Market' },
  { value: 'boutique', label: 'Boutique' },
];

const getStatusBadgeColor = (status: ListingStatus) => {
  switch (status) {
    case 'active':
      return 'bg-green-100 text-green-800';
    case 'pending_review':
      return 'bg-yellow-100 text-yellow-800';
    case 'suspended':
      return 'bg-red-100 text-red-800';
    case 'inactive':
      return 'bg-gray-100 text-gray-800';
    default:
      return 'bg-gray-100 text-gray-800';
  }
};

export default function ListingsPage() {
  const router = useRouter();
  const searchParams = useSearchParams();
  const [listings, setListings] = useState<Listing[]>([]);
  const [categories, setCategories] = useState<Category[]>([]);
  const [loading, setLoading] = useState(true);
  const [page, setPage] = useState(1);
  const [pageSize, setPageSize] = useState(10);
  const [total, setTotal] = useState(0);
  const [search, setSearch] = useState('');
  const debouncedSearch = useDebounce(search, 500);
  const [statusFilter, setStatusFilter] = useState<ListingStatus | ''>('');
  const [typeFilter, setTypeFilter] = useState<ListingType | ''>('');
  const [categoryFilter, setCategoryFilter] = useState<string>('');
  const [showCreateModal, setShowCreateModal] = useState(false);
  const [creating, setCreating] = useState(false);
  const [merchants, setMerchants] = useState<Merchant[]>([]);
  const [countries, setCountries] = useState<Country[]>([]);
  const [cities, setCities] = useState<Array<{ id: string; name: string; slug: string; countryId: string; isActive?: boolean }>>([]);
  const [users, setUsers] = useState<User[]>([]);
  const [showAdvancedFilters, setShowAdvancedFilters] = useState(false);
  const [countryFilter, setCountryFilter] = useState<string>('');
  const [cityFilter, setCityFilter] = useState<string>('');
  const [dateFrom, setDateFrom] = useState('');
  const [dateTo, setDateTo] = useState('');
  const [filterCities, setFilterCities] = useState<Array<{ id: string; name: string; slug: string; countryId: string; isActive?: boolean }>>([]);
  const [showNewMerchantForm, setShowNewMerchantForm] = useState(false);
  const [creatingMerchant, setCreatingMerchant] = useState(false);
  const [uploadedImages, setUploadedImages] = useState<Array<{ id: string; url: string; isPrimary?: boolean }>>([]);
  const [uploadingImage, setUploadingImage] = useState(false);
  const [googlePlacesKey, setGooglePlacesKey] = useState<string>('');
  const [fastOnboarding, setFastOnboarding] = useState(true); // Enable fast onboarding by default
  const [formData, setFormData] = useState<Partial<CreateListingParams>>({
    merchantId: '',
    name: '',
    description: '',
    shortDescription: '',
    type: undefined,
    categoryId: '',
    countryId: '',
    cityId: '',
    address: '',
    latitude: undefined,
    longitude: undefined,
    minPrice: undefined,
    maxPrice: undefined,
    contactPhone: '',
    contactEmail: '',
    website: '',
    status: 'draft',
  });
  const [merchantFormData, setMerchantFormData] = useState({
    userId: '',
    businessName: '',
    businessType: '' as ListingType | '',
    businessEmail: '',
    businessPhone: '',
    website: '',
    countryId: '',
    cityId: '',
    address: '',
  });
  const [userFormData, setUserFormData] = useState({
    fullName: '',
    email: '',
    phoneNumber: '',
    password: 'TempPass123!', // Default password for fast onboarding
  });

  // Get categoryId from URL params
  useEffect(() => {
    const categoryId = searchParams.get('categoryId');
    if (categoryId) {
      setCategoryFilter(categoryId);
    }
  }, [searchParams]);

  // Fetch categories and countries
  useEffect(() => {
    const fetchData = async () => {
        try {
          const [categoriesData, countriesData] = await Promise.all([
            CategoriesAPI.listCategories({ flat: true }),
            CountriesAPI.getActiveCountries(),
          ]);
        setCategories(categoriesData);
        setCountries(countriesData || []);
      } catch (error: any) {
        console.error('Failed to fetch data:', error);
      }
    };
    fetchData();
  }, []);

  // Fetch cities when country filter changes
  useEffect(() => {
    if (countryFilter) {
      CountriesAPI.getCitiesByCountry(countryFilter).then(setFilterCities).catch(console.error);
    } else {
      setFilterCities([]);
      setCityFilter('');
    }
  }, [countryFilter]);

  // Fetch merchants, countries, cities, users, Google API key for create modal
  useEffect(() => {
    if (showCreateModal) {
      const fetchData = async () => {
        try {
          const [merchantsRes, countriesRes, usersRes] = await Promise.all([
            MerchantsAPI.listMerchants({ limit: 100, page: 1 }),
            CountriesAPI.getActiveCountries(),
            UsersAPI.listUsers({ limit: 100, page: 1 }),
          ]);
          setMerchants(merchantsRes.data || []);
          setCountries(countriesRes || []);
          setUsers(usersRes.data || []);
          
          // Fetch Google Places API key from integrations
          try {
            const integrationsRes = await apiClient.get('/integrations/google_places').catch(() => null);
            if (integrationsRes?.data?.config?.apiKey) {
              setGooglePlacesKey(integrationsRes.data.config.apiKey);
            }
          } catch (e) {
            console.warn('Could not fetch Google Places API key:', e);
          }
        } catch (error: any) {
          console.error('Failed to fetch data:', error);
        }
      };
      fetchData();
    }
  }, [showCreateModal]);

  // Fetch cities when country changes (for listing form)
  useEffect(() => {
    const fetchCities = async () => {
      if (formData.countryId) {
        try {
          const citiesData = await CountriesAPI.getCitiesByCountry(formData.countryId);
          setCities(citiesData || []);
        } catch (error) {
          console.error('Failed to fetch cities:', error);
          setCities([]);
        }
      } else {
        setCities([]);
        setFormData((prev) => ({ ...prev, cityId: '' }));
      }
    };
    fetchCities();
  }, [formData.countryId]);

  // Fetch cities when merchant form country changes
  useEffect(() => {
    if (merchantFormData.countryId) {
      CountriesAPI.getCitiesByCountry(merchantFormData.countryId).then((citiesData) => {
        // Update cities state if needed, but we'll use a separate state for merchant form
      }).catch(console.error);
    }
  }, [merchantFormData.countryId]);

  // Load Google Places script and initialize autocomplete when key is available
  useEffect(() => {
    if (!googlePlacesKey || !showCreateModal || typeof window === 'undefined') return;

    let autocompleteInstances: any[] = [];

    const initializeAutocomplete = () => {
      // Wait a bit for DOM to be ready
      setTimeout(() => {
        // Initialize autocomplete for listing address
        const listingAddressInput = document.getElementById('listing-address-autocomplete') as HTMLInputElement;
        if (listingAddressInput && (window as any).google?.maps?.places) {
          // Remove existing autocomplete if any
          const existingAutocomplete = (listingAddressInput as any).autocomplete;
          if (existingAutocomplete) {
            (window as any).google.maps.event.clearInstanceListeners(existingAutocomplete);
          }

          const autocomplete = new (window as any).google.maps.places.Autocomplete(listingAddressInput, {
            types: ['establishment', 'geocode'],
            componentRestrictions: { country: ['rw'] },
          });
          
          (listingAddressInput as any).autocomplete = autocomplete;
          autocompleteInstances.push(autocomplete);

          autocomplete.addListener('place_changed', () => {
            const place = autocomplete.getPlace();
            if (place.formatted_address && place.geometry?.location) {
              const lat = place.geometry.location.lat();
              const lng = place.geometry.location.lng();
              setFormData((prev) => ({
                ...prev,
                address: place.formatted_address,
                latitude: typeof lat === 'number' ? Number(lat.toFixed(7)) : undefined,
                longitude: typeof lng === 'number' ? Number(lng.toFixed(7)) : undefined,
              }));
              
              // Auto-populate name if not set
              if (!formData.name && place.name) {
                setFormData((prev) => ({ ...prev, name: place.name }));
                if (fastOnboarding) {
                  setUserFormData((prev) => ({ ...prev, fullName: place.name }));
                  setMerchantFormData((prev) => ({ ...prev, businessName: place.name }));
                }
              }
            }
          });
        }

        // Initialize autocomplete for merchant address
        const merchantAddressInput = document.getElementById('merchant-address-autocomplete') as HTMLInputElement;
        if (merchantAddressInput && (window as any).google?.maps?.places) {
          const existingAutocomplete = (merchantAddressInput as any).autocomplete;
          if (existingAutocomplete) {
            (window as any).google.maps.event.clearInstanceListeners(existingAutocomplete);
          }

          const autocomplete = new (window as any).google.maps.places.Autocomplete(merchantAddressInput, {
            types: ['establishment', 'geocode'],
            componentRestrictions: { country: ['rw'] },
          });
          
          (merchantAddressInput as any).autocomplete = autocomplete;
          autocompleteInstances.push(autocomplete);

          autocomplete.addListener('place_changed', () => {
            const place = autocomplete.getPlace();
            if (place.formatted_address) {
              setMerchantFormData((prev) => ({ ...prev, address: place.formatted_address }));
            }
          });
        }
      }, 200);
    };

    // Check if script already exists
    const existingScript = document.querySelector('script[src*="maps.googleapis.com"]');
    if (existingScript && (window as any).google?.maps?.places) {
      // Script already loaded, initialize autocomplete
      initializeAutocomplete();
    } else if (!existingScript) {
      // Load Google Maps script
      const script = document.createElement('script');
      script.src = `https://maps.googleapis.com/maps/api/js?key=${googlePlacesKey}&libraries=places`;
      script.async = true;
      script.defer = true;
      
      script.onload = () => {
        // Wait a bit for Google Maps to fully initialize
        setTimeout(() => {
          if ((window as any).google?.maps?.places) {
            initializeAutocomplete();
          } else {
            console.error('Google Maps Places library not loaded');
            toast.error('Google Maps Places library failed to load');
          }
        }, 500);
      };
      
      script.onerror = () => {
        console.error('Failed to load Google Maps script');
        toast.error('Failed to load Google Maps. Please check your API key.');
      };
      document.head.appendChild(script);
    } else if (existingScript && !(window as any).google?.maps?.places) {
      // Script exists but not loaded yet, wait for it
      (existingScript as HTMLScriptElement).addEventListener('load', () => {
        setTimeout(initializeAutocomplete, 500);
      });
    }

    // Cleanup
    return () => {
      autocompleteInstances.forEach(instance => {
        if (instance && (window as any).google?.maps?.event) {
          (window as any).google.maps.event.clearInstanceListeners(instance);
        }
      });
    };
  }, [googlePlacesKey, showCreateModal, fastOnboarding, formData.name]);

  // Fetch listings
  useEffect(() => {
    const fetchListings = async () => {
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

        if (typeFilter) {
          params.type = typeFilter;
        }

        if (categoryFilter) {
          params.categoryId = categoryFilter;
        }

        const response = await ListingsAPI.listListings(params);
        setListings(response.data || []);
        setTotal(response.meta?.total || 0);
      } catch (error: any) {
        console.error('Failed to fetch listings:', error);
        toast.error(error?.message || 'Failed to load listings');
      } finally {
        setLoading(false);
      }
    };

    fetchListings();
  }, [page, pageSize, debouncedSearch, statusFilter, typeFilter, categoryFilter, countryFilter, cityFilter, dateFrom, dateTo]);

  const totalPages = Math.ceil(total / pageSize);

  const columns = [
    {
      key: 'name',
      label: 'Name',
      sortable: true,
      render: (_: any, row: Listing) => (
        <div className="flex items-center gap-3">
          <div className="w-10 h-10 bg-[#0e1a30]/10 rounded-full flex items-center justify-center">
            <Icon icon={faBox} className="text-[#0e1a30]" size="sm" />
          </div>
          <div>
            <p className="text-sm font-medium text-gray-900">{row?.name || '-'}</p>
            {row?.type && (
              <p className="text-xs text-gray-500">{row.type.replace(/_/g, ' ')}</p>
            )}
          </div>
        </div>
      ),
    },
    {
      key: 'merchant.businessName',
      label: 'Merchant',
      sortable: true,
      render: (_: any, row: Listing) => (
        <span className="text-sm text-gray-900">{row?.merchant?.businessName || '-'}</span>
      ),
    },
    {
      key: 'category',
      label: 'Category',
      sortable: false,
      render: (_: any, row: Listing) => (
        row?.category ? (
          <Link href={`/dashboard/categories/${row.category.id}`} className="text-sm text-[#0e1a30] hover:underline">
            {row.category.name}
          </Link>
        ) : (
          <span className="text-sm text-gray-400">-</span>
        )
      ),
    },
    {
      key: 'location',
      label: 'Location',
      sortable: false,
      render: (_: any, row: Listing) => (
        <div>
          {row?.city?.name && (
            <p className="text-sm text-gray-900">{row.city.name}</p>
          )}
          {row?.country?.name && (
            <p className="text-xs text-gray-500">{row.country.name}</p>
          )}
          {!row?.city && !row?.country && (
            <span className="text-sm text-gray-400">-</span>
          )}
        </div>
      ),
    },
    {
      key: 'status',
      label: 'Status',
      sortable: false,
      render: (_: any, row: Listing) => (
        <span className={`inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium ${getStatusBadgeColor(row?.status || 'draft')}`}>
          {row?.status?.replace(/_/g, ' ') || '-'}
        </span>
      ),
    },
    {
      key: 'features',
      label: 'Features',
      sortable: false,
      render: (_: any, row: Listing) => (
        <div className="flex flex-wrap gap-1">
          {row?.isFeatured && (
            <span className="inline-flex items-center px-2 py-0.5 rounded text-xs font-medium bg-blue-100 text-blue-800">
              Featured
            </span>
          )}
          {row?.isVerified && (
            <span className="inline-flex items-center px-2 py-0.5 rounded text-xs font-medium bg-green-100 text-green-800">
              Verified
            </span>
          )}
          {!row?.isFeatured && !row?.isVerified && (
            <span className="text-xs text-gray-400">-</span>
          )}
        </div>
      ),
    },
  ];

  if (loading) {
    return <PageSkeleton />;
  }

  return (
    <div className="space-y-6">
      <Breadcrumbs items={[{ label: 'Listings' }]} />
      
      {/* Header */}
      <div className="flex items-center justify-between flex-wrap gap-4">
        <div>
          <h1 className="text-2xl font-bold text-gray-900">Listings</h1>
          <p className="text-gray-600 mt-1">Manage business listings and venues</p>
        </div>
        <Button variant="primary" size="md" icon={faPlus} onClick={() => setShowCreateModal(true)}>
          Create Listing
        </Button>
      </div>

      {/* Filters */}
      <div className="bg-white border border-gray-200 rounded-sm p-4">
        <div className="grid grid-cols-1 md:grid-cols-5 gap-4">
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
                placeholder="Search by name, merchant..."
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
                setStatusFilter(e.target.value as ListingStatus | '');
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

          {/* Type Filter */}
          <div>
            <select
              value={typeFilter}
              onChange={(e) => {
                setTypeFilter(e.target.value as ListingType | '');
                setPage(1);
              }}
              className="w-full px-3 py-2 border border-gray-200 rounded-sm focus:outline-none focus:ring-1 focus:ring-[#0e1a30] focus:border-[#0e1a30] text-sm"
            >
              {TYPES.map((type) => (
                <option key={type.value} value={type.value}>
                  {type.label}
                </option>
              ))}
            </select>
          </div>

          {/* Category Filter */}
          <div>
            <select
              value={categoryFilter}
              onChange={(e) => {
                setCategoryFilter(e.target.value);
                setPage(1);
                // Update URL without navigation
                const params = new URLSearchParams(searchParams.toString());
                if (e.target.value) {
                  params.set('categoryId', e.target.value);
                } else {
                  params.delete('categoryId');
                }
                router.push(`/dashboard/listings?${params.toString()}`, { scroll: false });
              }}
              className="w-full px-3 py-2 border border-gray-200 rounded-sm focus:outline-none focus:ring-1 focus:ring-[#0e1a30] focus:border-[#0e1a30] text-sm"
            >
              <option value="">All Categories</option>
              {categories.map((cat) => (
                <option key={cat.id} value={cat.id}>
                  {cat.name}
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
            <div className="grid grid-cols-1 md:grid-cols-4 gap-4">
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
            </div>

            {/* Clear Filters */}
            {(countryFilter || cityFilter || dateFrom || dateTo) && (
              <div className="mt-4 flex justify-end">
                <Button
                  variant="ghost"
                  size="sm"
                  onClick={() => {
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

        {categoryFilter && (
          <div className="mt-3 flex items-center gap-2">
            <span className="text-sm text-gray-600">Filtered by category:</span>
            <Link href={`/dashboard/categories/${categoryFilter}`} className="text-sm text-[#0e1a30] hover:underline font-medium">
              {categories.find(c => c.id === categoryFilter)?.name || categoryFilter}
            </Link>
            <button
              onClick={() => {
                setCategoryFilter('');
                setPage(1);
                const params = new URLSearchParams(searchParams.toString());
                params.delete('categoryId');
                router.push(`/dashboard/listings?${params.toString()}`, { scroll: false });
              }}
              className="text-sm text-gray-500 hover:text-gray-700"
            >
              <Icon icon={faTimes} size="xs" />
            </button>
          </div>
        )}
      </div>

      {/* Table */}
      <DataTable
        columns={columns}
        data={listings}
        loading={loading}
        onRowClick={(row) => router.push(`/dashboard/listings/${row.id}`)}
        emptyMessage="No listings found"
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

      {/* Create Listing Modal */}
      <Modal
        isOpen={showCreateModal}
        onClose={() => {
          setShowCreateModal(false);
                setFormData({
                  merchantId: '',
                  name: '',
                  description: '',
                  shortDescription: '',
                  type: undefined,
                  categoryId: '',
                  countryId: '',
                  cityId: '',
                  address: '',
                  latitude: undefined,
                  longitude: undefined,
                  minPrice: undefined,
                  maxPrice: undefined,
                  contactPhone: '',
                  contactEmail: '',
                  website: '',
                  status: 'draft',
                });
                setUploadedImages([]);
                setShowNewMerchantForm(false);
                setMerchantFormData({
                  userId: '',
                  businessName: '',
                  businessType: '',
                  businessEmail: '',
                  businessPhone: '',
                  website: '',
                  countryId: '',
                  cityId: '',
                  address: '',
                });
                setUserFormData({
                  fullName: '',
                  email: '',
                  phoneNumber: '',
                  password: 'TempPass123!',
                });
                  setUserFormData({
                    fullName: '',
                    email: '',
                    phoneNumber: '',
                    password: 'TempPass123!',
                  });
        }}
        title="Create New Listing"
        size="xl"
      >
        <div className="space-y-4 max-h-[70vh] overflow-y-auto">
          {/* Fast Onboarding Toggle */}
          <div className="flex items-center gap-2 p-3 bg-blue-50 border border-blue-200 rounded-md">
            <input
              type="checkbox"
              id="fast-onboarding"
              checked={fastOnboarding}
              onChange={(e) => {
                setFastOnboarding(e.target.checked);
                if (!e.target.checked) {
                  setShowNewMerchantForm(false);
                }
              }}
              className="w-4 h-4 text-blue-600 border-gray-300 rounded focus:ring-blue-500"
            />
            <label htmlFor="fast-onboarding" className="text-sm font-medium text-gray-700 cursor-pointer">
              Fast Onboarding (Auto-create user & merchant from listing name)
            </label>
          </div>

          {!fastOnboarding && (
            <div className="grid grid-cols-2 gap-4">
              <div className="col-span-2">
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  Merchant <span className="text-red-500">*</span>
                </label>
                <div className="flex gap-2">
                  <Select
                    value={formData.merchantId || ''}
                    onChange={(e) => setFormData({ ...formData, merchantId: e.target.value })}
                    options={[
                      { value: '', label: 'Select merchant' },
                      ...merchants.map(m => ({ value: m.id, label: m.businessName })),
                    ]}
                    className="flex-1"
                  />
                  <Button
                    type="button"
                    variant="outline"
                    size="sm"
                    onClick={() => setShowNewMerchantForm(!showNewMerchantForm)}
                  >
                    {showNewMerchantForm ? 'Cancel' : '+ New Merchant'}
                  </Button>
                </div>
              </div>
            </div>
          )}

          {!fastOnboarding && showNewMerchantForm && (
              <div className="col-span-2 p-4 bg-gray-50 border border-gray-200 rounded-sm space-y-4">
                <h3 className="text-sm font-semibold text-gray-900">Create New Merchant</h3>
                <div className="grid grid-cols-2 gap-4">
                  <div className="col-span-2">
                    <label className="block text-sm font-medium text-gray-700 mb-1">
                      User (Owner) <span className="text-red-500">*</span>
                    </label>
                    <Select
                      value={merchantFormData.userId || ''}
                      onChange={(e) => setMerchantFormData({ ...merchantFormData, userId: e.target.value })}
                      options={[
                        { value: '', label: 'Select user' },
                        ...users.map(u => ({ value: u.id, label: `${u.fullName || u.email || u.phoneNumber} (${u.email || u.phoneNumber})` })),
                      ]}
                    />
                  </div>
                  <div className="col-span-2">
                    <Input
                      label="Business Name *"
                      value={merchantFormData.businessName}
                      onChange={(e) => setMerchantFormData({ ...merchantFormData, businessName: e.target.value })}
                      placeholder="Enter business name"
                    />
                  </div>
                  <div>
                    <Select
                      label="Business Type"
                      value={merchantFormData.businessType}
                      onChange={(e) => setMerchantFormData({ ...merchantFormData, businessType: e.target.value as ListingType || '' })}
                      options={[
                        { value: '', label: 'Select type' },
                        ...TYPES.filter(t => t.value).map(t => ({ value: t.value, label: t.label })),
                      ]}
                    />
                  </div>
                  <div>
                    <Input
                      label="Business Email"
                      type="email"
                      value={merchantFormData.businessEmail}
                      onChange={(e) => setMerchantFormData({ ...merchantFormData, businessEmail: e.target.value })}
                      placeholder="business@example.com"
                    />
                  </div>
                  <div>
                    <Input
                      label="Business Phone"
                      type="tel"
                      value={merchantFormData.businessPhone}
                      onChange={(e) => setMerchantFormData({ ...merchantFormData, businessPhone: e.target.value })}
                      placeholder="+250 788 123 456"
                    />
                  </div>
                  <div>
                    <Input
                      label="Website"
                      type="url"
                      value={merchantFormData.website}
                      onChange={(e) => setMerchantFormData({ ...merchantFormData, website: e.target.value })}
                      placeholder="https://example.com"
                    />
                  </div>
                  <div>
                    <Select
                      label="Country"
                      value={merchantFormData.countryId}
                      onChange={(e) => setMerchantFormData({ ...merchantFormData, countryId: e.target.value, cityId: '' })}
                      options={[
                        { value: '', label: 'Select country' },
                        ...countries.map(c => ({ value: c.id, label: c.name })),
                      ]}
                    />
                  </div>
                  <div>
                    <Select
                      label="City"
                      value={merchantFormData.cityId}
                      onChange={(e) => setMerchantFormData({ ...merchantFormData, cityId: e.target.value })}
                      options={[
                        { value: '', label: 'Select city' },
                        ...cities.filter(c => !merchantFormData.countryId || c.countryId === merchantFormData.countryId).map(c => ({ value: c.id, label: c.name })),
                      ]}
                      disabled={!merchantFormData.countryId}
                    />
                  </div>
                  <div className="col-span-2">
                    <Input
                      label="Address"
                      value={merchantFormData.address}
                      onChange={(e) => setMerchantFormData({ ...merchantFormData, address: e.target.value })}
                      placeholder="Enter address"
                      id="merchant-address-autocomplete"
                    />
                  </div>
                </div>
                <div className="flex justify-end">
                  <Button
                    type="button"
                    variant="primary"
                    size="sm"
                    onClick={async () => {
                      if (!merchantFormData.userId || !merchantFormData.businessName) {
                        toast.error('Please provide user and business name');
                        return;
                      }
                      setCreatingMerchant(true);
                      try {
                        const newMerchant = await MerchantsAPI.createMerchant({
                          userId: merchantFormData.userId,
                          businessName: merchantFormData.businessName,
                          businessType: merchantFormData.businessType || undefined,
                          businessEmail: merchantFormData.businessEmail || undefined,
                          businessPhone: merchantFormData.businessPhone || undefined,
                          website: merchantFormData.website || undefined,
                          countryId: merchantFormData.countryId || undefined,
                          cityId: merchantFormData.cityId || undefined,
                          address: merchantFormData.address || undefined,
                        });
                        toast.success('Merchant created successfully');
                        setFormData({ ...formData, merchantId: newMerchant.id });
                        setMerchants([...merchants, newMerchant]);
                        setShowNewMerchantForm(false);
                        setMerchantFormData({
                          userId: '',
                          businessName: '',
                          businessType: '',
                          businessEmail: '',
                          businessPhone: '',
                          website: '',
                          countryId: '',
                          cityId: '',
                          address: '',
                        });
                      } catch (error: any) {
                        console.error('Failed to create merchant:', error);
                        toast.error(error?.response?.data?.message || error?.message || 'Failed to create merchant');
                      } finally {
                        setCreatingMerchant(false);
                      }
                    }}
                    loading={creatingMerchant}
                  >
                    Create Merchant
                  </Button>
                </div>
              </div>
            )}

          <div className="grid grid-cols-2 gap-4">
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Name <span className="text-red-500">*</span>
                {fastOnboarding && <span className="text-xs text-gray-500 ml-2">(Auto-creates user & merchant)</span>}
              </label>
              <Input
                value={formData.name || ''}
                onChange={(e) => {
                  const name = e.target.value;
                  setFormData({ ...formData, name });
                  // Auto-populate user and merchant if fast onboarding is enabled
                  if (fastOnboarding) {
                    setUserFormData((prev) => ({ ...prev, fullName: name }));
                    setMerchantFormData((prev) => ({ ...prev, businessName: name }));
                  }
                }}
                placeholder="Enter listing name (will be used for user, merchant & listing)"
              />
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Type
              </label>
              <Select
                value={formData.type || ''}
                onChange={(e) => setFormData({ ...formData, type: e.target.value as ListingType || undefined })}
                options={[
                  { value: '', label: 'Select type' },
                  ...TYPES.filter(t => t.value).map(t => ({ value: t.value, label: t.label })),
                ]}
              />
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Category
              </label>
              <Select
                value={formData.categoryId || ''}
                onChange={(e) => setFormData({ ...formData, categoryId: e.target.value || undefined })}
                options={[
                  { value: '', label: 'Select category' },
                  ...categories.map(c => ({ value: c.id, label: c.name })),
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

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Min Price
              </label>
              <Input
                type="number"
                value={formData.minPrice || ''}
                onChange={(e) => setFormData({ ...formData, minPrice: e.target.value ? parseFloat(e.target.value) : undefined })}
                placeholder="0"
              />
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Max Price
              </label>
              <Input
                type="number"
                value={formData.maxPrice || ''}
                onChange={(e) => setFormData({ ...formData, maxPrice: e.target.value ? parseFloat(e.target.value) : undefined })}
                placeholder="0"
              />
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Contact Phone (Optional)
                {fastOnboarding && <span className="text-xs text-gray-500 ml-2">(Auto-syncs to user & merchant)</span>}
              </label>
              <Input
                type="tel"
                value={formData.contactPhone || ''}
                onChange={(e) => {
                  const phone = e.target.value;
                  setFormData({ ...formData, contactPhone: phone || undefined });
                  // Auto-populate user and merchant if fast onboarding is enabled
                  if (fastOnboarding) {
                    setUserFormData((prev) => ({ ...prev, phoneNumber: phone }));
                    setMerchantFormData((prev) => ({ ...prev, businessPhone: phone }));
                  }
                }}
                placeholder="Enter phone number (optional)"
              />
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Contact Email (Optional)
                {fastOnboarding && <span className="text-xs text-gray-500 ml-2">(Auto-syncs to user & merchant)</span>}
              </label>
              <Input
                type="email"
                value={formData.contactEmail || ''}
                onChange={(e) => {
                  const email = e.target.value;
                  setFormData({ ...formData, contactEmail: email || undefined });
                  // Auto-populate user and merchant if fast onboarding is enabled
                  if (fastOnboarding) {
                    setUserFormData((prev) => ({ ...prev, email: email }));
                    setMerchantFormData((prev) => ({ ...prev, businessEmail: email }));
                  }
                }}
                placeholder="Enter email (optional)"
              />
            </div>

            <div className="col-span-2">
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Website
              </label>
              <Input
                type="url"
                value={formData.website || ''}
                onChange={(e) => setFormData({ ...formData, website: e.target.value || undefined })}
                placeholder="https://example.com"
              />
            </div>

            <div className="col-span-2">
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Address (with Google Places)
              </label>
              <Input
                value={formData.address || ''}
                onChange={(e) => setFormData({ ...formData, address: e.target.value || undefined })}
                placeholder="Start typing address..."
                id="listing-address-autocomplete"
              />
            </div>

            <div className="col-span-2">
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Images / Photos
              </label>
              <div className="space-y-2">
                <div className="flex gap-2 flex-wrap">
                  {uploadedImages.map((img) => (
                    <div key={img.id} className="relative group">
                      <img
                        src={img.url}
                        alt="Listing"
                        className="w-24 h-24 object-cover rounded border border-gray-200"
                      />
                      {img.isPrimary && (
                        <span className="absolute top-1 left-1 bg-blue-500 text-white text-xs px-1 rounded">Primary</span>
                      )}
                      <button
                        type="button"
                        onClick={() => setUploadedImages(uploadedImages.filter(i => i.id !== img.id))}
                        className="absolute top-1 right-1 bg-red-500 text-white rounded-full w-5 h-5 flex items-center justify-center opacity-0 group-hover:opacity-100 transition-opacity"
                      >
                        <Icon icon={faTimes} size="xs" />
                      </button>
                    </div>
                  ))}
                </div>
                <div>
                  <input
                    type="file"
                    accept="image/*"
                    multiple
                    onChange={async (e) => {
                      const files = Array.from(e.target.files || []);
                      if (files.length === 0) return;
                      
                      // Validate file sizes (max 10MB before compression, will be compressed to <1MB)
                      const maxSize = 10 * 1024 * 1024; // 10MB
                      const invalidFiles = files.filter(f => f.size > maxSize);
                      if (invalidFiles.length > 0) {
                        toast.error(
                          `Some images are too large (max ${(maxSize / 1024 / 1024).toFixed(0)}MB). ` +
                          `Large images: ${invalidFiles.map(f => f.name).join(', ')}`
                        );
                        return;
                      }
                      
                      setUploadingImage(true);
                      try {
                        const uploadPromises = files.map(file => MediaAPI.upload({ file, category: 'listing' }));
                        const uploaded = await Promise.all(uploadPromises);
                        const newImages = uploaded.map((media, idx) => ({
                          id: media.id,
                          url: media.url,
                          isPrimary: uploadedImages.length === 0 && idx === 0,
                        }));
                        setUploadedImages([...uploadedImages, ...newImages]);
                        toast.success(`${files.length} image(s) uploaded and compressed successfully`);
                      } catch (error: any) {
                        console.error('Failed to upload images:', error);
                        toast.error(error?.response?.data?.message || error?.message || 'Failed to upload images');
                      } finally {
                        setUploadingImage(false);
                      }
                    }}
                    className="hidden"
                    id="listing-image-upload"
                    disabled={uploadingImage}
                  />
                  <label
                    htmlFor="listing-image-upload"
                    className="inline-flex items-center gap-2 px-4 py-2 border border-gray-300 rounded-sm cursor-pointer hover:bg-gray-50 disabled:opacity-50"
                  >
                    <Icon icon={faImage} />
                    {uploadingImage ? 'Uploading & Compressing...' : 'Upload Images (max 10MB, auto-compressed to <1MB)'}
                  </label>
                </div>
              </div>
            </div>

            <div className="col-span-2">
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Short Description
              </label>
              <Textarea
                value={formData.shortDescription || ''}
                onChange={(e) => setFormData({ ...formData, shortDescription: e.target.value || undefined })}
                placeholder="Brief description"
                rows={2}
              />
            </div>

            <div className="col-span-2">
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Description
              </label>
              <Textarea
                value={formData.description || ''}
                onChange={(e) => setFormData({ ...formData, description: e.target.value || undefined })}
                placeholder="Full description"
                rows={4}
              />
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Status
              </label>
              <Select
                value={formData.status || 'draft'}
                onChange={(e) => setFormData({ ...formData, status: e.target.value as ListingStatus })}
                options={STATUSES.filter(s => s.value).map(s => ({ value: s.value, label: s.label }))}
              />
            </div>
          </div>

          <div className="flex justify-end gap-3 pt-4 border-t border-gray-200">
            <Button
              variant="outline"
              onClick={() => {
                setShowCreateModal(false);
                setFormData({
                  merchantId: '',
                  name: '',
                  description: '',
                  shortDescription: '',
                  type: undefined,
                  categoryId: '',
                  countryId: '',
                  cityId: '',
                  address: '',
                  latitude: undefined,
                  longitude: undefined,
                  minPrice: undefined,
                  maxPrice: undefined,
                  contactPhone: '',
                  contactEmail: '',
                  website: '',
                  status: 'draft',
                });
              }}
            >
              Cancel
            </Button>
            <Button
              variant="primary"
              onClick={async () => {
                if (!formData.name) {
                  toast.error('Please provide listing name');
                  return;
                }

                // Fast onboarding: auto-create user and merchant if enabled
                let merchantId = formData.merchantId;
                
                if (fastOnboarding && !merchantId) {
                  // Create user first - only name is required
                  if (!userFormData.fullName) {
                    toast.error('Please provide listing name (will be used for user, merchant & listing)');
                    return;
                  }

                  try {
                    const userPhone = userFormData.phoneNumber || formData.contactPhone || undefined;
                    const userEmail = userFormData.email || formData.contactEmail || undefined;
                    
                    // First, check if a user already exists with this phone or email
                    let existingUser = await UsersAPI.findByPhoneOrEmail(userPhone, userEmail);
                    let newUser;
                    
                    if (existingUser) {
                      // Use existing user
                      newUser = existingUser;
                      toast.info(`Using existing user: ${existingUser.fullName || existingUser.email || existingUser.phoneNumber}`);
                      
                      // Check if user already has a merchant profile
                      if (existingUser.merchantProfiles && existingUser.merchantProfiles.length > 0) {
                        // Use existing merchant
                        merchantId = existingUser.merchantProfiles[0].id;
                        toast.info(`Using existing merchant: ${existingUser.merchantProfiles[0].businessName}`);
                      }
                    } else {
                      // Create new user
                      newUser = await UsersAPI.createUser({
                        fullName: userFormData.fullName || formData.name,
                        email: userEmail,
                        phoneNumber: userPhone,
                        password: userFormData.password || 'TempPass123!',
                        roles: ['merchant'],
                      });
                      toast.success('User created successfully');
                    }

                    // Create merchant if not already assigned
                    if (!merchantId) {
                      const newMerchant = await MerchantsAPI.createMerchant({
                        userId: newUser.id,
                        businessName: merchantFormData.businessName || formData.name,
                        businessType: merchantFormData.businessType || formData.type || undefined,
                        businessEmail: merchantFormData.businessEmail || formData.contactEmail || undefined,
                        businessPhone: merchantFormData.businessPhone || formData.contactPhone || undefined,
                        website: merchantFormData.website || formData.website || undefined,
                        countryId: merchantFormData.countryId || formData.countryId || undefined,
                        cityId: merchantFormData.cityId || formData.cityId || undefined,
                        address: merchantFormData.address || formData.address || undefined,
                      });

                      merchantId = newMerchant.id;
                      setMerchants([...merchants, newMerchant]);
                      toast.success('Merchant created successfully');
                    }
                    
                    setFormData({ ...formData, merchantId });
                  } catch (error: any) {
                    console.error('Failed to create user/merchant:', error);
                    toast.error(error?.response?.data?.message || error?.message || 'Failed to create user/merchant');
                    setCreating(false);
                    return;
                  }
                }

                if (!merchantId) {
                  toast.error('Please provide merchant or enable fast onboarding');
                  return;
                }
                
                setCreating(true);
                try {
                  const listing = await ListingsAPI.createListing({ ...formData, merchantId } as CreateListingParams);
                  
                  // Upload images if any - use local merchantId variable, not formData.merchantId
                  if (uploadedImages.length > 0) {
                    try {
                      const imagePromises = uploadedImages.map((img, idx) =>
                        apiClient.post(`/listings/${listing.id}/images`, {
                          merchantId: merchantId, // Use local variable, not formData
                          mediaId: img.id,
                          isPrimary: img.isPrimary || idx === 0,
                        })
                      );
                      await Promise.all(imagePromises);
                      toast.success(`${uploadedImages.length} image(s) attached to listing`);
                    } catch (imgError: any) {
                      console.error('Failed to add images:', imgError);
                      toast.error('Listing created but failed to add some images');
                    }
                  }
                  
                  toast.success('Listing created successfully');
                  setShowCreateModal(false);
                  setFormData({
                    merchantId: '',
                    name: '',
                    description: '',
                    shortDescription: '',
                    type: undefined,
                    categoryId: '',
                    countryId: '',
                    cityId: '',
                    address: '',
                    latitude: undefined,
                    longitude: undefined,
                    minPrice: undefined,
                    maxPrice: undefined,
                    contactPhone: '',
                    contactEmail: '',
                    website: '',
                    status: 'draft',
                  });
                  setUploadedImages([]);
                  setShowNewMerchantForm(false);
                  // Refresh listings
                  const response = await ListingsAPI.listListings({ page, limit: pageSize });
                  setListings(response.data || []);
                  setTotal(response.meta?.total || 0);
                } catch (error: any) {
                  console.error('Failed to create listing:', error);
                  toast.error(error?.response?.data?.message || error?.message || 'Failed to create listing');
                } finally {
                  setCreating(false);
                }
              }}
              loading={creating}
            >
              Create Listing
            </Button>
          </div>
        </div>
      </Modal>
    </div>
  );
}

