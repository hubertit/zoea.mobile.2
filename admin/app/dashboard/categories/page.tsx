'use client';

import { useState, useEffect } from 'react';
import { useRouter } from 'next/navigation';
import Link from 'next/link';
import { CategoriesAPI, type Category } from '@/src/lib/api';
import Icon, { faSearch, faPlus, faTimes, faTags, faChevronRight } from '@/app/components/Icon';
import { toast } from '@/app/components/Toaster';
import { Button, Modal } from '@/app/components';
import Card, { CardHeader, CardBody } from '@/app/components/Card';
import Input from '@/app/components/Input';
import PageSkeleton from '@/app/components/PageSkeleton';

export default function CategoriesPage() {
  const router = useRouter();
  const [categories, setCategories] = useState<Category[]>([]);
  const [loading, setLoading] = useState(true);
  const [search, setSearch] = useState('');
  const [createModalOpen, setCreateModalOpen] = useState(false);
  const [creating, setCreating] = useState(false);
  const [expandedCategories, setExpandedCategories] = useState<Set<string>>(new Set());

  const [formData, setFormData] = useState({
    name: '',
    slug: '',
    parentId: '',
    description: '',
    sortOrder: 0,
    isActive: true,
  });

  useEffect(() => {
    const fetchCategories = async () => {
      setLoading(true);
      try {
        const data = await CategoriesAPI.listCategories();
        setCategories(data);
      } catch (error: any) {
        console.error('Failed to fetch categories:', error);
        toast.error(error?.message || 'Failed to load categories');
      } finally {
        setLoading(false);
      }
    };

    fetchCategories();
  }, []);

  const handleCreate = async () => {
    if (!formData.name.trim() || !formData.slug.trim()) {
      toast.error('Name and slug are required');
      return;
    }

    setCreating(true);
    try {
      await CategoriesAPI.createCategory({
        name: formData.name.trim(),
        slug: formData.slug.trim(),
        parentId: formData.parentId || undefined,
        description: formData.description.trim() || undefined,
        sortOrder: formData.sortOrder || 0,
        isActive: formData.isActive,
      });
      
      toast.success('Category created successfully');
      setCreateModalOpen(false);
      setFormData({
        name: '',
        slug: '',
        parentId: '',
        description: '',
        sortOrder: 0,
        isActive: true,
      });
      
      // Refresh list
      const data = await CategoriesAPI.listCategories();
      setCategories(data);
    } catch (error: any) {
      console.error('Failed to create category:', error);
      toast.error(error?.message || 'Failed to create category');
    } finally {
      setCreating(false);
    }
  };

  const toggleCategory = (categoryId: string) => {
    setExpandedCategories((prev) => {
      const newSet = new Set(prev);
      if (newSet.has(categoryId)) {
        newSet.delete(categoryId);
      } else {
        newSet.add(categoryId);
      }
      return newSet;
    });
  };

  const filteredCategories = categories.filter((cat) => {
    if (!search.trim()) return true;
    const searchLower = search.toLowerCase();
    return cat.name.toLowerCase().includes(searchLower) ||
           cat.slug.toLowerCase().includes(searchLower) ||
           cat.description?.toLowerCase().includes(searchLower);
  });

  if (loading) {
    return <PageSkeleton />;
  }

  const renderCategory = (category: Category, level: number = 0) => {
    const isExpanded = expandedCategories.has(category.id);
    const hasChildren = category.children && category.children.length > 0;

    return (
      <div key={category.id} className="border border-gray-200 rounded-sm">
        <div
          className={`p-4 hover:bg-gray-50 cursor-pointer ${level > 0 ? 'ml-6' : ''}`}
          onClick={() => hasChildren && toggleCategory(category.id)}
        >
          <div className="flex items-center justify-between">
            <div className="flex items-center gap-3 flex-1">
              {hasChildren && (
                <Icon
                  icon={isExpanded ? faChevronRight : faChevronRight}
                  className={`text-gray-400 transform transition-transform ${isExpanded ? 'rotate-90' : ''}`}
                  size="sm"
                />
              )}
              {!hasChildren && <div className="w-4" />}
              <div className="w-10 h-10 bg-[#0e1a30]/10 rounded-full flex items-center justify-center">
                <Icon icon={faTags} className="text-[#0e1a30]" size="sm" />
              </div>
              <div className="flex-1">
                <div className="flex items-center gap-2">
                  <Link
                    href={`/dashboard/categories/${category.id}`}
                    className="text-sm font-medium text-[#0e1a30] hover:underline"
                    onClick={(e) => e.stopPropagation()}
                  >
                    {category.name}
                  </Link>
                  {!category.isActive && (
                    <span className="inline-flex items-center px-2 py-0.5 rounded-full text-xs font-medium bg-gray-100 text-gray-800">
                      Inactive
                    </span>
                  )}
                </div>
                <p className="text-xs text-gray-500 mt-1">
                  {category.slug} {category._count && (
                    <>• {category._count.listings || 0} listings, {category._count.tours || 0} tours</>
                  )}
                </p>
              </div>
            </div>
          </div>
        </div>
        {hasChildren && isExpanded && (
          <div className="border-t border-gray-200">
            {category.children?.map((child) => renderCategory(child, level + 1))}
          </div>
        )}
      </div>
    );
  };

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex items-center justify-between flex-wrap gap-4">
        <div>
          <h1 className="text-2xl font-bold text-gray-900">Categories</h1>
          <p className="text-gray-600 mt-1">Manage content categories and hierarchy</p>
        </div>
        <Button
          variant="primary"
          size="md"
          icon={faPlus}
          onClick={() => setCreateModalOpen(true)}
        >
          Create Category
        </Button>
      </div>

      {/* Filters */}
      <div className="bg-white border border-gray-200 rounded-sm p-4">
        <div className="relative">
          <Icon
            icon={faSearch}
            className="absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400"
            size="sm"
          />
          <input
            type="text"
            placeholder="Search categories..."
            value={search}
            onChange={(e) => setSearch(e.target.value)}
            className="w-full pl-10 pr-4 py-2 border border-gray-200 rounded-sm focus:outline-none focus:ring-1 focus:ring-[#0e1a30] focus:border-[#0e1a30] text-sm"
          />
          {search && (
            <button
              onClick={() => setSearch('')}
              className="absolute right-3 top-1/2 transform -translate-y-1/2 text-gray-400 hover:text-gray-600"
            >
              <Icon icon={faTimes} size="xs" />
            </button>
          )}
        </div>
      </div>

      {/* Categories List */}
      <div className="space-y-2">
        {filteredCategories.length > 0 ? (
          filteredCategories.map((category) => renderCategory(category))
        ) : (
          <Card>
            <CardBody>
              <p className="text-center text-gray-500 py-8">No categories found</p>
            </CardBody>
          </Card>
        )}
      </div>

      {/* Create Category Modal */}
      <Modal
        isOpen={createModalOpen}
        onClose={() => {
          setCreateModalOpen(false);
          setFormData({
            name: '',
            slug: '',
            parentId: '',
            description: '',
            sortOrder: 0,
            isActive: true,
          });
        }}
        title="Create Category"
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
              {categories.map((cat) => (
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
                setCreateModalOpen(false);
                setFormData({
                  name: '',
                  slug: '',
                  parentId: '',
                  description: '',
                  sortOrder: 0,
                  isActive: true,
                });
              }}
              disabled={creating}
            >
              Cancel
            </Button>
            <Button
              variant="primary"
              size="md"
              onClick={handleCreate}
              loading={creating}
            >
              Create Category
            </Button>
          </div>
        </div>
      </Modal>
    </div>
  );
}

