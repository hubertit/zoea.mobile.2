'use client';

import { ReactNode, useState, useMemo } from 'react';
import Icon, { faChevronUp, faChevronDown } from './Icon';
import DataTableSkeleton from './DataTableSkeleton';

interface Column {
  key: string;
  label: string;
  sortable?: boolean;
  render?: (value: any, row: any) => ReactNode;
}

interface DataTableProps {
  columns: Column[];
  data: any[];
  loading?: boolean;
  onSort?: (key: string, direction: 'asc' | 'desc') => void;
  sortKey?: string;
  sortDirection?: 'asc' | 'desc';
  onRowClick?: (row: any) => void;
  emptyMessage?: string;
  showNumbering?: boolean;
  numberingStart?: number;
  enableClientSort?: boolean; // Enable client-side sorting if onSort is not provided
}

export default function DataTable({
  columns,
  data,
  loading = false,
  onSort,
  sortKey: externalSortKey,
  sortDirection: externalSortDirection,
  onRowClick,
  emptyMessage = 'No data available',
  showNumbering = false,
  numberingStart = 1,
  enableClientSort = false,
}: DataTableProps) {
  const [internalSortKey, setInternalSortKey] = useState<string | undefined>();
  const [internalSortDirection, setInternalSortDirection] = useState<'asc' | 'desc'>('asc');

  const sortKey = externalSortKey ?? internalSortKey;
  const sortDirection = externalSortDirection ?? internalSortDirection;

  const handleSort = (key: string) => {
    if (onSort) {
      const newDirection = sortKey === key && sortDirection === 'asc' ? 'desc' : 'asc';
      onSort(key, newDirection);
    } else if (enableClientSort) {
      const newDirection = sortKey === key && sortDirection === 'asc' ? 'desc' : 'asc';
      setInternalSortKey(key);
      setInternalSortDirection(newDirection);
    }
  };

  // Client-side sorting
  const sortedData = useMemo(() => {
    if (!enableClientSort || !sortKey || !onSort) {
      if (!enableClientSort || !sortKey) return data;
      
      return [...data].sort((a, b) => {
        let aVal = a[sortKey];
        let bVal = b[sortKey];
        
        // Handle nested properties (e.g., 'merchant.businessName')
        if (sortKey.includes('.')) {
          const keys = sortKey.split('.');
          aVal = keys.reduce((obj: any, k) => obj?.[k], a);
          bVal = keys.reduce((obj: any, k) => obj?.[k], b);
        }
        
        // Handle null/undefined
        if (aVal == null && bVal == null) return 0;
        if (aVal == null) return 1;
        if (bVal == null) return -1;
        
        // Handle date strings
        if (typeof aVal === 'string' && typeof bVal === 'string') {
          const aDate = new Date(aVal);
          const bDate = new Date(bVal);
          if (!isNaN(aDate.getTime()) && !isNaN(bDate.getTime())) {
            return sortDirection === 'asc' 
              ? aDate.getTime() - bDate.getTime()
              : bDate.getTime() - aDate.getTime();
          }
        }
        
        // Handle different types
        if (typeof aVal === 'string' && typeof bVal === 'string') {
          return sortDirection === 'asc' 
            ? aVal.localeCompare(bVal)
            : bVal.localeCompare(aVal);
        }
        
        if (typeof aVal === 'number' && typeof bVal === 'number') {
          return sortDirection === 'asc' ? aVal - bVal : bVal - aVal;
        }
        
        if (aVal instanceof Date && bVal instanceof Date) {
          return sortDirection === 'asc' 
            ? aVal.getTime() - bVal.getTime()
            : bVal.getTime() - aVal.getTime();
        }
        
        // Fallback to string comparison
        return sortDirection === 'asc'
          ? String(aVal).localeCompare(String(bVal))
          : String(bVal).localeCompare(String(aVal));
      });
    }
    return data;
  }, [data, sortKey, sortDirection, enableClientSort, onSort]);

  if (loading) {
    return (
      <DataTableSkeleton
        rows={5}
        columns={columns.length + (showNumbering ? 1 : 0)}
        showHeader
        showActions={columns.some((col) => col.key === 'actions')}
      />
    );
  }

  const displayData = sortedData;

  if (displayData.length === 0) {
    return (
      <div className="bg-white rounded-sm border border-gray-200 p-6">
        <div className="text-center py-12">
          <p className="text-gray-500">{emptyMessage}</p>
        </div>
      </div>
    );
  }

  return (
    <div className="bg-white rounded-sm border border-gray-200 overflow-hidden">
      <div className="overflow-x-auto">
        <table className="w-full">
          <thead className="bg-gray-50 border-b border-gray-200">
            <tr>
              {showNumbering && (
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-700 uppercase tracking-wider w-16">
                  #
                </th>
              )}
              {columns.map((column) => (
                <th
                  key={column.key}
                  className={`px-6 py-3 text-left text-xs font-medium text-gray-700 uppercase tracking-wider ${
                    column.sortable ? 'cursor-pointer hover:bg-gray-100' : ''
                  }`}
                  onClick={() => column.sortable && handleSort(column.key)}
                >
                  <div className="flex items-center gap-2">
                    {column.label}
                    {column.sortable && sortKey === column.key && (
                      <Icon
                        icon={sortDirection === 'asc' ? faChevronUp : faChevronDown}
                        className="text-[#0e1a30]"
                        size="xs"
                      />
                    )}
                  </div>
                </th>
              ))}
            </tr>
          </thead>
          <tbody className="bg-white divide-y divide-gray-200">
            {displayData.map((row, index) => (
              <tr
                key={index}
                className={`hover:bg-gray-50 transition-colors ${onRowClick ? 'cursor-pointer' : ''}`}
                onClick={() => onRowClick && onRowClick(row)}
              >
                {showNumbering && (
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500 font-medium">
                    {numberingStart + index}
                  </td>
                )}
                {columns.map((column) => (
                  <td key={column.key} className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                    {column.render
                      ? column.render(row[column.key], row)
                      : row[column.key] || '-'}
                  </td>
                ))}
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  );
}

