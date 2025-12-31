'use client';

import { useState, useEffect } from 'react';
import { useParams, useRouter } from 'next/navigation';
import Link from 'next/link';
import { CategoriesAPI, type Category } from '@/src/lib/api';
import Icon, { 
  faArrowLeft, 
  faEdit, 
  faTrash,
  faTags,
  faChevronRight,
  faBox,
} from '@/app/components/Icon';
import { toast } from '@/app/components/Toaster';
import { Button, Modal } from '@/app/components';
import Card, { CardHeader, CardBody } from '@/app/components/Card';
import Input from '@/app/components/Input';

export default function CategoryDetailPage() {
  const params = useParams();
  const router = useRouter();
  const categoryId = params?.id as string | undefined;

  const [category, setCategory] = useState<Category | null>(null);
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);
  const [deleting, setDeleting] = useState(false);
  const [editModalOpen, setEditModalOpen] = useState(false);
  const [deleteModalOpen, setDeleteModalOpen] = useState(false);
  const [categories, setCategories] = useState<Category[]>([]);

  const [formData, setFormData] = useState({
    name: '',
    slug: '',
    parentId: '',
    description: '',
    sortOrder: 0,
    isActive: true,
  });

  useEffect(() => {
    if (!categoryId) {
      setLoading(false);
      return;
    }

    const fetchData = async () => {
      setLoading(true);
      try {
        const [categoryData, allCategories] = await Promise.all([
          CategoriesAPI.getCategoryById(categoryId),
          CategoriesAPI.listCategories(),
        ]);
        
        setCategory(categoryData);
        setCategories(allCategories);
        setFormData({
          name: categoryData.name || '',
          slug: categoryData.slug || '',
          parentId: categoryData.parentId || '',
          description: categoryData.description || '',
          sortOrder: categoryData.sortOrder || 0,
          isActive: categoryData.isActive || false,
        });
      } catch (error: any) {
        console.error('Failed to fetch category:', error);
        toast.error(error?.message || 'Failed to load category');
        router.push('/dashboard/categories');
      } finally {
        setLoading(false);
      }
    };

    fetchData();
  }, [categoryId, router]);

  const handleSave = async () => {
    if (!categoryId) return;

    if (!formData.name.trim() || !formData.slug.trim()) {
      toast.error('Name and slug are required');
      return;
    }

    setSaving(true);
    try {
      await CategoriesAPI.updateCategory(categoryId, {
        name: formData.name.trim(),
        slug: formData.slug.trim(),
        parentId: formData.parentId || null,
        description: formData.description.trim() || undefined,
        sortOrder: formData.sortOrder || 0,
        isActive: formData.isActive,
      });
      
      // Refresh category data
      const updatedCategory = await CategoriesAPI.getCategoryById(categoryId);
      setCategory(updatedCategory);
      setEditModalOpen(false);
      toast.success('Category updated successfully');
    } catch (error: any) {
      console.error('Failed to update category:', error);
      toast.error(error?.message || 'Failed to update category');
    } finally {
      setSaving(false);
    }
  };

  const handleDelete = async () => {
    if (!categoryId) return;

    setDeleting(true);
    try {
      await CategoriesAPI.deleteCategory(categoryId);
      toast.success('Category deleted successfully');
      router.push('/dashboard/categories');
    } catch (error: any) {
      console.error('Failed to delete category:', error);
      toast.error(error?.message || 'Failed to delete category');
    } finally {
      setDeleting(false);
      setDeleteModalOpen(false);
    }
  };

  if (loading) {
    return (
      <div className="flex items-center justify-center min-h-[400px]">
        <div className="text-center">
          <div className="inline-block animate-spin rounded-full h-12 w-12 border-b-2 border-[#0e1a30] mb-4"></div>
          <p className="text-gray-600">Loading category...</p>
        </div>
      </div>
    );
  }

  if (!category) {
    return null;
  }

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex items-center justify-between flex-wrap gap-4">
        <div className="flex items-center gap-4">
          <Link href="/dashboard/categories">
            <Button variant="ghost" size="sm" icon={faArrowLeft}>
              Back
            </Button>
          </Link>
          <div>
            <h1 className="text-2xl font-bold text-gray-900">{category.name || 'Category Details'}</h1>
            <p className="text-gray-600 mt-1">
              {category.slug || 'N/A'} • {category.isActive ? 'Active' : 'Inactive'}
            </p>
          </div>
        </div>
        <div className="flex items-center gap-2">
          {category._count && (category._count.listings > 0 || category._count.tours > 0) && (
            <Link href={`/dashboard/listings?categoryId=${categoryId}`}>
              <Button
                variant="secondary"
                size="sm"
                icon={faBox}
              >
                View Listings ({category._count.listings || 0})
              </Button>
            </Link>
          )}
          <Button
            onClick={() => {
              setEditModalOpen(true);
            }}
            variant="primary"
            size="sm"
            icon={faEdit}
          >
            Edit Category
          </Button>
          <Button
            onClick={() => {
              setDeleteModalOpen(true);
            }}
            variant="danger"
            size="sm"
            icon={faTrash}
          >
            Delete
          </Button>
        </div>
      </div>

      {/* Basic Information */}
      <Card>
        <CardHeader>
          <h2 className="text-lg font-semibold text-gray-900">Basic Information</h2>
        </CardHeader>
        <CardBody>
          <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">Name</label>
              <p className="text-sm text-gray-900">{category.name || 'N/A'}</p>
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">Slug</label>
              <p className="text-sm text-gray-900">{category.slug || 'N/A'}</p>
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">Status</label>
              <span className={`inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium ${
                category.isActive ? 'bg-green-100 text-green-800' : 'bg-gray-100 text-gray-800'
              }`}>
                {category.isActive ? 'Active' : 'Inactive'}
              </span>
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">Sort Order</label>
              <p className="text-sm text-gray-900">{category.sortOrder || 0}</p>
            </div>

            {category.parent && (
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">Parent Category</label>
                <Link href={`/dashboard/categories/${category.parent.id}`} className="text-sm text-[#0e1a30] hover:underline">
                  {category.parent.name}
                </Link>
              </div>
            )}

            {category.description && (
              <div className="md:col-span-2">
                <label className="block text-sm font-medium text-gray-700 mb-1">Description</label>
                <p className="text-sm text-gray-900 whitespace-pre-wrap">{category.description}</p>
              </div>
            )}
          </div>
        </CardBody>
      </Card>

      {/* Statistics */}
      {category._count && (
        <Card>
          <CardHeader>
            <h2 className="text-lg font-semibold text-gray-900">Statistics</h2>
          </CardHeader>
          <CardBody>
            <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">Listings</label>
                <p className="text-lg font-semibold text-gray-900">{category._count.listings || 0}</p>
              </div>
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">Tours</label>
                <p className="text-lg font-semibold text-gray-900">{category._count.tours || 0}</p>
              </div>
            </div>
          </CardBody>
        </Card>
      )}

      {/* Subcategories */}
      {category.children && category.children.length > 0 && (
        <Card>
          <CardHeader>
            <h2 className="text-lg font-semibold text-gray-900">Subcategories ({category.children.length})</h2>
          </CardHeader>
          <CardBody>
            <div className="space-y-2">
              {category.children.map((child) => (
                <Link key={child.id} href={`/dashboard/categories/${child.id}`}>
                  <div className="flex items-center justify-between p-3 border border-gray-200 rounded-sm hover:bg-gray-50 cursor-pointer">
                    <div className="flex items-center gap-3">
                      <div className="w-10 h-10 bg-[#0e1a30]/10 rounded-full flex items-center justify-center">
                        <Icon icon={faTags} className="text-[#0e1a30]" size="sm" />
                      </div>
                      <div>
                        <p className="text-sm font-medium text-gray-900">{child.name}</p>
                        <p className="text-xs text-gray-500">{child.slug}</p>
                      </div>
                    </div>
                    <Icon icon={faChevronRight} className="text-gray-400" size="sm" />
                  </div>
                </Link>
              ))}
            </div>
          </CardBody>
        </Card>
      )}

      {/* Edit Category Modal */}
      <Modal
        isOpen={editModalOpen}
        onClose={() => {
          setEditModalOpen(false);
          setFormData({
            name: category.name || '',
            slug: category.slug || '',
            parentId: category.parentId || '',
            description: category.description || '',
            sortOrder: category.sortOrder || 0,
            isActive: category.isActive || false,
          });
        }}
        title="Edit Category"
        size="md"
      >
        <div className="space-y-4">
          <Input
            label="Name"
            value={formData.name}
            onChange={(e) => setFormData({ ...formData, name: e.target.value })}
            placeholder="Category name"
            required
          />
          <Input
            label="Slug"
            value={formData.slug}
            onChange={(e) => setFormData({ ...formData, slug: e.target.value.toLowerCase().replace(/\s+/g, '-') })}
            placeholder="category-slug"
            required
          />
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">Parent Category</label>
            <select
              value={formData.parentId}
              onChange={(e) => setFormData({ ...formData, parentId: e.target.value })}
              className="w-full px-3 py-2 border border-gray-200 rounded-sm focus:outline-none focus:ring-1 focus:ring-[#0e1a30] focus:border-[#0e1a30] text-sm"
            >
              <option value="">None (Top-level category)</option>
              {categories.filter((cat) => cat.id !== categoryId).map((cat) => (
                <option key={cat.id} value={cat.id}>
                  {cat.name}
                </option>
              ))}
            </select>
          </div>
          <Input
            label="Description"
            value={formData.description}
            onChange={(e) => setFormData({ ...formData, description: e.target.value })}
            placeholder="Category description (optional)"
          />
          <Input
            label="Sort Order"
            type="number"
            value={formData.sortOrder}
            onChange={(e) => setFormData({ ...formData, sortOrder: parseInt(e.target.value) || 0 })}
            placeholder="0"
          />
          <div>
            <label className="flex items-center gap-2">
              <input
                type="checkbox"
                checked={formData.isActive}
                onChange={(e) => setFormData({ ...formData, isActive: e.target.checked })}
                className="w-4 h-4 text-[#0e1a30] border-gray-300 rounded focus:ring-[#0e1a30]"
              />
              <span className="text-sm text-gray-700">Active</span>
            </label>
          </div>
          <div className="flex items-center gap-2 justify-end pt-4 border-t border-gray-200">
            <Button
              variant="secondary"
              size="md"
              onClick={() => {
                setEditModalOpen(false);
                setFormData({
                  name: category.name || '',
                  slug: category.slug || '',
                  parentId: category.parentId || '',
                  description: category.description || '',
                  sortOrder: category.sortOrder || 0,
                  isActive: category.isActive || false,
                });
              }}
              disabled={saving}
            >
              Cancel
            </Button>
            <Button
              variant="primary"
              size="md"
              onClick={handleSave}
              loading={saving}
            >
              Save Changes
            </Button>
          </div>
        </div>
      </Modal>

      {/* Delete Confirmation Modal */}
      <Modal
        isOpen={deleteModalOpen}
        onClose={() => setDeleteModalOpen(false)}
        title="Delete Category"
        size="md"
      >
        <div className="space-y-4">
          <p className="text-sm text-gray-700">
            Are you sure you want to delete the category <strong>"{category.name}"</strong>?
          </p>
          {category._count && (category._count.listings > 0 || category._count.tours > 0 || (category.children && category.children.length > 0)) && (
            <div className="bg-yellow-50 border border-yellow-200 rounded-sm p-4">
              <p className="text-sm text-yellow-800">
                <strong>Warning:</strong> This category has:
                <ul className="list-disc list-inside mt-2 space-y-1">
                  {category._count.listings > 0 && <li>{category._count.listings} listing(s)</li>}
                  {category._count.tours > 0 && <li>{category._count.tours} tour(s)</li>}
                  {category.children && category.children.length > 0 && <li>{category.children.length} subcategor(ies)</li>}
                </ul>
                You must remove or reassign them before deleting this category.
              </p>
            </div>
          )}
          <div className="flex items-center gap-2 justify-end pt-4 border-t border-gray-200">
            <Button
              variant="secondary"
              size="md"
              onClick={() => setDeleteModalOpen(false)}
              disabled={deleting}
            >
              Cancel
            </Button>
            <Button
              variant="danger"
              size="md"
              onClick={handleDelete}
              loading={deleting}
            >
              Delete Category
            </Button>
          </div>
        </div>
      </Modal>
    </div>
  );
}

