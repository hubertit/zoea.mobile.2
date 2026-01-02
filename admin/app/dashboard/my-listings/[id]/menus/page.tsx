'use client';

import { useState, useEffect } from 'react';
import { useRouter, useParams, useSearchParams } from 'next/navigation';
import { MerchantPortalAPI } from '@/src/lib/api';
import { toast } from '@/app/components/Toaster';
import { Button, Modal, Input, Select, Textarea, Breadcrumbs, StatusBadge, ConfirmDialog } from '@/app/components';
import PageSkeleton from '@/app/components/PageSkeleton';
import Icon, { faPlus, faEdit, faTrash, faUtensils, faChevronDown, faChevronUp } from '@/app/components/Icon';

export default function MenusPage() {
  const router = useRouter();
  const params = useParams();
  const searchParams = useSearchParams();
  const listingId = params.id as string;
  const businessId = searchParams.get('businessId') || '';
  const [menus, setMenus] = useState<any[]>([]);
  const [selectedMenu, setSelectedMenu] = useState<any>(null);
  const [categories, setCategories] = useState<any[]>([]);
  const [menuItems, setMenuItems] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);
  const [showMenuModal, setShowMenuModal] = useState(false);
  const [showCategoryModal, setShowCategoryModal] = useState(false);
  const [showItemModal, setShowItemModal] = useState(false);
  const [editingMenu, setEditingMenu] = useState<any>(null);
  const [editingCategory, setEditingCategory] = useState<any>(null);
  const [editingItem, setEditingItem] = useState<any>(null);
  const [deletingMenuId, setDeletingMenuId] = useState<string | null>(null);
  const [deletingCategoryId, setDeletingCategoryId] = useState<string | null>(null);
  const [deletingItemId, setDeletingItemId] = useState<string | null>(null);
  const [expandedCategories, setExpandedCategories] = useState<Set<string>>(new Set());
  const [menuFormData, setMenuFormData] = useState({
    name: '',
    description: '',
    availableDays: [] as string[],
    startTime: '',
    endTime: '',
    isActive: true,
    isDefault: false,
  });
  const [categoryFormData, setCategoryFormData] = useState({
    name: '',
    description: '',
    sortOrder: '0',
  });
  const [itemFormData, setItemFormData] = useState({
    categoryId: '',
    name: '',
    description: '',
    shortDescription: '',
    price: '',
    currency: 'RWF',
    isAvailable: true,
    isVegetarian: false,
    isVegan: false,
    isGlutenFree: false,
    allergens: '',
    calories: '',
    sortOrder: '0',
  });

  useEffect(() => {
    if (businessId && listingId) {
      fetchMenus();
    }
  }, [businessId, listingId]);

  useEffect(() => {
    if (selectedMenu) {
      fetchCategories();
      fetchMenuItems();
    }
  }, [selectedMenu]);

  const fetchMenus = async () => {
    if (!businessId || !listingId) return;
    setLoading(true);
    try {
      const data = await MerchantPortalAPI.getMenus(listingId);
      setMenus(data || []);
      if (data && data.length > 0 && !selectedMenu) {
        setSelectedMenu(data[0]);
      }
    } catch (error: any) {
      console.error('Failed to fetch menus:', error);
      toast.error(error?.response?.data?.message || error?.message || 'Failed to load menus');
    } finally {
      setLoading(false);
    }
  };

  const fetchCategories = async () => {
    if (!selectedMenu) return;
    try {
      const data = await MerchantPortalAPI.getMenuCategories(selectedMenu.id);
      setCategories(data || []);
    } catch (error: any) {
      console.error('Failed to fetch categories:', error);
    }
  };

  const fetchMenuItems = async () => {
    if (!selectedMenu) return;
    try {
      const menu = await MerchantPortalAPI.getMenu(selectedMenu.id);
      setMenuItems(menu.items || []);
    } catch (error: any) {
      console.error('Failed to fetch menu items:', error);
    }
  };

  const handleSaveMenu = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!businessId || !listingId) return;

    try {
      const data = {
        listingId,
        name: menuFormData.name,
        description: menuFormData.description || undefined,
        availableDays: menuFormData.availableDays,
        startTime: menuFormData.startTime || undefined,
        endTime: menuFormData.endTime || undefined,
        isActive: menuFormData.isActive,
        isDefault: menuFormData.isDefault,
      };

      if (editingMenu) {
        await MerchantPortalAPI.updateMenu(editingMenu.id, data);
        toast.success('Menu updated successfully');
      } else {
        await MerchantPortalAPI.createMenu(data);
        toast.success('Menu created successfully');
      }
      setShowMenuModal(false);
      setEditingMenu(null);
      resetMenuForm();
      fetchMenus();
    } catch (error: any) {
      console.error('Failed to save menu:', error);
      toast.error(error?.response?.data?.message || error?.message || 'Failed to save menu');
    }
  };

  const handleSaveCategory = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!selectedMenu) return;

    try {
      const data = {
        name: categoryFormData.name,
        description: categoryFormData.description || undefined,
        sortOrder: parseInt(categoryFormData.sortOrder),
      };

      if (editingCategory) {
        await MerchantPortalAPI.updateMenuCategory(selectedMenu.id, editingCategory.id, data);
        toast.success('Category updated successfully');
      } else {
        await MerchantPortalAPI.createMenuCategory(selectedMenu.id, data);
        toast.success('Category created successfully');
      }
      setShowCategoryModal(false);
      setEditingCategory(null);
      resetCategoryForm();
      fetchCategories();
    } catch (error: any) {
      console.error('Failed to save category:', error);
      toast.error(error?.response?.data?.message || error?.message || 'Failed to save category');
    }
  };

  const handleSaveItem = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!selectedMenu) return;

    try {
      const data = {
        categoryId: itemFormData.categoryId,
        name: itemFormData.name,
        description: itemFormData.description || undefined,
        shortDescription: itemFormData.shortDescription || undefined,
        price: parseFloat(itemFormData.price),
        currency: itemFormData.currency,
        isAvailable: itemFormData.isAvailable,
        isVegetarian: itemFormData.isVegetarian,
        isVegan: itemFormData.isVegan,
        isGlutenFree: itemFormData.isGlutenFree,
        allergens: itemFormData.allergens ? itemFormData.allergens.split(',').map(a => a.trim()) : [],
        calories: itemFormData.calories ? parseInt(itemFormData.calories) : undefined,
        sortOrder: parseInt(itemFormData.sortOrder),
      };

      if (editingItem) {
        await MerchantPortalAPI.updateMenuItem(selectedMenu.id, editingItem.id, data);
        toast.success('Menu item updated successfully');
      } else {
        await MerchantPortalAPI.createMenuItem(selectedMenu.id, data);
        toast.success('Menu item created successfully');
      }
      setShowItemModal(false);
      setEditingItem(null);
      resetItemForm();
      fetchMenuItems();
    } catch (error: any) {
      console.error('Failed to save menu item:', error);
      toast.error(error?.response?.data?.message || error?.message || 'Failed to save menu item');
    }
  };

  const handleDeleteMenu = async (menuId: string) => {
    try {
      await MerchantPortalAPI.deleteMenu(menuId);
      toast.success('Menu deleted successfully');
      fetchMenus();
      if (selectedMenu?.id === menuId) {
        setSelectedMenu(null);
      }
      setDeletingMenuId(null);
    } catch (error: any) {
      console.error('Failed to delete menu:', error);
      toast.error(error?.response?.data?.message || error?.message || 'Failed to delete menu');
    }
  };

  const handleDeleteCategory = async (categoryId: string) => {
    if (!selectedMenu) return;
    try {
      await MerchantPortalAPI.deleteMenuCategory(selectedMenu.id, categoryId);
      toast.success('Category deleted successfully');
      fetchCategories();
      setDeletingCategoryId(null);
    } catch (error: any) {
      console.error('Failed to delete category:', error);
      toast.error(error?.response?.data?.message || error?.message || 'Failed to delete category');
    }
  };

  const handleDeleteItem = async (itemId: string) => {
    if (!selectedMenu) return;
    try {
      await MerchantPortalAPI.deleteMenuItem(selectedMenu.id, itemId);
      toast.success('Menu item deleted successfully');
      fetchMenuItems();
      setDeletingItemId(null);
    } catch (error: any) {
      console.error('Failed to delete menu item:', error);
      toast.error(error?.response?.data?.message || error?.message || 'Failed to delete menu item');
    }
  };

  const resetMenuForm = () => {
    setMenuFormData({
      name: '',
      description: '',
      availableDays: [],
      startTime: '',
      endTime: '',
      isActive: true,
      isDefault: false,
    });
  };

  const resetCategoryForm = () => {
    setCategoryFormData({
      name: '',
      description: '',
      sortOrder: '0',
    });
  };

  const resetItemForm = () => {
    setItemFormData({
      categoryId: categories.length > 0 ? categories[0].id : '',
      name: '',
      description: '',
      shortDescription: '',
      price: '',
      currency: 'RWF',
      isAvailable: true,
      isVegetarian: false,
      isVegan: false,
      isGlutenFree: false,
      allergens: '',
      calories: '',
      sortOrder: '0',
    });
  };

  const openEditMenu = (menu: any) => {
    setEditingMenu(menu);
    setMenuFormData({
      name: menu.name || '',
      description: menu.description || '',
      availableDays: menu.availableDays || [],
      startTime: menu.startTime || '',
      endTime: menu.endTime || '',
      isActive: menu.isActive ?? true,
      isDefault: menu.isDefault ?? false,
    });
    setShowMenuModal(true);
  };

  const openEditCategory = (category: any) => {
    setEditingCategory(category);
    setCategoryFormData({
      name: category.name || '',
      description: category.description || '',
      sortOrder: category.sortOrder?.toString() || '0',
    });
    setShowCategoryModal(true);
  };

  const openEditItem = (item: any) => {
    setEditingItem(item);
    setItemFormData({
      categoryId: item.categoryId || (categories.length > 0 ? categories[0].id : ''),
      name: item.name || '',
      description: item.description || '',
      shortDescription: item.shortDescription || '',
      price: item.price?.toString() || '',
      currency: item.currency || 'RWF',
      isAvailable: item.isAvailable ?? true,
      isVegetarian: item.isVegetarian ?? false,
      isVegan: item.isVegan ?? false,
      isGlutenFree: item.isGlutenFree ?? false,
      allergens: item.allergens?.join(', ') || '',
      calories: item.calories?.toString() || '',
      sortOrder: item.sortOrder?.toString() || '0',
    });
    setShowItemModal(true);
  };

  const toggleCategory = (categoryId: string) => {
    const newExpanded = new Set(expandedCategories);
    if (newExpanded.has(categoryId)) {
      newExpanded.delete(categoryId);
    } else {
      newExpanded.add(categoryId);
    }
    setExpandedCategories(newExpanded);
  };

  const itemsByCategory = categories.map(cat => ({
    category: cat,
    items: menuItems.filter(item => item.categoryId === cat.id),
  }));

  if (loading) {
    return <PageSkeleton />;
  }

  return (
    <div className="space-y-6">
      <Breadcrumbs items={[
        { label: 'Dashboard', href: '/dashboard/my-dashboard' },
        { label: 'My Listings', href: `/dashboard/my-listings?businessId=${businessId}` },
        { label: 'Listing Details', href: `/dashboard/my-listings/${listingId}?businessId=${businessId}` },
        { label: 'Menus' }
      ]} />

      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-bold text-gray-900">Menus</h1>
          <p className="text-gray-600 mt-1">Manage menus and menu items for this listing</p>
        </div>
        <Button
          variant="primary"
          icon={faPlus}
          onClick={() => {
            setEditingMenu(null);
            resetMenuForm();
            setShowMenuModal(true);
          }}
        >
          Add Menu
        </Button>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-4 gap-6">
        {/* Menu List */}
        <div className="lg:col-span-1">
          <div className="bg-white border border-gray-200 rounded-sm p-4">
            <h2 className="font-semibold text-gray-900 mb-4">Menus</h2>
            <div className="space-y-2">
              {menus.map((menu) => (
                <button
                  key={menu.id}
                  onClick={() => setSelectedMenu(menu)}
                  className={`w-full text-left p-3 rounded-sm border ${
                    selectedMenu?.id === menu.id
                      ? 'border-[#0e1a30] bg-[#0e1a30] text-white'
                      : 'border-gray-200 hover:border-gray-300'
                  }`}
                >
                  <p className="font-medium">{menu.name}</p>
                  {menu.isDefault && (
                    <p className="text-xs opacity-75">Default</p>
                  )}
                </button>
              ))}
            </div>
          </div>
        </div>

        {/* Menu Content */}
        <div className="lg:col-span-3">
          {selectedMenu ? (
            <div className="space-y-6">
              {/* Menu Header */}
              <div className="bg-white border border-gray-200 rounded-sm p-6">
                <div className="flex items-center justify-between mb-4">
                  <div>
                    <h2 className="text-xl font-bold text-gray-900">{selectedMenu.name}</h2>
                    {selectedMenu.description && (
                      <p className="text-gray-600 mt-1">{selectedMenu.description}</p>
                    )}
                  </div>
                  <div className="flex gap-2">
                    <Button
                      variant="ghost"
                      size="sm"
                      icon={faEdit}
                      onClick={() => openEditMenu(selectedMenu)}
                    >
                      Edit Menu
                    </Button>
                    <Button
                      variant="ghost"
                      size="sm"
                      icon={faTrash}
                      onClick={() => setDeletingMenuId(selectedMenu.id)}
                    >
                      Delete
                    </Button>
                  </div>
                </div>
                <div className="flex gap-4 text-sm text-gray-600">
                  <StatusBadge status={selectedMenu.isActive ? 'active' : 'inactive'} />
                  {selectedMenu.isDefault && <span className="text-xs bg-blue-100 text-blue-800 px-2 py-1 rounded">Default</span>}
                </div>
              </div>

              {/* Categories */}
              <div className="bg-white border border-gray-200 rounded-sm p-6">
                <div className="flex items-center justify-between mb-4">
                  <h3 className="font-semibold text-gray-900">Categories</h3>
                  <Button
                    variant="primary"
                    size="sm"
                    icon={faPlus}
                    onClick={() => {
                      setEditingCategory(null);
                      resetCategoryForm();
                      setShowCategoryModal(true);
                    }}
                  >
                    Add Category
                  </Button>
                </div>
                <div className="space-y-2">
                  {categories.map((category) => (
                    <div key={category.id} className="border border-gray-200 rounded-sm">
                      <div className="flex items-center justify-between p-3">
                        <div className="flex items-center gap-2">
                          <button
                            onClick={() => toggleCategory(category.id)}
                            className="text-gray-500 hover:text-gray-700"
                          >
                            <Icon icon={expandedCategories.has(category.id) ? faChevronUp : faChevronDown} />
                          </button>
                          <span className="font-medium text-gray-900">{category.name}</span>
                          {category.description && (
                            <span className="text-sm text-gray-500">- {category.description}</span>
                          )}
                        </div>
                        <div className="flex gap-2">
                          <Button
                            variant="ghost"
                            size="sm"
                            icon={faEdit}
                            onClick={() => openEditCategory(category)}
                          >
                            Edit
                          </Button>
                          <Button
                            variant="ghost"
                            size="sm"
                            icon={faTrash}
                            onClick={() => setDeletingCategoryId(category.id)}
                          >
                            Delete
                          </Button>
                        </div>
                      </div>
                      {expandedCategories.has(category.id) && (
                        <div className="p-3 border-t border-gray-200 bg-gray-50">
                          <div className="flex items-center justify-between mb-2">
                            <span className="text-sm font-medium text-gray-700">Items</span>
                            <Button
                              variant="ghost"
                              size="sm"
                              icon={faPlus}
                              onClick={() => {
                                setEditingItem(null);
                                resetItemForm();
                                setItemFormData(prev => ({ ...prev, categoryId: category.id }));
                                setShowItemModal(true);
                              }}
                            >
                              Add Item
                            </Button>
                          </div>
                          <div className="space-y-2">
                            {itemsByCategory.find(c => c.category.id === category.id)?.items.map((item) => (
                              <div key={item.id} className="flex items-center justify-between p-2 bg-white rounded border border-gray-200">
                                <div>
                                  <p className="font-medium text-gray-900">{item.name}</p>
                                  {item.shortDescription && (
                                    <p className="text-sm text-gray-500">{item.shortDescription}</p>
                                  )}
                                  <p className="text-sm font-medium text-gray-900 mt-1">
                                    {item.price?.toLocaleString()} {item.currency || 'RWF'}
                                  </p>
                                </div>
                                <div className="flex gap-2">
                                  <Button
                                    variant="ghost"
                                    size="sm"
                                    icon={faEdit}
                                    onClick={() => openEditItem(item)}
                                  >
                                    Edit
                                  </Button>
                                  <Button
                                    variant="ghost"
                                    size="sm"
                                    icon={faTrash}
                                    onClick={() => setDeletingItemId(item.id)}
                                  >
                                    Delete
                                  </Button>
                                </div>
                              </div>
                            ))}
                            {itemsByCategory.find(c => c.category.id === category.id)?.items.length === 0 && (
                              <p className="text-sm text-gray-500 text-center py-4">No items in this category</p>
                            )}
                          </div>
                        </div>
                      )}
                    </div>
                  ))}
                  {categories.length === 0 && (
                    <p className="text-gray-500 text-center py-8">No categories added yet</p>
                  )}
                </div>
              </div>
            </div>
          ) : (
            <div className="bg-white border border-gray-200 rounded-sm p-12 text-center">
              <Icon icon={faUtensils} className="text-gray-400 text-4xl mb-4" />
              <p className="text-gray-600">Select a menu to manage or create a new one</p>
            </div>
          )}
        </div>
      </div>

      {/* Menu Modal */}
      <Modal
        isOpen={showMenuModal}
        onClose={() => {
          setShowMenuModal(false);
          setEditingMenu(null);
          resetMenuForm();
        }}
        title={editingMenu ? 'Edit Menu' : 'Add Menu'}
      >
        <form onSubmit={handleSaveMenu} className="space-y-4">
          <Input
            label="Menu Name"
            value={menuFormData.name}
            onChange={(e) => setMenuFormData({ ...menuFormData, name: e.target.value })}
            required
          />
          <Textarea
            label="Description"
            value={menuFormData.description}
            onChange={(e) => setMenuFormData({ ...menuFormData, description: e.target.value })}
            rows={3}
          />
          <div className="grid grid-cols-2 gap-4">
            <Input
              label="Start Time"
              type="time"
              value={menuFormData.startTime}
              onChange={(e) => setMenuFormData({ ...menuFormData, startTime: e.target.value })}
            />
            <Input
              label="End Time"
              type="time"
              value={menuFormData.endTime}
              onChange={(e) => setMenuFormData({ ...menuFormData, endTime: e.target.value })}
            />
          </div>
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">Available Days</label>
            <div className="grid grid-cols-4 gap-2">
              {['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'].map((day) => (
                <label key={day} className="flex items-center gap-2">
                  <input
                    type="checkbox"
                    checked={menuFormData.availableDays.includes(day)}
                    onChange={(e) => {
                      if (e.target.checked) {
                        setMenuFormData({
                          ...menuFormData,
                          availableDays: [...menuFormData.availableDays, day],
                        });
                      } else {
                        setMenuFormData({
                          ...menuFormData,
                          availableDays: menuFormData.availableDays.filter(d => d !== day),
                        });
                      }
                    }}
                    className="rounded"
                  />
                  <span className="text-sm text-gray-700">{day.slice(0, 3)}</span>
                </label>
              ))}
            </div>
          </div>
          <div className="flex items-center gap-4">
            <label className="flex items-center gap-2">
              <input
                type="checkbox"
                checked={menuFormData.isActive}
                onChange={(e) => setMenuFormData({ ...menuFormData, isActive: e.target.checked })}
                className="rounded"
              />
              <span className="text-sm text-gray-700">Active</span>
            </label>
            <label className="flex items-center gap-2">
              <input
                type="checkbox"
                checked={menuFormData.isDefault}
                onChange={(e) => setMenuFormData({ ...menuFormData, isDefault: e.target.checked })}
                className="rounded"
              />
              <span className="text-sm text-gray-700">Default Menu</span>
            </label>
          </div>
          <div className="flex gap-2 justify-end">
            <Button
              type="button"
              variant="ghost"
              onClick={() => {
                setShowMenuModal(false);
                setEditingMenu(null);
                resetMenuForm();
              }}
            >
              Cancel
            </Button>
            <Button type="submit" variant="primary">
              {editingMenu ? 'Update' : 'Create'}
            </Button>
          </div>
        </form>
      </Modal>

      {/* Category Modal */}
      <Modal
        isOpen={showCategoryModal}
        onClose={() => {
          setShowCategoryModal(false);
          setEditingCategory(null);
          resetCategoryForm();
        }}
        title={editingCategory ? 'Edit Category' : 'Add Category'}
      >
        <form onSubmit={handleSaveCategory} className="space-y-4">
          <Input
            label="Category Name"
            value={categoryFormData.name}
            onChange={(e) => setCategoryFormData({ ...categoryFormData, name: e.target.value })}
            required
          />
          <Textarea
            label="Description"
            value={categoryFormData.description}
            onChange={(e) => setCategoryFormData({ ...categoryFormData, description: e.target.value })}
            rows={2}
          />
          <Input
            label="Sort Order"
            type="number"
            value={categoryFormData.sortOrder}
            onChange={(e) => setCategoryFormData({ ...categoryFormData, sortOrder: e.target.value })}
          />
          <div className="flex gap-2 justify-end">
            <Button
              type="button"
              variant="ghost"
              onClick={() => {
                setShowCategoryModal(false);
                setEditingCategory(null);
                resetCategoryForm();
              }}
            >
              Cancel
            </Button>
            <Button type="submit" variant="primary">
              {editingCategory ? 'Update' : 'Create'}
            </Button>
          </div>
        </form>
      </Modal>

      {/* Item Modal */}
      <Modal
        isOpen={showItemModal}
        onClose={() => {
          setShowItemModal(false);
          setEditingItem(null);
          resetItemForm();
        }}
        title={editingItem ? 'Edit Menu Item' : 'Add Menu Item'}
      >
        <form onSubmit={handleSaveItem} className="space-y-4">
          <Select
            label="Category"
            value={itemFormData.categoryId}
            onChange={(e) => setItemFormData({ ...itemFormData, categoryId: e.target.value })}
            options={[
              { value: '', label: 'Select category' },
              ...categories.map(c => ({ value: c.id, label: c.name })),
            ]}
            required
          />
          <Input
            label="Item Name"
            value={itemFormData.name}
            onChange={(e) => setItemFormData({ ...itemFormData, name: e.target.value })}
            required
          />
          <Input
            label="Short Description"
            value={itemFormData.shortDescription}
            onChange={(e) => setItemFormData({ ...itemFormData, shortDescription: e.target.value })}
            placeholder="Brief description"
          />
          <Textarea
            label="Description"
            value={itemFormData.description}
            onChange={(e) => setItemFormData({ ...itemFormData, description: e.target.value })}
            rows={3}
          />
          <div className="grid grid-cols-2 gap-4">
            <Input
              label="Price"
              type="number"
              value={itemFormData.price}
              onChange={(e) => setItemFormData({ ...itemFormData, price: e.target.value })}
              required
            />
            <Select
              label="Currency"
              value={itemFormData.currency}
              onChange={(e) => setItemFormData({ ...itemFormData, currency: e.target.value })}
              options={[
                { value: 'RWF', label: 'RWF' },
                { value: 'USD', label: 'USD' },
                { value: 'EUR', label: 'EUR' },
              ]}
            />
          </div>
          <Input
            label="Calories (Optional)"
            type="number"
            value={itemFormData.calories}
            onChange={(e) => setItemFormData({ ...itemFormData, calories: e.target.value })}
          />
          <Input
            label="Allergens (comma-separated)"
            value={itemFormData.allergens}
            onChange={(e) => setItemFormData({ ...itemFormData, allergens: e.target.value })}
            placeholder="e.g., Nuts, Dairy"
          />
          <Input
            label="Sort Order"
            type="number"
            value={itemFormData.sortOrder}
            onChange={(e) => setItemFormData({ ...itemFormData, sortOrder: e.target.value })}
          />
          <div className="flex items-center gap-4">
            <label className="flex items-center gap-2">
              <input
                type="checkbox"
                checked={itemFormData.isAvailable}
                onChange={(e) => setItemFormData({ ...itemFormData, isAvailable: e.target.checked })}
                className="rounded"
              />
              <span className="text-sm text-gray-700">Available</span>
            </label>
            <label className="flex items-center gap-2">
              <input
                type="checkbox"
                checked={itemFormData.isVegetarian}
                onChange={(e) => setItemFormData({ ...itemFormData, isVegetarian: e.target.checked })}
                className="rounded"
              />
              <span className="text-sm text-gray-700">Vegetarian</span>
            </label>
            <label className="flex items-center gap-2">
              <input
                type="checkbox"
                checked={itemFormData.isVegan}
                onChange={(e) => setItemFormData({ ...itemFormData, isVegan: e.target.checked })}
                className="rounded"
              />
              <span className="text-sm text-gray-700">Vegan</span>
            </label>
            <label className="flex items-center gap-2">
              <input
                type="checkbox"
                checked={itemFormData.isGlutenFree}
                onChange={(e) => setItemFormData({ ...itemFormData, isGlutenFree: e.target.checked })}
                className="rounded"
              />
              <span className="text-sm text-gray-700">Gluten Free</span>
            </label>
          </div>
          <div className="flex gap-2 justify-end">
            <Button
              type="button"
              variant="ghost"
              onClick={() => {
                setShowItemModal(false);
                setEditingItem(null);
                resetItemForm();
              }}
            >
              Cancel
            </Button>
            <Button type="submit" variant="primary">
              {editingItem ? 'Update' : 'Create'}
            </Button>
          </div>
        </form>
      </Modal>

      {/* Delete Confirmations */}
      <ConfirmDialog
        isOpen={deletingMenuId !== null}
        onClose={() => setDeletingMenuId(null)}
        onConfirm={() => deletingMenuId && handleDeleteMenu(deletingMenuId)}
        title="Delete Menu"
        message="Are you sure you want to delete this menu? All categories and items will also be deleted."
      />
      <ConfirmDialog
        isOpen={deletingCategoryId !== null}
        onClose={() => setDeletingCategoryId(null)}
        onConfirm={() => deletingCategoryId && handleDeleteCategory(deletingCategoryId)}
        title="Delete Category"
        message="Are you sure you want to delete this category? All items in this category will also be deleted."
      />
      <ConfirmDialog
        isOpen={deletingItemId !== null}
        onClose={() => setDeletingItemId(null)}
        onConfirm={() => deletingItemId && handleDeleteItem(deletingItemId)}
        title="Delete Menu Item"
        message="Are you sure you want to delete this menu item?"
      />
    </div>
  );
}

