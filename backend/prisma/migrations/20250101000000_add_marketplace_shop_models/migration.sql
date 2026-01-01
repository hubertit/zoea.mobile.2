-- Migration: Add Marketplace/Shop Models
-- Created: 2025-01-01
-- Description: Adds marketplace/shop functionality including products, services, menus, carts, and orders

-- ============================================
-- Step 1: Create New Enums
-- ============================================

-- Product status enum
CREATE TYPE product_status AS ENUM ('draft', 'active', 'inactive', 'out_of_stock');

-- Service enums
CREATE TYPE service_price_unit AS ENUM ('fixed', 'per_hour', 'per_session', 'per_person');
CREATE TYPE service_status AS ENUM ('active', 'inactive', 'unavailable');
CREATE TYPE service_booking_status AS ENUM ('pending', 'confirmed', 'completed', 'cancelled', 'no_show');

-- Cart and Order enums
CREATE TYPE cart_item_type AS ENUM ('product', 'service', 'menu_item');
CREATE TYPE order_type AS ENUM ('product', 'service', 'menu_item', 'mixed');
CREATE TYPE fulfillment_type AS ENUM ('delivery', 'pickup', 'dine_in');
CREATE TYPE order_status AS ENUM ('pending', 'confirmed', 'processing', 'ready_for_pickup', 'shipped', 'out_for_delivery', 'delivered', 'cancelled', 'refunded');
CREATE TYPE fulfillment_status AS ENUM ('pending', 'preparing', 'ready', 'in_transit', 'completed', 'cancelled');
CREATE TYPE order_item_type AS ENUM ('product', 'service', 'menu_item');

-- ============================================
-- Step 2: Alter Existing Tables
-- ============================================

-- Add shop fields to listings table
ALTER TABLE listings 
  ADD COLUMN IF NOT EXISTS is_shop_enabled BOOLEAN DEFAULT false,
  ADD COLUMN IF NOT EXISTS shop_settings JSONB;

-- Add order_id to transactions table (if not exists)
ALTER TABLE transactions 
  ADD COLUMN IF NOT EXISTS order_id UUID;

-- Add comments for documentation
COMMENT ON COLUMN listings.is_shop_enabled IS 'Whether this listing has shop/marketplace functionality enabled';
COMMENT ON COLUMN listings.shop_settings IS 'JSON object containing shop configuration (acceptsOnlineOrders, deliveryEnabled, pickupEnabled, etc.)';
COMMENT ON COLUMN transactions.order_id IS 'Reference to order if this transaction is for an order payment';

-- ============================================
-- Step 3: Create New Tables (in dependency order)
-- ============================================

-- Menu Categories (no dependencies)
CREATE TABLE menu_categories (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name VARCHAR(100) NOT NULL,
  description TEXT,
  sort_order INTEGER DEFAULT 0
);

COMMENT ON TABLE menu_categories IS 'Categories for menu items (e.g., Appetizers, Main Courses, Desserts)';

-- Products (depends on listings)
CREATE TABLE products (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  listing_id UUID NOT NULL,
  name VARCHAR(255) NOT NULL,
  slug VARCHAR(255) UNIQUE NOT NULL,
  description TEXT,
  short_description VARCHAR(500),
  base_price DECIMAL(10, 2) NOT NULL,
  compare_at_price DECIMAL(10, 2),
  currency VARCHAR(3) DEFAULT 'RWF',
  cost_price DECIMAL(10, 2),
  sku VARCHAR(100) UNIQUE,
  track_inventory BOOLEAN DEFAULT true,
  inventory_quantity INTEGER DEFAULT 0,
  low_stock_threshold INTEGER DEFAULT 5,
  allow_backorders BOOLEAN DEFAULT false,
  weight DECIMAL(8, 2),
  dimensions JSONB,
  category VARCHAR(100),
  tags TEXT[] DEFAULT '{}',
  has_variants BOOLEAN DEFAULT false,
  variant_options JSONB,
  status product_status DEFAULT 'draft',
  is_featured BOOLEAN DEFAULT false,
  images UUID[] DEFAULT '{}',
  view_count INTEGER DEFAULT 0,
  order_count INTEGER DEFAULT 0,
  rating DECIMAL(3, 2) DEFAULT 0,
  review_count INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  deleted_at TIMESTAMPTZ,
  CONSTRAINT fk_products_listing FOREIGN KEY (listing_id) REFERENCES listings(id) ON DELETE CASCADE ON UPDATE NO ACTION
);

COMMENT ON TABLE products IS 'Physical products that can be purchased from a shop listing';

