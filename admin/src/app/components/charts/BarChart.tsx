'use client';

import dynamic from 'next/dynamic';
import { ApexOptions } from 'apexcharts';

const Chart = dynamic(() => import('react-apexcharts'), { ssr: false });

interface BarChartProps {
  data: Array<Record<string, any>>;
  dataKey: string;
  bars: Array<{
    key: string;
    name: string;
    color?: string;
  }>;
  height?: number;
}

export default function BarChart({ data, dataKey, bars, height = 300 }: BarChartProps) {
  if (!data || data.length === 0) {
    return (
      <div className="flex items-center justify-center h-[300px] text-gray-400">
        <p className="text-sm">No data available</p>
      </div>
    );
  }

  const series = bars.map(bar => ({
    name: bar.name,
    data: data.map(item => item[bar.key] || 0),
  }));

  const options: ApexOptions = {
    chart: {
      type: 'bar',
      toolbar: {
        show: false,
      },
      fontFamily: 'inherit',
    },
    plotOptions: {
      bar: {
        borderRadius: 8,
        horizontal: false,
        columnWidth: bars.length > 1 ? '65%' : '75%',
        dataLabels: {
          position: 'top',
        },
        distributed: false,
      },
    },
    xaxis: {
      categories: data.map(item => item[dataKey]),
      labels: {
        style: {
          colors: '#6b7280',
          fontSize: '12px',
          fontFamily: 'inherit',
        },
        rotate: -45,
        rotateAlways: false,
      },
      axisBorder: {
        show: true,
        color: '#e5e7eb',
      },
      axisTicks: {
        show: true,
        color: '#e5e7eb',
      },
    },
    yaxis: {
      labels: {
        style: {
          colors: '#6b7280',
          fontSize: '12px',
          fontFamily: 'inherit',
        },
        formatter: (val: number) => {
          if (val >= 1000) return (val / 1000).toFixed(1) + 'K';
          return val.toString();
        },
      },
      axisBorder: {
        show: true,
        color: '#e5e7eb',
      },
    },
    grid: {
      borderColor: '#e5e7eb',
      strokeDashArray: 3,
      xaxis: {
        lines: {
          show: true,
        },
      },
      yaxis: {
        lines: {
          show: true,
        },
      },
      padding: {
        top: 10,
        right: 10,
        bottom: 10,
        left: 10,
      },
    },
    tooltip: {
      theme: 'light',
      style: {
        fontSize: '12px',
        fontFamily: 'inherit',
      },
      x: {
        show: true,
      },
      marker: {
        show: true,
      },
    },
    legend: {
      show: bars.length > 1,
      position: 'top',
      horizontalAlign: 'right',
      fontSize: '12px',
      fontFamily: 'inherit',
      labels: {
        colors: '#6b7280',
      },
      markers: {
        size: 8,
      },
      itemMargin: {
        horizontal: 12,
        vertical: 4,
      },
    },
    colors: bars.map((bar, index) => {
      if (bar.color) return bar.color;
      // Use blue as secondary color, primary as first
      const colorPalette = ['#181E29', '#1a74e8', '#10b981', '#f59e0b', '#ef4444', '#8b5cf6'];
      return colorPalette[index % colorPalette.length];
    }),
    dataLabels: {
      enabled: false,
    },
  };

  return (
    <div style={{ height: `${height}px` }}>
      <Chart
        options={options}
        series={series}
        type="bar"
        height={height}
      />
    </div>
  );
}
