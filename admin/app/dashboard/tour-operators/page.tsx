'use client';

import Card, { CardHeader, CardBody } from '@/app/components/Card';

export default function TourOperatorsPage() {
  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-2xl font-bold text-gray-900">Tour Operators</h1>
        <p className="text-gray-600 mt-1">Manage tour operators</p>
      </div>

      <Card>
        <CardHeader>
          <h2 className="text-lg font-semibold text-gray-900">Coming Soon</h2>
        </CardHeader>
        <CardBody>
          <p className="text-gray-600">Tour operators management will be available soon.</p>
        </CardBody>
      </Card>
    </div>
  );
}

