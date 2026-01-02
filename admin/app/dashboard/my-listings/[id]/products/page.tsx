'use client';

import { useState, useEffect } from 'react';
import { useRouter, useParams, useSearchParams } from 'next/navigation';
import { MerchantPortalAPI } from '@/src/lib/api';
import { toast } from '@/app/components/Toaster';
import { Button, Modal, Input, Select, Textarea, Breadcrumbs, StatusBadge, ConfirmDialog, DataTable, Pagination } from '@/app/components';
import PageSkeleton from '@/app/components/PageSkeleton';
import Icon, { faArrowLeft, faPlus, faEdit, faTrash, faBox } from '@/app/components/Icon';

export default function ProductsPage() {
  const router = useRouter();
  const params = useParams();
  const searchParams = useSearchParams();
  const listingId = params.id as string;
  const businessId = searchParams.get('businessId') || '';
  const [products, setProducts] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);
  const [page, setPage] = useState(1);
  const [pageSize, setPageSize] = useState(20);
  const [total, setTotal] = useState(0);
  const [showModal, setShowModal] = useState(false);
  const [editingProduct, setEditingProduct] = useState<any>(null);
  const [deletingProductId, setDeletingProductId] = useState<string | null>(null);
  const [formData, setFormData] = useState({
    name: '',
    description: '',
    shortDescription: '',
    basePrice: '',
    compareAtPrice: '',
    currency: 'RWF',
    sku: '',
    trackInventory: true,
    inventoryQuantity: '',
    lowStockThreshold: '5',
    allowBackorders: false,
    category: '',
    tags: '',
    status: 'draft',
    isFeatured: false,
  });

  useEffect(() => {
    if (businessId && listingId) {
      fetchProducts();
    }
  }, [businessId, listingId, page, pageSize]);

  const fetchProducts = async () => {
    if (!businessId || !listingId) return;
    setLoading(true);
    try {
      const response = await MerchantPortalAPI.getProducts(listingId, {
        page,
        limit: pageSize,
      });
      setProducts(response.data || []);
      setTotal(response.meta?.total || 0);
    } catch (error: any) {
      console.error('Failed to fetch products:', error);
      toast.error(error?.response?.data?.message || error?.message || 'Failed to load products');
    } finally {
      setLoading(false);
    }
  };

  const handleSave = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!businessId || !listingId) return;

    try {
      const data = {
        listingId,
        name: formData.name,
        description: formData.description || undefined,
        shortDescription: formData.shortDescription || undefined,
        basePrice: parseFloat(formData.basePrice),
        compareAtPrice: formData.compareAtPrice ? parseFloat(formData.compareAtPrice) : undefined,
        currency: formData.currency,
        sku: formData.sku || undefined,
        trackInventory: formData.trackInventory,
        inventoryQuantity: formData.inventoryQuantity ? parseInt(formData.inventoryQuantity) : 0,
        lowStockThreshold: parseInt(formData.lowStockThreshold),
        allowBackorders: formData.allowBackorders,
        category: formData.category || undefined,
        tags: formData.tags ? formData.tags.split(',').map(t => t.trim()) : [],
        status: formData.status as any,
        isFeatured: formData.isFeatured,
      };

      if (editingProduct) {
        await MerchantPortalAPI.updateProduct(editingProduct.id, data);
        toast.success('Product updated successfully');
      } else {
        await MerchantPortalAPI.createProduct(data);
        toast.success('Product created successfully');
      }
      setShowModal(false);
      setEditingProduct(null);
      resetForm();
      fetchProducts();
    } catch (error: any) {
      console.error('Failed to save product:', error);
      toast.error(error?.response?.data?.message || error?.message || 'Failed to save product');
    }
  };

  const handleDelete = async (productId: string) => {
    if (!businessId) return;
    try {
      await MerchantPortalAPI.deleteProduct(productId);
      toast.success('Product deleted successfully');
      fetchProducts();
      setDeletingProductId(null);
    } catch (error: any) {
      console.error('Failed to delete product:', error);
      toast.error(error?.response?.data?.message || error?.message || 'Failed to delete product');
    }
  };

  const resetForm = () => {
    setFormData({
      name: '',
      description: '',
      shortDescription: '',
      basePrice: '',
      compareAtPrice: '',
      currency: 'RWF',
      sku: '',
      trackInventory: true,
      inventoryQuantity: '',
      lowStockThreshold: '5',
      allowBackorders: false,
      category: '',
      tags: '',
      status: 'draft',
      isFeatured: false,
    });
  };

  const openEditModal = (product: any) => {
    setEditingProduct(product);
    setFormData({
      name: product.name || '',
      description: product.description || '',
      shortDescription: product.shortDescription || '',
      basePrice: product.basePrice?.toString() || '',
      compareAtPrice: product.compareAtPrice?.toString() || '',
      currency: product.currency || 'RWF',
      sku: product.sku || '',
      trackInventory: product.trackInventory ?? true,
      inventoryQuantity: product.inventoryQuantity?.toString() || '',
      lowStockThreshold: product.lowStockThreshold?.toString() || '5',
      allowBackorders: product.allowBackorders ?? false,
      category: product.category || '',
      tags: product.tags?.join(', ') || '',
      status: product.status || 'draft',
      isFeatured: product.isFeatured ?? false,
    });
    setShowModal(true);
  };

  const columns = [
    {
      key: 'name',
      label: 'Product',
      sortable: false,
      render: (_: any, row: any) => (
        <div>
          <p className="font-medium text-gray-900">{row.name}</p>
          {row.shortDescription && (
            <p className="text-sm text-gray-500">{row.shortDescription}</p>
          )}
        </div>
      ),
    },
    {
      key: 'price',
      label: 'Price',
      sortable: false,
      render: (_: any, row: any) => (
        <div>
          <p className="font-medium text-gray-900">
            {row.basePrice?.toLocaleString()} {row.currency || 'RWF'}
          </p>
          {row.compareAtPrice && (
            <p className="text-sm text-gray-500 line-through">
              {row.compareAtPrice.toLocaleString()} {row.currency || 'RWF'}
            </p>
          )}
        </div>
      ),
    },
    {
      key: 'inventory',
      label: 'Inventory',
      sortable: false,
      render: (_: any, row: any) => (
        <div>
          {row.trackInventory ? (
            <>
              <p className="text-sm text-gray-900">
                {row.inventoryQuantity || 0} in stock
              </p>
              {row.inventoryQuantity <= row.lowStockThreshold && (
                <p className="text-sm text-red-600">Low stock</p>
              )}
            </>
          ) : (
            <p className="text-sm text-gray-500">Not tracked</p>
          )}
        </div>
      ),
    },
    {
      key: 'status',
      label: 'Status',
      sortable: false,
      render: (_: any, row: any) => (
        <StatusBadge
          status={
            row.status === 'active' ? 'active' :
            row.status === 'draft' ? 'pending' :
            row.status === 'out_of_stock' ? 'inactive' : 'pending'
          }
        />
      ),
    },
    {
      key: 'actions',
      label: 'Actions',
      sortable: false,
      render: (_: any, row: any) => (
        <div className="flex gap-2">
          <Button
            variant="ghost"
            size="sm"
            icon={faEdit}
            onClick={() => openEditModal(row)}
          >
            Edit
          </Button>
          <Button
            variant="ghost"
            size="sm"
            icon={faTrash}
            onClick={() => setDeletingProductId(row.id)}
          >
            Delete
          </Button>
        </div>
      ),
    },
  ];

  if (loading && products.length === 0) {
    return <PageSkeleton />;
  }

  return (
    <div className="space-y-6">
      <Breadcrumbs items={[
        { label: 'Dashboard', href: '/dashboard/my-dashboard' },
        { label: 'My Listings', href: `/dashboard/my-listings?businessId=${businessId}` },
        { label: 'Listing Details', href: `/dashboard/my-listings/${listingId}?businessId=${businessId}` },
        { label: 'Products' }
      ]} />

      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-bold text-gray-900">Products</h1>
          <p className="text-gray-600 mt-1">Manage products for this listing</p>
        </div>
        <Button
          variant="primary"
          icon={faPlus}
          onClick={() => {
            setEditingProduct(null);
            resetForm();
            setShowModal(true);
          }}
        >
          Add Product
        </Button>
      </div>

      <div className="bg-white border border-gray-200 rounded-sm">
        <DataTable
          data={products}
          columns={columns}
          loading={loading}
        />
        {total > pageSize && (
          <div className="p-4 border-t border-gray-200">
            <Pagination
              currentPage={page}
              totalPages={Math.ceil(total / pageSize)}
              onPageChange={setPage}
            />
          </div>
        )}
      </div>

      {/* Product Modal */}
      <Modal
        isOpen={showModal}
        onClose={() => {
          setShowModal(false);
          setEditingProduct(null);
          resetForm();
        }}
        title={editingProduct ? 'Edit Product' : 'Add Product'}
      >
        <form onSubmit={handleSave} className="space-y-4">
          <Input
            label="Product Name"
            value={formData.name}
            onChange={(e) => setFormData({ ...formData, name: e.target.value })}
            required
          />
          <Input
            label="Short Description"
            value={formData.shortDescription}
            onChange={(e) => setFormData({ ...formData, shortDescription: e.target.value })}
            placeholder="Brief product description"
          />
          <Textarea
            label="Description"
            value={formData.description}
            onChange={(e) => setFormData({ ...formData, description: e.target.value })}
            rows={4}
          />
          <div className="grid grid-cols-2 gap-4">
            <Input
              label="Base Price"
              type="number"
              value={formData.basePrice}
              onChange={(e) => setFormData({ ...formData, basePrice: e.target.value })}
              required
            />
            <Input
              label="Compare At Price (Optional)"
              type="number"
              value={formData.compareAtPrice}
              onChange={(e) => setFormData({ ...formData, compareAtPrice: e.target.value })}
            />
          </div>
          <div className="grid grid-cols-2 gap-4">
            <Select
              label="Currency"
              value={formData.currency}
              onChange={(e) => setFormData({ ...formData, currency: e.target.value })}
              options={[
                { value: 'RWF', label: 'RWF' },
                { value: 'USD', label: 'USD' },
                { value: 'EUR', label: 'EUR' },
              ]}
            />
            <Select
              label="Status"
              value={formData.status}
              onChange={(e) => setFormData({ ...formData, status: e.target.value })}
              options={[
                { value: 'draft', label: 'Draft' },
                { value: 'active', label: 'Active' },
                { value: 'inactive', label: 'Inactive' },
                { value: 'out_of_stock', label: 'Out of Stock' },
              ]}
            />
          </div>
          <Input
            label="SKU (Optional)"
            value={formData.sku}
            onChange={(e) => setFormData({ ...formData, sku: e.target.value })}
            placeholder="Product SKU"
          />
          <div className="flex items-center gap-4">
            <label className="flex items-center gap-2">
              <input
                type="checkbox"
                checked={formData.trackInventory}
                onChange={(e) => setFormData({ ...formData, trackInventory: e.target.checked })}
                className="rounded"
              />
              <span className="text-sm text-gray-700">Track Inventory</span>
            </label>
            <label className="flex items-center gap-2">
              <input
                type="checkbox"
                checked={formData.isFeatured}
                onChange={(e) => setFormData({ ...formData, isFeatured: e.target.checked })}
                className="rounded"
              />
              <span className="text-sm text-gray-700">Featured</span>
            </label>
          </div>
          {formData.trackInventory && (
            <div className="grid grid-cols-2 gap-4">
              <Input
                label="Inventory Quantity"
                type="number"
                value={formData.inventoryQuantity}
                onChange={(e) => setFormData({ ...formData, inventoryQuantity: e.target.value })}
              />
              <Input
                label="Low Stock Threshold"
                type="number"
                value={formData.lowStockThreshold}
                onChange={(e) => setFormData({ ...formData, lowStockThreshold: e.target.value })}
              />
            </div>
          )}
          <Input
            label="Category (Optional)"
            value={formData.category}
            onChange={(e) => setFormData({ ...formData, category: e.target.value })}
            placeholder="e.g., Apparel, Electronics"
          />
          <Input
            label="Tags (comma-separated)"
            value={formData.tags}
            onChange={(e) => setFormData({ ...formData, tags: e.target.value })}
            placeholder="tag1, tag2, tag3"
          />
          <div className="flex gap-2 justify-end">
            <Button
              type="button"
              variant="ghost"
              onClick={() => {
                setShowModal(false);
                setEditingProduct(null);
                resetForm();
              }}
            >
              Cancel
            </Button>
            <Button type="submit" variant="primary">
              {editingProduct ? 'Update' : 'Create'}
            </Button>
          </div>
        </form>
      </Modal>

      {/* Delete Confirmation */}
      <ConfirmDialog
        isOpen={deletingProductId !== null}
        onClose={() => setDeletingProductId(null)}
        onConfirm={() => deletingProductId && handleDelete(deletingProductId)}
        title="Delete Product"
        message="Are you sure you want to delete this product? This action cannot be undone."
      />
    </div>
  );
}

