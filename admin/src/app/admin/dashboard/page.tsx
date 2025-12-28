'use client';

import { useEffect, useState } from 'react';
import Icon, {
  faUsers,
  faStore,
  faHome as faHomeIcon,
  faShoppingCart,
  faCalendar,
  faDollarSign,
  faArrowRight,
  faFileAlt,
  faClock,
} from '../../components/Icon';
import StatCard from '../../components/StatCard';
import ChartWrapper from '../../components/ChartWrapper';
import LineChart from '../../components/charts/LineChart';
import BarChart from '../../components/charts/BarChart';
import PieChart from '../../components/charts/PieChart';
import { fetchAdminStats, fetchChartData } from '@/lib/api';

export default function AdminDashboard() {
  const [statsData, setStatsData] = useState({
    totalUsers: 0,
    activeUsers: 0,
    inactiveUsers: 0,
    totalVenues: 0,
    activeVenues: 0,
    pendingVenues: 0,
    totalProperties: 0,
    totalEvents: 0,
    totalOrders: 0,
    totalRevenue: 0,
    totalApplications: 0,
    pendingApplications: 0,
  });
  const [chartData, setChartData] = useState<{
    revenue: Array<{ date: string; revenue: number; orders: number }>;
    ordersByStatus: Array<{ name: string; value: number }>;
    userGrowth: Array<{ date: string; users: number }>;
    applicationsByStatus: Array<{ name: string; value: number }>;
    propertiesByCategory: Array<{ name: string; value: number }>;
  }>({
    revenue: [],
    ordersByStatus: [],
    userGrowth: [],
    applicationsByStatus: [],
    propertiesByCategory: [],
  });
  const [loading, setLoading] = useState(true);
  const [chartsLoading, setChartsLoading] = useState(true);

  useEffect(() => {
    const loadData = async () => {
      setLoading(true);
      setChartsLoading(true);
      try {
        const [stats, charts] = await Promise.all([
          fetchAdminStats(),
          fetchChartData(),
        ]);
        setStatsData(stats);
        setChartData(charts);
      } catch (error) {
        console.error('Failed to load dashboard data:', error);
      } finally {
        setLoading(false);
        setChartsLoading(false);
      }
    };

    loadData();
  }, []);

  const formatCurrency = (amount: number) => {
    return new Intl.NumberFormat('en-RW', {
      style: 'currency',
      currency: 'RWF',
      minimumFractionDigits: 0,
    }).format(amount);
  };

  const stats = [
    { 
      label: 'Total Users', 
      value: loading ? '...' : statsData.totalUsers.toLocaleString(), 
      icon: faUsers,
      subtitle: `${statsData.activeUsers} active, ${statsData.inactiveUsers} inactive`,
      href: '/admin/users',
      iconColor: '#1a74e8',
      iconBgColor: '#eff6ff'
    },
    { 
      label: 'Total Venues', 
      value: loading ? '...' : statsData.totalVenues.toLocaleString(), 
      icon: faStore,
      subtitle: `${statsData.activeVenues} active, ${statsData.pendingVenues} pending`,
      href: '/admin/venues',
      iconColor: '#181E29',
      iconBgColor: '#f9fafb'
    },
    { 
      label: 'Properties', 
      value: loading ? '...' : statsData.totalProperties.toLocaleString(), 
      icon: faHomeIcon,
      subtitle: 'Available listings',
      href: '/admin/real-estate',
      iconColor: '#1a74e8',
      iconBgColor: '#eff6ff'
    },
    { 
      label: 'Total Events', 
      value: loading ? '...' : statsData.totalEvents.toLocaleString(), 
      icon: faCalendar,
      subtitle: 'All events',
      href: '/admin/events',
      iconColor: '#181E29',
      iconBgColor: '#f9fafb'
    },
    { 
      label: 'Total Orders', 
      value: loading ? '...' : statsData.totalOrders.toLocaleString(), 
      icon: faShoppingCart,
      subtitle: 'E-commerce orders',
      href: '/admin/ecommerce/orders',
      iconColor: '#1a74e8',
      iconBgColor: '#eff6ff'
    },
    { 
      label: 'Total Revenue', 
      value: loading ? '...' : formatCurrency(statsData.totalRevenue), 
      icon: faDollarSign,
      subtitle: 'From all orders',
      href: '/admin/reports',
      iconColor: '#181E29',
      iconBgColor: '#f9fafb'
    },
    { 
      label: 'Applications', 
      value: loading ? '...' : statsData.totalApplications.toLocaleString(), 
      icon: faFileAlt,
      subtitle: `${statsData.pendingApplications} pending review`,
      href: '/admin/applications',
      iconColor: '#1a74e8',
      iconBgColor: '#eff6ff'
    },
    { 
      label: 'Pending Venues', 
      value: loading ? '...' : statsData.pendingVenues.toLocaleString(), 
      icon: faClock,
      subtitle: 'Awaiting approval',
      href: '/admin/venues',
      iconColor: '#181E29',
      iconBgColor: '#f9fafb'
    },
  ];

  const quickActions = [
    { label: 'Manage Users', href: '/admin/users', icon: faUsers },
    { label: 'Manage Venues', href: '/admin/venues', icon: faStore },
    { label: 'Manage Properties', href: '/admin/real-estate', icon: faHomeIcon },
    { label: 'View Orders', href: '/admin/ecommerce/orders', icon: faShoppingCart },
    { label: 'Event Applications', href: '/admin/events/applications', icon: faCalendar },
    { label: 'View Reports', href: '/admin/reports', icon: faDollarSign },
  ];

  return (
    <div>
      {/* Stats Grid */}
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-6 mb-8">
        {stats.map((stat, index) => (
          <StatCard
            key={index}
            label={stat.label}
            value={stat.value}
            icon={stat.icon}
            href={stat.href}
            loading={loading}
            subtitle={stat.subtitle}
            iconColor={stat.iconColor}
            iconBgColor={stat.iconBgColor}
          />
        ))}
      </div>

      {/* Charts Section */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6 mb-8">
        {/* Revenue & Orders Chart */}
        <ChartWrapper title="Revenue & Orders (Last 7 Days)" loading={chartsLoading}>
          <LineChart
            data={chartData.revenue}
            dataKey="date"
            lines={[
              { key: 'revenue', name: 'Revenue', color: '#181E29' },
              { key: 'orders', name: 'Orders', color: '#1a74e8' },
            ]}
            height={300}
          />
        </ChartWrapper>

        {/* User Growth Chart */}
        <ChartWrapper title="User Growth (Last 7 Days)" loading={chartsLoading}>
          <BarChart
            data={chartData.userGrowth}
            dataKey="date"
            bars={[
              { key: 'users', name: 'New Users', color: '#1a74e8' },
            ]}
            height={300}
          />
        </ChartWrapper>

        {/* Orders by Status */}
        <ChartWrapper title="Orders by Status" loading={chartsLoading}>
          <PieChart
            data={chartData.ordersByStatus}
            height={300}
          />
        </ChartWrapper>

        {/* Applications by Status */}
        <ChartWrapper title="Applications by Status" loading={chartsLoading}>
          <PieChart
            data={chartData.applicationsByStatus}
            height={300}
          />
        </ChartWrapper>
      </div>

      {/* Quick Actions */}
      <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-6">
        <h2 className="text-xl font-bold text-gray-900 mb-4">Quick Actions</h2>
        <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-4">
          {quickActions.map((action, index) => (
            <a
              key={index}
              href={action.href}
              className="flex items-center gap-3 p-4 border border-gray-200 rounded-lg hover:border-primary hover:bg-primary/5 transition-all group"
            >
              <Icon icon={action.icon} className="text-gray-500 group-hover:text-primary" />
              <span className="font-medium text-gray-900 group-hover:text-primary">{action.label}</span>
              <Icon icon={faArrowRight} className="ml-auto text-gray-400 group-hover:text-primary" size="sm" />
            </a>
          ))}
        </div>
      </div>
    </div>
  );
}

