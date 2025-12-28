'use client';

import Icon, {
  faFileAlt,
  faChartLine,
  faDownload,
  faCalendar,
  faStore,
  faShoppingCart,
  faUsers,
} from '../../components/Icon';
import Link from 'next/link';

export default function ReportsPage() {
  const reportCategories = [
    {
      title: 'Event Reports',
      icon: faCalendar,
      color: 'bg-pink-500',
      reports: [
        { name: 'Event Applications Report', href: '/admin/reports/events/applications' },
        { name: 'Event Attendance Report', href: '/admin/reports/events/attendance' },
        { name: 'QR Code Usage Report', href: '/admin/reports/events/qr-codes' },
      ],
    },
    {
      title: 'Venue Reports',
      icon: faStore,
      color: 'bg-green-500',
      reports: [
        { name: 'Venue Performance Report', href: '/admin/reports/venues/performance' },
        { name: 'Booking Analytics Report', href: '/admin/reports/venues/bookings' },
        { name: 'Revenue Report', href: '/admin/reports/venues/revenue' },
        { name: 'Review & Rating Report', href: '/admin/reports/venues/reviews' },
      ],
    },
    {
      title: 'Real Estate Reports',
      icon: faStore,
      color: 'bg-purple-500',
      reports: [
        { name: 'Property Listing Report', href: '/admin/reports/real-estate/listings' },
        { name: 'Sales Report', href: '/admin/reports/real-estate/sales' },
        { name: 'Market Analysis Report', href: '/admin/reports/real-estate/market' },
        { name: 'Agent Performance Report', href: '/admin/reports/real-estate/agents' },
      ],
    },
    {
      title: 'E-commerce Reports',
      icon: faShoppingCart,
      color: 'bg-orange-500',
      reports: [
        { name: 'Sales Report', href: '/admin/reports/ecommerce/sales' },
        { name: 'Order Status Report', href: '/admin/reports/ecommerce/orders' },
        { name: 'Payment Report', href: '/admin/reports/ecommerce/payments' },
        { name: 'Merchant Performance Report', href: '/admin/reports/ecommerce/merchants' },
      ],
    },
    {
      title: 'User Reports',
      icon: faUsers,
      color: 'bg-blue-500',
      reports: [
        { name: 'User Growth Report', href: '/admin/reports/users/growth' },
        { name: 'User Activity Report', href: '/admin/reports/users/activity' },
        { name: 'User Segmentation Report', href: '/admin/reports/users/segmentation' },
      ],
    },
  ];

  return (
    <div>
      <div className="mb-8">
        <h1 className="text-3xl font-bold text-gray-900 mb-2">Reports</h1>
        <p className="text-gray-600">Generate and view comprehensive reports across all modules</p>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        {reportCategories.map((category, index) => (
          <div
            key={index}
            className="bg-white rounded-sm shadow-sm border border-gray-200 p-6"
          >
            <div className="flex items-center gap-4 mb-4">
              <div className={`${category.color} p-3 rounded-sm`}>
                <Icon icon={category.icon} className="text-white" size="lg" />
              </div>
              <h3 className="text-lg font-semibold text-gray-900">{category.title}</h3>
            </div>
            <ul className="space-y-2">
              {category.reports.map((report, reportIndex) => (
                <li key={reportIndex}>
                  <Link
                    href={report.href}
                    className="flex items-center gap-2 text-sm text-gray-700 hover:text-primary transition-colors py-2"
                  >
                    <Icon icon={faFileAlt} className="text-gray-400" size="xs" />
                    <span>{report.name}</span>
                  </Link>
                </li>
              ))}
            </ul>
          </div>
        ))}
      </div>

      {/* Quick Actions */}
      <div className="mt-8 bg-white rounded-sm shadow-sm border border-gray-200 p-6">
        <h2 className="text-xl font-bold text-gray-900 mb-4">Quick Actions</h2>
        <div className="flex flex-wrap gap-4">
          <button className="flex items-center gap-2 px-4 py-2 bg-primary text-white rounded-sm hover:bg-primary-600 transition-colors">
            <Icon icon={faDownload} />
            <span>Export All Reports</span>
          </button>
          <button className="flex items-center gap-2 px-4 py-2 bg-gray-100 text-gray-700 rounded-sm hover:bg-gray-200 transition-colors">
            <Icon icon={faCalendar} />
            <span>Schedule Report</span>
          </button>
        </div>
      </div>
    </div>
  );
}

