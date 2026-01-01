# Marketplace/Shop & Enhanced Tours - Brainstorming Document

## Executive Summary

This document outlines the architecture and design for:
1. **Marketplace/Shop Feature**: Transforming listings into shops that can sell products, services, and menus
2. **Enhanced Tour Packages**: Redesigning tour bookings with advanced features similar to dining bookings

---

## Current Architecture Analysis

### ✅ What We Have

**Core Structure:**
- `User` → `MerchantProfile` (Business) → `Listing`
- One user can have multiple businesses
- One business can have multiple listings
- Listings support multiple types: `hotel`, `restaurant`, `tour`, `event`, `attraction`, `bar`, `club`, `lounge`, `cafe`, `fast_food`, `mall`, `market`, `boutique`

**Booking System:**
- Comprehensive booking system with support for:
  - Hotels (check-in/check-out, rooms, guests)
  - Restaurants (date, time, party size, tables, guests)
  - Tours (basic support exists)
  - Events (tickets, attendees)
- `BookingGuest` model for guest information
- Payment integration ready

**Tours:**
- `Tour` model exists with:
  - Basic info (name, description, slug)
  - Duration (hours/days)
  - Location (start/end locations)
  - Pricing (per person, group discounts)
  - Schedules (`TourSchedule` with dates, times, available spots)
  - Images, operators
- Basic booking support via `Booking.tourId`

### ❌ What's Missing

**Marketplace/Shop:**
- No `Product` model
- No `Service` model
- No `Menu` model (for restaurants)
- No `Order` model (e-commerce orders)
- No `Cart`/`CartItem` model
- No inventory management
- No product variants (sizes, colors, etc.)

**Enhanced Tours:**
- No advanced guest management for tours
- No pickup/dropoff location selection
- No dietary preferences for tour meals
- No equipment rental options
- No add-on services (insurance, photography, etc.)
- Limited schedule flexibility

---

## Proposed Architecture

### 1. Marketplace/Shop System

#### 1.1 Core Concept

**A Listing can become a Shop** when:
- The listing type supports it (e.g., `restaurant`, `boutique`, `market`, `mall`, `cafe`, `fast_food`)
- The merchant enables "Shop Mode" on their listing
- The listing can then:
  - List products (physical items)
  - List services (bookable services)
  - Post menus (restaurant menus with items)
  - Accept online orders

#### 1.2 Database Schema Design

