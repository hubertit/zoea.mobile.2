'use client';

import Link from 'next/link';
import Icon, { faChevronRight, faHome } from './Icon';

interface BreadcrumbItem {
  label: string;
  href?: string;
}

interface BreadcrumbsProps {
  items: BreadcrumbItem[];
}

export default function Breadcrumbs({ items }: BreadcrumbsProps) {
  return (
    <nav className="flex items-center space-x-2 text-sm text-gray-600 mb-4">
      <Link href="/dashboard" className="hover:text-[#0e1a30] transition-colors">
        <Icon icon={faHome} size="sm" />
      </Link>
      {items.map((item, index) => (
        <div key={index} className="flex items-center space-x-2">
          <Icon icon={faChevronRight} size="xs" className="text-gray-400" />
          {item.href && index < items.length - 1 ? (
            <Link href={item.href} className="hover:text-[#0e1a30] transition-colors">
              {item.label}
            </Link>
          ) : (
            <span className={index === items.length - 1 ? 'text-gray-900 font-medium' : ''}>
              {item.label}
            </span>
          )}
        </div>
      ))}
    </nav>
  );
}

