'use client';

import { useState, useEffect, useRef, useCallback, startTransition } from 'react';
import { usePathname } from 'next/navigation';
import Link from 'next/link';
import { useAuthStore } from '@/src/store/auth';
import Icon, {
  faHome,
  faBox,
  faBuilding,
  faIdCard as faCar,
  faUser,
  faClipboardList,
  faReceipt,
  faChartLine,
  faUsers,
  faCog,
  faUserShield,
  faChevronLeft,
  faChevronRight,
  faBars,
  faChevronDown,
  faChevronUp,
  faCalendar,
  faList,
  faStar,
  faMapMarkerAlt,
  faFileAlt,
  faBell,
  faImage,
  faGlobe,
  faShieldAlt,
  faTags,
  faRoute,
} from './Icon';

interface DashboardSidebarProps {
  isOpen: boolean;
  onClose: () => void;
  onCollapsedChange?: (collapsed: boolean) => void;
}

interface MenuItem {
  icon: any;
  label: string;
  href?: string;
  children?: MenuItem[];
  roles?: string[];
}

export default function DashboardSidebar({ isOpen, onClose, onCollapsedChange }: DashboardSidebarProps) {
  const pathname = usePathname();
  const { user } = useAuthStore();
  
  const getInitialCollapsed = () => {
    if (typeof window === 'undefined') return false;
    const saved = localStorage.getItem('zoeaSidebarCollapsed');
    return saved === 'true';
  };
  
  const [collapsed, setCollapsed] = useState(getInitialCollapsed);
  const [expandedMenus, setExpandedMenus] = useState<string[]>(['dashboard']);
  const [userInfo, setUserInfo] = useState<{ name?: string; email?: string; role?: string } | null>(null);
  
  const onCollapsedChangeRef = useRef(onCollapsedChange);
  const isInitialMount = useRef(true);
  
  useEffect(() => {
    onCollapsedChangeRef.current = onCollapsedChange;
  }, [onCollapsedChange]);
  
  useEffect(() => {
    if (isInitialMount.current) {
      onCollapsedChangeRef.current?.(collapsed);
      isInitialMount.current = false;
    }
  }, []);
  
  useEffect(() => {
    const timeoutId = setTimeout(() => {
      localStorage.setItem('zoeaSidebarCollapsed', collapsed.toString());
    }, 0);
    
    if (!isInitialMount.current) {
      startTransition(() => {
        onCollapsedChangeRef.current?.(collapsed);
      });
    }
    
    return () => clearTimeout(timeoutId);
  }, [collapsed]);

  useEffect(() => {
    if (user) {
      const userRoles = user.roles || [];
      let roleLabel = 'Admin';
      const roleValues = userRoles.map((r: any) => {
        if (typeof r === 'string') return r.toLowerCase();
        return (r.code || r.name || '').toLowerCase();
      });
      
      if (roleValues.includes('super_admin')) {
        roleLabel = 'Super Admin';
      } else if (roleValues.includes('admin')) {
        roleLabel = 'Admin';
      } else if (roleValues.includes('merchant')) {
        roleLabel = 'Merchant';
      }
      
      setUserInfo({
        name: user.name || user.fullName || 'Admin',
        email: user.email || '',
        role: roleLabel,
      });
    }
  }, [user]);
  
  const handleCollapse = useCallback((e: React.MouseEvent<HTMLButtonElement>) => {
    e.preventDefault();
    e.stopPropagation();
    e.nativeEvent.stopImmediatePropagation();
    isInitialMount.current = false;
    
    startTransition(() => {
      setCollapsed(true);
    });
  }, []);
  
  const handleExpand = useCallback((e: React.MouseEvent<HTMLButtonElement>) => {
    e.preventDefault();
    e.stopPropagation();
    e.nativeEvent.stopImmediatePropagation();
    isInitialMount.current = false;
    
    startTransition(() => {
      setCollapsed(false);
    });
  }, []);

  const userRoles = user?.roles || [];
  const userRoleCodes = userRoles.map((r: any) => {
    if (typeof r === 'string') return r.toUpperCase();
    return (r.code || r.name || 'admin').toUpperCase();
  });

  const allMenuItems: MenuItem[] = [
    { 
      icon: faHome, 
      label: 'Dashboard', 
      href: '/dashboard',
      roles: ['SUPER_ADMIN', 'ADMIN'],
    },
    { 
      icon: faHome, 
      label: 'Dashboard', 
      href: '/dashboard/my-dashboard',
      roles: ['MERCHANT', 'merchant'],
    },
    {
      icon: faBox,
      label: 'Content',
      roles: ['SUPER_ADMIN', 'ADMIN'],
      children: [
        {
          icon: faList,
          label: 'Listings',
          href: '/dashboard/listings',
        },
        {
          icon: faCalendar,
          label: 'Events',
          href: '/dashboard/events',
        },
        {
          icon: faTags,
          label: 'Categories',
          href: '/dashboard/categories',
        },
        {
          icon: faStar,
          label: 'Reviews',
          href: '/dashboard/reviews',
        },
        {
          icon: faRoute,
          label: 'Tours',
          href: '/dashboard/tours',
        },
      ],
    },
    {
      icon: faUsers,
      label: 'Users',
      roles: ['SUPER_ADMIN', 'ADMIN'],
      children: [
        {
          icon: faUser,
          label: 'All Users',
          href: '/dashboard/users',
        },
        {
          icon: faShieldAlt,
          label: 'Roles',
          href: '/dashboard/users/roles',
        },
      ],
    },
    {
      icon: faBuilding,
      label: 'Business',
      roles: ['SUPER_ADMIN', 'ADMIN'],
      children: [
        {
          icon: faBuilding,
          label: 'Merchants',
          href: '/dashboard/merchants',
        },
        {
          icon: faUserShield,
          label: 'Organizers',
          href: '/dashboard/organizers',
        },
        {
          icon: faRoute,
          label: 'Operators',
          href: '/dashboard/tour-operators',
        },
      ],
    },
    {
      icon: faClipboardList,
      label: 'Bookings',
      roles: ['SUPER_ADMIN', 'ADMIN'],
      children: [
        {
          icon: faClipboardList,
          label: 'All',
          href: '/dashboard/bookings',
        },
        {
          icon: faCalendar,
          label: 'Events',
          href: '/dashboard/bookings/events',
        },
        {
          icon: faBox,
          label: 'Listings',
          href: '/dashboard/bookings/listings',
        },
      ],
    },
    {
      icon: faReceipt,
      label: 'Financial',
      roles: ['SUPER_ADMIN', 'ADMIN'],
      children: [
        {
          icon: faReceipt,
          label: 'Payments',
          href: '/dashboard/payments',
        },
        {
          icon: faFileAlt,
          label: 'Transactions',
          href: '/dashboard/transactions',
        },
        {
          icon: faReceipt,
          label: 'Payouts',
          href: '/dashboard/payouts',
        },
      ],
    },
    {
      icon: faChartLine,
      label: 'Analytics',
      roles: ['SUPER_ADMIN', 'ADMIN'],
      children: [
        {
          icon: faChartLine,
          label: 'Analytics',
          href: '/dashboard/analytics',
        },
        {
          icon: faFileAlt,
          label: 'Reports',
          href: '/dashboard/reports',
        },
      ],
    },
    {
      icon: faCog,
      label: 'System',
      roles: ['SUPER_ADMIN', 'ADMIN'],
      children: [
        {
          icon: faBell,
          label: 'Notifications',
          href: '/dashboard/notifications',
        },
        {
          icon: faImage,
          label: 'Media',
          href: '/dashboard/media',
        },
        {
          icon: faMapMarkerAlt,
          label: 'Locations',
          href: '/dashboard/locations',
        },
        {
          icon: faCog,
          label: 'Settings',
          href: '/dashboard/settings',
        },
      ],
    },
    // Merchant-specific menus
    {
      icon: faBuilding,
      label: 'Businesses',
      href: '/dashboard/my-businesses',
      roles: ['MERCHANT', 'merchant'],
    },
    {
      icon: faBox,
      label: 'My Content',
      roles: ['MERCHANT', 'merchant'],
      children: [
        {
          icon: faList,
          label: 'My Listings',
          href: '/dashboard/my-listings',
        },
        {
          icon: faCalendar,
          label: 'My Events',
          href: '/dashboard/my-events',
        },
      ],
    },
    {
      icon: faClipboardList,
      label: 'My Bookings',
      href: '/dashboard/my-bookings',
      roles: ['MERCHANT', 'merchant'],
    },
    {
      icon: faChartLine,
      label: 'Analytics',
      href: '/dashboard/my-analytics',
      roles: ['MERCHANT', 'merchant'],
    },
    {
      icon: faUser,
      label: 'Profile',
      href: '/dashboard/profile',
      roles: ['MERCHANT', 'merchant'],
    },
  ];

  const menuItems = allMenuItems.filter(item => {
    if (!item.roles) return true;
    return item.roles.some(role => userRoleCodes.includes(role.toUpperCase()));
  });

  useEffect(() => {
    const currentMenu = menuItems.find(item => 
      item.href === pathname || 
      item.children?.some(child => child.href === pathname)
    );
    if (currentMenu && currentMenu.children) {
      setExpandedMenus(prev => {
        const menuKey = currentMenu.label.toLowerCase().replace(/\s+/g, '-');
        if (!prev.includes(menuKey)) {
          return [...prev, menuKey];
        }
        return prev;
      });
    }
  }, [pathname, menuItems]);

  const isActive = (href?: string) => {
    if (!href) return false;
    if (href === '/dashboard') {
      return pathname === '/dashboard';
    }
    return pathname?.startsWith(href);
  };

  const toggleMenu = (menuLabel: string) => {
    const menuKey = menuLabel.toLowerCase().replace(/\s+/g, '-');
    setExpandedMenus(prev => 
      prev.includes(menuKey) 
        ? prev.filter(key => key !== menuKey)
        : [...prev, menuKey]
    );
  };

  const isMenuExpanded = (menuLabel: string) => {
    const menuKey = menuLabel.toLowerCase().replace(/\s+/g, '-');
    return expandedMenus.includes(menuKey);
  };

  return (
    <>
      {isOpen && (
        <div
          className="fixed inset-0 bg-black/50 z-40 lg:hidden"
          onClick={onClose}
        />
      )}

      <aside
        className={`
          fixed top-0 left-0 h-full bg-[#08101c] border-r border-[#050b12] z-50
          transform transition-all duration-300 ease-in-out
          lg:translate-x-0
          ${isOpen ? 'translate-x-0' : '-translate-x-full'}
          ${collapsed ? 'w-20' : 'w-64'}
          flex flex-col
          overflow-y-auto
        `}
      >
        {/* Logo Section */}
        <div className="p-5 border-b border-[#050b12] flex-shrink-0">
          <div className={`flex items-center ${collapsed ? 'justify-center' : 'gap-3'}`}>
            <Link 
              href="/dashboard" 
              className="flex items-center gap-3 flex-1"
              onClick={(e) => {
                if (collapsed) {
                  e.preventDefault();
                }
              }}
            >
              <div className="w-10 h-10 bg-[#050b12] rounded-full flex items-center justify-center flex-shrink-0">
                <Icon icon={faBox} className="text-white" size="lg" />
              </div>
              {!collapsed && (
                <div className="flex flex-col">
                  <span className="text-lg font-bold text-white leading-tight">Zoea</span>
                  <span className="text-xs text-white/70 leading-tight">Admin Portal</span>
                </div>
              )}
            </Link>
            <div className="flex-shrink-0" onClick={(e) => e.stopPropagation()}>
              {!collapsed && (
                <button
                  type="button"
                  onClick={handleCollapse}
                  className="p-1.5 hover:bg-[#08101c] rounded-sm transition-colors text-white/80 hover:text-white"
                  aria-label="Collapse sidebar"
                  title="Collapse sidebar"
                >
                  <Icon icon={faBars} size="sm" />
                </button>
              )}
              {collapsed && (
                <button
                  type="button"
                  onClick={handleExpand}
                  className="p-1.5 hover:bg-[#08101c] rounded-sm transition-colors text-white/80 hover:text-white"
                  aria-label="Expand sidebar"
                  title="Expand sidebar"
                >
                  <Icon icon={faBars} size="sm" />
                </button>
              )}
            </div>
          </div>
        </div>

        {/* User Information Section */}
        {userInfo && (
          <div className={`
            border-b border-[#050b12] flex-shrink-0
            ${collapsed ? 'p-3 flex flex-col items-center' : 'p-5'}
          `}>
            <div className={`
              ${collapsed ? 'w-12 h-12' : 'w-24 h-24'}
              rounded-full bg-[#050b12] flex items-center justify-center flex-shrink-0 ${collapsed ? '' : 'mx-auto mb-3'}
            `}>
              <Icon icon={faUserShield} className="text-white" size={collapsed ? 'sm' : '2x'} />
            </div>
            {!collapsed && (
              <div className="text-center">
                <div className="text-sm font-semibold text-white mb-1 truncate">
                  {userInfo.name}
                </div>
                {userInfo.email && (
                  <div className="text-xs text-white/70 mb-1 truncate">
                    {userInfo.email}
                  </div>
                )}
                <div className="text-xs text-white/80 font-medium">
                  {userInfo.role}
                </div>
              </div>
            )}
          </div>
        )}

        {/* Navigation - Scrollable */}
        <nav className="flex-1 py-4 overflow-y-auto min-h-0">
          <ul className="space-y-1 px-2">
            {menuItems.map((item, index) => {
              const active = isActive(item.href);
              const hasChildren = item.children && item.children.length > 0;
              const menuKey = item.label.toLowerCase().replace(/\s+/g, '-');
              const isExpanded = isMenuExpanded(item.label);

              if (hasChildren) {
                return (
                  <li key={index}>
                    <button
                      onClick={() => toggleMenu(item.label)}
                      className={`
                        w-full flex items-center gap-3 px-4 py-3
                        transition-all duration-200
                        ${collapsed ? 'justify-center' : 'justify-between'}
                        ${
                          item.children?.some(child => isActive(child.href))
                            ? 'bg-[#050b12] text-white border-l-4 border-white/30'
                            : 'text-white/80 hover:bg-[#050b12] hover:text-white'
                        }
                      `}
                      title={collapsed ? item.label : undefined}
                    >
                      <div className="flex items-center gap-3">
                        <Icon
                          icon={item.icon}
                          className={item.children?.some(child => isActive(child.href)) ? 'text-white' : 'text-white/70'}
                          size="sm"
                        />
                        {!collapsed && (
                          <span className="text-sm font-medium">{item.label}</span>
                        )}
                      </div>
                      {!collapsed && (
                        <Icon
                          icon={isExpanded ? faChevronUp : faChevronDown}
                          className="text-white/70"
                          size="xs"
                        />
                      )}
                    </button>
                    {!collapsed && isExpanded && (
                      <ul className="ml-4 mt-1 space-y-1">
                        {item.children?.map((child, childIndex) => {
                          const childActive = isActive(child.href);
                          return (
                            <li key={childIndex}>
                              <Link
                                href={child.href || '#'}
                                onClick={onClose}
                                className={`
                                  flex items-center gap-3 px-4 py-2
                                  transition-all duration-200
                                  ${
                                    childActive
                                      ? 'bg-[#050b12] text-white border-l-2 border-white/30'
                                      : 'text-white/70 hover:bg-[#050b12] hover:text-white'
                                  }
                                `}
                              >
                                <Icon
                                  icon={child.icon}
                                  className={childActive ? 'text-white' : 'text-white/70'}
                                  size="xs"
                                />
                                <span className="text-sm">{child.label}</span>
                              </Link>
                            </li>
                          );
                        })}
                      </ul>
                    )}
                  </li>
                );
              }

              return (
                <li key={index}>
                  <Link
                    href={item.href || '#'}
                    onClick={onClose}
                    className={`
                      flex items-center gap-3 px-4 py-3
                      transition-all duration-200
                      ${collapsed ? 'justify-center' : ''}
                      ${
                        active
                          ? 'bg-[#050b12] text-white border-l-4 border-white/30'
                          : 'text-white/80 hover:bg-[#050b12] hover:text-white'
                      }
                    `}
                    title={collapsed ? item.label : undefined}
                  >
                    <Icon
                      icon={item.icon}
                      className={active ? 'text-white' : 'text-white/70'}
                      size="sm"
                    />
                    {!collapsed && (
                      <span className="text-sm font-medium">{item.label}</span>
                    )}
                  </Link>
                </li>
              );
            })}
          </ul>
        </nav>

        {/* Footer */}
        <div className="p-4 border-t border-[#050b12] flex-shrink-0">
          <Link
            href="/"
            className={`
              flex items-center gap-2 text-xs text-white/70 hover:text-white transition-colors
              ${collapsed ? 'justify-center' : ''}
            `}
            title={collapsed ? 'Back to Website' : undefined}
          >
            {!collapsed && <span>← Back to Website</span>}
            {collapsed && <Icon icon={faChevronLeft} />}
          </Link>
        </div>
      </aside>
    </>
  );
}

