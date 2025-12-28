'use client';

import dynamic from 'next/dynamic';
import { ApexOptions } from 'apexcharts';

const Chart = dynamic(() => import('react-apexcharts'), { ssr: false });

interface PieChartProps {
  data: Array<{
    name: string;
    value: number;
  }>;
  height?: number;
  colors?: string[];
}

const DEFAULT_COLORS = ['#181E29', '#1a74e8', '#10b981', '#f59e0b', '#ef4444', '#8b5cf6', '#06b6d4', '#ec4899'];

export default function PieChart({ data, height = 300, colors = DEFAULT_COLORS }: PieChartProps) {
  if (!data || data.length === 0 || data.every(item => item.value === 0)) {
    return (
      <div className="flex items-center justify-center h-[300px] text-gray-400">
        <p className="text-sm">No data available</p>
      </div>
    );
  }

  const series = data.map(item => item.value);
  const labels = data.map(item => item.name);

  const options: ApexOptions = {
    chart: {
      type: 'donut',
      toolbar: {
        show: false,
      },
      fontFamily: 'inherit',
    },
    labels: labels,
    colors: colors.slice(0, data.length),
    legend: {
      position: 'bottom',
      fontSize: '12px',
      fontFamily: 'inherit',
      labels: {
        colors: '#6b7280',
      },
      markers: {
        size: 8,
      },
      itemMargin: {
        horizontal: 8,
        vertical: 4,
      },
    },
    tooltip: {
      theme: 'light',
      style: {
        fontSize: '12px',
        fontFamily: 'inherit',
      },
      y: {
        formatter: (value: number) => {
          const total = data.reduce((sum, item) => sum + item.value, 0);
          const percent = total > 0 ? ((value / total) * 100).toFixed(1) : '0';
          return `${value.toLocaleString()} (${percent}%)`;
        },
      },
    },
    dataLabels: {
      enabled: true,
      formatter: (val: number) => {
        return val > 3 ? `${val.toFixed(0)}%` : '';
      },
      style: {
        fontSize: '12px',
        fontWeight: 600,
        colors: ['#fff'],
        fontFamily: 'inherit',
      },
      dropShadow: {
        enabled: true,
        blur: 3,
        opacity: 0.3,
      },
    },
    plotOptions: {
      pie: {
        donut: {
          size: '70%',
          labels: {
            show: true,
            name: {
              show: true,
              fontSize: '13px',
              fontWeight: 500,
              color: '#6b7280',
              fontFamily: 'inherit',
            },
            value: {
              show: true,
              fontSize: '18px',
              fontWeight: 700,
              color: '#181E29',
              fontFamily: 'inherit',
              formatter: (val: string) => {
                const total = data.reduce((sum, item) => sum + item.value, 0);
                return total > 0 ? Math.round((parseFloat(val) / total) * 100) + '%' : '0%';
              },
            },
            total: {
              show: true,
              label: 'Total',
              fontSize: '12px',
              fontWeight: 500,
              color: '#9ca3af',
              fontFamily: 'inherit',
              formatter: () => {
                const total = data.reduce((sum, item) => sum + item.value, 0);
                return total.toLocaleString();
              },
            },
          },
        },
      },
    },
  };

  return (
    <div style={{ height: `${height}px` }}>
      <Chart
        options={options}
        series={series}
        type="donut"
        height={height}
      />
    </div>
  );
}
