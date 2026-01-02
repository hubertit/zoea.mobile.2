'use client';

import { useState, useEffect } from 'react';
import { useRouter, useParams, useSearchParams } from 'next/navigation';
import { MerchantPortalAPI } from '@/src/lib/api';
import { toast } from '@/app/components/Toaster';
import { Button, Select, Breadcrumbs, StatusBadge } from '@/app/components';
import PageSkeleton from '@/app/components/PageSkeleton';
import Icon, { faArrowLeft, faReceipt } from '@/app/components/Icon';

export default function OrderDetailPage() {
  const router = useRouter();
  const params = useParams();
  const searchParams = useSearchParams();
  const orderId = params.id as string;
  const businessId = searchParams.get('businessId') || '';
  const [order, setOrder] = useState<any>(null);
  const [loading, setLoading] = useState(true);
  const [updating, setUpdating] = useState(false);
  const [status, setStatus] = useState<string>('');

  useEffect(() => {
    if (orderId) {
      fetchOrder();
    }
  }, [orderId]);

  useEffect(() => {
    if (order) {
      setStatus(order.status || 'pending');
    }
  }, [order]);

  const fetchOrder = async () => {
    setLoading(true);
    try {
      const data = await MerchantPortalAPI.getOrder(orderId);
      setOrder(data);
    } catch (error: any) {
      console.error('Failed to fetch order:', error);
      toast.error(error?.response?.data?.message || error?.message || 'Failed to load order');
    } finally {
      setLoading(false);
    }
  };

  const handleUpdateStatus = async () => {
    if (!businessId || !order) return;
    setUpdating(true);
    try {
      await MerchantPortalAPI.updateOrderStatus(orderId, {
        status,
      });
      toast.success('Order status updated successfully');
      fetchOrder();
    } catch (error: any) {
      console.error('Failed to update order status:', error);
      toast.error(error?.response?.data?.message || error?.message || 'Failed to update order status');
    } finally {
      setUpdating(false);
    }
  };

  if (loading) {
    return <PageSkeleton />;
  }

  if (!order) {
    return (
      <div className="space-y-6">
        <Breadcrumbs items={[
          { label: 'Dashboard', href: '/dashboard/my-dashboard' },
          { label: 'Orders', href: `/dashboard/my-orders?businessId=${businessId}` },
          { label: 'Order Details' }
        ]} />
        <div className="text-center py-12">
          <p className="text-gray-600">Order not found</p>
        </div>
      </div>
    );
  }

  return (
    <div className="space-y-6">
      <Breadcrumbs items={[
        { label: 'Dashboard', href: '/dashboard/my-dashboard' },
        { label: 'Orders', href: `/dashboard/my-orders?businessId=${businessId}` },
        { label: `Order #${order.orderNumber}` }
      ]} />

      <div className="flex items-center justify-between">
        <div className="flex items-center gap-4">
          <Button
            variant="ghost"
            size="sm"
            icon={faArrowLeft}
            onClick={() => router.push(`/dashboard/my-orders?businessId=${businessId}`)}
          >
            Back
          </Button>
          <div>
            <h1 className="text-2xl font-bold text-gray-900">Order #{order.orderNumber}</h1>
            <p className="text-gray-600 mt-1">{order.listing?.name || 'N/A'}</p>
          </div>
        </div>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        {/* Order Details */}
        <div className="lg:col-span-2 space-y-6">
          <div className="bg-white border border-gray-200 rounded-sm p-6">
            <h2 className="text-lg font-semibold text-gray-900 mb-4">Order Items</h2>
            <div className="space-y-4">
              {order.items?.map((item: any) => (
                <div key={item.id} className="flex items-center justify-between p-4 border border-gray-200 rounded-sm">
                  <div>
                    <p className="font-medium text-gray-900">
                      {item.product?.name || item.service?.name || item.menuItem?.name || 'Unknown Item'}
                    </p>
                    <p className="text-sm text-gray-600">
                      Quantity: {item.quantity} × {item.unitPrice?.toLocaleString()} {item.currency || 'RWF'}
                    </p>
                  </div>
                  <p className="font-medium text-gray-900">
                    {(item.quantity * (item.unitPrice || 0)).toLocaleString()} {item.currency || 'RWF'}
                  </p>
                </div>
              ))}
            </div>
          </div>

          <div className="bg-white border border-gray-200 rounded-sm p-6">
            <h2 className="text-lg font-semibold text-gray-900 mb-4">Customer Information</h2>
            <div className="space-y-3">
              <div>
                <p className="text-sm text-gray-600">Name</p>
                <p className="text-gray-900 font-medium">{order.customerName}</p>
              </div>
              {order.customerEmail && (
                <div>
                  <p className="text-sm text-gray-600">Email</p>
                  <p className="text-gray-900">{order.customerEmail}</p>
                </div>
              )}
              <div>
                <p className="text-sm text-gray-600">Phone</p>
                <p className="text-gray-900">{order.customerPhone}</p>
              </div>
              {order.customerNotes && (
                <div>
                  <p className="text-sm text-gray-600">Notes</p>
                  <p className="text-gray-900">{order.customerNotes}</p>
                </div>
              )}
            </div>
          </div>

          {order.deliveryAddress && (
            <div className="bg-white border border-gray-200 rounded-sm p-6">
              <h2 className="text-lg font-semibold text-gray-900 mb-4">Delivery Address</h2>
              <div className="space-y-2">
                <p className="text-gray-900">{order.deliveryAddress.address1}</p>
                {order.deliveryAddress.address2 && (
                  <p className="text-gray-900">{order.deliveryAddress.address2}</p>
                )}
                <p className="text-gray-900">
                  {order.deliveryAddress.city}
                  {order.deliveryAddress.state ? `, ${order.deliveryAddress.state}` : ''}
                  {order.deliveryAddress.zipCode ? ` ${order.deliveryAddress.zipCode}` : ''}
                </p>
                <p className="text-gray-900">{order.deliveryAddress.country}</p>
              </div>
            </div>
          )}
        </div>

        {/* Order Summary */}
        <div className="space-y-6">
          <div className="bg-white border border-gray-200 rounded-sm p-6">
            <h2 className="text-lg font-semibold text-gray-900 mb-4">Order Summary</h2>
            <div className="space-y-3">
              <div className="flex justify-between">
                <span className="text-gray-600">Status</span>
                <StatusBadge
                  status={
                    order.status === 'confirmed' || order.status === 'processing' ? 'active' :
                    order.status === 'pending' ? 'pending' :
                    order.status === 'delivered' ? 'active' :
                    order.status === 'cancelled' ? 'inactive' : 'pending'
                  }
                />
              </div>
              <div className="flex justify-between">
                <span className="text-gray-600">Fulfillment</span>
                <span className="text-gray-900 capitalize">
                  {order.fulfillmentType?.replace('_', ' ') || 'N/A'}
                </span>
              </div>
              <div className="flex justify-between">
                <span className="text-gray-600">Subtotal</span>
                <span className="text-gray-900">
                  {order.subtotal?.toLocaleString()} {order.currency || 'RWF'}
                </span>
              </div>
              {order.taxAmount > 0 && (
                <div className="flex justify-between">
                  <span className="text-gray-600">Tax</span>
                  <span className="text-gray-900">
                    {order.taxAmount.toLocaleString()} {order.currency || 'RWF'}
                  </span>
                </div>
              )}
              {order.shippingAmount > 0 && (
                <div className="flex justify-between">
                  <span className="text-gray-600">Shipping</span>
                  <span className="text-gray-900">
                    {order.shippingAmount.toLocaleString()} {order.currency || 'RWF'}
                  </span>
                </div>
              )}
              {order.discountAmount > 0 && (
                <div className="flex justify-between">
                  <span className="text-gray-600">Discount</span>
                  <span className="text-gray-900 text-red-600">
                    -{order.discountAmount.toLocaleString()} {order.currency || 'RWF'}
                  </span>
                </div>
              )}
              <div className="border-t border-gray-200 pt-3 flex justify-between">
                <span className="font-semibold text-gray-900">Total</span>
                <span className="font-semibold text-gray-900">
                  {order.totalAmount?.toLocaleString()} {order.currency || 'RWF'}
                </span>
              </div>
            </div>
          </div>

          <div className="bg-white border border-gray-200 rounded-sm p-6">
            <h2 className="text-lg font-semibold text-gray-900 mb-4">Update Status</h2>
            <div className="space-y-4">
              <Select
                label="Order Status"
                value={status}
                onChange={(e) => setStatus(e.target.value)}
                options={[
                  { value: 'pending', label: 'Pending' },
                  { value: 'confirmed', label: 'Confirmed' },
                  { value: 'processing', label: 'Processing' },
                  { value: 'shipped', label: 'Shipped' },
                  { value: 'out_for_delivery', label: 'Out for Delivery' },
                  { value: 'ready_for_pickup', label: 'Ready for Pickup' },
                  { value: 'delivered', label: 'Delivered' },
                  { value: 'cancelled', label: 'Cancelled' },
                ]}
              />
              <Button
                variant="primary"
                onClick={handleUpdateStatus}
                loading={updating}
                className="w-full"
              >
                Update Status
              </Button>
            </div>
          </div>

          <div className="bg-white border border-gray-200 rounded-sm p-6">
            <h2 className="text-lg font-semibold text-gray-900 mb-4">Order Information</h2>
            <div className="space-y-3 text-sm">
              <div>
                <p className="text-gray-600">Order Date</p>
                <p className="text-gray-900">
                  {new Date(order.createdAt).toLocaleString()}
                </p>
              </div>
              {order.deliveryDate && (
                <div>
                  <p className="text-gray-600">Delivery Date</p>
                  <p className="text-gray-900">
                    {new Date(order.deliveryDate).toLocaleDateString()}
                  </p>
                </div>
              )}
              {order.deliveryTimeSlot && (
                <div>
                  <p className="text-gray-600">Delivery Time</p>
                  <p className="text-gray-900">{order.deliveryTimeSlot}</p>
                </div>
              )}
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
