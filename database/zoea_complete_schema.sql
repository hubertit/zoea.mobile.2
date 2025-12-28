-- ============================================
-- ZOEA DATABASE SCHEMA - COMPLETE VERSION
-- PostgreSQL 16 with PostGIS
-- All IDs are UUIDs, soft deletes, audit columns
-- ============================================

-- Enable extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "postgis";
CREATE EXTENSION IF NOT EXISTS "pg_trgm";

-- ============================================
-- ENUMS
-- ============================================

CREATE TYPE user_role AS ENUM ('explorer', 'merchant', 'event_organizer', 'tour_operator', 'admin', 'super_admin');
CREATE TYPE account_type AS ENUM ('personal', 'business', 'creator');
CREATE TYPE verification_status AS ENUM ('unverified', 'pending', 'verified', 'rejected');
CREATE TYPE listing_type AS ENUM ('hotel', 'restaurant', 'tour', 'event', 'attraction', 'bar', 'club', 'lounge', 'cafe', 'fast_food', 'mall', 'market', 'boutique');
CREATE TYPE listing_status AS ENUM ('draft', 'pending_review', 'active', 'inactive', 'suspended');
CREATE TYPE price_unit AS ENUM ('per_night', 'per_person', 'per_meal', 'per_tour', 'per_event', 'per_hour', 'per_table');
CREATE TYPE booking_type AS ENUM ('hotel', 'restaurant', 'tour', 'event', 'experience');
CREATE TYPE booking_status AS ENUM ('pending', 'confirmed', 'checked_in', 'completed', 'cancelled', 'no_show', 'refunded');
CREATE TYPE payment_method AS ENUM ('zoea_card', 'momo', 'bank_transfer', 'cash', 'card');
CREATE TYPE payment_status AS ENUM ('pending', 'processing', 'completed', 'failed', 'refunded', 'partially_refunded');
CREATE TYPE card_status AS ENUM ('active', 'inactive', 'suspended', 'blocked');
CREATE TYPE transaction_type AS ENUM ('deposit', 'withdrawal', 'payment', 'refund', 'commission', 'bonus', 'payout', 'subscription');
CREATE TYPE transaction_status AS ENUM ('pending', 'completed', 'failed', 'cancelled');
CREATE TYPE event_privacy AS ENUM ('public', 'private', 'invite_only');
CREATE TYPE event_setup AS ENUM ('in_person', 'virtual', 'hybrid');
CREATE TYPE ticket_type AS ENUM ('free', 'paid', 'donation', 'vip', 'early_bird');
CREATE TYPE ticket_order_type AS ENUM ('first_come', 'lottery', 'approval');
CREATE TYPE subscription_status AS ENUM ('active', 'past_due', 'cancelled', 'paused', 'trial');
CREATE TYPE subscription_interval AS ENUM ('monthly', 'quarterly', 'yearly');
CREATE TYPE notification_type AS ENUM ('booking', 'payment', 'event', 'promotion', 'system', 'social');
CREATE TYPE document_type AS ENUM ('id_card', 'passport', 'business_license', 'tax_certificate', 'bank_statement');
CREATE TYPE document_status AS ENUM ('pending', 'approved', 'rejected');
CREATE TYPE room_status AS ENUM ('available', 'occupied', 'maintenance', 'blocked');
CREATE TYPE table_status AS ENUM ('available', 'reserved', 'occupied', 'unavailable');
CREATE TYPE day_of_week AS ENUM ('monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday');
CREATE TYPE media_type AS ENUM ('image', 'video', 'document', 'audio');
CREATE TYPE referral_reward_status AS ENUM ('pending', 'credited', 'expired', 'cancelled');
CREATE TYPE event_status AS ENUM ('draft', 'pending_review', 'published', 'ongoing', 'completed', 'cancelled', 'suspended');
CREATE TYPE tour_status AS ENUM ('draft', 'pending_review', 'active', 'inactive', 'suspended');
CREATE TYPE review_status AS ENUM ('pending', 'approved', 'rejected', 'flagged');
CREATE TYPE ticket_status AS ENUM ('available', 'sold_out', 'expired', 'disabled');

-- ============================================
-- CORE TABLES
-- ============================================

-- ============================================
-- UTILITY / REFERENCE TABLES
-- ============================================

-- Languages
CREATE TABLE languages (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    code VARCHAR(10) UNIQUE NOT NULL, -- ISO 639-1 (e.g., 'en', 'fr', 'rw')
    code_3 VARCHAR(10), -- ISO 639-2 (e.g., 'eng', 'fra', 'kin')
    name VARCHAR(100) NOT NULL,
    native_name VARCHAR(100),
    is_rtl BOOLEAN DEFAULT false,
    is_active BOOLEAN DEFAULT true,
    sort_order INTEGER DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Currencies
CREATE TABLE currencies (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    code VARCHAR(3) UNIQUE NOT NULL, -- ISO 4217 (e.g., 'RWF', 'USD')
    name VARCHAR(100) NOT NULL,
    symbol VARCHAR(10) NOT NULL,
    symbol_native VARCHAR(10),
    decimal_digits INTEGER DEFAULT 2,
    
    -- Exchange rates (base: USD)
    exchange_rate_to_usd DECIMAL(15,6) DEFAULT 1,
    exchange_rate_updated_at TIMESTAMPTZ,
    
    is_active BOOLEAN DEFAULT true,
    sort_order INTEGER DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Timezones
CREATE TABLE timezones (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(100) UNIQUE NOT NULL, -- e.g., 'Africa/Kigali'
    abbreviation VARCHAR(10), -- e.g., 'CAT'
    utc_offset VARCHAR(10) NOT NULL, -- e.g., '+02:00'
    utc_offset_minutes INTEGER NOT NULL, -- e.g., 120
    
    -- DST info
    has_dst BOOLEAN DEFAULT false,
    dst_offset_minutes INTEGER,
    
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================
-- GEOGRAPHIC / MULTI-COUNTRY SUPPORT
-- ============================================

-- Countries
CREATE TABLE countries (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(100) NOT NULL,
    code VARCHAR(3) UNIQUE NOT NULL, -- ISO 3166-1 alpha-3
    code_2 VARCHAR(2) UNIQUE NOT NULL, -- ISO 3166-1 alpha-2
    phone_code VARCHAR(10),
    currency_code VARCHAR(3),
    currency_symbol VARCHAR(10),
    flag_emoji VARCHAR(10),
    
    -- Localization
    default_language VARCHAR(10) DEFAULT 'en',
    supported_languages TEXT[] DEFAULT '{en}',
    timezone VARCHAR(50),
    
    -- Operations
    is_active BOOLEAN DEFAULT false, -- are we operating here?
    launched_at TIMESTAMPTZ,
    
    -- Settings
    settings JSONB, -- country-specific settings
    
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Regions/Provinces/States
CREATE TABLE regions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    country_id UUID NOT NULL REFERENCES countries(id),
    name VARCHAR(100) NOT NULL,
    code VARCHAR(20),
    
    is_active BOOLEAN DEFAULT true,
    
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Cities
CREATE TABLE cities (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    country_id UUID NOT NULL REFERENCES countries(id),
    region_id UUID REFERENCES regions(id),
    
    name VARCHAR(100) NOT NULL,
    slug VARCHAR(100) NOT NULL,
    
    -- Location
    location GEOGRAPHY(POINT, 4326),
    bounds GEOGRAPHY(POLYGON, 4326), -- city boundaries
    timezone VARCHAR(50),
    
    -- Info
    population INTEGER,
    description TEXT,
    image_id UUID REFERENCES media(id),
    
    -- Operations
    is_active BOOLEAN DEFAULT false,
    is_featured BOOLEAN DEFAULT false,
    launched_at TIMESTAMPTZ,
    
    -- Stats (denormalized)
    listing_count INTEGER DEFAULT 0,
    event_count INTEGER DEFAULT 0,
    
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    
    UNIQUE(country_id, slug)
);

-- Districts/Neighborhoods (within cities)
CREATE TABLE districts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    city_id UUID NOT NULL REFERENCES cities(id),
    
    name VARCHAR(100) NOT NULL,
    slug VARCHAR(100) NOT NULL,
    
    location GEOGRAPHY(POINT, 4326),
    bounds GEOGRAPHY(POLYGON, 4326),
    
    is_active BOOLEAN DEFAULT true,
    
    created_at TIMESTAMPTZ DEFAULT NOW(),
    
    UNIQUE(city_id, slug)
);

-- ============================================
-- CORE TABLES
-- ============================================

-- Media/Files Storage
CREATE TABLE media (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    url VARCHAR(500) NOT NULL,
    media_type media_type NOT NULL DEFAULT 'image',
    file_name VARCHAR(255),
    file_size INTEGER,
    mime_type VARCHAR(100),
    width INTEGER,
    height INTEGER,
    blurhash VARCHAR(100),
    color VARCHAR(20),
    is_dark BOOLEAN DEFAULT false,
    thumbnail_url VARCHAR(500),
    medium_url VARCHAR(500),
    uploaded_by UUID, -- FK added after users table creation via ALTER
    created_at TIMESTAMPTZ DEFAULT NOW(),
    deleted_at TIMESTAMPTZ
);

-- Add FK constraint after users table is created (circular dependency)
-- ALTER TABLE media ADD CONSTRAINT fk_media_uploaded_by FOREIGN KEY (uploaded_by) REFERENCES users(id);

-- Users (Central table - all user types)
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    email VARCHAR(255) UNIQUE, -- nullable for phone-only registration
    phone_number VARCHAR(20) UNIQUE, -- nullable for email-only registration
    password_hash VARCHAR(255), -- nullable for social login
    username VARCHAR(50) UNIQUE, -- nullable, can be set later
    full_name VARCHAR(255), -- nullable for migration
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    bio TEXT,
    profile_image_id UUID REFERENCES media(id),
    background_image_id UUID REFERENCES media(id),
    
    -- Demographics (all nullable - optional info)
    date_of_birth DATE,
    gender VARCHAR(20), -- 'male', 'female', 'other', 'prefer_not_to_say'
    
    -- Location (all nullable)
    country_id UUID REFERENCES countries(id),
    city_id UUID REFERENCES cities(id),
    address TEXT,
    postal_code VARCHAR(20),
    current_location GEOGRAPHY(POINT, 4326),
    
    -- Professional Info (all nullable - optional)
    profession VARCHAR(100),
    company VARCHAR(255),
    industry VARCHAR(100),
    
    -- Interests & Preferences (all nullable - optional)
    interests TEXT[],
    dietary_preferences TEXT[],
    accessibility_needs TEXT[],
    
    -- Roles & Status
    roles user_role[] DEFAULT '{explorer}',
    account_type account_type DEFAULT 'personal',
    is_verified BOOLEAN DEFAULT false,
    is_active BOOLEAN DEFAULT true,
    is_private BOOLEAN DEFAULT false,
    is_blocked BOOLEAN DEFAULT false,
    verification_status verification_status DEFAULT 'unverified',
    
    -- Preferences (with defaults)
    preferred_currency VARCHAR(3) DEFAULT 'RWF',
    preferred_language VARCHAR(10) DEFAULT 'en',
    timezone VARCHAR(50) DEFAULT 'Africa/Kigali',
    max_distance INTEGER DEFAULT 50,
    notification_preferences JSONB DEFAULT '{"push": true, "email": true, "sms": false}',
    
    -- Marketing
    marketing_consent BOOLEAN DEFAULT false,
    marketing_consent_at TIMESTAMPTZ,
    
    -- Auth
    email_verified_at TIMESTAMPTZ,
    phone_verified_at TIMESTAMPTZ,
    last_login_at TIMESTAMPTZ,
    
    -- Audit
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    deleted_at TIMESTAMPTZ,
    
    -- Ensure at least email or phone is provided
    CONSTRAINT users_contact_check CHECK (email IS NOT NULL OR phone_number IS NOT NULL)
);

-- User Content Preferences (which countries/cities to see content from)
CREATE TABLE user_content_preferences (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) UNIQUE,
    
    -- Selected countries/cities for content feed
    selected_countries UUID[], -- references countries
    selected_cities UUID[], -- references cities
    
    -- Show content from
    show_current_location BOOLEAN DEFAULT true, -- auto-detect and show nearby
    show_selected_only BOOLEAN DEFAULT false, -- only show from selected locations
    
    -- Content type preferences
    show_events BOOLEAN DEFAULT true,
    show_listings BOOLEAN DEFAULT true,
    show_tours BOOLEAN DEFAULT true,
    show_promotions BOOLEAN DEFAULT true,
    
    -- Category preferences
    preferred_categories UUID[], -- references categories
    hidden_categories UUID[],
    
    -- Price preferences
    min_price DECIMAL(10,2),
    max_price DECIMAL(10,2),
    preferred_price_range VARCHAR(20), -- 'budget', 'mid', 'luxury'
    
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- User Sessions/Devices
CREATE TABLE user_sessions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id),
    device_id VARCHAR(255),
    device_name VARCHAR(255),
    device_type VARCHAR(50),
    os_version VARCHAR(50),
    app_version VARCHAR(20),
    fcm_token VARCHAR(500),
    ip_address INET,
    is_active BOOLEAN DEFAULT true,
    last_active_at TIMESTAMPTZ DEFAULT NOW(),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    expires_at TIMESTAMPTZ
);