-- Product Variants (depends on products)
CREATE TABLE product_variants (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  product_id UUID NOT NULL,
  name VARCHAR(255) NOT NULL,
  sku VARCHAR(100) UNIQUE,
  price DECIMAL(10, 2),
  compare_at_price DECIMAL(10, 2),
  attributes JSONB NOT NULL,
  inventory_quantity INTEGER DEFAULT 0,
  track_inventory BOOLEAN DEFAULT true,
  image_id UUID,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  CONSTRAINT fk_product_variants_product FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE ON UPDATE NO ACTION
);

COMMENT ON TABLE product_variants IS 'Variants of products (e.g., Size: M, Color: Red)';

-- Services (depends on listings)
CREATE TABLE services (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  listing_id UUID NOT NULL,
  name VARCHAR(255) NOT NULL,
  slug VARCHAR(255) UNIQUE NOT NULL,
  description TEXT,
  short_description VARCHAR(500),
  base_price DECIMAL(10, 2) NOT NULL,
  currency VARCHAR(3) DEFAULT 'RWF',
  price_unit service_price_unit DEFAULT 'fixed',
  duration_minutes INTEGER,
  requires_booking BOOLEAN DEFAULT true,
  advance_booking_days INTEGER DEFAULT 7,
  max_concurrent_bookings INTEGER DEFAULT 1,
  availability_schedule JSONB,
  is_available BOOLEAN DEFAULT true,
  category VARCHAR(100),
  tags TEXT[] DEFAULT '{}',
  images UUID[] DEFAULT '{}',
  status service_status DEFAULT 'active',
  is_featured BOOLEAN DEFAULT false,
  view_count INTEGER DEFAULT 0,
  booking_count INTEGER DEFAULT 0,
  rating DECIMAL(3, 2) DEFAULT 0,
  review_count INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  deleted_at TIMESTAMPTZ,
  CONSTRAINT fk_services_listing FOREIGN KEY (listing_id) REFERENCES listings(id) ON DELETE CASCADE ON UPDATE NO ACTION
);

COMMENT ON TABLE services IS 'Bookable services (e.g., Haircut, Massage, Consultation)';

-- Menus (depends on listings)
CREATE TABLE menus (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  listing_id UUID NOT NULL,
  name VARCHAR(255) NOT NULL,
  description TEXT,
  available_days TEXT[] DEFAULT '{}',
  start_time VARCHAR(10),
  end_time VARCHAR(10),
  is_active BOOLEAN DEFAULT true,
  is_default BOOLEAN DEFAULT false,
  sort_order INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  deleted_at TIMESTAMPTZ,
  CONSTRAINT fk_menus_listing FOREIGN KEY (listing_id) REFERENCES listings(id) ON DELETE CASCADE ON UPDATE NO ACTION
);

COMMENT ON TABLE menus IS 'Restaurant menus with items';

-- Menu Items (depends on menus and menu_categories)
CREATE TABLE menu_items (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  menu_id UUID NOT NULL,
  category_id UUID,
  name VARCHAR(255) NOT NULL,
  description TEXT,
  price DECIMAL(10, 2) NOT NULL,
  currency VARCHAR(3) DEFAULT 'RWF',
  compare_at_price DECIMAL(10, 2),
  dietary_tags TEXT[] DEFAULT '{}',
  allergens TEXT[] DEFAULT '{}',
  spice_level VARCHAR(20),
  is_available BOOLEAN DEFAULT true,
  is_popular BOOLEAN DEFAULT false,
  is_chef_special BOOLEAN DEFAULT false,
  allow_customization BOOLEAN DEFAULT false,
  customization_options JSONB,
  image_id UUID,
  estimated_prep_time INTEGER,
  sort_order INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  CONSTRAINT fk_menu_items_menu FOREIGN KEY (menu_id) REFERENCES menus(id) ON DELETE CASCADE ON UPDATE NO ACTION,
  CONSTRAINT fk_menu_items_category FOREIGN KEY (category_id) REFERENCES menu_categories(id) ON DELETE NO ACTION ON UPDATE NO ACTION
);

COMMENT ON TABLE menu_items IS 'Individual items on a restaurant menu';

-- Shopping Carts (depends on users)
CREATE TABLE carts (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID UNIQUE,
  session_id VARCHAR(255),
  expires_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  CONSTRAINT fk_carts_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE ON UPDATE NO ACTION
);

COMMENT ON TABLE carts IS 'Shopping carts for users (supports both authenticated and guest users via session_id)';