```prisma
// Enable shop functionality on listings
model Listing {
  // ... existing fields ...
  isShopEnabled Boolean? @default(false) @map("is_shop_enabled")
  shopSettings Json? @map("shop_settings") // { acceptsOnlineOrders, deliveryEnabled, pickupEnabled, etc. }
}

// Products - Physical items that can be purchased
model Product {
  id String @id @default(uuid())
  listingId String @map("listing_id") @db.Uuid
  name String @db.VarChar(255)
  slug String @unique @db.VarChar(255)
  description String?
  shortDescription String? @map("short_description") @db.VarChar(500)
  
  // Pricing
  basePrice Decimal @map("base_price") @db.Decimal(10, 2)
  compareAtPrice Decimal? @map("compare_at_price") @db.Decimal(10, 2) // For showing discounts
  currency String? @default("RWF") @db.VarChar(3)
  costPrice Decimal? @map("cost_price") @db.Decimal(10, 2) // For merchant profit calculation
  
  // Inventory
  sku String? @unique @db.VarChar(100)
  trackInventory Boolean? @default(true) @map("track_inventory")
  inventoryQuantity Int? @default(0) @map("inventory_quantity")
  lowStockThreshold Int? @default(5) @map("low_stock_threshold")
  allowBackorders Boolean? @default(false) @map("allow_backorders")
  
  // Product Details
  weight Decimal? @db.Decimal(8, 2) // For shipping calculations
  dimensions Json? // { length, width, height, unit }
  category String? @db.VarChar(100) // e.g., "apparel", "electronics", "food"
  tags String[]
  
  // Variants (sizes, colors, etc.)
  hasVariants Boolean? @default(false) @map("has_variants")
  variantOptions Json? @map("variant_options") // { size: ["S", "M", "L"], color: ["Red", "Blue"] }
  
  // Status
  status product_status? @default(draft) // draft, active, inactive, out_of_stock
  isFeatured Boolean? @default(false) @map("is_featured")
  
  // Media
  images String[] @db.Uuid // Array of media IDs
  
  // Stats
  viewCount Int? @default(0) @map("view_count")
  orderCount Int? @default(0) @map("order_count")
  rating Decimal? @default(0) @db.Decimal(3, 2)
  reviewCount Int? @default(0) @map("review_count")
  
  createdAt DateTime? @default(now()) @map("created_at")
  updatedAt DateTime? @updatedAt @map("updated_at")
  deletedAt DateTime? @map("deleted_at")
  
  listing Listing @relation(fields: [listingId], references: [id], onDelete: Cascade)
  variants ProductVariant[]
  orderItems OrderItem[]
  reviews ProductReview[]
  
  @@index([listingId])
  @@index([status])
  @@index([slug])
  @@map("products")
}

enum product_status {
  draft
  active
  inactive
  out_of_stock
}

// Product Variants (e.g., Size: M, Color: Red)
model ProductVariant {
  id String @id @default(uuid())
  productId String @map("product_id") @db.Uuid
  name String @db.VarChar(255) // e.g., "M - Red"
  sku String? @unique @db.VarChar(100)
  
  // Variant-specific pricing
  price Decimal? @db.Decimal(10, 2) // Overrides product basePrice if set
  compareAtPrice Decimal? @map("compare_at_price") @db.Decimal(10, 2)
  
  // Variant attributes
  attributes Json // { size: "M", color: "Red" }
  
  // Inventory
  inventoryQuantity Int? @default(0) @map("inventory_quantity")
  trackInventory Boolean? @default(true) @map("track_inventory")
  
  // Media
  imageId String? @map("image_id") @db.Uuid // Variant-specific image
  
  isActive Boolean? @default(true) @map("is_active")
  createdAt DateTime? @default(now()) @map("created_at")
  updatedAt DateTime? @updatedAt @map("updated_at")
  
  product Product @relation(fields: [productId], references: [id], onDelete: Cascade)
  orderItems OrderItem[]
  
  @@index([productId])
  @@map("product_variants")
}

// Services - Bookable services (e.g., "Haircut", "Massage", "Consultation")
model Service {
  id String @id @default(uuid())
  listingId String @map("listing_id") @db.Uuid
  
  name String @db.VarChar(255)
  slug String @unique @db.VarChar(255)
  description String?
  shortDescription String? @map("short_description") @db.VarChar(500)
  
  // Pricing
  basePrice Decimal @map("base_price") @db.Decimal(10, 2)
  currency String? @default("RWF") @db.VarChar(3)
  priceUnit service_price_unit? @default(fixed) @map("price_unit") // fixed, per_hour, per_session
  
  // Duration
  durationMinutes Int? @map("duration_minutes") // e.g., 60 for 1 hour service
  
  // Booking
  requiresBooking Boolean? @default(true) @map("requires_booking")
  advanceBookingDays Int? @default(7) @map("advance_booking_days") // How many days in advance
  maxConcurrentBookings Int? @default(1) @map("max_concurrent_bookings")
  
  // Availability
  availabilitySchedule Json? @map("availability_schedule") // Weekly schedule
  isAvailable Boolean? @default(true) @map("is_available")
  
  // Category
  category String? @db.VarChar(100) // e.g., "beauty", "wellness", "consultation"
  tags String[]
  
  // Media
  images String[] @db.Uuid
  
  // Status
  status service_status? @default(active)
  isFeatured Boolean? @default(false) @map("is_featured")
  
  // Stats
  viewCount Int? @default(0) @map("view_count")
  bookingCount Int? @default(0) @map("booking_count")
  rating Decimal? @default(0) @db.Decimal(3, 2)
  reviewCount Int? @default(0) @map("review_count")
  
  createdAt DateTime? @default(now()) @map("created_at")
  updatedAt DateTime? @updatedAt @map("updated_at")
  deletedAt DateTime? @map("deleted_at")
  
  listing Listing @relation(fields: [listingId], references: [id], onDelete: Cascade)
  serviceBookings ServiceBooking[]
  reviews ServiceReview[]
  
  @@index([listingId])
  @@index([status])
  @@map("services")
}

enum service_price_unit {
  fixed
  per_hour
  per_session
  per_person
}

enum service_status {
  active
  inactive
  unavailable
}

// Menus - Restaurant menus with items
model Menu {
  id String @id @default(uuid())
  listingId String @map("listing_id") @db.Uuid // Restaurant listing
  
  name String @db.VarChar(255) // e.g., "Lunch Menu", "Dinner Menu", "Brunch Menu"
  description String?
  
  // Availability
  availableDays String[] @map("available_days") // ["monday", "tuesday", ...]
  startTime String? @map("start_time") @db.VarChar(10) // "09:00"
  endTime String? @map("end_time") @db.VarChar(10) // "17:00"
  
  // Status
  isActive Boolean? @default(true) @map("is_active")
  isDefault Boolean? @default(false) @map("is_default") // Default menu for the restaurant
  
  sortOrder Int? @default(0) @map("sort_order")
  
  createdAt DateTime? @default(now()) @map("created_at")
  updatedAt DateTime? @updatedAt @map("updated_at")
  deletedAt DateTime? @map("deleted_at")
  
  listing Listing @relation(fields: [listingId], references: [id], onDelete: Cascade)
  items MenuItem[]
  
  @@index([listingId])
  @@map("menus")
}

// Menu Items - Individual items on a menu
model MenuItem {
  id String @id @default(uuid())
  menuId String @map("menu_id") @db.Uuid
  categoryId String? @map("category_id") @db.Uuid // Menu category (e.g., "Appetizers", "Main Courses")
  
  name String @db.VarChar(255)
  description String?
  
  // Pricing
  price Decimal @db.Decimal(10, 2)
  currency String? @default("RWF") @db.VarChar(3)
  compareAtPrice Decimal? @map("compare_at_price") @db.Decimal(10, 2)
  
  // Dietary Info
  dietaryTags String[] @map("dietary_tags") // ["vegetarian", "vegan", "gluten-free", "halal"]
  allergens String[] // ["nuts", "dairy", "eggs"]
  spiceLevel String? @map("spice_level") @db.VarChar(20) // "mild", "medium", "hot"
  
  // Availability
  isAvailable Boolean? @default(true) @map("is_available")
  isPopular Boolean? @default(false) @map("is_popular")
  isChefSpecial Boolean? @default(false) @map("is_chef_special")
  
  // Customization
  allowCustomization Boolean? @default(false) @map("allow_customization")
  customizationOptions Json? @map("customization_options") // { "add_ons": [...], "sides": [...] }
  
  // Media
  imageId String? @map("image_id") @db.Uuid
  
  // Preparation
  estimatedPrepTime Int? @map("estimated_prep_time") // Minutes
  
  sortOrder Int? @default(0) @map("sort_order")
  
  createdAt DateTime? @default(now()) @map("created_at")
  updatedAt DateTime? @updatedAt @map("updated_at")
  
  menu Menu @relation(fields: [menuId], references: [id], onDelete: Cascade)
  category MenuCategory? @relation(fields: [categoryId], references: [id])
  orderItems OrderItem[]
  
  @@index([menuId])
  @@index([categoryId])
  @@map("menu_items")
}

// Menu Categories (e.g., "Appetizers", "Main Courses", "Desserts")
model MenuCategory {
  id String @id @default(uuid())
  name String @db.VarChar(100)
  description String?
  sortOrder Int? @default(0) @map("sort_order")
  items MenuItem[]
  
  @@map("menu_categories")
}

// Shopping Cart
model Cart {
  id String @id @default(uuid())
  userId String @map("user_id") @db.Uuid
  
  // Session cart (for guest users)
  sessionId String? @map("session_id") @db.VarChar(255)
  
  expiresAt DateTime? @map("expires_at") // Auto-cleanup old carts
  
  createdAt DateTime? @default(now()) @map("created_at")
  updatedAt DateTime? @updatedAt @map("updated_at")
  
  user User? @relation(fields: [userId], references: [id], onDelete: Cascade)
  items CartItem[]
  
  @@unique([userId])
  @@index([sessionId])
  @@map("carts")
}

// Cart Items
model CartItem {
  id String @id @default(uuid())
  cartId String @map("cart_id") @db.Uuid
  
  // Polymorphic: can be product, service, or menu item
  itemType cart_item_type @map("item_type")
  productId String? @map("product_id") @db.Uuid
  productVariantId String? @map("product_variant_id") @db.Uuid
  serviceId String? @map("service_id") @db.Uuid
  menuItemId String? @map("menu_item_id") @db.Uuid
  
  quantity Int @default(1)
  
  // Snapshot pricing (at time of adding to cart)
  unitPrice Decimal @map("unit_price") @db.Decimal(10, 2)
  totalPrice Decimal @map("total_price") @db.Decimal(10, 2)
  currency String? @default("RWF") @db.VarChar(3)
  
  // Customization (for menu items)
  customization Json? // Selected options
  
  // Service booking details (if service)
  serviceBookingDate DateTime? @map("service_booking_date")
  serviceBookingTime String? @map("service_booking_time")
  
  createdAt DateTime? @default(now()) @map("created_at")
  updatedAt DateTime? @updatedAt @map("updated_at")
  
  cart Cart @relation(fields: [cartId], references: [id], onDelete: Cascade)
  product Product? @relation(fields: [productId], references: [id])
  productVariant ProductVariant? @relation(fields: [productVariantId], references: [id])
  service Service? @relation(fields: [serviceId], references: [id])
  menuItem MenuItem? @relation(fields: [menuItemId], references: [id])
  
  @@index([cartId])
  @@map("cart_items")
}

enum cart_item_type {
  product
  service
  menu_item
}

// Orders - E-commerce orders
model Order {
  id String @id @default(uuid())
  orderNumber String @unique @map("order_number") @db.VarChar(50) // e.g., "ORD-2024-001234"
  
  userId String? @map("user_id") @db.Uuid
  listingId String @map("listing_id") @db.Uuid // Shop/merchant
  merchantId String? @map("merchant_id") @db.Uuid
  
  // Order Type
  orderType order_type @map("order_type") // product, service, menu_item, mixed
  
  // Pricing
  subtotal Decimal @db.Decimal(12, 2)
  taxAmount Decimal? @default(0) @map("tax_amount") @db.Decimal(10, 2)
  shippingAmount Decimal? @default(0) @map("shipping_amount") @db.Decimal(10, 2)
  discountAmount Decimal? @default(0) @map("discount_amount") @db.Decimal(10, 2)
  totalAmount Decimal @map("total_amount") @db.Decimal(12, 2)
  currency String? @default("RWF") @db.VarChar(3)
  
  // Delivery/Pickup
  fulfillmentType fulfillment_type @map("fulfillment_type") // delivery, pickup, dine_in
  deliveryAddress Json? @map("delivery_address")
  pickupLocation String? @map("pickup_location")
  deliveryDate DateTime? @map("delivery_date")
  deliveryTimeSlot String? @map("delivery_time_slot")
  
  // Customer Info
  customerName String @map("customer_name") @db.VarChar(255)
  customerEmail String? @map("customer_email") @db.VarChar(255)
  customerPhone String @map("customer_phone") @db.VarChar(20)
  
  // Status
  status order_status @default(pending)
  fulfillmentStatus fulfillment_status? @default(pending) @map("fulfillment_status")
  
  // Payment
  paymentStatus payment_status? @default(pending) @map("payment_status")
  paymentMethod payment_method? @map("payment_method")
  paymentReference String? @map("payment_reference") @db.VarChar(255)
  paidAt DateTime? @map("paid_at")
  
  // Notes
  customerNotes String? @map("customer_notes")
  internalNotes String? @map("internal_notes")
  
  // Timestamps
  confirmedAt DateTime? @map("confirmed_at")
  shippedAt DateTime? @map("shipped_at")
  deliveredAt DateTime? @map("delivered_at")
  cancelledAt DateTime? @map("cancelled_at")
  cancelledBy String? @map("cancelled_by") @db.Uuid
  cancellationReason String? @map("cancellation_reason")
  
  createdAt DateTime? @default(now()) @map("created_at")
  updatedAt DateTime? @updatedAt @map("updated_at")
  
  user User? @relation(fields: [userId], references: [id])
  listing Listing @relation(fields: [listingId], references: [id])
  merchant MerchantProfile? @relation(fields: [merchantId], references: [id])
  items OrderItem[]
  transactions Transaction[]
  
  @@index([userId])
  @@index([listingId])
  @@index([merchantId])
  @@index([status])
  @@index([orderNumber])
  @@map("orders")
}

enum order_type {
  product
  service
  menu_item
  mixed
}

enum fulfillment_type {
  delivery
  pickup
  dine_in
}

enum order_status {
  pending
  confirmed
  processing
  ready_for_pickup
  shipped
  out_for_delivery
  delivered
  cancelled
  refunded
}

enum fulfillment_status {
  pending
  preparing
  ready
  in_transit
  completed
  cancelled
}

// Order Items
model OrderItem {
  id String @id @default(uuid())
  orderId String @map("order_id") @db.Uuid
  
  // Polymorphic item reference
  itemType order_item_type @map("item_type")
  productId String? @map("product_id") @db.Uuid
  productVariantId String? @map("product_variant_id") @db.Uuid
  serviceId String? @map("service_id") @db.Uuid
  menuItemId String? @map("menu_item_id") @db.Uuid
  
  // Item details (snapshot at time of order)
  itemName String @map("item_name") @db.VarChar(255)
  itemSku String? @map("item_sku") @db.VarChar(100)
  itemImageId String? @map("item_image_id") @db.Uuid
  
  quantity Int @default(1)
  
  // Pricing (snapshot)
  unitPrice Decimal @map("unit_price") @db.Decimal(10, 2)
  totalPrice Decimal @map("total_price") @db.Decimal(10, 2)
  currency String? @default("RWF") @db.VarChar(3)
  
  // Customization (for menu items)
  customization Json?
  
  // Service booking (if service)
  serviceBookingDate DateTime? @map("service_booking_date")
  serviceBookingTime String? @map("service_booking_time")
  serviceBookingId String? @map("service_booking_id") @db.Uuid
  
  createdAt DateTime? @default(now()) @map("created_at")
  
  order Order @relation(fields: [orderId], references: [id], onDelete: Cascade)
  product Product? @relation(fields: [productId], references: [id])
  productVariant ProductVariant? @relation(fields: [productVariantId], references: [id])
  service Service? @relation(fields: [serviceId], references: [id])
  menuItem MenuItem? @relation(fields: [menuItemId], references: [id])
  serviceBooking ServiceBooking? @relation(fields: [serviceBookingId], references: [id])
  
  @@index([orderId])
  @@map("order_items")
}

enum order_item_type {
  product
  service
  menu_item
}

// Service Bookings (for bookable services)
model ServiceBooking {
  id String @id @default(uuid())
  userId String? @map("user_id") @db.Uuid
  serviceId String @map("service_id") @db.Uuid
  listingId String? @map("listing_id") @db.Uuid
  orderId String? @map("order_id") @db.Uuid
  orderItemId String? @map("order_item_id") @db.Uuid
  
  bookingDate DateTime @map("booking_date")
  bookingTime String @map("booking_time") // "14:00"
  durationMinutes Int? @map("duration_minutes")
  
  // Customer info
  customerName String @map("customer_name") @db.VarChar(255)
  customerEmail String? @map("customer_email") @db.VarChar(255)
  customerPhone String @map("customer_phone") @db.VarChar(20)
  
  // Status
  status service_booking_status @default(pending)
  
  // Notes
  specialRequests String? @map("special_requests")
  
  createdAt DateTime? @default(now()) @map("created_at")
  updatedAt DateTime? @updatedAt @map("updated_at")
  
  user User? @relation(fields: [userId], references: [id])
  service Service @relation(fields: [serviceId], references: [id])
  listing Listing? @relation(fields: [listingId], references: [id])
  order Order? @relation(fields: [orderId], references: [id])
  orderItem OrderItem? @relation(fields: [orderItemId], references: [id])
  
  @@index([serviceId])
  @@index([userId])
  @@index([bookingDate])
  @@map("service_bookings")
}

enum service_booking_status {
  pending
  confirmed
  completed
  cancelled
  no_show
}
```

