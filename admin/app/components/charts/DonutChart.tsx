'use client';

import dynamic from 'next/dynamic';
import { ApexOptions } from 'apexcharts';

const Chart = dynamic(() => import('react-apexcharts'), { ssr: false });

interface DonutChartProps {
  title?: string;
  data: Array<{ label: string; value: number }>;
  colors?: string[];
  height?: number;
  showLegend?: boolean;
}

export default function DonutChart({
  title,
  data,
  colors = ['#0e1a30', '#334f87', '#667ba5', '#99a7c3', '#ccd3e1'],
  height = 300,
  showLegend = true,
}: DonutChartProps) {
  const series = data.map((item) => item.value);
  const labels = data.map((item) => item.label);

  const options: ApexOptions = {
    chart: {
      type: 'donut',
      toolbar: {
        show: false,
      },
    },
    labels: labels,
    colors: colors,
    dataLabels: {
      enabled: true,
      formatter: (val: number) => `${val.toFixed(1)}%`,
    },
    legend: {
      show: showLegend,
      position: 'bottom',
      horizontalAlign: 'center',
    },
    tooltip: {
      theme: 'light',
      y: {
        formatter: (val: number) => `${val}`,
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
              fontSize: '14px',
              fontWeight: 600,
              color: '#111827',
            },
            value: {
              show: true,
              fontSize: '20px',
              fontWeight: 700,
              color: '#0e1a30',
            },
            total: {
              show: title ? true : false,
              label: title || '',
              fontSize: '14px',
              fontWeight: 600,
              color: '#6b7280',
            },
          },
        },
      },
    },
  };

  return <Chart options={options} series={series} type="donut" height={height} />;
}

