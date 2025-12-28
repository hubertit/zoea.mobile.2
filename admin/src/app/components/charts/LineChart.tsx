'use client';

import dynamic from 'next/dynamic';
import { ApexOptions } from 'apexcharts';

const Chart = dynamic(() => import('react-apexcharts'), { ssr: false });

interface LineChartProps {
  data: Array<Record<string, any>>;
  dataKey: string;
  lines: Array<{
    key: string;
    name: string;
    color?: string;
  }>;
  height?: number;
}

export default function LineChart({ data, dataKey, lines, height = 300 }: LineChartProps) {
  if (!data || data.length === 0) {
    return (
      <div className="flex items-center justify-center h-[300px] text-gray-400">
        <p className="text-sm">No data available</p>
      </div>
    );
  }

  const series = lines.map(line => ({
    name: line.name,
    data: data.map(item => item[line.key] || 0),
  }));

  const options: ApexOptions = {
    chart: {
      type: 'area',
      toolbar: {
        show: false,
      },
      zoom: {
        enabled: false,
      },
      fontFamily: 'inherit',
      sparkline: {
        enabled: false,
      },
    },
    stroke: {
      curve: 'smooth',
      width: 3,
    },
    fill: {
      type: 'gradient',
      gradient: {
        shadeIntensity: 1,
        opacityFrom: 0.5,
        opacityTo: 0.1,
        stops: [0, 50, 100],
      },
    },
    markers: {
      size: 4,
      hover: {
        size: 6,
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
      show: true,
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
    colors: lines.map((line, index) => {
      if (line.color) return line.color;
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
        type="area"
        height={height}
      />
    </div>
  );
}