#### 1.3 API Endpoints

**Products:**
- `GET /api/listings/:id/products` - List products for a shop
- `GET /api/products/:id` - Get product details
- `POST /api/products` - Create product (merchant)
- `PUT /api/products/:id` - Update product (merchant)
- `DELETE /api/products/:id` - Delete product (merchant)

**Services:**
- `GET /api/listings/:id/services` - List services
- `GET /api/services/:id` - Get service details
- `POST /api/services` - Create service (merchant)
- `POST /api/services/:id/book` - Book a service

**Menus:**
- `GET /api/listings/:id/menus` - Get restaurant menus
- `GET /api/menus/:id` - Get menu with items
- `POST /api/menus` - Create menu (merchant)
- `POST /api/menus/:id/items` - Add menu item

**Cart:**
- `GET /api/cart` - Get user's cart
- `POST /api/cart/items` - Add item to cart
- `PUT /api/cart/items/:id` - Update cart item
- `DELETE /api/cart/items/:id` - Remove cart item
- `DELETE /api/cart` - Clear cart

**Orders:**
- `POST /api/orders` - Create order from cart
- `GET /api/orders` - List user's orders
- `GET /api/orders/:id` - Get order details
- `PUT /api/orders/:id/cancel` - Cancel order
- `GET /api/merchant/orders` - Merchant's orders
- `PUT /api/merchant/orders/:id/status` - Update order status

