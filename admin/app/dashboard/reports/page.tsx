'use client';

import { useState } from 'react';
import Card, { CardHeader, CardBody } from '@/app/components/Card';
import { Button } from '@/app/components';
import Icon, { faFileAlt, faDownload } from '@/app/components/Icon';
import { UsersAPI, BookingsAPI, PaymentsAPI } from '@/src/lib/api';
import { toast } from '@/app/components/Toaster';

type ReportType = 'users' | 'bookings' | 'transactions' | 'revenue';
type ExportFormat = 'csv' | 'excel' | 'pdf';

export default function ReportsPage() {
  const [loading, setLoading] = useState(false);
  const [reportType, setReportType] = useState<ReportType>('users');
  const [dateRange, setDateRange] = useState<'7d' | '30d' | '90d' | '1y' | 'custom'>('30d');
  const [startDate, setStartDate] = useState('');
  const [endDate, setEndDate] = useState('');

  const exportToCSV = async (data: any[], filename: string) => {
    if (data.length === 0) {
      toast.error('No data to export');
      return;
    }

    // Get headers from first object
    const headers = Object.keys(data[0]);
    const csvContent = [
      headers.join(','),
      ...data.map((row) =>
        headers
          .map((header) => {
            const value = row[header];
            if (value === null || value === undefined) return '';
            if (typeof value === 'object') return JSON.stringify(value);
            return `"${String(value).replace(/"/g, '""')}"`;
          })
          .join(',')
      ),
    ].join('\n');

    const blob = new Blob([csvContent], { type: 'text/csv;charset=utf-8;' });
    const link = document.createElement('a');
    const url = URL.createObjectURL(blob);
    link.setAttribute('href', url);
    link.setAttribute('download', `${filename}.csv`);
    link.style.visibility = 'hidden';
    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);
  };

  const exportToExcel = async (data: any[], filename: string) => {
    // For Excel, we'll export as CSV with .xlsx extension
    // In a real implementation, you'd use a library like xlsx
    toast.info('Excel export will be available soon. Exporting as CSV for now.');
    await exportToCSV(data, filename);
  };

  const exportToPDF = async (data: any[], filename: string) => {
    // For PDF, we'll show a message
    // In a real implementation, you'd use a library like jsPDF or pdfmake
    toast.info('PDF export will be available soon. Please use CSV export for now.');
  };

  const handleExport = async (format: ExportFormat) => {
    setLoading(true);
    try {
      let data: any[] = [];
      let filename = '';

      // Calculate date range
      const now = new Date();
      let start: Date;
      if (dateRange === 'custom') {
        if (!startDate || !endDate) {
          toast.error('Please select start and end dates');
          setLoading(false);
          return;
        }
        start = new Date(startDate);
        const end = new Date(endDate);
      } else {
        const daysBack = dateRange === '7d' ? 7 : dateRange === '30d' ? 30 : dateRange === '90d' ? 90 : 365;
        start = new Date(now);
        start.setDate(start.getDate() - daysBack);
      }

      switch (reportType) {
        case 'users':
          const usersRes = await UsersAPI.listUsers({ limit: 10000, page: 1 });
          data = (usersRes.data || []).map((user: any) => ({
            ID: user.id,
            'Full Name': user.fullName || '',
            Email: user.email || '',
            Phone: user.phoneNumber || '',
            Roles: Array.isArray(user.roles) ? user.roles.map((r: any) => typeof r === 'string' ? r : r.code || r.name).join(', ') : '',
            'Verification Status': user.verificationStatus || '',
            'Is Active': user.isActive ? 'Yes' : 'No',
            'Is Blocked': user.isBlocked ? 'Yes' : 'No',
            'Created At': user.createdAt ? new Date(user.createdAt).toLocaleString() : '',
            Country: user.country?.name || '',
            City: user.city?.name || '',
          }));
          filename = `users-report-${new Date().toISOString().split('T')[0]}`;
          break;

        case 'bookings':
          const bookingsRes = await BookingsAPI.listBookings({ limit: 10000, page: 1 });
          data = (bookingsRes.data || [])
            .filter((booking: any) => {
              const bookingDate = new Date(booking.createdAt || booking.bookingDate);
              return bookingDate >= start;
            })
            .map((booking: any) => ({
              'Booking Number': booking.bookingNumber || '',
              'User Name': booking.user?.fullName || '',
              'User Email': booking.user?.email || '',
              'Listing/Event': booking.listing?.name || booking.event?.name || '',
              Status: booking.status || '',
              'Payment Status': booking.paymentStatus || '',
              Amount: booking.totalAmount || 0,
              Currency: booking.currency || 'RWF',
              'Booking Date': booking.bookingDate ? new Date(booking.bookingDate).toLocaleString() : '',
              'Created At': booking.createdAt ? new Date(booking.createdAt).toLocaleString() : '',
            }));
          filename = `bookings-report-${new Date().toISOString().split('T')[0]}`;
          break;

        case 'transactions':
          const transactionsRes = await PaymentsAPI.listTransactions({ limit: 10000, page: 1 });
          data = (transactionsRes.data || [])
            .filter((tx: any) => {
              const txDate = new Date(tx.createdAt);
              return txDate >= start;
            })
            .map((tx: any) => ({
              Reference: tx.reference || tx.id,
              Type: tx.type || '',
              Status: tx.status || '',
              Amount: tx.amount || 0,
              Currency: tx.currency || 'RWF',
              'Payment Method': tx.paymentMethod || '',
              'User Name': tx.user?.fullName || '',
              'User Email': tx.user?.email || '',
              'Created At': tx.createdAt ? new Date(tx.createdAt).toLocaleString() : '',
            }));
          filename = `transactions-report-${new Date().toISOString().split('T')[0]}`;
          break;

        case 'revenue':
          const revenueRes = await PaymentsAPI.listTransactions({ limit: 10000, page: 1 });
          data = (revenueRes.data || [])
            .filter((tx: any) => {
              const txDate = new Date(tx.createdAt);
              return txDate >= start && tx.status === 'completed';
            })
            .map((tx: any) => ({
              Reference: tx.reference || tx.id,
              Type: tx.type || '',
              Amount: tx.amount || 0,
              Currency: tx.currency || 'RWF',
              'Payment Method': tx.paymentMethod || '',
              'Created At': tx.createdAt ? new Date(tx.createdAt).toLocaleString() : '',
            }));
          filename = `revenue-report-${new Date().toISOString().split('T')[0]}`;
          break;
      }

      if (format === 'csv') {
        await exportToCSV(data, filename);
        toast.success(`Report exported successfully as ${filename}.csv`);
      } else if (format === 'excel') {
        await exportToExcel(data, filename);
        toast.success(`Report exported successfully as ${filename}.xlsx`);
      } else if (format === 'pdf') {
        await exportToPDF(data, filename);
      }
    } catch (error: any) {
      console.error('Failed to export report:', error);
      toast.error(error?.message || 'Failed to export report');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="space-y-6">
      {/* Header */}
      <div>
        <h1 className="text-2xl font-bold text-gray-900">Reports</h1>
        <p className="text-gray-600 mt-1">Generate and export reports</p>
      </div>

      {/* Report Configuration */}
      <Card>
        <CardHeader>
          <div className="flex items-center gap-2">
            <Icon icon={faFileAlt} className="text-[#0e1a30]" size="sm" />
            <h2 className="text-lg font-semibold text-gray-900">Report Configuration</h2>
          </div>
        </CardHeader>
        <CardBody>
          <div className="space-y-6">
            {/* Report Type */}
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">Report Type</label>
              <div className="grid grid-cols-2 md:grid-cols-4 gap-3">
                {(['users', 'bookings', 'transactions', 'revenue'] as ReportType[]).map((type) => (
                  <button
                    key={type}
                    onClick={() => setReportType(type)}
                    className={`px-4 py-3 border rounded-sm text-sm font-medium transition-colors ${
                      reportType === type
                        ? 'border-[#0e1a30] bg-[#0e1a30] text-white'
                        : 'border-gray-200 text-gray-700 hover:border-[#0e1a30] hover:text-[#0e1a30]'
                    }`}
                  >
                    {type.charAt(0).toUpperCase() + type.slice(1)}
                  </button>
                ))}
              </div>
            </div>

            {/* Date Range */}
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">Date Range</label>
              <div className="grid grid-cols-2 md:grid-cols-5 gap-3">
                {(['7d', '30d', '90d', '1y', 'custom'] as const).map((range) => (
                  <button
                    key={range}
                    onClick={() => setDateRange(range)}
                    className={`px-4 py-2 border rounded-sm text-sm font-medium transition-colors ${
                      dateRange === range
                        ? 'border-[#0e1a30] bg-[#0e1a30] text-white'
                        : 'border-gray-200 text-gray-700 hover:border-[#0e1a30] hover:text-[#0e1a30]'
                    }`}
                  >
                    {range === '7d' ? 'Last 7 days' : range === '30d' ? 'Last 30 days' : range === '90d' ? 'Last 90 days' : range === '1y' ? 'Last year' : 'Custom'}
                  </button>
                ))}
              </div>
            </div>

            {/* Custom Date Range */}
            {dateRange === 'custom' && (
              <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">Start Date</label>
                  <input
                    type="date"
                    value={startDate}
                    onChange={(e) => setStartDate(e.target.value)}
                    className="w-full px-3 py-2 border border-gray-200 rounded-sm focus:outline-none focus:ring-1 focus:ring-[#0e1a30] focus:border-[#0e1a30]"
                  />
                </div>
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">End Date</label>
                  <input
                    type="date"
                    value={endDate}
                    onChange={(e) => setEndDate(e.target.value)}
                    className="w-full px-3 py-2 border border-gray-200 rounded-sm focus:outline-none focus:ring-1 focus:ring-[#0e1a30] focus:border-[#0e1a30]"
                  />
                </div>
              </div>
            )}

            {/* Export Buttons */}
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">Export Format</label>
              <div className="flex flex-wrap gap-3">
                <Button
                  onClick={() => handleExport('csv')}
                  disabled={loading}
                  className="flex items-center gap-2"
                >
                  <Icon icon={faFileAlt} size="sm" />
                  Export CSV
                </Button>
                <Button
                  onClick={() => handleExport('excel')}
                  disabled={loading}
                  variant="secondary"
                  className="flex items-center gap-2"
                >
                  <Icon icon={faFileAlt} size="sm" />
                  Export Excel
                </Button>
                <Button
                  onClick={() => handleExport('pdf')}
                  disabled={loading}
                  variant="outline"
                  className="flex items-center gap-2"
                >
                  <Icon icon={faFileAlt} size="sm" />
                  Export PDF
                </Button>
              </div>
            </div>
          </div>
        </CardBody>
      </Card>

      {/* Report Information */}
      <Card>
        <CardHeader>
          <h2 className="text-lg font-semibold text-gray-900">Report Information</h2>
        </CardHeader>
        <CardBody>
          <div className="space-y-2 text-sm text-gray-600">
            <p>
              <strong>Users Report:</strong> Exports all user data including name, email, phone, roles, verification status, and account status.
            </p>
            <p>
              <strong>Bookings Report:</strong> Exports booking information including booking number, user details, listing/event, status, payment status, and amounts.
            </p>
            <p>
              <strong>Transactions Report:</strong> Exports all transaction data including reference, type, status, amount, payment method, and user information.
            </p>
            <p>
              <strong>Revenue Report:</strong> Exports completed transactions only, showing revenue breakdown by type and payment method.
            </p>
          </div>
        </CardBody>
      </Card>
    </div>
  );
}
