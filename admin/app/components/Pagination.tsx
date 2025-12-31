'use client';

import Icon, { faChevronLeft, faChevronRight } from './Icon';
import Button from './Button';

interface PaginationProps {
  currentPage: number;
  totalPages: number;
  onPageChange: (page: number) => void;
  showPageNumbers?: boolean;
  maxVisiblePages?: number;
  pageSize?: number;
  onPageSizeChange?: (size: number) => void;
  totalItems?: number;
  pageSizeOptions?: number[];
}

export default function Pagination({
  currentPage,
  totalPages,
  onPageChange,
  showPageNumbers = true,
  maxVisiblePages = 5,
  pageSize,
  onPageSizeChange,
  totalItems,
  pageSizeOptions = [10, 25, 50, 100],
}: PaginationProps) {
  if (totalPages <= 1 && !onPageSizeChange) return null;

  const getPageNumbers = () => {
    const pages: (number | string)[] = [];
    const halfVisible = Math.floor(maxVisiblePages / 2);

    let startPage = Math.max(1, currentPage - halfVisible);
    let endPage = Math.min(totalPages, currentPage + halfVisible);

    if (endPage - startPage < maxVisiblePages - 1) {
      if (startPage === 1) {
        endPage = Math.min(totalPages, startPage + maxVisiblePages - 1);
      } else {
        startPage = Math.max(1, endPage - maxVisiblePages + 1);
      }
    }

    if (startPage > 1) {
      pages.push(1);
      if (startPage > 2) pages.push('...');
    }

    for (let i = startPage; i <= endPage; i++) {
      pages.push(i);
    }

    if (endPage < totalPages) {
      if (endPage < totalPages - 1) pages.push('...');
      pages.push(totalPages);
    }

    return pages;
  };

  return (
    <div className="flex items-center justify-between px-4 py-3 border-t border-gray-200 bg-white sm:px-6">
      <div className="flex flex-1 justify-between sm:hidden">
        <Button
          variant="outline"
          size="sm"
          onClick={() => onPageChange(currentPage - 1)}
          disabled={currentPage === 1}
        >
          Previous
        </Button>
        <Button
          variant="outline"
          size="sm"
          onClick={() => onPageChange(currentPage + 1)}
          disabled={currentPage === totalPages}
        >
          Next
        </Button>
      </div>
      <div className="hidden sm:flex sm:flex-1 sm:items-center sm:justify-between">
        <div className="flex items-center gap-4">
          <p className="text-sm text-gray-700">
            {totalItems !== undefined && pageSize !== undefined ? (
              <>
                Showing <span className="font-medium">{(currentPage - 1) * pageSize + 1}</span> to{' '}
                <span className="font-medium">{Math.min(currentPage * pageSize, totalItems)}</span> of{' '}
                <span className="font-medium">{totalItems}</span> results
              </>
            ) : (
              <>
                Page <span className="font-medium">{currentPage}</span> of{' '}
                <span className="font-medium">{totalPages}</span>
              </>
            )}
          </p>
          {onPageSizeChange && pageSize && (
            <div className="flex items-center gap-2">
              <label className="text-sm text-gray-700">Show:</label>
              <select
                value={pageSize}
                onChange={(e) => onPageSizeChange(Number(e.target.value))}
                className="px-2 py-1 text-sm border border-gray-200 rounded-sm focus:outline-none focus:ring-1 focus:ring-[#0e1a30] focus:border-[#0e1a30]"
              >
                {pageSizeOptions.map((size) => (
                  <option key={size} value={size}>
                    {size}
                  </option>
                ))}
              </select>
            </div>
          )}
        </div>
        <div>
          <nav className="isolate inline-flex -space-x-px rounded-md" aria-label="Pagination">
            <Button
              variant="ghost"
              size="sm"
              onClick={() => onPageChange(currentPage - 1)}
              disabled={currentPage === 1}
              className="rounded-l-md"
            >
              <Icon icon={faChevronLeft} size="sm" />
            </Button>
            {showPageNumbers &&
              getPageNumbers().map((page, index) => {
                if (page === '...') {
                  return (
                    <span
                      key={`ellipsis-${index}`}
                      className="relative inline-flex items-center px-4 py-2 text-sm font-semibold text-gray-700 ring-1 ring-inset ring-gray-300"
                    >
                      ...
                    </span>
                  );
                }
                const pageNum = page as number;
                return (
                  <Button
                    key={pageNum}
                    variant={pageNum === currentPage ? 'primary' : 'ghost'}
                    size="sm"
                    onClick={() => onPageChange(pageNum)}
                    className="rounded-none"
                  >
                    {pageNum}
                  </Button>
                );
              })}
            <Button
              variant="ghost"
              size="sm"
              onClick={() => onPageChange(currentPage + 1)}
              disabled={currentPage === totalPages}
              className="rounded-r-md"
            >
              <Icon icon={faChevronRight} size="sm" />
            </Button>
          </nav>
        </div>
      </div>
    </div>
  );
}