---

### 2. Enhanced Tour Packages

#### 2.1 Enhanced Tour Booking Flow

**Current Tour Booking:**
- Basic: tour selection, date, number of participants
- Limited guest information

**Enhanced Tour Booking (Similar to Dining):**
- Tour selection
- Schedule selection (date & time)
- Guest count (adults, children, infants)
- Guest details (names, ages, dietary preferences, special needs)
- Pickup/dropoff location selection
- Add-on services (insurance, equipment rental, photography)
- Payment & confirmation

#### 2.2 Database Schema Enhancements

```prisma
// Enhance existing Tour model
model Tour {
  // ... existing fields ...
  
  // Enhanced booking fields
  requiresGuestDetails Boolean? @default(true) @map("requires_guest_details")
  requiresPickupLocation Boolean? @default(false) @map("requires_pickup_location")
  allowsAddOns Boolean? @default(false) @map("allows_add_ons")
  
  // Pickup/Dropoff
  pickupLocations Json? @map("pickup_locations") // Array of available pickup points
  defaultPickupLocation String? @map("default_pickup_location")
  
  // Add-ons
  availableAddOns Json? @map("available_add_ons") // { insurance: {...}, equipment: {...} }
}

// Tour Booking Guests (enhanced)
model TourBookingGuest {
  id String @id @default(uuid())
  bookingId String @map("booking_id") @db.Uuid
  
  // Basic Info
  fullName String @map("full_name") @db.VarChar(255)
  email String? @db.VarChar(255)
  phone String? @db.VarChar(20)
  isPrimary Boolean? @default(false) @map("is_primary")
  
  // Age & Type
  age Int?
  guestType guest_type @map("guest_type") // adult, child, infant
  
  // Dietary & Special Needs
  dietaryPreferences String[] @map("dietary_preferences") // ["vegetarian", "vegan", "halal"]
  dietaryRestrictions String[] @map("dietary_restrictions") // ["no_nuts", "no_dairy"]
  specialNeeds String[] @map("special_needs") // ["wheelchair", "hearing_aid"]
  medicalConditions String? @map("medical_conditions")
  
  // Emergency Contact
  emergencyContactName String? @map("emergency_contact_name") @db.VarChar(255)
  emergencyContactPhone String? @map("emergency_contact_phone") @db.VarChar(20)
  
  // Identification (for some tours)
  idType String? @map("id_type") @db.VarChar(50) // "passport", "id_card"
  idNumber String? @map("id_number") @db.VarChar(100)
  nationality String? @db.VarChar(100)
  
  createdAt DateTime? @default(now()) @map("created_at")
  
  booking Booking @relation(fields: [bookingId], references: [id], onDelete: Cascade)
  
  @@index([bookingId])
  @@map("tour_booking_guests")
}

enum guest_type {
  adult
  child
  infant
}

// Tour Add-ons
model TourAddOn {
  id String @id @default(uuid())
  tourId String @map("tour_id") @db.Uuid
  
  name String @db.VarChar(255)
  description String?
  
  // Pricing
  price Decimal @db.Decimal(10, 2)
  currency String? @default("RWF") @db.VarChar(3)
  priceType add_on_price_type @map("price_type") // per_person, per_booking, per_group
  
  // Type
  addOnType add_on_type @map("add_on_type") // insurance, equipment, photography, meal_upgrade
  
  // Availability
  isRequired Boolean? @default(false) @map("is_required")
  isActive Boolean? @default(true) @map("is_active")
  
  createdAt DateTime? @default(now()) @map("created_at")
  updatedAt DateTime? @updatedAt @map("updated_at")
  
  tour Tour @relation(fields: [tourId], references: [id], onDelete: Cascade)
  bookingAddOns TourBookingAddOn[]
  
  @@index([tourId])
  @@map("tour_add_ons")
}

enum add_on_type {
  insurance
  equipment_rental
  photography
  meal_upgrade
  transportation_upgrade
  guide_upgrade
  other
}

enum add_on_price_type {
  per_person
  per_booking
  per_group
}

// Tour Booking Add-ons (selected add-ons for a booking)
model TourBookingAddOn {
  id String @id @default(uuid())
  bookingId String @map("booking_id") @db.Uuid
  addOnId String @map("add_on_id") @db.Uuid
  
  quantity Int @default(1)
  unitPrice Decimal @map("unit_price") @db.Decimal(10, 2)
  totalPrice Decimal @map("total_price") @db.Decimal(10, 2)
  
  createdAt DateTime? @default(now()) @map("created_at")
  
  booking Booking @relation(fields: [bookingId], references: [id], onDelete: Cascade)
  addOn TourAddOn @relation(fields: [addOnId], references: [id])
  
  @@index([bookingId])
  @@map("tour_booking_add_ons")
}

// Enhance Booking model for tours
model Booking {
  // ... existing fields ...
  
  // Tour-specific enhancements
  tourPickupLocation String? @map("tour_pickup_location")
  tourPickupTime String? @map("tour_pickup_time")
  tourDropoffLocation String? @map("tour_dropoff_location")
  
  // Guest breakdown
  adults Int? @default(0)
  children Int? @default(0)
  infants Int? @default(0)
  
  // Tour-specific guests (use TourBookingGuest instead of BookingGuest for tours)
  tourGuests TourBookingGuest[]
  tourAddOns TourBookingAddOn[]
}
```

