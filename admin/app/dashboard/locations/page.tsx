'use client';

import { useState, useEffect } from 'react';
import Card, { CardHeader, CardBody } from '@/app/components/Card';
import { Button, DataTable, Pagination } from '@/app/components';
import Icon, { faMapMarkerAlt, faPlus, faEdit, faTrash, faSearch, faTimes } from '@/app/components/Icon';
import { toast } from '@/app/components/Toaster';
import PageSkeleton from '@/app/components/PageSkeleton';
import { LocationsAPI, type Country, type City } from '@/src/lib/api';


export default function LocationsPage() {
  const [activeTab, setActiveTab] = useState<'countries' | 'cities'>('countries');
  const [countries, setCountries] = useState<Country[]>([]);
  const [cities, setCities] = useState<City[]>([]);
  const [loading, setLoading] = useState(true);
  const [search, setSearch] = useState('');

  useEffect(() => {
    const fetchData = async () => {
      setLoading(true);
      try {
        const [countriesRes, citiesRes] = await Promise.all([
          LocationsAPI.getCountries(),
          LocationsAPI.getCities(),
        ]);
        setCountries(countriesRes || []);
        setCities(citiesRes || []);
      } catch (error: any) {
        console.error('Failed to fetch locations:', error);
        toast.error(error?.message || 'Failed to load locations');
      } finally {
        setLoading(false);
      }
    };

    fetchData();
  }, []);

  const filteredCountries = countries.filter((country) =>
    country.name.toLowerCase().includes(search.toLowerCase()) ||
    country.code.toLowerCase().includes(search.toLowerCase())
  );

  const filteredCities = cities.filter((city) =>
    city.name.toLowerCase().includes(search.toLowerCase()) ||
    city.country?.name.toLowerCase().includes(search.toLowerCase())
  );

  if (loading) {
    return <PageSkeleton />;
  }

  const countryColumns = [
    {
      key: 'country',
      label: 'Country',
      sortable: false,
      render: (_: any, row: Country) => (
        <div className="flex items-center gap-3">
          <div>
            <p className="text-sm font-medium text-gray-900">{row.name}</p>
            <p className="text-xs text-gray-500">{row.code}</p>
          </div>
        </div>
      ),
    },
    {
      key: 'code',
      label: 'Code',
      sortable: false,
      render: (_: any, row: Country) => (
        <span className="text-sm text-gray-900">{row.code}</span>
      ),
    },
    {
      key: 'actions',
      label: 'Actions',
      sortable: false,
      render: (_: any, row: Country) => (
        <div className="flex items-center gap-2">
          <Button variant="ghost" size="sm">
            <Icon icon={faEdit} size="xs" />
          </Button>
          <Button variant="ghost" size="sm" className="text-red-600 hover:text-red-700">
            <Icon icon={faTrash} size="xs" />
          </Button>
        </div>
      ),
    },
  ];

  const cityColumns = [
    {
      key: 'city',
      label: 'City',
      sortable: false,
      render: (_: any, row: City) => (
        <div>
          <p className="text-sm font-medium text-gray-900">{row.name}</p>
        </div>
      ),
    },
    {
      key: 'country',
      label: 'Country',
      sortable: false,
      render: (_: any, row: City) => (
        <span className="text-sm text-gray-900">{row.country?.name || '-'}</span>
      ),
    },
    {
      key: 'actions',
      label: 'Actions',
      sortable: false,
      render: (_: any, row: City) => (
        <div className="flex items-center gap-2">
          <Button variant="ghost" size="sm">
            <Icon icon={faEdit} size="xs" />
          </Button>
          <Button variant="ghost" size="sm" className="text-red-600 hover:text-red-700">
            <Icon icon={faTrash} size="xs" />
          </Button>
        </div>
      ),
    },
  ];

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex items-center justify-between flex-wrap gap-4">
        <div>
          <h1 className="text-2xl font-bold text-gray-900">Locations</h1>
          <p className="text-gray-600 mt-1">Manage countries, cities, and districts</p>
        </div>
        <Button className="flex items-center gap-2">
          <Icon icon={faPlus} size="sm" />
          Add {activeTab === 'countries' ? 'Country' : 'City'}
        </Button>
      </div>

      {/* Tabs */}
      <div className="border-b border-gray-200">
        <nav className="-mb-px flex space-x-8">
          <button
            onClick={() => {
              setActiveTab('countries');
              setSearch('');
            }}
            className={`py-4 px-1 border-b-2 font-medium text-sm ${
              activeTab === 'countries'
                ? 'border-[#0e1a30] text-[#0e1a30]'
                : 'border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300'
            }`}
          >
            Countries
          </button>
          <button
            onClick={() => {
              setActiveTab('cities');
              setSearch('');
            }}
            className={`py-4 px-1 border-b-2 font-medium text-sm ${
              activeTab === 'cities'
                ? 'border-[#0e1a30] text-[#0e1a30]'
                : 'border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300'
            }`}
          >
            Cities
          </button>
        </nav>
      </div>

      {/* Search */}
      <div className="bg-white border border-gray-200 rounded-sm p-4">
        <div className="relative">
          <Icon
            icon={faSearch}
            className="absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400"
            size="sm"
          />
          <input
            type="text"
            placeholder={`Search ${activeTab}...`}
            value={search}
            onChange={(e) => setSearch(e.target.value)}
            className="w-full pl-10 pr-4 py-2 border border-gray-200 rounded-sm focus:outline-none focus:ring-1 focus:ring-[#0e1a30] focus:border-[#0e1a30] text-sm"
          />
          {search && (
            <button
              onClick={() => setSearch('')}
              className="absolute right-3 top-1/2 transform -translate-y-1/2 text-gray-400 hover:text-gray-600"
            >
              <Icon icon={faTimes} size="xs" />
            </button>
          )}
        </div>
      </div>

      {/* Content */}
      {activeTab === 'countries' ? (
        <Card>
          <CardHeader>
            <h2 className="text-lg font-semibold text-gray-900">Countries</h2>
          </CardHeader>
          <CardBody>
            {filteredCountries.length > 0 ? (
              <DataTable
                columns={countryColumns}
                data={filteredCountries}
                emptyMessage="No countries found"
                showNumbering={true}
              />
            ) : (
              <div className="text-center py-12">
                <div className="w-16 h-16 bg-gray-100 rounded-full flex items-center justify-center mx-auto mb-4">
                  <Icon icon={faMapMarkerAlt} className="text-gray-400" size="2x" />
                </div>
                <p className="text-gray-600 mb-2">No countries found</p>
                <p className="text-sm text-gray-500">
                  {search ? 'Try adjusting your search' : 'Countries management will be available when the API is ready'}
                </p>
              </div>
            )}
          </CardBody>
        </Card>
      ) : (
        <Card>
          <CardHeader>
            <h2 className="text-lg font-semibold text-gray-900">Cities</h2>
          </CardHeader>
          <CardBody>
            {filteredCities.length > 0 ? (
              <DataTable
                columns={cityColumns}
                data={filteredCities}
                emptyMessage="No cities found"
                showNumbering={true}
              />
            ) : (
              <div className="text-center py-12">
                <div className="w-16 h-16 bg-gray-100 rounded-full flex items-center justify-center mx-auto mb-4">
                  <Icon icon={faMapMarkerAlt} className="text-gray-400" size="2x" />
                </div>
                <p className="text-gray-600 mb-2">No cities found</p>
                <p className="text-sm text-gray-500">
                  {search ? 'Try adjusting your search' : 'Cities management will be available when the API is ready'}
                </p>
              </div>
            )}
          </CardBody>
        </Card>
      )}
    </div>
  );
}
