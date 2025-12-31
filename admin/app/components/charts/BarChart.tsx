'use client';

import dynamic from 'next/dynamic';
import { ApexOptions } from 'apexcharts';

const Chart = dynamic(() => import('react-apexcharts'), { ssr: false });

interface BarChartProps {
  title?: string;
  data: Array<{ x: string | number; y: number }>;
  colors?: string[];
  height?: number;
  showLegend?: boolean;
  horizontal?: boolean;
}

export default function BarChart({
  title,
  data,
  colors = ['#0e1a30'],
  height = 300,
  showLegend = false,
  horizontal = false,
}: BarChartProps) {
  const series = [
    {
      name: title || 'Data',
      data: data.map((item) => item.y),
    },
  ];

  const options: ApexOptions = {
    chart: {
      type: 'bar',
      toolbar: {
        show: false,
      },
    },
    plotOptions: {
      bar: {
        horizontal: horizontal,
        borderRadius: 4,
      },
    },
    dataLabels: {
      enabled: false,
    },
    colors: colors,
    xaxis: {
      categories: data.map((item) => item.x),
      labels: {
        style: {
          colors: '#6b7280',
          fontSize: '12px',
        },
      },
    },
    yaxis: {
      labels: {
        style: {
          colors: '#6b7280',
          fontSize: '12px',
        },
      },
    },
    grid: {
      borderColor: '#e5e7eb',
      strokeDashArray: 4,
    },
    legend: {
      show: showLegend,
      position: 'top',
      horizontalAlign: 'right',
    },
    tooltip: {
      theme: 'light',
    },
  };

  return <Chart options={options} series={series} type="bar" height={height} />;
}