#### 2.3 Enhanced Tour Booking API

**Endpoints:**
- `GET /api/tours/:id` - Get tour with schedules, add-ons, pickup locations
- `GET /api/tours/:id/schedules` - Get available schedules
- `POST /api/tours/:id/book` - Create tour booking with:
  ```json
  {
    "tourId": "uuid",
    "tourScheduleId": "uuid",
    "adults": 2,
    "children": 1,
    "infants": 0,
    "pickupLocation": "Hotel XYZ",
    "pickupTime": "08:00",
    "guests": [
      {
        "fullName": "John Doe",
        "age": 35,
        "guestType": "adult",
        "dietaryPreferences": ["vegetarian"],
        "isPrimary": true
      }
    ],
    "addOns": [
      {
        "addOnId": "uuid",
        "quantity": 2
      }
    ],
    "specialRequests": "Window seat preferred"
  }
  ```

---

## Implementation Phases

### Phase 1: Foundation (Week 1-2)
1. Database migrations for:
   - Products, ProductVariants
   - Services, ServiceBookings
   - Menus, MenuItems, MenuCategories
   - Carts, CartItems
   - Orders, OrderItems
2. Basic API endpoints for CRUD operations
3. Admin panel for managing products/services/menus

### Phase 2: Shopping Experience (Week 3-4)
1. Shop browsing UI (mobile & web)
2. Product/service/menu detail pages
3. Shopping cart functionality
4. Checkout flow
5. Order management (customer & merchant views)

