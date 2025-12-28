'use client';

import Link from 'next/link';
import Icon, { faArrowLeft, faFileAlt } from '../../../components/Icon';

export default function SalesReportsPage() {
  const reports = [
    { name: 'E-commerce Sales Report', href: '/admin/reports/ecommerce/sales' },
    { name: 'Real Estate Sales Report', href: '/admin/reports/real-estate/sales' },
  ];

  return (
    <div>
      <div className="mb-8">
        <div className="flex items-center gap-4 mb-4">
          <Link
            href="/admin/reports"
            className="p-2 hover:bg-gray-100 rounded-lg transition-colors"
          >
            <Icon icon={faArrowLeft} />
          </Link>
          <div>
            <h1 className="text-3xl font-bold text-gray-900 mb-2">Sales Reports</h1>
            <p className="text-gray-600">View and analyze sales-related reports</p>
          </div>
        </div>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        {reports.map((report, index) => (
          <Link
            key={index}
            href={report.href}
            className="bg-white rounded-lg shadow-sm border border-gray-200 p-6 hover:shadow-md hover:border-primary transition-all"
          >
            <div className="flex items-center gap-3">
              <Icon icon={faFileAlt} className="text-primary" size="lg" />
              <span className="font-medium text-gray-900">{report.name}</span>
            </div>
          </Link>
        ))}
      </div>
    </div>
  );
}

