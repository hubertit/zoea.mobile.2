'use client';

import Card, { CardHeader, CardBody } from '@/app/components/Card';

export default function OrganizersPage() {
  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-2xl font-bold text-gray-900">Event Organizers</h1>
        <p className="text-gray-600 mt-1">Manage event organizers</p>
      </div>

      <Card>
        <CardHeader>
          <h2 className="text-lg font-semibold text-gray-900">Coming Soon</h2>
        </CardHeader>
        <CardBody>
          <p className="text-gray-600">Event organizers management will be available soon.</p>
        </CardBody>
      </Card>
    </div>
  );
}