### Phase 3: Enhanced Tours (Week 5-6)
1. Database migrations for tour enhancements
2. Enhanced tour booking API
3. Tour booking UI with guest management
4. Add-on selection
5. Pickup location selection

### Phase 4: Advanced Features (Week 7-8)
1. Inventory management
2. Order fulfillment tracking
3. Delivery integration (if needed)
4. Reviews for products/services
5. Analytics & reporting

---

## Key Design Decisions

### 1. Listing as Shop
- **Decision**: Enable shop mode on listings rather than separate Shop model
- **Rationale**: 
  - Reuses existing listing infrastructure
  - One listing can be both a place (for discovery) and a shop (for e-commerce)
  - Simpler architecture

### 2. Polymorphic Items
- **Decision**: Use `itemType` enum + nullable foreign keys for cart/order items
- **Rationale**:
  - Flexible: can add products, services, menu items to same cart
  - Type-safe with Prisma
  - Easy to query and filter

### 3. Menu Items vs Products
- **Decision**: Separate MenuItem model for restaurants
- **Rationale**:
  - Menus have unique needs (dietary info, prep time, customization)
  - Products are for general e-commerce
  - Can convert menu items to products if restaurant wants to sell retail

### 4. Service Bookings
- **Decision**: Separate ServiceBooking model linked to Orders
- **Rationale**:
  - Services need scheduling (date/time)
  - Can be purchased as part of order or standalone
  - Reuses booking infrastructure