-- User Verification Documents (KYC)
CREATE TABLE user_documents (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id),
    document_type document_type NOT NULL,
    document_number VARCHAR(100),
    media_id UUID REFERENCES media(id),
    status document_status DEFAULT 'pending',
    reviewed_by UUID REFERENCES users(id),
    reviewed_at TIMESTAMPTZ,
    rejection_reason TEXT,
    expires_at DATE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================
-- ROLE-SPECIFIC PROFILES
-- ============================================

-- Merchant Profiles (Hotels, Restaurants, Shops, etc.)
CREATE TABLE merchant_profiles (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) UNIQUE,
    business_name VARCHAR(255), -- nullable for migration
    business_type listing_type, -- nullable for migration
    business_registration_number VARCHAR(100),
    tax_id VARCHAR(100),
    description TEXT,
    logo_id UUID REFERENCES media(id),
    
    -- Contact (all nullable)
    business_email VARCHAR(255),
    business_phone VARCHAR(20),
    website VARCHAR(255),
    social_links JSONB,
    
    -- Location (all nullable)
    country_id UUID REFERENCES countries(id),
    city_id UUID REFERENCES cities(id),
    district_id UUID REFERENCES districts(id),
    address TEXT,
    location GEOGRAPHY(POINT, 4326),
    
    -- Registration & Approval
    registration_status approval_status DEFAULT 'pending',
    submitted_at TIMESTAMPTZ DEFAULT NOW(),
    reviewed_by UUID REFERENCES users(id),
    reviewed_at TIMESTAMPTZ,
    rejection_reason TEXT,
    revision_notes TEXT,
    
    -- Verification (after approval, additional verification)
    is_verified BOOLEAN DEFAULT false,
    verified_at TIMESTAMPTZ,
    verified_by UUID REFERENCES users(id),
    
    -- Settings
    commission_rate DECIMAL(5,2) DEFAULT 10.00,
    payout_schedule VARCHAR(20) DEFAULT 'weekly',
    bank_account_info JSONB,
    
    -- Stats
    total_revenue DECIMAL(15,2) DEFAULT 0,
    total_bookings INTEGER DEFAULT 0,
    average_rating DECIMAL(3,2) DEFAULT 0,
    
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    deleted_at TIMESTAMPTZ
);

-- Event Organizer Profiles
CREATE TABLE organizer_profiles (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) UNIQUE,
    organization_name VARCHAR(255), -- nullable, can use user's name
    organization_type VARCHAR(100),
    description TEXT,
    logo_id UUID REFERENCES media(id),
    
    -- Location (nullable)
    country_id UUID REFERENCES countries(id),
    city_id UUID REFERENCES cities(id),
    
    -- Contact (all nullable)
    contact_email VARCHAR(255),
    contact_phone VARCHAR(20),
    website VARCHAR(255),
    social_links JSONB,
    
    -- Registration & Approval
    registration_status approval_status DEFAULT 'pending',
    submitted_at TIMESTAMPTZ DEFAULT NOW(),
    reviewed_by UUID REFERENCES users(id),
    reviewed_at TIMESTAMPTZ,
    rejection_reason TEXT,
    revision_notes TEXT,
    
    -- Verification (after approval)
    is_verified BOOLEAN DEFAULT false,
    verified_at TIMESTAMPTZ,
    
    -- Stats
    total_events INTEGER DEFAULT 0,
    total_attendees INTEGER DEFAULT 0,
    average_rating DECIMAL(3,2) DEFAULT 0,
    follower_count INTEGER DEFAULT 0,
    
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    deleted_at TIMESTAMPTZ
);

-- Tour Operator Profiles
CREATE TABLE tour_operator_profiles (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) UNIQUE,
    company_name VARCHAR(255), -- nullable for migration
    license_number VARCHAR(100),
    description TEXT,
    logo_id UUID REFERENCES media(id),
    
    -- Specializations (nullable)
    specializations TEXT[],
    languages_offered TEXT[] DEFAULT '{en}',
    
    -- Contact (all nullable)
    contact_email VARCHAR(255),
    contact_phone VARCHAR(20),
    website VARCHAR(255),
    social_links JSONB,
    
    -- Location (all nullable)
    country_id UUID REFERENCES countries(id),
    city_id UUID REFERENCES cities(id),
    operating_regions UUID[],
    
    -- Registration & Approval
    registration_status approval_status DEFAULT 'pending',
    submitted_at TIMESTAMPTZ DEFAULT NOW(),
    reviewed_by UUID REFERENCES users(id),
    reviewed_at TIMESTAMPTZ,
    rejection_reason TEXT,
    revision_notes TEXT,
    
    -- Verification (after approval)
    is_verified BOOLEAN DEFAULT false,
    verified_at TIMESTAMPTZ,
    
    -- Stats
    total_tours INTEGER DEFAULT 0,
    total_customers INTEGER DEFAULT 0,
    average_rating DECIMAL(3,2) DEFAULT 0,
    
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    deleted_at TIMESTAMPTZ
);

-- ============================================
-- SUBSCRIPTION & BILLING
-- ============================================