-- Cart Items (depends on carts, products, product_variants, services, menu_items)
CREATE TABLE cart_items (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  cart_id UUID NOT NULL,
  item_type cart_item_type NOT NULL,
  product_id UUID,
  product_variant_id UUID,
  service_id UUID,
  menu_item_id UUID,
  quantity INTEGER DEFAULT 1 NOT NULL,
  unit_price DECIMAL(10, 2) NOT NULL,
  total_price DECIMAL(10, 2) NOT NULL,
  currency VARCHAR(3) DEFAULT 'RWF',
  customization JSONB,
  service_booking_date TIMESTAMPTZ,
  service_booking_time VARCHAR(10),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  CONSTRAINT fk_cart_items_cart FOREIGN KEY (cart_id) REFERENCES carts(id) ON DELETE CASCADE ON UPDATE NO ACTION,
  CONSTRAINT fk_cart_items_product FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT fk_cart_items_product_variant FOREIGN KEY (product_variant_id) REFERENCES product_variants(id) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT fk_cart_items_service FOREIGN KEY (service_id) REFERENCES services(id) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT fk_cart_items_menu_item FOREIGN KEY (menu_item_id) REFERENCES menu_items(id) ON DELETE NO ACTION ON UPDATE NO ACTION
);

COMMENT ON TABLE cart_items IS 'Items in shopping carts (polymorphic: can be product, service, or menu_item)';

-- Orders (depends on users, listings, merchant_profiles)
CREATE TABLE orders (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  order_number VARCHAR(50) UNIQUE NOT NULL,
  user_id UUID,
  listing_id UUID NOT NULL,
  merchant_id UUID,
  order_type order_type NOT NULL,
  subtotal DECIMAL(12, 2) NOT NULL,
  tax_amount DECIMAL(10, 2) DEFAULT 0,
  shipping_amount DECIMAL(10, 2) DEFAULT 0,
  discount_amount DECIMAL(10, 2) DEFAULT 0,
  total_amount DECIMAL(12, 2) NOT NULL,
  currency VARCHAR(3) DEFAULT 'RWF',
  fulfillment_type fulfillment_type NOT NULL,
  delivery_address JSONB,
  pickup_location VARCHAR(255),
  delivery_date DATE,
  delivery_time_slot VARCHAR(50),
  customer_name VARCHAR(255) NOT NULL,
  customer_email VARCHAR(255),
  customer_phone VARCHAR(20) NOT NULL,
  status order_status DEFAULT 'pending',
  fulfillment_status fulfillment_status DEFAULT 'pending',
  payment_status payment_status DEFAULT 'pending',
  payment_method payment_method,
  payment_reference VARCHAR(255),
  paid_at TIMESTAMPTZ,
  customer_notes TEXT,
  internal_notes TEXT,
  confirmed_at TIMESTAMPTZ,
  shipped_at TIMESTAMPTZ,
  delivered_at TIMESTAMPTZ,
  cancelled_at TIMESTAMPTZ,
  cancelled_by UUID,
  cancellation_reason TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  CONSTRAINT fk_orders_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT fk_orders_listing FOREIGN KEY (listing_id) REFERENCES listings(id) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT fk_orders_merchant FOREIGN KEY (merchant_id) REFERENCES merchant_profiles(id) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT fk_orders_cancelled_by FOREIGN KEY (cancelled_by) REFERENCES users(id) ON DELETE NO ACTION ON UPDATE NO ACTION
);

COMMENT ON TABLE orders IS 'E-commerce orders from marketplace/shop listings';

-- Order Items (depends on orders, products, product_variants, services, menu_items)
CREATE TABLE order_items (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  order_id UUID NOT NULL,
  item_type order_item_type NOT NULL,
  product_id UUID,
  product_variant_id UUID,
  service_id UUID,
  menu_item_id UUID,
  item_name VARCHAR(255) NOT NULL,
  item_sku VARCHAR(100),
  item_image_id UUID,
  quantity INTEGER DEFAULT 1 NOT NULL,
  unit_price DECIMAL(10, 2) NOT NULL,
  total_price DECIMAL(10, 2) NOT NULL,
  currency VARCHAR(3) DEFAULT 'RWF',
  customization JSONB,
  service_booking_date TIMESTAMPTZ,
  service_booking_time VARCHAR(10),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  CONSTRAINT fk_order_items_order FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE ON UPDATE NO ACTION,
  CONSTRAINT fk_order_items_product FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT fk_order_items_product_variant FOREIGN KEY (product_variant_id) REFERENCES product_variants(id) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT fk_order_items_service FOREIGN KEY (service_id) REFERENCES services(id) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT fk_order_items_menu_item FOREIGN KEY (menu_item_id) REFERENCES menu_items(id) ON DELETE NO ACTION ON UPDATE NO ACTION
);