### 5. Tour Guest Management
- **Decision**: Separate TourBookingGuest model (not reuse BookingGuest)
- **Rationale**:
  - Tours need more guest details (age, dietary, special needs)
  - Different from hotel/restaurant guests
  - Can still link to main Booking for payment/status

---

## User Flows

### Marketplace/Shop Flow

**Customer:**
1. Browse listings → Filter by "Has Shop"
2. View shop → Browse products/services/menu
3. Add items to cart
4. Checkout → Select delivery/pickup
5. Payment → Order confirmation
6. Track order → Receive updates

**Merchant:**
1. Enable shop mode on listing
2. Add products/services/menu items
3. Manage inventory
4. Receive orders → Process & fulfill
5. Update order status
6. View analytics

### Enhanced Tour Booking Flow

**Customer:**
1. Browse tours → Filter by category/location
2. View tour details → See schedules, add-ons, pickup locations
3. Select schedule → Choose date & time
4. Enter guest details → Adults, children, dietary preferences
5. Select add-ons → Insurance, equipment, etc.
6. Choose pickup location
7. Review & pay → Booking confirmation
8. Receive booking details → QR code, meeting point info

**Tour Operator:**
1. Create/update tour → Add schedules, add-ons
2. View bookings → See guest details
3. Manage schedules → Update availability
4. Check-in guests → Scan QR code
5. Complete tour → Mark as completed

---

## Open Questions & Considerations

1. **Delivery Integration**: Do we need delivery partner integration, or just pickup/dine-in?
2. **Inventory Sync**: How to handle inventory when items are in cart but not yet ordered?
3. **Multi-vendor Orders**: Can one order contain items from multiple shops?
4. **Tour Capacity**: How to handle group bookings vs individual bookings?
5. **Menu Pricing**: Should menu items have dynamic pricing (lunch vs dinner)?
6. **Service Availability**: Real-time availability checking for services?
7. **Order Modifications**: Can customers modify orders after placement?
8. **Refunds**: Automated refund system for cancellations?

---

## Next Steps

1. **Review & Refine**: Get feedback on architecture
2. **Prioritize Features**: Decide MVP vs nice-to-have
3. **Create Detailed Specs**: Break down each phase into tasks
4. **Database Design Review**: Finalize schema
5. **API Design**: Create OpenAPI/Swagger specs
6. **UI/UX Mockups**: Design screens for key flows
7. **Start Implementation**: Begin Phase 1

---

## References

- Current Booking System: `/docs/12-features/03-bookings.md`
- Tours Brainstorm: `/docs/12-features/09-tours-packages-brainstorm.md`
- Database Schema: `/backend/prisma/schema.prisma`

