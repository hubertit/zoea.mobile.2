'use client';

import { useState, useEffect } from 'react';
import { useRouter, usePathname } from 'next/navigation';
import AdminHeader from '../components/AdminHeader';
import AdminSidebar from '../components/AdminSidebar';

export default function AdminLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  const router = useRouter();
  const pathname = usePathname();
  const [sidebarOpen, setSidebarOpen] = useState(false);
  const [sidebarCollapsed, setSidebarCollapsed] = useState(false);
  const [adminName, setAdminName] = useState('');

  useEffect(() => {
    if (pathname === '/admin/login') {
      return;
    }

    try {
      const authRaw = sessionStorage.getItem('zoeaAdminAuth');
      if (!authRaw) {
        router.replace('/admin/login');
        return;
      }

      const auth = JSON.parse(authRaw) as { role?: string; name?: string; email?: string } | null;
      if (!auth || auth.role !== 'admin') {
        router.replace('/admin/login');
        return;
      }

      setAdminName(auth.name || auth.email || 'Administrator');
    } catch (error) {
      console.error('Failed to read authentication state', error);
      router.replace('/admin/login');
    }
  }, [router, pathname]);

  if (pathname === '/admin/login') {
    return <>{children}</>;
  }

  return (
    <div className="min-h-screen bg-background">
      <AdminHeader
        adminName={adminName}
        onMenuToggle={() => setSidebarOpen(!sidebarOpen)}
        sidebarOpen={sidebarOpen}
        sidebarCollapsed={sidebarCollapsed}
      />
      <div className="flex">
        <AdminSidebar
          isOpen={sidebarOpen}
          onClose={() => setSidebarOpen(false)}
          onCollapsedChange={setSidebarCollapsed}
        />
        <main className={`flex-1 transition-all duration-300 ${sidebarCollapsed ? 'lg:ml-20' : 'lg:ml-64'}`}>
          <div className="p-4 sm:p-6 lg:p-8">
            {children}
          </div>
        </main>
      </div>
    </div>
  );
}