COMMENT ON TABLE order_items IS 'Items within orders (polymorphic: can be product, service, or menu_item)';

-- Service Bookings (depends on users, services, listings, orders, order_items)
CREATE TABLE service_bookings (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID,
  service_id UUID NOT NULL,
  listing_id UUID,
  order_id UUID,
  order_item_id UUID UNIQUE,
  booking_date DATE NOT NULL,
  booking_time VARCHAR(10) NOT NULL,
  duration_minutes INTEGER,
  customer_name VARCHAR(255) NOT NULL,
  customer_email VARCHAR(255),
  customer_phone VARCHAR(20) NOT NULL,
  status service_booking_status DEFAULT 'pending',
  special_requests TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  CONSTRAINT fk_service_bookings_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT fk_service_bookings_service FOREIGN KEY (service_id) REFERENCES services(id) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT fk_service_bookings_listing FOREIGN KEY (listing_id) REFERENCES listings(id) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT fk_service_bookings_order FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT fk_service_bookings_order_item FOREIGN KEY (order_item_id) REFERENCES order_items(id) ON DELETE NO ACTION ON UPDATE NO ACTION
);

COMMENT ON TABLE service_bookings IS 'Bookings for services (can be standalone or part of an order)';

-- ============================================
-- Step 4: Create Indexes
-- ============================================

-- Products indexes
CREATE INDEX idx_products_listing ON products(listing_id);
CREATE INDEX idx_products_status ON products(status);
CREATE INDEX idx_products_slug ON products(slug);

-- Product Variants indexes
CREATE INDEX idx_product_variants_product ON product_variants(product_id);

-- Services indexes
CREATE INDEX idx_services_listing ON services(listing_id);
CREATE INDEX idx_services_status ON services(status);

-- Menus indexes
CREATE INDEX idx_menus_listing ON menus(listing_id);

-- Menu Items indexes
CREATE INDEX idx_menu_items_menu ON menu_items(menu_id);
CREATE INDEX idx_menu_items_category ON menu_items(category_id);

-- Carts indexes
CREATE INDEX idx_carts_session ON carts(session_id);

-- Cart Items indexes
CREATE INDEX idx_cart_items_cart ON cart_items(cart_id);

-- Orders indexes
CREATE INDEX idx_orders_user ON orders(user_id);
CREATE INDEX idx_orders_listing ON orders(listing_id);
CREATE INDEX idx_orders_merchant ON orders(merchant_id);
CREATE INDEX idx_orders_status ON orders(status);
CREATE INDEX idx_orders_number ON orders(order_number);

-- Order Items indexes
CREATE INDEX idx_order_items_order ON order_items(order_id);

-- Service Bookings indexes
CREATE INDEX idx_service_bookings_order ON service_bookings(order_id);
CREATE INDEX idx_service_bookings_service ON service_bookings(service_id);
CREATE INDEX idx_service_bookings_user ON service_bookings(user_id);
CREATE INDEX idx_service_bookings_date ON service_bookings(booking_date);

-- Transactions order_id index (if column was added)
CREATE INDEX IF NOT EXISTS idx_transactions_order ON transactions(order_id);

-- ============================================
-- Step 5: Add Foreign Key Constraint for Transaction.order_id
-- ============================================

-- Add foreign key constraint for transactions.order_id (if column exists)
DO $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'transactions' AND column_name = 'order_id'
  ) THEN
    -- Check if constraint doesn't already exist
    IF NOT EXISTS (
      SELECT 1 FROM information_schema.table_constraints 
      WHERE constraint_name = 'fk_transactions_order'
    ) THEN
      ALTER TABLE transactions 
        ADD CONSTRAINT fk_transactions_order 
        FOREIGN KEY (order_id) REFERENCES orders(id) 
        ON DELETE NO ACTION ON UPDATE NO ACTION;
    END IF;
  END IF;
END $$;

-- ============================================
-- Step 6: Add Triggers for Updated At (if needed)
-- ============================================

-- Create function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Add triggers for updated_at on new tables
CREATE TRIGGER update_products_updated_at BEFORE UPDATE ON products
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_product_variants_updated_at BEFORE UPDATE ON product_variants
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_services_updated_at BEFORE UPDATE ON services
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_menus_updated_at BEFORE UPDATE ON menus
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_menu_items_updated_at BEFORE UPDATE ON menu_items
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_carts_updated_at BEFORE UPDATE ON carts
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_cart_items_updated_at BEFORE UPDATE ON cart_items
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_orders_updated_at BEFORE UPDATE ON orders
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_service_bookings_updated_at BEFORE UPDATE ON service_bookings
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- ============================================
-- Migration Complete
-- ============================================