-- Subscription Plans
CREATE TABLE subscription_plans (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(100), -- nullable for migration
    slug VARCHAR(100) UNIQUE,
    description TEXT,
    
    -- Pricing
    price DECIMAL(10,2),
    currency VARCHAR(3) DEFAULT 'RWF',
    interval subscription_interval,
    trial_days INTEGER DEFAULT 0,
    
    -- Features
    features JSONB DEFAULT '{}', -- {"max_listings": 10, "featured_listings": 2, "analytics": true}
    
    -- For specific user types
    applicable_roles user_role[],
    
    is_active BOOLEAN DEFAULT true,
    sort_order INTEGER DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Merchant/Organizer Subscriptions
CREATE TABLE subscriptions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id), -- nullable for migration
    plan_id UUID REFERENCES subscription_plans(id),
    
    status subscription_status DEFAULT 'active',
    
    -- Billing (nullable for migration)
    current_period_start TIMESTAMPTZ,
    current_period_end TIMESTAMPTZ,
    trial_end TIMESTAMPTZ,
    
    -- Payment
    payment_method payment_method,
    payment_reference VARCHAR(255),
    
    -- Cancellation
    cancelled_at TIMESTAMPTZ,
    cancel_reason TEXT,
    
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Subscription Invoices
CREATE TABLE subscription_invoices (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    subscription_id UUID REFERENCES subscriptions(id),
    user_id UUID REFERENCES users(id),
    
    invoice_number VARCHAR(50) UNIQUE,
    amount DECIMAL(10,2),
    currency VARCHAR(3) DEFAULT 'RWF',
    tax_amount DECIMAL(10,2) DEFAULT 0,
    total_amount DECIMAL(10,2),
    
    status payment_status DEFAULT 'pending',
    paid_at TIMESTAMPTZ,
    payment_method payment_method,
    payment_reference VARCHAR(255),
    
    period_start TIMESTAMPTZ,
    period_end TIMESTAMPTZ,
    due_date DATE,
    
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================
-- LISTINGS (Places/Venues)
-- ============================================

-- Master Tables for Normalization
CREATE TABLE amenities (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(100) NOT NULL,
    slug VARCHAR(100) UNIQUE NOT NULL,
    description TEXT,
    icon VARCHAR(50),
    category VARCHAR(50), -- 'room', 'property', 'dining', etc.
    applicable_types listing_type[],
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE tags (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(100) NOT NULL,
    slug VARCHAR(100) UNIQUE NOT NULL,
    description TEXT,
    category VARCHAR(50),
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE categories (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(100) NOT NULL,
    slug VARCHAR(100) UNIQUE NOT NULL,
    parent_id UUID REFERENCES categories(id),
    icon VARCHAR(50),
    image_id UUID REFERENCES media(id),
    description TEXT,
    sort_order INTEGER DEFAULT 0,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Main Listings Table
CREATE TABLE listings (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    merchant_id UUID REFERENCES merchant_profiles(id), -- nullable for migration
    
    -- Basic Info
    name VARCHAR(255), -- nullable for migration
    slug VARCHAR(255) UNIQUE, -- nullable for migration
    description TEXT,
    short_description VARCHAR(500),
    
    -- Classification
    type listing_type, -- nullable for migration
    category_id UUID REFERENCES categories(id),
    status listing_status DEFAULT 'draft',
    
    -- Location (all nullable)
    country_id UUID REFERENCES countries(id),
    city_id UUID REFERENCES cities(id),
    district_id UUID REFERENCES districts(id),
    address TEXT,
    postal_code VARCHAR(20),
    location GEOGRAPHY(POINT, 4326),
    location_name VARCHAR(255),
    
    -- Pricing (all nullable)
    min_price DECIMAL(10,2),
    max_price DECIMAL(10,2),
    currency VARCHAR(3) DEFAULT 'RWF',
    price_unit price_unit,
    
    -- Contact (all nullable)
    contact_phone VARCHAR(20),
    contact_email VARCHAR(255),
    website VARCHAR(255),
    
    -- Operating Hours (nullable)
    operating_hours JSONB,
    
    -- Flags
    is_verified BOOLEAN DEFAULT false,
    is_featured BOOLEAN DEFAULT false,
    is_blocked BOOLEAN DEFAULT false,
    
    -- Stats (with defaults)
    rating DECIMAL(3,2) DEFAULT 0,
    review_count INTEGER DEFAULT 0,
    booking_count INTEGER DEFAULT 0,
    view_count INTEGER DEFAULT 0,
    favorite_count INTEGER DEFAULT 0,
    
    -- SEO (nullable)
    meta_title VARCHAR(255),
    meta_description TEXT,
    
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    deleted_at TIMESTAMPTZ
);

-- Listing Images
CREATE TABLE listing_images (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    listing_id UUID NOT NULL REFERENCES listings(id) ON DELETE CASCADE,
    media_id UUID NOT NULL REFERENCES media(id),
    is_primary BOOLEAN DEFAULT false,
    sort_order INTEGER DEFAULT 0,
    caption VARCHAR(255),
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Listing Amenities (Many-to-Many)
CREATE TABLE listing_amenities (
    listing_id UUID NOT NULL REFERENCES listings(id) ON DELETE CASCADE,
    amenity_id UUID NOT NULL REFERENCES amenities(id),
    PRIMARY KEY (listing_id, amenity_id)
);

-- Listing Tags (Many-to-Many)
CREATE TABLE listing_tags (
    listing_id UUID NOT NULL REFERENCES listings(id) ON DELETE CASCADE,
    tag_id UUID NOT NULL REFERENCES tags(id),
    PRIMARY KEY (listing_id, tag_id)
);

-- ============================================
-- HOTEL SPECIFIC
-- ============================================

-- Room Types
CREATE TABLE room_types (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    listing_id UUID NOT NULL REFERENCES listings(id) ON DELETE CASCADE,
    
    name VARCHAR(100) NOT NULL,
    description TEXT,
    
    -- Capacity
    max_occupancy INTEGER NOT NULL DEFAULT 2,
    bed_type VARCHAR(50),
    bed_count INTEGER DEFAULT 1,
    room_size DECIMAL(6,2), -- square meters
    
    -- Pricing
    base_price DECIMAL(10,2) NOT NULL CHECK (base_price >= 0),
    currency VARCHAR(3) DEFAULT 'RWF',
    
    -- Inventory
    total_rooms INTEGER NOT NULL DEFAULT 1 CHECK (total_rooms > 0),
    
    -- Features
    amenities UUID[], -- references amenities
    images UUID[], -- references media
    
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Room Inventory (for availability tracking)
CREATE TABLE rooms (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    room_type_id UUID NOT NULL REFERENCES room_types(id) ON DELETE CASCADE,
    room_number VARCHAR(20) NOT NULL,
    floor INTEGER,
    status room_status DEFAULT 'available',
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Room Availability & Pricing (per date)
CREATE TABLE room_availability (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    room_type_id UUID NOT NULL REFERENCES room_types(id) ON DELETE CASCADE,
    date DATE NOT NULL,
    available_count INTEGER NOT NULL,
    price DECIMAL(10,2), -- override base price if set
    min_stay INTEGER DEFAULT 1,
    is_blocked BOOLEAN DEFAULT false,
    UNIQUE(room_type_id, date)
);

-- ============================================
-- RESTAURANT SPECIFIC (OpenTable-like)
-- ============================================

-- Restaurant Tables
CREATE TABLE restaurant_tables (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    listing_id UUID NOT NULL REFERENCES listings(id) ON DELETE CASCADE,
    
    table_number VARCHAR(20) NOT NULL,
    capacity INTEGER NOT NULL CHECK (capacity > 0),
    min_capacity INTEGER DEFAULT 1 CHECK (min_capacity > 0),
    location VARCHAR(50), -- 'indoor', 'outdoor', 'rooftop', 'private'
    
    status table_status DEFAULT 'available',
    is_active BOOLEAN DEFAULT true,
    
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Time Slots for Reservations
CREATE TABLE reservation_time_slots (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    listing_id UUID NOT NULL REFERENCES listings(id) ON DELETE CASCADE,
    
    day_of_week day_of_week NOT NULL,
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    slot_duration INTEGER DEFAULT 90, -- minutes
    max_reservations INTEGER,
    
    is_active BOOLEAN DEFAULT true,
    
    UNIQUE(listing_id, day_of_week, start_time)
);

-- Special Date Overrides (holidays, special events)
CREATE TABLE reservation_date_overrides (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    listing_id UUID NOT NULL REFERENCES listings(id) ON DELETE CASCADE,
    date DATE NOT NULL,
    is_closed BOOLEAN DEFAULT false,
    custom_slots JSONB, -- override time slots for this date
    notes TEXT,
    UNIQUE(listing_id, date)
);

-- ============================================
-- EVENTS
-- ============================================

-- Event Contexts/Categories
CREATE TABLE event_contexts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(100) NOT NULL,
    slug VARCHAR(100) UNIQUE NOT NULL,
    description TEXT,
    icon VARCHAR(50),
    parent_id UUID REFERENCES event_contexts(id),
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Events
CREATE TABLE events (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    organizer_id UUID REFERENCES organizer_profiles(id), -- nullable for migration
    
    -- Basic Info
    name VARCHAR(255), -- nullable for migration
    slug VARCHAR(255) UNIQUE, -- nullable for migration
    description TEXT,
    
    -- Classification
    event_context_id UUID REFERENCES event_contexts(id),
    type VARCHAR(50), -- 'concert', 'conference', 'workshop', 'party', etc.
    privacy event_privacy DEFAULT 'public',
    setup event_setup DEFAULT 'in_person',
    
    -- Media
    flyer_id UUID REFERENCES media(id),
    
    -- Location
    country_id UUID REFERENCES countries(id),
    city_id UUID REFERENCES cities(id),
    district_id UUID REFERENCES districts(id),
    location GEOGRAPHY(POINT, 4326),
    location_name VARCHAR(255),
    venue_name VARCHAR(255),
    address TEXT,
    
    -- Virtual Event
    virtual_url VARCHAR(500),
    virtual_platform VARCHAR(50),
    
    -- Schedule (nullable for migration)
    start_date TIMESTAMPTZ,
    end_date TIMESTAMPTZ,
    timezone VARCHAR(50) DEFAULT 'Africa/Kigali',
    
    -- Capacity
    max_attendance INTEGER,
    attending_count INTEGER DEFAULT 0,
    
    -- Status
    status event_status DEFAULT 'draft',
    is_blocked BOOLEAN DEFAULT false,
    cancellation_reason TEXT,
    
    -- Stats (denormalized)
    view_count INTEGER DEFAULT 0,
    like_count INTEGER DEFAULT 0,
    comment_count INTEGER DEFAULT 0,
    share_count INTEGER DEFAULT 0,
    
    -- MICE specific
    is_mice BOOLEAN DEFAULT false, -- Meetings, Incentives, Conferences, Exhibitions
    
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    deleted_at TIMESTAMPTZ,
    
    -- Constraints
    CONSTRAINT events_dates_check CHECK (end_date IS NULL OR start_date IS NULL OR end_date >= start_date),
    CONSTRAINT events_attendance_check CHECK (max_attendance IS NULL OR max_attendance > 0)
);

-- Event Attachments/Gallery
CREATE TABLE event_attachments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    event_id UUID NOT NULL REFERENCES events(id) ON DELETE CASCADE,
    media_id UUID NOT NULL REFERENCES media(id),
    is_main_flyer BOOLEAN DEFAULT false,
    sort_order INTEGER DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Event Tickets
CREATE TABLE event_tickets (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    event_id UUID NOT NULL REFERENCES events(id) ON DELETE CASCADE,
    
    name VARCHAR(100) NOT NULL,
    description TEXT,
    
    type ticket_type DEFAULT 'paid',
    order_type ticket_order_type DEFAULT 'first_come',
    
    price DECIMAL(10,2) NOT NULL DEFAULT 0,
    currency VARCHAR(3) DEFAULT 'RWF',
    
    -- Inventory
    total_quantity INTEGER,
    sold_quantity INTEGER DEFAULT 0,
    reserved_quantity INTEGER DEFAULT 0,
    
    -- Limits
    min_per_order INTEGER DEFAULT 1,
    max_per_order INTEGER DEFAULT 10,
    
    -- Availability
    sale_start TIMESTAMPTZ,
    sale_end TIMESTAMPTZ,
    status ticket_status DEFAULT 'available',
    is_visible BOOLEAN DEFAULT true,
    
    sort_order INTEGER DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    
    -- Constraints
    CONSTRAINT event_tickets_price_check CHECK (price IS NULL OR price >= 0),
    CONSTRAINT event_tickets_quantity_check CHECK (total_quantity IS NULL OR total_quantity >= 0),
    CONSTRAINT event_tickets_per_order_check CHECK (max_per_order IS NULL OR min_per_order IS NULL OR max_per_order >= min_per_order)
);

-- ============================================
-- TOURS & EXPERIENCES
-- ============================================

-- Tours/Experiences
CREATE TABLE tours (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    operator_id UUID REFERENCES tour_operator_profiles(id), -- nullable for migration
    
    name VARCHAR(255), -- nullable for migration
    slug VARCHAR(255) UNIQUE, -- nullable for migration
    description TEXT,
    short_description VARCHAR(500),
    
    -- Classification
    category_id UUID REFERENCES categories(id),
    type VARCHAR(50), -- 'day_trip', 'multi_day', 'adventure', 'cultural', etc.
    
    -- Duration
    duration_hours DECIMAL(5,2),
    duration_days INTEGER,
    
    -- Location
    country_id UUID REFERENCES countries(id),
    city_id UUID REFERENCES cities(id),
    start_location GEOGRAPHY(POINT, 4326),
    start_location_name VARCHAR(255),
    end_location GEOGRAPHY(POINT, 4326),
    end_location_name VARCHAR(255),
    operating_regions UUID[], -- references regions
    
    -- Pricing (nullable for migration)
    price_per_person DECIMAL(10,2),
    currency VARCHAR(3) DEFAULT 'USD',
    group_discount_percentage DECIMAL(5,2),
    min_group_size INTEGER DEFAULT 1,
    max_group_size INTEGER DEFAULT 20,
    
    -- Details
    includes TEXT[],
    excludes TEXT[],
    itinerary JSONB,
    requirements TEXT[],
    difficulty_level VARCHAR(20), -- 'easy', 'moderate', 'challenging'
    
    -- Languages
    languages TEXT[] DEFAULT '{en}',
    
    -- Status & Flags
    status tour_status DEFAULT 'draft',
    is_featured BOOLEAN DEFAULT false,
    
    -- Stats
    rating DECIMAL(3,2) DEFAULT 0,
    review_count INTEGER DEFAULT 0,
    booking_count INTEGER DEFAULT 0,
    
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    deleted_at TIMESTAMPTZ,
    
    -- Constraints
    CONSTRAINT tours_price_check CHECK (price_per_person IS NULL OR price_per_person >= 0),
    CONSTRAINT tours_group_size_check CHECK (max_group_size IS NULL OR min_group_size IS NULL OR max_group_size >= min_group_size),
    CONSTRAINT tours_rating_check CHECK (rating IS NULL OR (rating >= 0 AND rating <= 5))
);

-- Tour Images
CREATE TABLE tour_images (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    tour_id UUID NOT NULL REFERENCES tours(id) ON DELETE CASCADE,
    media_id UUID NOT NULL REFERENCES media(id),
    is_primary BOOLEAN DEFAULT false,
    sort_order INTEGER DEFAULT 0,
    caption VARCHAR(255),
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Tour Schedules (Available dates)
CREATE TABLE tour_schedules (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    tour_id UUID NOT NULL REFERENCES tours(id) ON DELETE CASCADE,
    
    date DATE NOT NULL,
    start_time TIME,
    
    available_spots INTEGER NOT NULL,
    booked_spots INTEGER DEFAULT 0,
    
    price_override DECIMAL(10,2),
    is_available BOOLEAN DEFAULT true,
    
    UNIQUE(tour_id, date, start_time)
);

-- ============================================
-- BOOKINGS
-- ============================================

-- Main Bookings Table
CREATE TABLE bookings (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    booking_number VARCHAR(20) UNIQUE, -- nullable for migration
    user_id UUID REFERENCES users(id), -- nullable for migration (guest bookings)
    
    -- What is being booked (polymorphic) - all nullable
    booking_type booking_type,
    listing_id UUID REFERENCES listings(id),
    event_id UUID REFERENCES events(id),
    tour_id UUID REFERENCES tours(id),
    
    -- Merchant (denormalized for easier queries) - all nullable
    merchant_id UUID REFERENCES merchant_profiles(id),
    organizer_id UUID REFERENCES organizer_profiles(id),
    operator_id UUID REFERENCES tour_operator_profiles(id),
    
    -- Hotel specific
    room_type_id UUID REFERENCES room_types(id),
    room_id UUID REFERENCES rooms(id),
    
    -- Restaurant specific
    table_id UUID REFERENCES restaurant_tables(id),
    time_slot_id UUID REFERENCES reservation_time_slots(id),
    party_size INTEGER,
    
    -- Event specific
    ticket_id UUID REFERENCES event_tickets(id),
    ticket_quantity INTEGER,
    
    -- Tour specific
    tour_schedule_id UUID REFERENCES tour_schedules(id),
    
    -- Dates
    check_in_date DATE,
    check_out_date DATE,
    booking_date DATE,
    booking_time TIME,
    
    -- Guests
    guest_count INTEGER DEFAULT 1,
    adults INTEGER DEFAULT 1,
    children INTEGER DEFAULT 0,
    
    -- Pricing (nullable for migration)
    subtotal DECIMAL(12,2),
    tax_amount DECIMAL(10,2) DEFAULT 0,
    discount_amount DECIMAL(10,2) DEFAULT 0,
    total_amount DECIMAL(12,2),
    currency VARCHAR(3) DEFAULT 'RWF',
    
    -- Status
    status booking_status DEFAULT 'pending',
    
    -- Payment
    payment_status payment_status DEFAULT 'pending',
    payment_method payment_method,
    payment_reference VARCHAR(255),
    paid_at TIMESTAMPTZ,
    
    -- Additional Info
    special_requests TEXT,
    internal_notes TEXT,
    
    -- Cancellation
    cancelled_at TIMESTAMPTZ,
    cancelled_by UUID REFERENCES users(id),
    cancellation_reason TEXT,
    refund_amount DECIMAL(10,2),
    
    -- Confirmation
    confirmed_at TIMESTAMPTZ,
    confirmation_code VARCHAR(20),
    
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    
    -- Constraints
    CONSTRAINT bookings_dates_check CHECK (check_out_date IS NULL OR check_in_date IS NULL OR check_out_date >= check_in_date),
    CONSTRAINT bookings_guest_count_check CHECK (guest_count IS NULL OR guest_count > 0),
    CONSTRAINT bookings_amount_check CHECK (total_amount IS NULL OR total_amount >= 0)
);

-- Booking Guests (for hotel/restaurant)
CREATE TABLE booking_guests (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    booking_id UUID REFERENCES bookings(id) ON DELETE CASCADE, -- nullable for migration
    
    full_name VARCHAR(255), -- nullable for migration
    email VARCHAR(255),
    phone VARCHAR(20),
    is_primary BOOLEAN DEFAULT false,
    
    -- For hotels
    id_type VARCHAR(50),
    id_number VARCHAR(100),
    nationality VARCHAR(100),
    
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Event Attendees (Purchased tickets)
CREATE TABLE event_attendees (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    event_id UUID REFERENCES events(id), -- nullable for migration
    user_id UUID REFERENCES users(id),
    booking_id UUID REFERENCES bookings(id),
    ticket_id UUID REFERENCES event_tickets(id),
    
    -- Attendee Info (nullable for migration)
    full_name VARCHAR(255),
    email VARCHAR(255),
    phone VARCHAR(20),
    
    -- Ticket (nullable for migration)
    ticket_code VARCHAR(50) UNIQUE,
    qr_code VARCHAR(500),
    
    -- Status
    is_checked_in BOOLEAN DEFAULT false,
    checked_in_at TIMESTAMPTZ,
    checked_in_by UUID REFERENCES users(id),
    
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================
-- ZOEA CARD (Digital Wallet)
-- ============================================

-- Zoea Cards
CREATE TABLE zoea_cards (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) UNIQUE, -- nullable for migration
    
    card_number VARCHAR(16) UNIQUE, -- nullable for migration
    
    balance DECIMAL(12,2) DEFAULT 0,
    currency VARCHAR(3) DEFAULT 'RWF',
    
    status card_status DEFAULT 'active',
    
    -- Linked Payment Method
    linked_momo_number VARCHAR(20),
    linked_bank_account JSONB,
    
    -- Security
    pin_hash VARCHAR(255),
    pin_attempts INTEGER DEFAULT 0,
    pin_locked_until TIMESTAMPTZ,
    
    -- Limits
    daily_limit DECIMAL(12,2) DEFAULT 1000000,
    transaction_limit DECIMAL(12,2) DEFAULT 500000,
    
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Transactions
CREATE TABLE transactions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    card_id UUID REFERENCES zoea_cards(id), -- nullable for non-card transactions
    user_id UUID REFERENCES users(id), -- direct user reference for flexibility
    
    type transaction_type,
    amount DECIMAL(12,2),
    currency VARCHAR(3) DEFAULT 'RWF',
    
    -- Balance tracking (nullable for migration)
    balance_before DECIMAL(12,2),
    balance_after DECIMAL(12,2),
    
    description TEXT,
    reference VARCHAR(100),
    
    -- Related entities
    booking_id UUID REFERENCES bookings(id),
    merchant_id UUID REFERENCES merchant_profiles(id),
    
    status transaction_status DEFAULT 'completed',
    
    -- Metadata
    metadata JSONB,
    
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================
-- MERCHANT PAYOUTS & COMMISSIONS
-- ============================================

-- Commission Rules
CREATE TABLE commission_rules (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    
    name VARCHAR(100) NOT NULL,
    description TEXT,
    
    -- Applicability
    listing_type listing_type,
    category_id UUID REFERENCES categories(id),
    merchant_id UUID REFERENCES merchant_profiles(id), -- specific merchant override
    
    -- Rates
    percentage DECIMAL(5,2) NOT NULL,
    fixed_amount DECIMAL(10,2) DEFAULT 0,
    
    -- Validity
    valid_from DATE,
    valid_until DATE,
    
    is_active BOOLEAN DEFAULT true,
    priority INTEGER DEFAULT 0, -- higher = more specific
    
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Merchant Payouts
CREATE TABLE payouts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    merchant_id UUID NOT NULL REFERENCES merchant_profiles(id),
    
    payout_number VARCHAR(50) UNIQUE NOT NULL,
    
    -- Amount
    gross_amount DECIMAL(12,2) NOT NULL,
    commission_amount DECIMAL(10,2) NOT NULL,
    net_amount DECIMAL(12,2) NOT NULL,
    currency VARCHAR(3) DEFAULT 'RWF',
    
    -- Period
    period_start DATE NOT NULL,
    period_end DATE NOT NULL,
    
    -- Status
    status payment_status DEFAULT 'pending',
    
    -- Payment
    payment_method VARCHAR(50),
    payment_reference VARCHAR(255),
    paid_at TIMESTAMPTZ,
    
    -- Bookings included
    booking_ids UUID[],
    booking_count INTEGER,
    
    notes TEXT,
    
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================
-- REVIEWS & RATINGS
-- ============================================

CREATE TABLE reviews (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id), -- nullable for migration
    
    -- What is being reviewed (polymorphic) - all nullable
    listing_id UUID REFERENCES listings(id),
    event_id UUID REFERENCES events(id),
    tour_id UUID REFERENCES tours(id),
    booking_id UUID REFERENCES bookings(id),
    
    -- Review
    rating INTEGER CHECK (rating >= 1 AND rating <= 5), -- nullable for migration
    title VARCHAR(255),
    content TEXT,
    
    -- Detailed ratings
    ratings_breakdown JSONB, -- {"cleanliness": 5, "service": 4, "value": 4}
    
    -- Media
    images UUID[], -- references media
    
    -- Status
    status review_status DEFAULT 'pending',
    is_verified BOOLEAN DEFAULT false, -- verified purchase
    
    -- Response
    response TEXT,
    response_by UUID REFERENCES users(id),
    response_at TIMESTAMPTZ,
    
    -- Helpfulness
    helpful_count INTEGER DEFAULT 0,
    
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    deleted_at TIMESTAMPTZ
);

-- Review Helpfulness Votes
CREATE TABLE review_votes (
    user_id UUID NOT NULL REFERENCES users(id),
    review_id UUID NOT NULL REFERENCES reviews(id) ON DELETE CASCADE,
    is_helpful BOOLEAN NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    PRIMARY KEY (user_id, review_id)
);

-- ============================================
-- SOCIAL FEATURES
-- ============================================

-- User Follows (for organizers, merchants)
CREATE TABLE user_follows (
    follower_id UUID NOT NULL REFERENCES users(id),
    following_id UUID NOT NULL REFERENCES users(id),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    PRIMARY KEY (follower_id, following_id)
);

-- Favorites/Wishlists
CREATE TABLE favorites (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id),
    
    -- What is favorited (polymorphic)
    listing_id UUID REFERENCES listings(id),
    event_id UUID REFERENCES events(id),
    tour_id UUID REFERENCES tours(id),
    
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    
    UNIQUE(user_id, listing_id),
    UNIQUE(user_id, event_id),
    UNIQUE(user_id, tour_id)
);

-- Event Likes
CREATE TABLE event_likes (
    user_id UUID NOT NULL REFERENCES users(id),
    event_id UUID NOT NULL REFERENCES events(id),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    PRIMARY KEY (user_id, event_id)
);

-- Event Comments
CREATE TABLE event_comments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    event_id UUID NOT NULL REFERENCES events(id),
    user_id UUID NOT NULL REFERENCES users(id),
    parent_id UUID REFERENCES event_comments(id),
    
    content TEXT NOT NULL,
    
    like_count INTEGER DEFAULT 0,
    is_pinned BOOLEAN DEFAULT false,
    is_hidden BOOLEAN DEFAULT false,
    
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    deleted_at TIMESTAMPTZ
);

-- Comment Likes
CREATE TABLE comment_likes (
    user_id UUID NOT NULL REFERENCES users(id),
    comment_id UUID NOT NULL REFERENCES event_comments(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    PRIMARY KEY (user_id, comment_id)
);

-- ============================================
-- REFERRALS
-- ============================================

-- Referral Codes
CREATE TABLE referral_codes (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) UNIQUE,
    code VARCHAR(20) UNIQUE NOT NULL,
    
    -- Stats
    total_referrals INTEGER DEFAULT 0,
    successful_referrals INTEGER DEFAULT 0,
    total_earnings DECIMAL(12,2) DEFAULT 0,
    
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Referrals
CREATE TABLE referrals (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    referrer_id UUID NOT NULL REFERENCES users(id),
    referred_id UUID NOT NULL REFERENCES users(id) UNIQUE,
    referral_code_id UUID NOT NULL REFERENCES referral_codes(id),
    
    -- Status
    is_successful BOOLEAN DEFAULT false, -- completed qualifying action
    qualified_at TIMESTAMPTZ,
    
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Referral Rewards
CREATE TABLE referral_rewards (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    referral_id UUID NOT NULL REFERENCES referrals(id),
    user_id UUID NOT NULL REFERENCES users(id), -- who receives the reward
    
    reward_type VARCHAR(50) NOT NULL, -- 'cash', 'credit', 'discount'
    amount DECIMAL(10,2) NOT NULL,
    currency VARCHAR(3) DEFAULT 'RWF',
    
    status referral_reward_status DEFAULT 'pending',
    credited_at TIMESTAMPTZ,
    expires_at TIMESTAMPTZ,
    
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================
-- NOTIFICATIONS
-- ============================================

-- Notification Templates
CREATE TABLE notification_templates (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    
    code VARCHAR(100) UNIQUE NOT NULL, -- 'booking_confirmed', 'event_reminder', etc.
    name VARCHAR(255) NOT NULL,
    description TEXT,
    
    type notification_type NOT NULL,
    
    -- Templates (supports variables like {{user_name}}, {{booking_id}})
    title_template VARCHAR(255) NOT NULL,
    body_template TEXT NOT NULL,
    email_subject_template VARCHAR(255),
    email_body_template TEXT,
    sms_template VARCHAR(500),
    
    -- Default channels
    send_push BOOLEAN DEFAULT true,
    send_email BOOLEAN DEFAULT false,
    send_sms BOOLEAN DEFAULT false,
    
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Scheduled Notifications
CREATE TABLE scheduled_notifications (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    
    template_id UUID REFERENCES notification_templates(id),
    
    -- Target
    user_id UUID REFERENCES users(id), -- specific user
    user_segment JSONB, -- or segment criteria {"roles": ["merchant"], "city": "Kigali"}
    
    -- Content (overrides template if provided)
    title VARCHAR(255),
    body TEXT,
    
    -- Schedule
    scheduled_at TIMESTAMPTZ NOT NULL,
    timezone VARCHAR(50) DEFAULT 'Africa/Kigali',
    
    -- Recurrence
    is_recurring BOOLEAN DEFAULT false,
    recurrence_rule VARCHAR(100), -- RRULE format: 'FREQ=DAILY;INTERVAL=1'
    recurrence_end TIMESTAMPTZ,
    
    -- Related entities
    event_id UUID REFERENCES events(id),
    booking_id UUID REFERENCES bookings(id),
    promotion_id UUID REFERENCES promotions(id),
    
    -- Status
    status VARCHAR(20) DEFAULT 'pending', -- 'pending', 'sent', 'failed', 'cancelled'
    sent_at TIMESTAMPTZ,
    error_message TEXT,
    
    -- Stats
    recipients_count INTEGER DEFAULT 0,
    delivered_count INTEGER DEFAULT 0,
    opened_count INTEGER DEFAULT 0,
    clicked_count INTEGER DEFAULT 0,
    
    created_by UUID REFERENCES users(id),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- User Notifications (delivered notifications)
CREATE TABLE notifications (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id), -- nullable for broadcast notifications
    
    template_id UUID REFERENCES notification_templates(id),
    scheduled_id UUID REFERENCES scheduled_notifications(id),
    
    type notification_type,
    title VARCHAR(255),
    body TEXT,
    
    -- Deep link
    action_url VARCHAR(500),
    action_data JSONB, -- additional data for the action
    
    -- Related entities
    booking_id UUID REFERENCES bookings(id),
    event_id UUID REFERENCES events(id),
    listing_id UUID REFERENCES listings(id),
    
    -- Delivery status
    is_read BOOLEAN DEFAULT false,
    read_at TIMESTAMPTZ,
    
    push_sent BOOLEAN DEFAULT false,
    push_sent_at TIMESTAMPTZ,
    push_delivered BOOLEAN DEFAULT false,
    push_clicked BOOLEAN DEFAULT false,
    
    email_sent BOOLEAN DEFAULT false,
    email_sent_at TIMESTAMPTZ,
    email_opened BOOLEAN DEFAULT false,
    
    sms_sent BOOLEAN DEFAULT false,
    sms_sent_at TIMESTAMPTZ,
    
    -- Expiry
    expires_at TIMESTAMPTZ,
    
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Notification Preferences (per notification type)
CREATE TABLE notification_preferences (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id),
    notification_type notification_type NOT NULL,
    
    push_enabled BOOLEAN DEFAULT true,
    email_enabled BOOLEAN DEFAULT true,
    sms_enabled BOOLEAN DEFAULT false,
    
    -- Quiet hours
    quiet_hours_start TIME,
    quiet_hours_end TIME,
    
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    
    UNIQUE(user_id, notification_type)
);

-- ============================================
-- CONTENT MODERATION / APPROVAL WORKFLOW
-- ============================================

CREATE TYPE approval_status AS ENUM ('pending', 'approved', 'rejected', 'revision_requested');
CREATE TYPE content_type AS ENUM ('event', 'listing', 'notification', 'review', 'promotion', 'merchant', 'organizer', 'tour_operator');

-- Business/Organizer Notification Requests (push notifications from merchants)
CREATE TABLE notification_requests (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    
    -- Who is requesting
    requester_id UUID NOT NULL REFERENCES users(id),
    merchant_id UUID REFERENCES merchant_profiles(id),
    organizer_id UUID REFERENCES organizer_profiles(id),
    
    -- Content
    title VARCHAR(255) NOT NULL,
    body TEXT NOT NULL,
    image_id UUID REFERENCES media(id),
    action_url VARCHAR(500),
    
    -- Target audience
    target_type VARCHAR(50) NOT NULL, -- 'all_users', 'followers', 'past_customers', 'segment'
    target_segment JSONB, -- {"city": "Kigali", "interests": ["music"]}
    estimated_reach INTEGER,
    
    -- Schedule
    scheduled_at TIMESTAMPTZ,
    expires_at TIMESTAMPTZ,
    
    -- Approval
    status approval_status DEFAULT 'pending',
    reviewed_by UUID REFERENCES users(id),
    reviewed_at TIMESTAMPTZ,
    rejection_reason TEXT,
    revision_notes TEXT,
    
    -- After approval
    sent_at TIMESTAMPTZ,
    delivered_count INTEGER DEFAULT 0,
    opened_count INTEGER DEFAULT 0,
    
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Content Approval Queue (unified approval for events, listings, etc.)
CREATE TABLE content_approvals (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    
    content_type content_type NOT NULL,
    content_id UUID NOT NULL, -- references events.id, listings.id, etc.
    
    -- Submitter
    submitted_by UUID NOT NULL REFERENCES users(id),
    submitted_at TIMESTAMPTZ DEFAULT NOW(),
    
    -- Version tracking
    version INTEGER DEFAULT 1,
    changes_summary TEXT, -- what changed from previous version
    snapshot JSONB, -- snapshot of content at submission time
    
    -- Approval workflow
    status approval_status DEFAULT 'pending',
    priority VARCHAR(20) DEFAULT 'normal', -- 'low', 'normal', 'high', 'urgent'
    
    -- Review
    assigned_to UUID REFERENCES users(id),
    reviewed_by UUID REFERENCES users(id),
    reviewed_at TIMESTAMPTZ,
    
    -- Feedback
    rejection_reason TEXT,
    revision_notes TEXT,
    internal_notes TEXT, -- admin-only notes
    
    -- Auto-approval rules
    auto_approved BOOLEAN DEFAULT false,
    auto_approval_reason VARCHAR(255),
    
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Approval History (audit trail)
CREATE TABLE approval_history (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    approval_id UUID NOT NULL REFERENCES content_approvals(id) ON DELETE CASCADE,
    
    action VARCHAR(50) NOT NULL, -- 'submitted', 'assigned', 'approved', 'rejected', 'revision_requested', 'resubmitted'
    from_status approval_status,
    to_status approval_status,
    
    performed_by UUID NOT NULL REFERENCES users(id),
    notes TEXT,
    
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Moderation Rules (auto-approval criteria)
CREATE TABLE moderation_rules (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    
    name VARCHAR(100) NOT NULL,
    description TEXT,
    
    content_type content_type NOT NULL,
    
    -- Conditions (JSONB for flexibility)
    conditions JSONB NOT NULL, 
    -- e.g., {"merchant_verified": true, "past_approvals_count": {"gte": 5}, "content_flags": {"eq": 0}}
    
    -- Action
    action VARCHAR(50) NOT NULL, -- 'auto_approve', 'auto_reject', 'flag_for_review', 'assign_to'
    action_params JSONB, -- {"assign_to_user_id": "..."}
    
    priority INTEGER DEFAULT 0, -- higher = checked first
    is_active BOOLEAN DEFAULT true,
    
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Flagged Content (user reports)
CREATE TABLE content_flags (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    
    content_type content_type NOT NULL,
    content_id UUID NOT NULL,
    
    -- Reporter
    reported_by UUID NOT NULL REFERENCES users(id),
    
    -- Reason
    reason VARCHAR(50) NOT NULL, -- 'spam', 'inappropriate', 'misleading', 'copyright', 'other'
    description TEXT,
    
    -- Status
    status VARCHAR(20) DEFAULT 'pending', -- 'pending', 'reviewed', 'action_taken', 'dismissed'
    
    -- Review
    reviewed_by UUID REFERENCES users(id),
    reviewed_at TIMESTAMPTZ,
    action_taken VARCHAR(100),
    
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================
-- SEARCH & DISCOVERY
-- ============================================

-- Search History
CREATE TABLE search_history (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id),
    session_id VARCHAR(100),
    
    query TEXT NOT NULL,
    filters JSONB,
    result_count INTEGER,
    
    -- Location context
    location GEOGRAPHY(POINT, 4326),
    
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Recently Viewed
CREATE TABLE recently_viewed (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id),
    
    -- What was viewed (polymorphic)
    listing_id UUID REFERENCES listings(id),
    event_id UUID REFERENCES events(id),
    tour_id UUID REFERENCES tours(id),
    
    view_count INTEGER DEFAULT 1,
    last_viewed_at TIMESTAMPTZ DEFAULT NOW(),
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Visited Places (Check-ins / Places user has been to)
CREATE TABLE visited_places (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id),
    listing_id UUID NOT NULL REFERENCES listings(id),
    booking_id UUID REFERENCES bookings(id),
    
    visited_at TIMESTAMPTZ DEFAULT NOW(),
    notes TEXT,
    
    -- Verification
    is_verified BOOLEAN DEFAULT false, -- verified via booking or check-in
    verified_at TIMESTAMPTZ,
    
    created_at TIMESTAMPTZ DEFAULT NOW(),
    
    UNIQUE(user_id, listing_id, visited_at::DATE)
);

-- User Location History (for "Near Me" features)
CREATE TABLE user_locations (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id),
    location GEOGRAPHY(POINT, 4326) NOT NULL,
    accuracy DECIMAL(10,2), -- meters
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Password Reset Tokens
CREATE TABLE password_reset_tokens (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id),
    token VARCHAR(255) UNIQUE NOT NULL,
    expires_at TIMESTAMPTZ NOT NULL,
    used_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Email Verification Tokens
CREATE TABLE email_verification_tokens (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id),
    email VARCHAR(255) NOT NULL,
    token VARCHAR(255) UNIQUE NOT NULL,
    expires_at TIMESTAMPTZ NOT NULL,
    verified_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================
-- PROMOTIONS & OFFERS
-- ============================================

CREATE TABLE promotions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    
    name VARCHAR(255) NOT NULL,
    slug VARCHAR(255) UNIQUE NOT NULL,
    description TEXT,
    
    -- Type
    discount_type VARCHAR(20) NOT NULL, -- 'percentage', 'fixed', 'bogo'
    discount_value DECIMAL(10,2) NOT NULL,
    
    -- Geographic scope
    country_ids UUID[], -- references countries
    city_ids UUID[], -- references cities
    
    -- Applicability
    applicable_types listing_type[],
    listing_ids UUID[],
    merchant_ids UUID[],
    
    -- Codes
    promo_code VARCHAR(50) UNIQUE,
    
    -- Limits
    max_uses INTEGER,
    used_count INTEGER DEFAULT 0,
    max_uses_per_user INTEGER DEFAULT 1,
    min_order_amount DECIMAL(10,2),
    max_discount_amount DECIMAL(10,2),
    
    -- Validity
    start_date TIMESTAMPTZ NOT NULL,
    end_date TIMESTAMPTZ NOT NULL,
    
    -- Media
    image_id UUID REFERENCES media(id),
    
    is_active BOOLEAN DEFAULT true,
    is_featured BOOLEAN DEFAULT false,
    
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- User Promotion Usage
CREATE TABLE promotion_uses (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    promotion_id UUID NOT NULL REFERENCES promotions(id),
    user_id UUID NOT NULL REFERENCES users(id),
    booking_id UUID REFERENCES bookings(id),
    
    discount_amount DECIMAL(10,2) NOT NULL,
    
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================
-- SYSTEM & CONFIG
-- ============================================

-- App Configuration
CREATE TABLE app_config (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    key VARCHAR(100) UNIQUE NOT NULL,
    value JSONB NOT NULL,
    description TEXT,
    is_public BOOLEAN DEFAULT false, -- can be fetched by app
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- FAQ Categories
CREATE TABLE faq_categories (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(100) NOT NULL,
    slug VARCHAR(100) UNIQUE NOT NULL,
    icon VARCHAR(50),
    sort_order INTEGER DEFAULT 0,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- FAQs (Help Center)
CREATE TABLE faqs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    category_id UUID REFERENCES faq_categories(id),
    question TEXT NOT NULL,
    answer TEXT NOT NULL,
    sort_order INTEGER DEFAULT 0,
    is_active BOOLEAN DEFAULT true,
    view_count INTEGER DEFAULT 0,
    helpful_count INTEGER DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Support Tickets (Live Chat / Contact Support)
CREATE TABLE support_tickets (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id),
    ticket_number VARCHAR(20) UNIQUE NOT NULL,
    
    subject VARCHAR(255) NOT NULL,
    category VARCHAR(50), -- 'account', 'payment', 'booking', 'technical', 'other'
    priority VARCHAR(20) DEFAULT 'normal', -- 'low', 'normal', 'high', 'urgent'
    status VARCHAR(20) DEFAULT 'open', -- 'open', 'in_progress', 'waiting', 'resolved', 'closed'
    
    -- Assignment
    assigned_to UUID REFERENCES users(id),
    
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    resolved_at TIMESTAMPTZ,
    closed_at TIMESTAMPTZ
);

-- Support Ticket Messages
CREATE TABLE support_messages (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    ticket_id UUID NOT NULL REFERENCES support_tickets(id) ON DELETE CASCADE,
    sender_id UUID NOT NULL REFERENCES users(id),
    
    message TEXT NOT NULL,
    attachments UUID[], -- references media
    
    is_internal BOOLEAN DEFAULT false, -- internal notes not visible to user
    is_read BOOLEAN DEFAULT false,
    
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Coupons/Discount Codes (separate from promotions for direct user input)
CREATE TABLE coupons (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    code VARCHAR(50) UNIQUE NOT NULL,
    
    name VARCHAR(100) NOT NULL,
    description TEXT,
    
    -- Discount
    discount_type VARCHAR(20) NOT NULL, -- 'percentage', 'fixed'
    discount_value DECIMAL(10,2) NOT NULL,
    max_discount_amount DECIMAL(10,2),
    min_order_amount DECIMAL(10,2),
    
    -- Geographic scope
    country_ids UUID[], -- references countries
    city_ids UUID[], -- references cities
    
    -- Applicability
    applicable_types listing_type[],
    listing_ids UUID[],
    user_ids UUID[], -- specific users only
    
    -- Limits
    max_uses INTEGER,
    max_uses_per_user INTEGER DEFAULT 1,
    used_count INTEGER DEFAULT 0,
    
    -- Validity
    start_date TIMESTAMPTZ NOT NULL,
    end_date TIMESTAMPTZ NOT NULL,
    
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Coupon Usage
CREATE TABLE coupon_uses (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    coupon_id UUID NOT NULL REFERENCES coupons(id),
    user_id UUID NOT NULL REFERENCES users(id),
    booking_id UUID REFERENCES bookings(id),
    
    discount_amount DECIMAL(10,2) NOT NULL,
    
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- User Payment Methods (saved cards, mobile money)
CREATE TABLE user_payment_methods (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id),
    
    type payment_method NOT NULL,
    
    -- Card details (tokenized)
    card_last_four VARCHAR(4),
    card_brand VARCHAR(20), -- 'visa', 'mastercard', etc.
    card_expiry_month INTEGER,
    card_expiry_year INTEGER,
    card_token VARCHAR(255), -- payment gateway token
    
    -- Mobile Money
    momo_number VARCHAR(20),
    momo_provider VARCHAR(50), -- 'mtn', 'airtel'
    
    -- Bank
    bank_name VARCHAR(100),
    bank_account_number VARCHAR(50),
    
    is_default BOOLEAN DEFAULT false,
    is_verified BOOLEAN DEFAULT false,
    
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Currency Exchange Rates
CREATE TABLE exchange_rates (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    from_currency VARCHAR(3) NOT NULL,
    to_currency VARCHAR(3) NOT NULL,
    rate DECIMAL(15,6) NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(from_currency, to_currency)
);

-- Weather Data Cache
CREATE TABLE weather_cache (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    city VARCHAR(100) NOT NULL,
    country VARCHAR(100) NOT NULL,
    
    temperature DECIMAL(5,2),
    condition VARCHAR(50),
    icon VARCHAR(50),
    humidity INTEGER,
    wind_speed DECIMAL(5,2),
    
    forecast JSONB,
    
    fetched_at TIMESTAMPTZ DEFAULT NOW(),
    expires_at TIMESTAMPTZ NOT NULL,
    
    UNIQUE(city, country)
);

-- Audit Log
CREATE TABLE audit_logs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    
    user_id UUID REFERENCES users(id),
    action VARCHAR(50) NOT NULL,
    entity_type VARCHAR(50) NOT NULL,
    entity_id UUID,
    
    old_values JSONB,
    new_values JSONB,
    
    ip_address INET,
    user_agent TEXT,
    
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================
-- ANALYTICS & REPORTING
-- ============================================

-- Profile Viewers (who viewed whose profile)
CREATE TABLE profile_views (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    
    -- Whose profile was viewed
    profile_user_id UUID NOT NULL REFERENCES users(id),
    
    -- Who viewed (null for anonymous)
    viewer_user_id UUID REFERENCES users(id),
    session_id VARCHAR(100),
    
    -- Context
    source VARCHAR(50), -- 'search', 'event', 'listing', 'recommendation'
    referrer_type content_type,
    referrer_id UUID,
    
    -- Device info
    device_type VARCHAR(20),
    ip_address INET,
    
    -- Location
    location GEOGRAPHY(POINT, 4326),
    city_id UUID REFERENCES cities(id),
    country_id UUID REFERENCES countries(id),
    
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Page/Content Views (granular tracking)
CREATE TABLE content_views (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    
    -- What was viewed
    content_type content_type NOT NULL,
    content_id UUID NOT NULL,
    
    -- Who viewed
    user_id UUID REFERENCES users(id),
    session_id VARCHAR(100), -- for anonymous users
    
    -- Viewer demographics (denormalized for analytics)
    viewer_age_range VARCHAR(20), -- '18-24', '25-34', etc.
    viewer_gender VARCHAR(20),
    viewer_interests TEXT[],
    viewer_profession VARCHAR(100),
    
    -- Context
    source VARCHAR(50), -- 'search', 'home', 'category', 'recommendation', 'share', 'direct'
    referrer VARCHAR(500),
    
    -- Device info
    device_type VARCHAR(20), -- 'mobile', 'tablet', 'desktop'
    os VARCHAR(50),
    browser VARCHAR(50),
    app_version VARCHAR(20),
    ip_address INET,
    
    -- Location
    location GEOGRAPHY(POINT, 4326),
    city_id UUID REFERENCES cities(id),
    country_id UUID REFERENCES countries(id),
    
    -- Duration & Engagement
    duration_seconds INTEGER,
    scroll_depth INTEGER, -- percentage
    clicked_book BOOLEAN DEFAULT false,
    clicked_contact BOOLEAN DEFAULT false,
    added_to_favorites BOOLEAN DEFAULT false,
    
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Daily Aggregated Stats (for fast reporting)
CREATE TABLE daily_stats (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    
    date DATE NOT NULL,
    content_type content_type NOT NULL,
    content_id UUID NOT NULL,
    
    -- Views
    view_count INTEGER DEFAULT 0,
    unique_viewers INTEGER DEFAULT 0,
    
    -- Engagement
    like_count INTEGER DEFAULT 0,
    share_count INTEGER DEFAULT 0,
    comment_count INTEGER DEFAULT 0,
    favorite_count INTEGER DEFAULT 0,
    
    -- Bookings (for listings/events/tours)
    booking_count INTEGER DEFAULT 0,
    booking_revenue DECIMAL(15,2) DEFAULT 0,
    
    -- Reviews
    review_count INTEGER DEFAULT 0,
    average_rating DECIMAL(3,2),
    
    created_at TIMESTAMPTZ DEFAULT NOW(),
    
    UNIQUE(date, content_type, content_id)
);

-- Platform-wide Daily Stats
CREATE TABLE platform_daily_stats (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    date DATE UNIQUE NOT NULL,
    
    -- Users
    new_users INTEGER DEFAULT 0,
    active_users INTEGER DEFAULT 0,
    returning_users INTEGER DEFAULT 0,
    
    -- Merchants
    new_merchants INTEGER DEFAULT 0,
    pending_merchants INTEGER DEFAULT 0,
    approved_merchants INTEGER DEFAULT 0,
    
    -- Events
    new_events INTEGER DEFAULT 0,
    pending_events INTEGER DEFAULT 0,
    published_events INTEGER DEFAULT 0,
    
    -- Bookings
    total_bookings INTEGER DEFAULT 0,
    completed_bookings INTEGER DEFAULT 0,
    cancelled_bookings INTEGER DEFAULT 0,
    
    -- Revenue
    gross_revenue DECIMAL(15,2) DEFAULT 0,
    commission_revenue DECIMAL(15,2) DEFAULT 0,
    refunds DECIMAL(15,2) DEFAULT 0,
    
    -- Transactions
    total_transactions INTEGER DEFAULT 0,
    zoea_card_transactions INTEGER DEFAULT 0,
    momo_transactions INTEGER DEFAULT 0,
    
    -- Engagement
    total_views INTEGER DEFAULT 0,
    total_searches INTEGER DEFAULT 0,
    total_reviews INTEGER DEFAULT 0,
    
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Search Analytics
CREATE TABLE search_analytics (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    
    user_id UUID REFERENCES users(id),
    session_id VARCHAR(100),
    
    query TEXT NOT NULL,
    filters JSONB,
    
    -- Results
    result_count INTEGER,
    clicked_result_id UUID,
    clicked_result_type content_type,
    clicked_position INTEGER,
    
    -- Context
    source VARCHAR(50), -- 'home', 'explore', 'events', etc.
    location GEOGRAPHY(POINT, 4326),
    
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Conversion Funnel Tracking
CREATE TABLE funnel_events (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    
    user_id UUID REFERENCES users(id),
    session_id VARCHAR(100) NOT NULL,
    
    -- Funnel
    funnel_name VARCHAR(50) NOT NULL, -- 'booking', 'registration', 'event_ticket'
    step_name VARCHAR(50) NOT NULL, -- 'view', 'select_date', 'payment', 'confirm'
    step_number INTEGER NOT NULL,
    
    -- Context
    content_type content_type,
    content_id UUID,
    
    -- Outcome
    completed BOOLEAN DEFAULT false,
    dropped_off BOOLEAN DEFAULT false,
    
    metadata JSONB,
    
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Revenue Reports (monthly aggregation)
CREATE TABLE monthly_revenue_reports (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    
    year INTEGER NOT NULL,
    month INTEGER NOT NULL,
    
    -- By category
    category_breakdown JSONB, -- {"hotel": 1000000, "restaurant": 500000, ...}
    
    -- By merchant (top performers)
    top_merchants JSONB, -- [{"merchant_id": "...", "revenue": 100000}, ...]
    
    -- Totals
    gross_revenue DECIMAL(15,2) DEFAULT 0,
    commission_revenue DECIMAL(15,2) DEFAULT 0,
    refunds DECIMAL(15,2) DEFAULT 0,
    net_revenue DECIMAL(15,2) DEFAULT 0,
    
    -- Comparisons
    revenue_growth_percentage DECIMAL(5,2),
    booking_growth_percentage DECIMAL(5,2),
    
    -- Bookings
    total_bookings INTEGER DEFAULT 0,
    average_booking_value DECIMAL(10,2),
    
    created_at TIMESTAMPTZ DEFAULT NOW(),
    
    UNIQUE(year, month)
);

-- Merchant Performance Reports
CREATE TABLE merchant_reports (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    
    merchant_id UUID NOT NULL REFERENCES merchant_profiles(id),
    report_type VARCHAR(20) NOT NULL, -- 'daily', 'weekly', 'monthly'
    period_start DATE NOT NULL,
    period_end DATE NOT NULL,
    
    -- Views & Engagement
    total_views INTEGER DEFAULT 0,
    unique_visitors INTEGER DEFAULT 0,
    profile_views INTEGER DEFAULT 0,
    listing_views JSONB, -- {"listing_id": views, ...}
    
    -- Bookings
    total_bookings INTEGER DEFAULT 0,
    completed_bookings INTEGER DEFAULT 0,
    cancelled_bookings INTEGER DEFAULT 0,
    no_show_bookings INTEGER DEFAULT 0,
    
    -- Revenue
    gross_revenue DECIMAL(15,2) DEFAULT 0,
    commission_paid DECIMAL(10,2) DEFAULT 0,
    net_revenue DECIMAL(15,2) DEFAULT 0,
    refunds DECIMAL(10,2) DEFAULT 0,
    
    -- Reviews
    new_reviews INTEGER DEFAULT 0,
    average_rating DECIMAL(3,2),
    
    -- Comparison to previous period
    revenue_change_percentage DECIMAL(5,2),
    booking_change_percentage DECIMAL(5,2),
    rating_change DECIMAL(3,2),
    
    created_at TIMESTAMPTZ DEFAULT NOW(),
    
    UNIQUE(merchant_id, report_type, period_start)
);

-- Event Performance Reports
CREATE TABLE event_reports (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    
    event_id UUID NOT NULL REFERENCES events(id),
    
    -- Views
    total_views INTEGER DEFAULT 0,
    unique_visitors INTEGER DEFAULT 0,
    
    -- Tickets
    tickets_sold INTEGER DEFAULT 0,
    tickets_available INTEGER DEFAULT 0,
    ticket_revenue DECIMAL(15,2) DEFAULT 0,
    
    -- By ticket type
    ticket_breakdown JSONB, -- {"vip": {"sold": 10, "revenue": 50000}, ...}
    
    -- Attendance
    checked_in_count INTEGER DEFAULT 0,
    no_show_count INTEGER DEFAULT 0,
    
    -- Engagement
    likes INTEGER DEFAULT 0,
    shares INTEGER DEFAULT 0,
    comments INTEGER DEFAULT 0,
    
    -- Traffic sources
    traffic_sources JSONB, -- {"direct": 100, "search": 50, "social": 30}
    
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Popular/Trending Content (cached rankings)
CREATE TABLE trending_content (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    
    content_type content_type NOT NULL,
    content_id UUID NOT NULL,
    
    -- Ranking
    rank INTEGER NOT NULL,
    score DECIMAL(10,2) NOT NULL, -- calculated score
    
    -- Metrics used for ranking
    views_24h INTEGER DEFAULT 0,
    views_7d INTEGER DEFAULT 0,
    bookings_24h INTEGER DEFAULT 0,
    bookings_7d INTEGER DEFAULT 0,
    engagement_score DECIMAL(10,2) DEFAULT 0,
    
    -- Context
    category VARCHAR(50), -- for category-specific rankings
    city VARCHAR(100), -- for location-specific rankings
    
    period VARCHAR(20) NOT NULL, -- 'hourly', 'daily', 'weekly'
    
    created_at TIMESTAMPTZ DEFAULT NOW(),
    expires_at TIMESTAMPTZ NOT NULL,
    
    UNIQUE(content_type, content_id, period, category, city)
);

-- User Activity Summary (for personalization)
CREATE TABLE user_activity_summary (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) UNIQUE,
    
    -- Interests (inferred from behavior)
    interests JSONB, -- {"categories": ["music", "food"], "price_range": "mid", ...}
    
    -- Activity
    total_views INTEGER DEFAULT 0,
    total_bookings INTEGER DEFAULT 0,
    total_spent DECIMAL(15,2) DEFAULT 0,
    total_reviews INTEGER DEFAULT 0,
    
    -- Favorites
    favorite_categories TEXT[],
    favorite_locations TEXT[],
    
    -- Engagement
    last_active_at TIMESTAMPTZ,
    avg_session_duration INTEGER, -- seconds
    
    -- Lifecycle
    first_booking_at TIMESTAMPTZ,
    last_booking_at TIMESTAMPTZ,
    days_since_last_booking INTEGER,
    
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Admin Dashboard Widgets (cached data)
CREATE TABLE dashboard_widgets (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    
    widget_key VARCHAR(100) UNIQUE NOT NULL,
    title VARCHAR(255) NOT NULL,
    
    data JSONB NOT NULL,
    
    -- Cache
    cached_at TIMESTAMPTZ DEFAULT NOW(),
    expires_at TIMESTAMPTZ NOT NULL,
    refresh_interval INTEGER DEFAULT 300 -- seconds
);

-- ============================================
-- INDEXES
-- ============================================

-- Countries & Cities
CREATE INDEX idx_countries_code ON countries(code);
CREATE INDEX idx_countries_active ON countries(is_active) WHERE is_active = true;
CREATE INDEX idx_cities_country ON cities(country_id);
CREATE INDEX idx_cities_location ON cities USING GIST(location);
CREATE INDEX idx_cities_active ON cities(is_active) WHERE is_active = true;
CREATE INDEX idx_districts_city ON districts(city_id);
CREATE INDEX idx_regions_country ON regions(country_id);

-- Users
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_phone ON users(phone_number);
CREATE INDEX idx_users_username ON users(username);
CREATE INDEX idx_users_roles ON users USING GIN(roles);
CREATE INDEX idx_users_active ON users(is_active) WHERE deleted_at IS NULL;
CREATE INDEX idx_users_country ON users(country_id);
CREATE INDEX idx_users_city ON users(city_id);
CREATE INDEX idx_users_interests ON users USING GIN(interests);

-- Business Registration Approvals
CREATE INDEX idx_merchant_profiles_status ON merchant_profiles(registration_status);
CREATE INDEX idx_merchant_profiles_user ON merchant_profiles(user_id);
CREATE INDEX idx_merchant_profiles_country ON merchant_profiles(country_id);
CREATE INDEX idx_merchant_profiles_city ON merchant_profiles(city_id);
CREATE INDEX idx_organizer_profiles_status ON organizer_profiles(registration_status);
CREATE INDEX idx_organizer_profiles_user ON organizer_profiles(user_id);
CREATE INDEX idx_tour_operator_profiles_status ON tour_operator_profiles(registration_status);
CREATE INDEX idx_tour_operator_profiles_user ON tour_operator_profiles(user_id);
CREATE INDEX idx_tour_operator_profiles_country ON tour_operator_profiles(country_id);

-- Listings
CREATE INDEX idx_listings_merchant ON listings(merchant_id);
CREATE INDEX idx_listings_type ON listings(type);
CREATE INDEX idx_listings_status ON listings(status);
CREATE INDEX idx_listings_location ON listings USING GIST(location);
CREATE INDEX idx_listings_featured ON listings(is_featured) WHERE is_featured = true;
CREATE INDEX idx_listings_search ON listings USING GIN(to_tsvector('english', name || ' ' || COALESCE(description, '')));
CREATE INDEX idx_listings_country ON listings(country_id);
CREATE INDEX idx_listings_city ON listings(city_id);

-- Events
CREATE INDEX idx_events_organizer ON events(organizer_id);
CREATE INDEX idx_events_dates ON events(start_date, end_date);
CREATE INDEX idx_events_location ON events USING GIST(location);
CREATE INDEX idx_events_status ON events(status);
CREATE INDEX idx_events_search ON events USING GIN(to_tsvector('english', name || ' ' || COALESCE(description, '')));
CREATE INDEX idx_events_country ON events(country_id);
CREATE INDEX idx_events_city ON events(city_id);

-- Tours
CREATE INDEX idx_tours_operator ON tours(operator_id);
CREATE INDEX idx_tours_location ON tours USING GIST(start_location);
CREATE INDEX idx_tours_status ON tours(status);
CREATE INDEX idx_tours_country ON tours(country_id);
CREATE INDEX idx_tours_city ON tours(city_id);

-- User Content Preferences
CREATE INDEX idx_user_content_preferences_user ON user_content_preferences(user_id);

-- Reviews
CREATE INDEX idx_reviews_status ON reviews(status);

-- Bookings
CREATE INDEX idx_bookings_user ON bookings(user_id);
CREATE INDEX idx_bookings_listing ON bookings(listing_id);
CREATE INDEX idx_bookings_event ON bookings(event_id);
CREATE INDEX idx_bookings_tour ON bookings(tour_id);
CREATE INDEX idx_bookings_status ON bookings(status);
CREATE INDEX idx_bookings_dates ON bookings(check_in_date, check_out_date);
CREATE INDEX idx_bookings_number ON bookings(booking_number);

-- Transactions
CREATE INDEX idx_transactions_card ON transactions(card_id);
CREATE INDEX idx_transactions_created ON transactions(created_at);

-- Reviews
CREATE INDEX idx_reviews_listing ON reviews(listing_id);
CREATE INDEX idx_reviews_event ON reviews(event_id);
CREATE INDEX idx_reviews_tour ON reviews(tour_id);
CREATE INDEX idx_reviews_user ON reviews(user_id);

-- Notifications
CREATE INDEX idx_notifications_user ON notifications(user_id);
CREATE INDEX idx_notifications_unread ON notifications(user_id, is_read) WHERE is_read = false;
CREATE INDEX idx_notifications_type ON notifications(type);

-- Scheduled Notifications
CREATE INDEX idx_scheduled_notifications_status ON scheduled_notifications(status);
CREATE INDEX idx_scheduled_notifications_scheduled ON scheduled_notifications(scheduled_at) WHERE status = 'pending';

-- Notification Preferences
CREATE INDEX idx_notification_preferences_user ON notification_preferences(user_id);

-- Notification Requests
CREATE INDEX idx_notification_requests_status ON notification_requests(status);
CREATE INDEX idx_notification_requests_requester ON notification_requests(requester_id);

-- Content Approvals
CREATE INDEX idx_content_approvals_status ON content_approvals(status);
CREATE INDEX idx_content_approvals_type ON content_approvals(content_type, content_id);
CREATE INDEX idx_content_approvals_pending ON content_approvals(status, priority) WHERE status = 'pending';
CREATE INDEX idx_content_approvals_assigned ON content_approvals(assigned_to) WHERE status = 'pending';

-- Content Flags
CREATE INDEX idx_content_flags_status ON content_flags(status);
CREATE INDEX idx_content_flags_content ON content_flags(content_type, content_id);

-- Profile Views
CREATE INDEX idx_profile_views_profile ON profile_views(profile_user_id);
CREATE INDEX idx_profile_views_viewer ON profile_views(viewer_user_id);
CREATE INDEX idx_profile_views_created ON profile_views(created_at);

-- Analytics
CREATE INDEX idx_content_views_content ON content_views(content_type, content_id);
CREATE INDEX idx_content_views_user ON content_views(user_id);
CREATE INDEX idx_content_views_created ON content_views(created_at);
CREATE INDEX idx_content_views_country ON content_views(country_id);
CREATE INDEX idx_content_views_city ON content_views(city_id);
CREATE INDEX idx_daily_stats_date ON daily_stats(date);
CREATE INDEX idx_daily_stats_content ON daily_stats(content_type, content_id);
CREATE INDEX idx_search_analytics_query ON search_analytics USING GIN(to_tsvector('english', query));
CREATE INDEX idx_search_analytics_created ON search_analytics(created_at);
CREATE INDEX idx_funnel_events_session ON funnel_events(session_id);
CREATE INDEX idx_funnel_events_funnel ON funnel_events(funnel_name, step_name);
CREATE INDEX idx_trending_content_rank ON trending_content(content_type, period, rank);
CREATE INDEX idx_merchant_reports_merchant ON merchant_reports(merchant_id, report_type);
CREATE INDEX idx_event_reports_event ON event_reports(event_id);

-- Favorites
CREATE INDEX idx_favorites_user ON favorites(user_id);

-- Room Availability
CREATE INDEX idx_room_availability_date ON room_availability(room_type_id, date);

-- Tour Schedules
CREATE INDEX idx_tour_schedules_date ON tour_schedules(tour_id, date);

-- Event Attendees
CREATE INDEX idx_event_attendees_event ON event_attendees(event_id);
CREATE INDEX idx_event_attendees_ticket_code ON event_attendees(ticket_code);

-- Audit Logs
CREATE INDEX idx_audit_logs_user ON audit_logs(user_id);
CREATE INDEX idx_audit_logs_entity ON audit_logs(entity_type, entity_id);
CREATE INDEX idx_audit_logs_created ON audit_logs(created_at);

-- Visited Places
CREATE INDEX idx_visited_places_user ON visited_places(user_id);
CREATE INDEX idx_visited_places_listing ON visited_places(listing_id);

-- User Locations
CREATE INDEX idx_user_locations_user ON user_locations(user_id);
CREATE INDEX idx_user_locations_location ON user_locations USING GIST(location);

-- Support Tickets
CREATE INDEX idx_support_tickets_user ON support_tickets(user_id);
CREATE INDEX idx_support_tickets_status ON support_tickets(status);
CREATE INDEX idx_support_tickets_assigned ON support_tickets(assigned_to);

-- Coupons
CREATE INDEX idx_coupons_code ON coupons(code);
CREATE INDEX idx_coupon_uses_user ON coupon_uses(user_id);

-- User Payment Methods
CREATE INDEX idx_user_payment_methods_user ON user_payment_methods(user_id);

-- ============================================
-- TRIGGERS
-- ============================================

-- Updated_at trigger function
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Apply updated_at trigger to relevant tables
CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_listings_updated_at BEFORE UPDATE ON listings FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_events_updated_at BEFORE UPDATE ON events FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_tours_updated_at BEFORE UPDATE ON tours FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_bookings_updated_at BEFORE UPDATE ON bookings FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_reviews_updated_at BEFORE UPDATE ON reviews FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_merchant_profiles_updated_at BEFORE UPDATE ON merchant_profiles FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_organizer_profiles_updated_at BEFORE UPDATE ON organizer_profiles FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_tour_operator_profiles_updated_at BEFORE UPDATE ON tour_operator_profiles FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_zoea_cards_updated_at BEFORE UPDATE ON zoea_cards FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_room_types_updated_at BEFORE UPDATE ON room_types FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_subscriptions_updated_at BEFORE UPDATE ON subscriptions FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- ============================================
-- INITIAL DATA
-- ============================================

-- Countries (East Africa focus + expansion)
INSERT INTO countries (name, code, code_2, phone_code, currency_code, currency_symbol, flag_emoji, default_language, timezone, is_active, launched_at) VALUES
('Rwanda', 'RWA', 'RW', '+250', 'RWF', 'FRw', '🇷🇼', 'en', 'Africa/Kigali', true, NOW()),
('Kenya', 'KEN', 'KE', '+254', 'KES', 'KSh', '🇰🇪', 'en', 'Africa/Nairobi', false, NULL),
('Uganda', 'UGA', 'UG', '+256', 'UGX', 'USh', '🇺🇬', 'en', 'Africa/Kampala', false, NULL),
('Tanzania', 'TZA', 'TZ', '+255', 'TZS', 'TSh', '🇹🇿', 'sw', 'Africa/Dar_es_Salaam', false, NULL),
('Burundi', 'BDI', 'BI', '+257', 'BIF', 'FBu', '🇧🇮', 'fr', 'Africa/Bujumbura', false, NULL),
('Democratic Republic of Congo', 'COD', 'CD', '+243', 'CDF', 'FC', '🇨🇩', 'fr', 'Africa/Kinshasa', false, NULL),
('South Africa', 'ZAF', 'ZA', '+27', 'ZAR', 'R', '🇿🇦', 'en', 'Africa/Johannesburg', false, NULL),
('Nigeria', 'NGA', 'NG', '+234', 'NGN', '₦', '🇳🇬', 'en', 'Africa/Lagos', false, NULL),
('Ghana', 'GHA', 'GH', '+233', 'GHS', 'GH₵', '🇬🇭', 'en', 'Africa/Accra', false, NULL),
('Ethiopia', 'ETH', 'ET', '+251', 'ETB', 'Br', '🇪🇹', 'am', 'Africa/Addis_Ababa', false, NULL);

-- Rwanda Regions (Provinces)
INSERT INTO regions (country_id, name, code) 
SELECT id, 'Kigali City', 'KGL' FROM countries WHERE code = 'RWA'
UNION ALL SELECT id, 'Northern Province', 'NOR' FROM countries WHERE code = 'RWA'
UNION ALL SELECT id, 'Southern Province', 'SOU' FROM countries WHERE code = 'RWA'
UNION ALL SELECT id, 'Eastern Province', 'EST' FROM countries WHERE code = 'RWA'
UNION ALL SELECT id, 'Western Province', 'WST' FROM countries WHERE code = 'RWA';

-- Rwanda Cities
INSERT INTO cities (country_id, region_id, name, slug, timezone, is_active, is_featured, launched_at)
SELECT c.id, r.id, 'Kigali', 'kigali', 'Africa/Kigali', true, true, NOW()
FROM countries c, regions r WHERE c.code = 'RWA' AND r.code = 'KGL';

INSERT INTO cities (country_id, region_id, name, slug, timezone, is_active)
SELECT c.id, r.id, 'Musanze', 'musanze', 'Africa/Kigali', true
FROM countries c, regions r WHERE c.code = 'RWA' AND r.code = 'NOR';

INSERT INTO cities (country_id, region_id, name, slug, timezone, is_active)
SELECT c.id, r.id, 'Rubavu', 'rubavu', 'Africa/Kigali', true
FROM countries c, regions r WHERE c.code = 'RWA' AND r.code = 'WST';

INSERT INTO cities (country_id, region_id, name, slug, timezone, is_active)
SELECT c.id, r.id, 'Huye', 'huye', 'Africa/Kigali', true
FROM countries c, regions r WHERE c.code = 'RWA' AND r.code = 'SOU';

INSERT INTO cities (country_id, region_id, name, slug, timezone, is_active)
SELECT c.id, r.id, 'Rusizi', 'rusizi', 'Africa/Kigali', true
FROM countries c, regions r WHERE c.code = 'RWA' AND r.code = 'WST';

INSERT INTO cities (country_id, region_id, name, slug, timezone, is_active)
SELECT c.id, r.id, 'Nyagatare', 'nyagatare', 'Africa/Kigali', true
FROM countries c, regions r WHERE c.code = 'RWA' AND r.code = 'EST';

-- Default Languages
INSERT INTO languages (code, code_3, name, native_name, is_rtl, sort_order) VALUES
('en', 'eng', 'English', 'English', false, 1),
('fr', 'fra', 'French', 'Français', false, 2),
('rw', 'kin', 'Kinyarwanda', 'Ikinyarwanda', false, 3),
('sw', 'swa', 'Swahili', 'Kiswahili', false, 4),
('de', 'deu', 'German', 'Deutsch', false, 5),
('zh', 'zho', 'Chinese', '中文', false, 6);

-- Default Currencies
INSERT INTO currencies (code, name, symbol, symbol_native, decimal_digits, exchange_rate_to_usd, sort_order) VALUES
('RWF', 'Rwandan Franc', 'FRw', 'FRw', 0, 0.00076, 1),
('USD', 'US Dollar', '$', '$', 2, 1.0, 2),
('EUR', 'Euro', '€', '€', 2, 1.08, 3),
('GBP', 'British Pound', '£', '£', 2, 1.27, 4),
('KES', 'Kenyan Shilling', 'KSh', 'KSh', 2, 0.0077, 5),
('UGX', 'Ugandan Shilling', 'USh', 'USh', 0, 0.00027, 6),
('TZS', 'Tanzanian Shilling', 'TSh', 'TSh', 0, 0.00039, 7);

-- Default Timezones
INSERT INTO timezones (name, abbreviation, utc_offset, utc_offset_minutes, has_dst) VALUES
('Africa/Kigali', 'CAT', '+02:00', 120, false),
('Africa/Nairobi', 'EAT', '+03:00', 180, false),
('Africa/Kampala', 'EAT', '+03:00', 180, false),
('Africa/Dar_es_Salaam', 'EAT', '+03:00', 180, false),
('Europe/London', 'GMT', '+00:00', 0, true),
('Europe/Paris', 'CET', '+01:00', 60, true),
('America/New_York', 'EST', '-05:00', -300, true),
('Asia/Dubai', 'GST', '+04:00', 240, false);

-- Default Categories
INSERT INTO categories (name, slug, icon, sort_order) VALUES
('Hotels & Resorts', 'hotels', 'hotel', 1),
('Restaurants & Cafes', 'restaurants', 'restaurant', 2),
('Bars & Nightlife', 'nightlife', 'local_bar', 3),
('Tours & Experiences', 'tours', 'explore', 4),
('Events & Entertainment', 'events', 'event', 5),
('Shopping', 'shopping', 'shopping_bag', 6),
('Attractions', 'attractions', 'attractions', 7);

-- Default Event Contexts
INSERT INTO event_contexts (name, slug, icon) VALUES
('Music & Concerts', 'music', 'music_note'),
('Conferences & Seminars', 'conferences', 'business'),
('Sports & Fitness', 'sports', 'sports'),
('Food & Drink', 'food-drink', 'restaurant'),
('Arts & Culture', 'arts', 'palette'),
('Networking', 'networking', 'people'),
('Workshops & Classes', 'workshops', 'school'),
('Parties & Social', 'parties', 'celebration');

-- Default Amenities
INSERT INTO amenities (name, slug, icon, category, applicable_types) VALUES
('WiFi', 'wifi', 'wifi', 'general', '{hotel,restaurant,cafe}'),
('Parking', 'parking', 'local_parking', 'general', '{hotel,restaurant,bar,club}'),
('Pool', 'pool', 'pool', 'property', '{hotel}'),
('Gym', 'gym', 'fitness_center', 'property', '{hotel}'),
('Spa', 'spa', 'spa', 'property', '{hotel}'),
('Restaurant', 'restaurant', 'restaurant', 'property', '{hotel}'),
('Bar', 'bar', 'local_bar', 'property', '{hotel}'),
('Room Service', 'room-service', 'room_service', 'room', '{hotel}'),
('Air Conditioning', 'ac', 'ac_unit', 'room', '{hotel,restaurant}'),
('TV', 'tv', 'tv', 'room', '{hotel}'),
('Outdoor Seating', 'outdoor-seating', 'deck', 'dining', '{restaurant,cafe,bar}'),
('Live Music', 'live-music', 'music_note', 'entertainment', '{restaurant,bar,club}'),
('Private Rooms', 'private-rooms', 'meeting_room', 'dining', '{restaurant}'),
('Wheelchair Accessible', 'wheelchair', 'accessible', 'accessibility', '{hotel,restaurant,bar,club}');

-- Default Subscription Plans
INSERT INTO subscription_plans (name, slug, description, price, currency, interval, features, applicable_roles) VALUES
('Basic', 'basic', 'Perfect for small businesses', 50000, 'RWF', 'monthly', 
 '{"max_listings": 3, "featured_listings": 0, "analytics": false, "priority_support": false}', 
 '{merchant}'),
('Professional', 'professional', 'For growing businesses', 150000, 'RWF', 'monthly',
 '{"max_listings": 10, "featured_listings": 2, "analytics": true, "priority_support": false}',
 '{merchant}'),
('Enterprise', 'enterprise', 'For large organizations', 500000, 'RWF', 'monthly',
 '{"max_listings": -1, "featured_listings": 10, "analytics": true, "priority_support": true}',
 '{merchant}'),
('Event Starter', 'event-starter', 'For occasional organizers', 30000, 'RWF', 'monthly',
 '{"max_events": 2, "featured_events": 0, "ticket_fee_discount": 0}',
 '{event_organizer}'),
('Event Pro', 'event-pro', 'For professional organizers', 200000, 'RWF', 'monthly',
 '{"max_events": -1, "featured_events": 5, "ticket_fee_discount": 20}',
 '{event_organizer}');

-- ============================================
-- AUTO-GENERATION TRIGGERS
-- ============================================

-- Function to generate booking number
CREATE OR REPLACE FUNCTION generate_booking_number()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.booking_number IS NULL THEN
        NEW.booking_number := 'BK' || TO_CHAR(NOW(), 'YYYYMMDD') || '-' || 
            UPPER(SUBSTRING(REPLACE(NEW.id::text, '-', ''), 1, 8));
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_generate_booking_number
    BEFORE INSERT ON bookings
    FOR EACH ROW
    EXECUTE FUNCTION generate_booking_number();

-- Function to generate ticket code
CREATE OR REPLACE FUNCTION generate_ticket_code()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.ticket_code IS NULL THEN
        NEW.ticket_code := 'TK' || TO_CHAR(NOW(), 'YYYYMMDD') || '-' || 
            UPPER(SUBSTRING(REPLACE(NEW.id::text, '-', ''), 1, 8));
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_generate_ticket_code
    BEFORE INSERT ON booking_tickets
    FOR EACH ROW
    EXECUTE FUNCTION generate_ticket_code();

-- Function to generate referral code for users
CREATE OR REPLACE FUNCTION generate_referral_code()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.referral_code IS NULL THEN
        NEW.referral_code := 'ZOE' || UPPER(SUBSTRING(REPLACE(NEW.id::text, '-', ''), 1, 6));
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_generate_referral_code
    BEFORE INSERT ON users
    FOR EACH ROW
    EXECUTE FUNCTION generate_referral_code();

-- App Config
INSERT INTO app_config (key, value, description, is_public) VALUES
('default_currency', '"RWF"', 'Default currency for the app', true),
('supported_currencies', '["RWF", "USD", "EUR"]', 'Supported currencies', true),
('booking_fee_percentage', '5', 'Platform booking fee percentage', false),
('min_payout_amount', '10000', 'Minimum payout amount in RWF', false),
('referral_reward_amount', '5000', 'Referral reward amount in RWF', false);

-- Default Commission Rules
INSERT INTO commission_rules (name, listing_type, percentage, is_active, priority) VALUES
('Default Hotel Commission', 'hotel', 15.00, true, 0),
('Default Restaurant Commission', 'restaurant', 10.00, true, 0),
('Default Tour Commission', 'tour', 12.00, true, 0),
('Default Event Commission', NULL, 8.00, true, 0);

-- FAQ Categories
INSERT INTO faq_categories (name, slug, icon, sort_order) VALUES
('Getting Started', 'getting-started', 'rocket_launch', 1),
('Account & Profile', 'account-profile', 'person', 2),
('Bookings & Events', 'bookings-events', 'event', 3),
('Payment & Refunds', 'payment-refunds', 'payment', 4),
('Technical Issues', 'technical-issues', 'build', 5);

-- Notification Templates
INSERT INTO notification_templates (code, name, type, title_template, body_template, send_push, send_email) VALUES
('booking_confirmed', 'Booking Confirmed', 'booking', 'Booking Confirmed! 🎉', 'Your booking #{{booking_number}} has been confirmed. See you on {{date}}!', true, true),
('booking_cancelled', 'Booking Cancelled', 'booking', 'Booking Cancelled', 'Your booking #{{booking_number}} has been cancelled.', true, true),
('booking_reminder', 'Booking Reminder', 'booking', 'Reminder: Upcoming Booking', 'Don''t forget! Your booking at {{place_name}} is tomorrow at {{time}}.', true, false),
('payment_received', 'Payment Received', 'payment', 'Payment Successful ✓', 'We received your payment of {{amount}} {{currency}} for booking #{{booking_number}}.', true, true),
('payment_failed', 'Payment Failed', 'payment', 'Payment Failed', 'Your payment for booking #{{booking_number}} failed. Please try again.', true, true),
('event_reminder_24h', 'Event Reminder 24h', 'event', '{{event_name}} is Tomorrow! 🎪', 'Get ready! {{event_name}} starts tomorrow at {{time}}.', true, true),
('event_reminder_1h', 'Event Reminder 1h', 'event', '{{event_name}} Starts Soon!', '{{event_name}} starts in 1 hour. Don''t be late!', true, false),
('event_cancelled', 'Event Cancelled', 'event', 'Event Cancelled', '{{event_name}} has been cancelled. A refund will be processed.', true, true),
('new_promotion', 'New Promotion', 'promotion', 'Special Offer! 🔥', '{{promotion_title}} - {{discount}}% off! Limited time only.', true, false),
('welcome', 'Welcome', 'system', 'Welcome to Zoea! 🌍', 'Start exploring Rwanda''s best experiences, events, and places.', true, true),
('referral_reward', 'Referral Reward', 'social', 'You Earned a Reward! 🎁', 'Your friend joined Zoea! You earned {{amount}} {{currency}}.', true, true);

-- ============================================
-- COMMENTS
-- ============================================
COMMENT ON TABLE users IS 'Central user table - all user types (explorers, merchants, organizers, operators)';
COMMENT ON TABLE merchant_profiles IS 'Extended profile for users with merchant role';
COMMENT ON TABLE organizer_profiles IS 'Extended profile for users with event_organizer role';
COMMENT ON TABLE tour_operator_profiles IS 'Extended profile for users with tour_operator role';
COMMENT ON TABLE listings IS 'All bookable places - hotels, restaurants, bars, shops, etc.';
COMMENT ON TABLE events IS 'All events including MICE (Meetings, Incentives, Conferences, Exhibitions)';
COMMENT ON TABLE tours IS 'Tours and experiences offered by tour operators';
COMMENT ON TABLE bookings IS 'Central booking table for all booking types';
COMMENT ON TABLE zoea_cards IS 'Digital wallet for users';
COMMENT ON TABLE transactions IS 'All financial transactions through Zoea Card';
COMMENT ON TABLE subscriptions IS 'Merchant/Organizer subscription management';
COMMENT ON TABLE payouts IS 'Merchant payout tracking';

