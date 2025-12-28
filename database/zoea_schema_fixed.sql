-- ============================================
-- ZOEA DATABASE SCHEMA - FIXED VERSION
-- PostgreSQL 16 with PostGIS
-- ============================================

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "postgis";
CREATE EXTENSION IF NOT EXISTS "pg_trgm";

-- ENUMS
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
CREATE TYPE subscription_status AS ENUM ('active', 'past_due', 'cancelled', 'paused', 'trial');
CREATE TYPE subscription_interval AS ENUM ('monthly', 'quarterly', 'yearly');
CREATE TYPE notification_type AS ENUM ('booking', 'payment', 'event', 'promotion', 'system', 'social');
CREATE TYPE document_status AS ENUM ('pending', 'approved', 'rejected');
CREATE TYPE room_status AS ENUM ('available', 'occupied', 'maintenance', 'blocked');
CREATE TYPE table_status AS ENUM ('available', 'reserved', 'occupied', 'unavailable');
CREATE TYPE day_of_week AS ENUM ('monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday');
CREATE TYPE media_type AS ENUM ('image', 'video', 'document', 'audio');
CREATE TYPE event_status AS ENUM ('draft', 'pending_review', 'published', 'ongoing', 'completed', 'cancelled', 'suspended');
CREATE TYPE tour_status AS ENUM ('draft', 'pending_review', 'active', 'inactive', 'suspended');
CREATE TYPE review_status AS ENUM ('pending', 'approved', 'rejected', 'flagged');
CREATE TYPE approval_status AS ENUM ('pending', 'approved', 'rejected', 'suspended');
CREATE TYPE content_type AS ENUM ('listing', 'event', 'tour', 'review', 'notification', 'merchant_registration', 'organizer_registration', 'operator_registration');

-- UTILITY TABLES
CREATE TABLE languages (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    code VARCHAR(10) UNIQUE NOT NULL,
    name VARCHAR(100) NOT NULL,
    native_name VARCHAR(100),
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE currencies (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    code VARCHAR(3) UNIQUE NOT NULL,
    name VARCHAR(100) NOT NULL,
    symbol VARCHAR(10) NOT NULL,
    decimal_digits INTEGER DEFAULT 2,
    exchange_rate_to_usd DECIMAL(15,6) DEFAULT 1,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE timezones (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(100) UNIQUE NOT NULL,
    abbreviation VARCHAR(10),
    utc_offset VARCHAR(10) NOT NULL,
    utc_offset_minutes INTEGER NOT NULL,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- GEOGRAPHIC
CREATE TABLE countries (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    code VARCHAR(3) UNIQUE NOT NULL,
    name VARCHAR(100) NOT NULL,
    phone_code VARCHAR(10),
    currency_code VARCHAR(3),
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE regions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    country_id UUID REFERENCES countries(id),
    code VARCHAR(10),
    name VARCHAR(100) NOT NULL,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE cities (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    country_id UUID REFERENCES countries(id),
    region_id UUID REFERENCES regions(id),
    name VARCHAR(100) NOT NULL,
    slug VARCHAR(100),
    timezone VARCHAR(50),
    location GEOGRAPHY(POINT, 4326),
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE districts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    city_id UUID REFERENCES cities(id),
    name VARCHAR(100) NOT NULL,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- MEDIA
CREATE TABLE media (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    type media_type NOT NULL,
    url TEXT NOT NULL,
    thumbnail_url TEXT,
    blurhash VARCHAR(100),
    width INTEGER,
    height INTEGER,
    file_size INTEGER,
    mime_type VARCHAR(50),
    alt_text TEXT,
    is_dark BOOLEAN DEFAULT false,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- USERS (no FK to other tables initially)
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    email VARCHAR(255) UNIQUE,
    phone_number VARCHAR(20) UNIQUE,
    password_hash VARCHAR(255),
    username VARCHAR(50) UNIQUE,
    full_name VARCHAR(255),
    bio TEXT,
    profile_image_id UUID,
    date_of_birth DATE,
    gender VARCHAR(20),
    country_id UUID,
    city_id UUID,
    address TEXT,
    current_location GEOGRAPHY(POINT, 4326),
    profession VARCHAR(100),
    interests TEXT[],
    roles user_role[] DEFAULT '{explorer}',
    account_type account_type DEFAULT 'personal',
    is_verified BOOLEAN DEFAULT false,
    is_active BOOLEAN DEFAULT true,
    is_private BOOLEAN DEFAULT false,
    verification_status verification_status DEFAULT 'unverified',
    preferred_currency VARCHAR(3) DEFAULT 'RWF',
    preferred_language VARCHAR(10) DEFAULT 'en',
    timezone VARCHAR(50) DEFAULT 'Africa/Kigali',
    referral_code VARCHAR(20) UNIQUE,
    referred_by UUID,
    email_verified_at TIMESTAMPTZ,
    phone_verified_at TIMESTAMPTZ,
    last_login_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    deleted_at TIMESTAMPTZ,
    CHECK (email IS NOT NULL OR phone_number IS NOT NULL)
);

-- PROFILES
CREATE TABLE merchant_profiles (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL,
    business_name VARCHAR(255) NOT NULL,
    description TEXT,
    logo_id UUID,
    country_id UUID,
    city_id UUID,
    address TEXT,
    phone VARCHAR(20),
    email VARCHAR(255),
    website VARCHAR(255),
    tax_id VARCHAR(50),
    registration_status approval_status DEFAULT 'pending',
    is_verified BOOLEAN DEFAULT false,
    rating DECIMAL(3,2) DEFAULT 0,
    review_count INTEGER DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    deleted_at TIMESTAMPTZ
);

CREATE TABLE organizer_profiles (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    logo_id UUID,
    country_id UUID,
    city_id UUID,
    phone VARCHAR(20),
    email VARCHAR(255),
    website VARCHAR(255),
    registration_status approval_status DEFAULT 'pending',
    is_verified BOOLEAN DEFAULT false,
    total_events INTEGER DEFAULT 0,
    total_attendees INTEGER DEFAULT 0,
    rating DECIMAL(3,2) DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    deleted_at TIMESTAMPTZ
);

CREATE TABLE tour_operator_profiles (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL,
    company_name VARCHAR(255) NOT NULL,
    description TEXT,
    logo_id UUID,
    country_id UUID,
    city_id UUID,
    license_number VARCHAR(50),
    phone VARCHAR(20),
    email VARCHAR(255),
    website VARCHAR(255),
    registration_status approval_status DEFAULT 'pending',
    is_verified BOOLEAN DEFAULT false,
    rating DECIMAL(3,2) DEFAULT 0,
    review_count INTEGER DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    deleted_at TIMESTAMPTZ
);

-- CATEGORIES & AMENITIES
CREATE TABLE categories (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(100) NOT NULL,
    slug VARCHAR(100) UNIQUE NOT NULL,
    description TEXT,
    icon VARCHAR(50),
    parent_id UUID,
    sort_order INTEGER DEFAULT 0,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE amenities (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(100) NOT NULL,
    slug VARCHAR(100) UNIQUE NOT NULL,
    description TEXT,
    icon VARCHAR(50),
    category VARCHAR(50),
    applicable_types listing_type[],
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE tags (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(100) NOT NULL,
    slug VARCHAR(100) UNIQUE NOT NULL,
    description TEXT,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE event_contexts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(100) NOT NULL,
    slug VARCHAR(100) UNIQUE NOT NULL,
    description TEXT,
    icon VARCHAR(50),
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- LISTINGS
CREATE TABLE listings (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    merchant_id UUID,
    name VARCHAR(255) NOT NULL,
    slug VARCHAR(255),
    description TEXT,
    type listing_type NOT NULL,
    status listing_status DEFAULT 'draft',
    category_id UUID,
    country_id UUID,
    city_id UUID,
    district_id UUID,
    address TEXT,
    location GEOGRAPHY(POINT, 4326),
    phone VARCHAR(20),
    email VARCHAR(255),
    website VARCHAR(255),
    price_min DECIMAL(10,2),
    price_max DECIMAL(10,2),
    currency VARCHAR(3) DEFAULT 'RWF',
    price_unit price_unit,
    is_verified BOOLEAN DEFAULT false,
    is_featured BOOLEAN DEFAULT false,
    rating DECIMAL(3,2) DEFAULT 0,
    review_count INTEGER DEFAULT 0,
    view_count INTEGER DEFAULT 0,
    booking_count INTEGER DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    deleted_at TIMESTAMPTZ
);

CREATE TABLE listing_images (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    listing_id UUID NOT NULL,
    media_id UUID,
    is_primary BOOLEAN DEFAULT false,
    sort_order INTEGER DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE listing_amenities (
    listing_id UUID NOT NULL,
    amenity_id UUID NOT NULL,
    PRIMARY KEY (listing_id, amenity_id)
);

CREATE TABLE listing_tags (
    listing_id UUID NOT NULL,
    tag_id UUID NOT NULL,
    PRIMARY KEY (listing_id, tag_id)
);

CREATE TABLE operating_hours (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    listing_id UUID NOT NULL,
    day day_of_week NOT NULL,
    open_time TIME,
    close_time TIME,
    is_closed BOOLEAN DEFAULT false,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ROOMS (Hotels)
CREATE TABLE room_types (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    listing_id UUID NOT NULL,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    base_price DECIMAL(10,2) NOT NULL CHECK (base_price >= 0),
    currency VARCHAR(3) DEFAULT 'RWF',
    total_rooms INTEGER NOT NULL DEFAULT 1 CHECK (total_rooms > 0),
    max_occupancy INTEGER DEFAULT 2,
    bed_type VARCHAR(50),
    size_sqm DECIMAL(6,2),
    amenities TEXT[],
    images UUID[],
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE rooms (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    room_type_id UUID NOT NULL,
    room_number VARCHAR(20) NOT NULL,
    floor INTEGER,
    status room_status DEFAULT 'available',
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE room_availability (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    room_type_id UUID NOT NULL,
    date DATE NOT NULL,
    available_rooms INTEGER NOT NULL,
    price_override DECIMAL(10,2),
    min_stay INTEGER DEFAULT 1,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(room_type_id, date)
);

-- RESTAURANT TABLES
CREATE TABLE restaurant_tables (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    listing_id UUID NOT NULL,
    table_number VARCHAR(20) NOT NULL,
    capacity INTEGER NOT NULL CHECK (capacity > 0),
    min_capacity INTEGER DEFAULT 1 CHECK (min_capacity > 0),
    location VARCHAR(50),
    status table_status DEFAULT 'available',
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE reservation_time_slots (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    listing_id UUID NOT NULL,
    day day_of_week NOT NULL,
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    max_reservations INTEGER,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- EVENTS
CREATE TABLE events (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    organizer_id UUID,
    name VARCHAR(255) NOT NULL,
    slug VARCHAR(255),
    description TEXT,
    flyer_id UUID,
    context_id UUID,
    status event_status DEFAULT 'draft',
    privacy event_privacy DEFAULT 'public',
    setup event_setup DEFAULT 'in_person',
    country_id UUID,
    city_id UUID,
    location_name VARCHAR(255),
    location GEOGRAPHY(POINT, 4326),
    virtual_url TEXT,
    start_date TIMESTAMPTZ,
    end_date TIMESTAMPTZ,
    max_attendance INTEGER,
    attending INTEGER DEFAULT 0,
    is_featured BOOLEAN DEFAULT false,
    is_mice BOOLEAN DEFAULT false,
    view_count INTEGER DEFAULT 0,
    like_count INTEGER DEFAULT 0,
    comment_count INTEGER DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    deleted_at TIMESTAMPTZ,
    CONSTRAINT events_dates_check CHECK (end_date IS NULL OR start_date IS NULL OR end_date >= start_date),
    CONSTRAINT events_attendance_check CHECK (max_attendance IS NULL OR max_attendance > 0)
);

CREATE TABLE event_attachments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    event_id UUID NOT NULL,
    media_id UUID,
    is_main_flyer BOOLEAN DEFAULT false,
    sort_order INTEGER DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE event_tickets (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    event_id UUID NOT NULL,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    type ticket_type DEFAULT 'paid',
    price DECIMAL(10,2) DEFAULT 0 CHECK (price IS NULL OR price >= 0),
    currency VARCHAR(3) DEFAULT 'RWF',
    total_quantity INTEGER CHECK (total_quantity IS NULL OR total_quantity >= 0),
    sold_quantity INTEGER DEFAULT 0,
    min_per_order INTEGER DEFAULT 1,
    max_per_order INTEGER DEFAULT 10,
    sales_start TIMESTAMPTZ,
    sales_end TIMESTAMPTZ,
    is_active BOOLEAN DEFAULT true,
    sort_order INTEGER DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    CONSTRAINT event_tickets_per_order_check CHECK (max_per_order IS NULL OR min_per_order IS NULL OR max_per_order >= min_per_order)
);

CREATE TABLE event_attendees (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    event_id UUID NOT NULL,
    user_id UUID NOT NULL,
    ticket_id UUID,
    status VARCHAR(20) DEFAULT 'registered',
    checked_in_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(event_id, user_id)
);

CREATE TABLE event_likes (
    user_id UUID NOT NULL,
    event_id UUID NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    PRIMARY KEY (user_id, event_id)
);

CREATE TABLE event_comments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    event_id UUID NOT NULL,
    user_id UUID NOT NULL,
    parent_id UUID,
    content TEXT NOT NULL,
    like_count INTEGER DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    deleted_at TIMESTAMPTZ
);

-- TOURS
CREATE TABLE tours (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    operator_id UUID,
    name VARCHAR(255) NOT NULL,
    slug VARCHAR(255),
    description TEXT,
    type VARCHAR(50),
    status tour_status DEFAULT 'draft',
    country_id UUID,
    city_id UUID,
    start_location GEOGRAPHY(POINT, 4326),
    start_location_name VARCHAR(255),
    duration_hours DECIMAL(5,2),
    difficulty VARCHAR(20),
    min_group_size INTEGER DEFAULT 1,
    max_group_size INTEGER DEFAULT 20,
    price_per_person DECIMAL(10,2) CHECK (price_per_person IS NULL OR price_per_person >= 0),
    currency VARCHAR(3) DEFAULT 'RWF',
    includes TEXT[],
    excludes TEXT[],
    what_to_bring TEXT[],
    is_featured BOOLEAN DEFAULT false,
    rating DECIMAL(3,2) DEFAULT 0 CHECK (rating IS NULL OR (rating >= 0 AND rating <= 5)),
    review_count INTEGER DEFAULT 0,
    booking_count INTEGER DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    deleted_at TIMESTAMPTZ,
    CONSTRAINT tours_group_size_check CHECK (max_group_size IS NULL OR min_group_size IS NULL OR max_group_size >= min_group_size)
);

CREATE TABLE tour_images (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    tour_id UUID NOT NULL,
    media_id UUID,
    is_primary BOOLEAN DEFAULT false,
    sort_order INTEGER DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE tour_schedules (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    tour_id UUID NOT NULL,
    date DATE NOT NULL,
    start_time TIME,
    available_spots INTEGER,
    price_override DECIMAL(10,2),
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- SUBSCRIPTIONS
CREATE TABLE subscription_plans (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(100) NOT NULL,
    slug VARCHAR(100) UNIQUE NOT NULL,
    description TEXT,
    price DECIMAL(10,2) NOT NULL,
    currency VARCHAR(3) DEFAULT 'RWF',
    interval subscription_interval DEFAULT 'monthly',
    features JSONB,
    applicable_roles user_role[],
    is_active BOOLEAN DEFAULT true,
    sort_order INTEGER DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE subscriptions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL,
    plan_id UUID NOT NULL,
    status subscription_status DEFAULT 'active',
    current_period_start TIMESTAMPTZ,
    current_period_end TIMESTAMPTZ,
    cancelled_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE subscription_invoices (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    subscription_id UUID NOT NULL,
    amount DECIMAL(10,2) NOT NULL,
    currency VARCHAR(3) DEFAULT 'RWF',
    status payment_status DEFAULT 'pending',
    due_date DATE,
    paid_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- BOOKINGS
CREATE TABLE bookings (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    booking_number VARCHAR(30) UNIQUE,
    user_id UUID NOT NULL,
    listing_id UUID,
    event_id UUID,
    tour_id UUID,
    merchant_id UUID,
    organizer_id UUID,
    operator_id UUID,
    type booking_type NOT NULL,
    status booking_status DEFAULT 'pending',
    check_in_date TIMESTAMPTZ,
    check_out_date TIMESTAMPTZ,
    guest_count INTEGER,
    room_type_id UUID,
    room_count INTEGER DEFAULT 1,
    table_id UUID,
    time_slot TIME,
    special_requests TEXT,
    total_amount DECIMAL(10,2),
    currency VARCHAR(3) DEFAULT 'RWF',
    payment_method payment_method,
    payment_status payment_status DEFAULT 'pending',
    paid_amount DECIMAL(10,2) DEFAULT 0,
    confirmed_at TIMESTAMPTZ,
    confirmation_code VARCHAR(20),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    CONSTRAINT bookings_dates_check CHECK (check_out_date IS NULL OR check_in_date IS NULL OR check_out_date >= check_in_date),
    CONSTRAINT bookings_guest_count_check CHECK (guest_count IS NULL OR guest_count > 0),
    CONSTRAINT bookings_amount_check CHECK (total_amount IS NULL OR total_amount >= 0)
);

CREATE TABLE booking_guests (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    booking_id UUID NOT NULL,
    full_name VARCHAR(255) NOT NULL,
    email VARCHAR(255),
    phone VARCHAR(20),
    is_primary BOOLEAN DEFAULT false,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE booking_tickets (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    booking_id UUID NOT NULL,
    ticket_type_id UUID NOT NULL,
    ticket_code VARCHAR(30) UNIQUE,
    quantity INTEGER DEFAULT 1,
    unit_price DECIMAL(10,2),
    status VARCHAR(20) DEFAULT 'valid',
    used_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ZOEA CARD & TRANSACTIONS
CREATE TABLE zoea_cards (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL UNIQUE,
    balance DECIMAL(12,2) DEFAULT 0,
    currency VARCHAR(3) DEFAULT 'RWF',
    status card_status DEFAULT 'active',
    linked_account_id VARCHAR(100),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE transactions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    card_id UUID NOT NULL,
    type transaction_type NOT NULL,
    amount DECIMAL(12,2) NOT NULL,
    currency VARCHAR(3) DEFAULT 'RWF',
    balance_after DECIMAL(12,2),
    description TEXT,
    reference VARCHAR(100),
    merchant_id UUID,
    booking_id UUID,
    status transaction_status DEFAULT 'pending',
    metadata JSONB,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- PAYOUTS
CREATE TABLE commission_rules (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(100) NOT NULL,
    description TEXT,
    listing_type listing_type,
    percentage DECIMAL(5,2) NOT NULL,
    is_active BOOLEAN DEFAULT true,
    priority INTEGER DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE payouts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL,
    amount DECIMAL(12,2) NOT NULL,
    currency VARCHAR(3) DEFAULT 'RWF',
    status payment_status DEFAULT 'pending',
    payment_method VARCHAR(50),
    account_details JSONB,
    period_start DATE,
    period_end DATE,
    processed_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- REVIEWS
CREATE TABLE reviews (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL,
    listing_id UUID,
    event_id UUID,
    tour_id UUID,
    booking_id UUID,
    rating INTEGER NOT NULL CHECK (rating >= 1 AND rating <= 5),
    title VARCHAR(255),
    content TEXT,
    status review_status DEFAULT 'pending',
    pros TEXT[],
    cons TEXT[],
    images UUID[],
    helpful_count INTEGER DEFAULT 0,
    response TEXT,
    response_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    deleted_at TIMESTAMPTZ
);

-- FAVORITES
CREATE TABLE favorites (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL,
    listing_id UUID,
    event_id UUID,
    tour_id UUID,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- REFERRALS
CREATE TABLE referrals (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    referrer_id UUID NOT NULL,
    referred_id UUID NOT NULL,
    status VARCHAR(20) DEFAULT 'pending',
    reward_amount DECIMAL(10,2),
    credited_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- NOTIFICATIONS
CREATE TABLE notification_templates (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    code VARCHAR(50) UNIQUE NOT NULL,
    name VARCHAR(100) NOT NULL,
    type notification_type NOT NULL,
    title_template TEXT NOT NULL,
    body_template TEXT NOT NULL,
    send_push BOOLEAN DEFAULT true,
    send_email BOOLEAN DEFAULT false,
    send_sms BOOLEAN DEFAULT false,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE notifications (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL,
    type notification_type NOT NULL,
    title TEXT NOT NULL,
    body TEXT NOT NULL,
    data JSONB,
    is_read BOOLEAN DEFAULT false,
    read_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE scheduled_notifications (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    template_id UUID,
    target_type VARCHAR(50),
    target_filters JSONB,
    scheduled_for TIMESTAMPTZ NOT NULL,
    sent_at TIMESTAMPTZ,
    status VARCHAR(20) DEFAULT 'scheduled',
    created_by UUID,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE notification_preferences (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL UNIQUE,
    push_enabled BOOLEAN DEFAULT true,
    email_enabled BOOLEAN DEFAULT true,
    sms_enabled BOOLEAN DEFAULT false,
    booking_notifications BOOLEAN DEFAULT true,
    event_notifications BOOLEAN DEFAULT true,
    promotion_notifications BOOLEAN DEFAULT true,
    social_notifications BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE notification_requests (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    requester_id UUID NOT NULL,
    merchant_id UUID,
    organizer_id UUID,
    title TEXT NOT NULL,
    body TEXT NOT NULL,
    target_audience JSONB,
    status approval_status DEFAULT 'pending',
    reviewed_by UUID,
    reviewed_at TIMESTAMPTZ,
    rejection_reason TEXT,
    scheduled_for TIMESTAMPTZ,
    sent_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- CONTENT MODERATION
CREATE TABLE content_approvals (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    content_type content_type NOT NULL,
    content_id UUID NOT NULL,
    status approval_status DEFAULT 'pending',
    submitted_by UUID NOT NULL,
    reviewed_by UUID,
    reviewed_at TIMESTAMPTZ,
    rejection_reason TEXT,
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE approval_history (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    approval_id UUID NOT NULL,
    old_status approval_status,
    new_status approval_status NOT NULL,
    changed_by UUID NOT NULL,
    reason TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE moderation_rules (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(100) NOT NULL,
    content_type content_type,
    condition JSONB NOT NULL,
    action VARCHAR(50) NOT NULL,
    is_active BOOLEAN DEFAULT true,
    priority INTEGER DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE content_flags (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    content_type content_type NOT NULL,
    content_id UUID NOT NULL,
    reporter_id UUID NOT NULL,
    reason VARCHAR(100) NOT NULL,
    description TEXT,
    status VARCHAR(20) DEFAULT 'pending',
    reviewed_by UUID,
    reviewed_at TIMESTAMPTZ,
    action_taken VARCHAR(50),
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ANALYTICS
CREATE TABLE profile_views (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    profile_id UUID NOT NULL,
    viewer_id UUID,
    viewed_at TIMESTAMPTZ DEFAULT NOW(),
    source VARCHAR(50)
);

CREATE TABLE content_views (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    content_type content_type NOT NULL,
    content_id UUID NOT NULL,
    user_id UUID,
    session_id VARCHAR(100),
    viewed_at TIMESTAMPTZ DEFAULT NOW(),
    duration_seconds INTEGER,
    source VARCHAR(50)
);

CREATE TABLE search_analytics (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID,
    query TEXT NOT NULL,
    filters JSONB,
    results_count INTEGER,
    clicked_result_id UUID,
    clicked_result_type VARCHAR(50),
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE daily_stats (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    entity_type VARCHAR(50) NOT NULL,
    entity_id UUID NOT NULL,
    date DATE NOT NULL,
    views INTEGER DEFAULT 0,
    unique_views INTEGER DEFAULT 0,
    bookings INTEGER DEFAULT 0,
    revenue DECIMAL(12,2) DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(entity_type, entity_id, date)
);

CREATE TABLE platform_daily_stats (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    date DATE UNIQUE NOT NULL,
    new_users INTEGER DEFAULT 0,
    active_users INTEGER DEFAULT 0,
    total_bookings INTEGER DEFAULT 0,
    total_revenue DECIMAL(12,2) DEFAULT 0,
    total_events INTEGER DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE trending_content (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    content_type content_type NOT NULL,
    content_id UUID NOT NULL,
    score DECIMAL(10,4) NOT NULL,
    rank INTEGER,
    period VARCHAR(20) NOT NULL,
    calculated_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(content_type, content_id, period)
);

-- SUPPORT
CREATE TABLE faq_categories (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(100) NOT NULL,
    slug VARCHAR(100) UNIQUE NOT NULL,
    icon VARCHAR(50),
    sort_order INTEGER DEFAULT 0,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE faqs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    category_id UUID,
    question TEXT NOT NULL,
    answer TEXT NOT NULL,
    sort_order INTEGER DEFAULT 0,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE support_tickets (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL,
    subject VARCHAR(255) NOT NULL,
    description TEXT NOT NULL,
    status VARCHAR(20) DEFAULT 'open',
    priority VARCHAR(20) DEFAULT 'normal',
    assigned_to UUID,
    resolved_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE support_messages (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    ticket_id UUID NOT NULL,
    sender_id UUID NOT NULL,
    message TEXT NOT NULL,
    attachments UUID[],
    is_internal BOOLEAN DEFAULT false,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- PROMOTIONS & COUPONS
CREATE TABLE promotions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255) NOT NULL,
    description TEXT,
    type VARCHAR(50) NOT NULL,
    discount_type VARCHAR(20) NOT NULL,
    discount_value DECIMAL(10,2) NOT NULL,
    country_id UUID,
    city_id UUID,
    applicable_types listing_type[],
    start_date TIMESTAMPTZ,
    end_date TIMESTAMPTZ,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE coupons (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    code VARCHAR(50) UNIQUE NOT NULL,
    name VARCHAR(255),
    discount_type VARCHAR(20) NOT NULL,
    discount_value DECIMAL(10,2) NOT NULL,
    min_order_amount DECIMAL(10,2),
    max_discount DECIMAL(10,2),
    usage_limit INTEGER,
    used_count INTEGER DEFAULT 0,
    user_limit INTEGER DEFAULT 1,
    applicable_types listing_type[],
    country_id UUID,
    city_id UUID,
    start_date TIMESTAMPTZ,
    end_date TIMESTAMPTZ,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE coupon_uses (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    coupon_id UUID NOT NULL,
    user_id UUID NOT NULL,
    booking_id UUID,
    discount_amount DECIMAL(10,2) NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- USER CONTENT PREFERENCES
CREATE TABLE user_content_preferences (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL UNIQUE,
    preferred_countries UUID[],
    preferred_cities UUID[],
    preferred_categories UUID[],
    excluded_categories UUID[],
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- USER PAYMENT METHODS
CREATE TABLE user_payment_methods (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL,
    type payment_method NOT NULL,
    provider VARCHAR(50),
    account_number VARCHAR(100),
    account_name VARCHAR(255),
    is_default BOOLEAN DEFAULT false,
    is_verified BOOLEAN DEFAULT false,
    metadata JSONB,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- AUDIT LOG
CREATE TABLE audit_logs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID,
    action VARCHAR(100) NOT NULL,
    entity_type VARCHAR(50),
    entity_id UUID,
    old_values JSONB,
    new_values JSONB,
    ip_address INET,
    user_agent TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- APP CONFIG
CREATE TABLE app_config (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    key VARCHAR(100) UNIQUE NOT NULL,
    value JSONB NOT NULL,
    description TEXT,
    is_public BOOLEAN DEFAULT false,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================
-- ADD FOREIGN KEY CONSTRAINTS
-- ============================================

ALTER TABLE users ADD CONSTRAINT fk_users_profile_image FOREIGN KEY (profile_image_id) REFERENCES media(id);
ALTER TABLE users ADD CONSTRAINT fk_users_country FOREIGN KEY (country_id) REFERENCES countries(id);
ALTER TABLE users ADD CONSTRAINT fk_users_city FOREIGN KEY (city_id) REFERENCES cities(id);
ALTER TABLE users ADD CONSTRAINT fk_users_referred_by FOREIGN KEY (referred_by) REFERENCES users(id);

ALTER TABLE merchant_profiles ADD CONSTRAINT fk_merchant_user FOREIGN KEY (user_id) REFERENCES users(id);
ALTER TABLE merchant_profiles ADD CONSTRAINT fk_merchant_logo FOREIGN KEY (logo_id) REFERENCES media(id);
ALTER TABLE merchant_profiles ADD CONSTRAINT fk_merchant_country FOREIGN KEY (country_id) REFERENCES countries(id);
ALTER TABLE merchant_profiles ADD CONSTRAINT fk_merchant_city FOREIGN KEY (city_id) REFERENCES cities(id);

ALTER TABLE organizer_profiles ADD CONSTRAINT fk_organizer_user FOREIGN KEY (user_id) REFERENCES users(id);
ALTER TABLE organizer_profiles ADD CONSTRAINT fk_organizer_logo FOREIGN KEY (logo_id) REFERENCES media(id);
ALTER TABLE organizer_profiles ADD CONSTRAINT fk_organizer_country FOREIGN KEY (country_id) REFERENCES countries(id);
ALTER TABLE organizer_profiles ADD CONSTRAINT fk_organizer_city FOREIGN KEY (city_id) REFERENCES cities(id);

ALTER TABLE tour_operator_profiles ADD CONSTRAINT fk_operator_user FOREIGN KEY (user_id) REFERENCES users(id);
ALTER TABLE tour_operator_profiles ADD CONSTRAINT fk_operator_logo FOREIGN KEY (logo_id) REFERENCES media(id);
ALTER TABLE tour_operator_profiles ADD CONSTRAINT fk_operator_country FOREIGN KEY (country_id) REFERENCES countries(id);
ALTER TABLE tour_operator_profiles ADD CONSTRAINT fk_operator_city FOREIGN KEY (city_id) REFERENCES cities(id);

ALTER TABLE categories ADD CONSTRAINT fk_category_parent FOREIGN KEY (parent_id) REFERENCES categories(id);

ALTER TABLE listings ADD CONSTRAINT fk_listing_merchant FOREIGN KEY (merchant_id) REFERENCES merchant_profiles(id);
ALTER TABLE listings ADD CONSTRAINT fk_listing_category FOREIGN KEY (category_id) REFERENCES categories(id);
ALTER TABLE listings ADD CONSTRAINT fk_listing_country FOREIGN KEY (country_id) REFERENCES countries(id);
ALTER TABLE listings ADD CONSTRAINT fk_listing_city FOREIGN KEY (city_id) REFERENCES cities(id);
ALTER TABLE listings ADD CONSTRAINT fk_listing_district FOREIGN KEY (district_id) REFERENCES districts(id);

ALTER TABLE listing_images ADD CONSTRAINT fk_listing_image_listing FOREIGN KEY (listing_id) REFERENCES listings(id) ON DELETE CASCADE;
ALTER TABLE listing_images ADD CONSTRAINT fk_listing_image_media FOREIGN KEY (media_id) REFERENCES media(id);

ALTER TABLE listing_amenities ADD CONSTRAINT fk_listing_amenity_listing FOREIGN KEY (listing_id) REFERENCES listings(id) ON DELETE CASCADE;
ALTER TABLE listing_amenities ADD CONSTRAINT fk_listing_amenity_amenity FOREIGN KEY (amenity_id) REFERENCES amenities(id);

ALTER TABLE listing_tags ADD CONSTRAINT fk_listing_tag_listing FOREIGN KEY (listing_id) REFERENCES listings(id) ON DELETE CASCADE;
ALTER TABLE listing_tags ADD CONSTRAINT fk_listing_tag_tag FOREIGN KEY (tag_id) REFERENCES tags(id);

ALTER TABLE operating_hours ADD CONSTRAINT fk_operating_hours_listing FOREIGN KEY (listing_id) REFERENCES listings(id) ON DELETE CASCADE;

ALTER TABLE room_types ADD CONSTRAINT fk_room_type_listing FOREIGN KEY (listing_id) REFERENCES listings(id) ON DELETE CASCADE;

ALTER TABLE rooms ADD CONSTRAINT fk_room_type FOREIGN KEY (room_type_id) REFERENCES room_types(id) ON DELETE CASCADE;

ALTER TABLE room_availability ADD CONSTRAINT fk_room_avail_type FOREIGN KEY (room_type_id) REFERENCES room_types(id) ON DELETE CASCADE;

ALTER TABLE restaurant_tables ADD CONSTRAINT fk_restaurant_table_listing FOREIGN KEY (listing_id) REFERENCES listings(id) ON DELETE CASCADE;

ALTER TABLE reservation_time_slots ADD CONSTRAINT fk_time_slot_listing FOREIGN KEY (listing_id) REFERENCES listings(id) ON DELETE CASCADE;

ALTER TABLE events ADD CONSTRAINT fk_event_organizer FOREIGN KEY (organizer_id) REFERENCES organizer_profiles(id);
ALTER TABLE events ADD CONSTRAINT fk_event_flyer FOREIGN KEY (flyer_id) REFERENCES media(id);
ALTER TABLE events ADD CONSTRAINT fk_event_context FOREIGN KEY (context_id) REFERENCES event_contexts(id);
ALTER TABLE events ADD CONSTRAINT fk_event_country FOREIGN KEY (country_id) REFERENCES countries(id);
ALTER TABLE events ADD CONSTRAINT fk_event_city FOREIGN KEY (city_id) REFERENCES cities(id);

ALTER TABLE event_attachments ADD CONSTRAINT fk_event_attach_event FOREIGN KEY (event_id) REFERENCES events(id) ON DELETE CASCADE;
ALTER TABLE event_attachments ADD CONSTRAINT fk_event_attach_media FOREIGN KEY (media_id) REFERENCES media(id);

ALTER TABLE event_tickets ADD CONSTRAINT fk_event_ticket_event FOREIGN KEY (event_id) REFERENCES events(id) ON DELETE CASCADE;

ALTER TABLE event_attendees ADD CONSTRAINT fk_attendee_event FOREIGN KEY (event_id) REFERENCES events(id) ON DELETE CASCADE;
ALTER TABLE event_attendees ADD CONSTRAINT fk_attendee_user FOREIGN KEY (user_id) REFERENCES users(id);
ALTER TABLE event_attendees ADD CONSTRAINT fk_attendee_ticket FOREIGN KEY (ticket_id) REFERENCES event_tickets(id);

ALTER TABLE event_likes ADD CONSTRAINT fk_event_like_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;
ALTER TABLE event_likes ADD CONSTRAINT fk_event_like_event FOREIGN KEY (event_id) REFERENCES events(id) ON DELETE CASCADE;

ALTER TABLE event_comments ADD CONSTRAINT fk_event_comment_event FOREIGN KEY (event_id) REFERENCES events(id) ON DELETE CASCADE;
ALTER TABLE event_comments ADD CONSTRAINT fk_event_comment_user FOREIGN KEY (user_id) REFERENCES users(id);
ALTER TABLE event_comments ADD CONSTRAINT fk_event_comment_parent FOREIGN KEY (parent_id) REFERENCES event_comments(id);

ALTER TABLE tours ADD CONSTRAINT fk_tour_operator FOREIGN KEY (operator_id) REFERENCES tour_operator_profiles(id);
ALTER TABLE tours ADD CONSTRAINT fk_tour_country FOREIGN KEY (country_id) REFERENCES countries(id);
ALTER TABLE tours ADD CONSTRAINT fk_tour_city FOREIGN KEY (city_id) REFERENCES cities(id);

ALTER TABLE tour_images ADD CONSTRAINT fk_tour_image_tour FOREIGN KEY (tour_id) REFERENCES tours(id) ON DELETE CASCADE;
ALTER TABLE tour_images ADD CONSTRAINT fk_tour_image_media FOREIGN KEY (media_id) REFERENCES media(id);

ALTER TABLE tour_schedules ADD CONSTRAINT fk_tour_schedule_tour FOREIGN KEY (tour_id) REFERENCES tours(id) ON DELETE CASCADE;

ALTER TABLE subscriptions ADD CONSTRAINT fk_subscription_user FOREIGN KEY (user_id) REFERENCES users(id);
ALTER TABLE subscriptions ADD CONSTRAINT fk_subscription_plan FOREIGN KEY (plan_id) REFERENCES subscription_plans(id);

ALTER TABLE subscription_invoices ADD CONSTRAINT fk_invoice_subscription FOREIGN KEY (subscription_id) REFERENCES subscriptions(id);

ALTER TABLE bookings ADD CONSTRAINT fk_booking_user FOREIGN KEY (user_id) REFERENCES users(id);
ALTER TABLE bookings ADD CONSTRAINT fk_booking_listing FOREIGN KEY (listing_id) REFERENCES listings(id);
ALTER TABLE bookings ADD CONSTRAINT fk_booking_event FOREIGN KEY (event_id) REFERENCES events(id);
ALTER TABLE bookings ADD CONSTRAINT fk_booking_tour FOREIGN KEY (tour_id) REFERENCES tours(id);
ALTER TABLE bookings ADD CONSTRAINT fk_booking_merchant FOREIGN KEY (merchant_id) REFERENCES merchant_profiles(id);
ALTER TABLE bookings ADD CONSTRAINT fk_booking_organizer FOREIGN KEY (organizer_id) REFERENCES organizer_profiles(id);
ALTER TABLE bookings ADD CONSTRAINT fk_booking_operator FOREIGN KEY (operator_id) REFERENCES tour_operator_profiles(id);
ALTER TABLE bookings ADD CONSTRAINT fk_booking_room_type FOREIGN KEY (room_type_id) REFERENCES room_types(id);
ALTER TABLE bookings ADD CONSTRAINT fk_booking_table FOREIGN KEY (table_id) REFERENCES restaurant_tables(id);

ALTER TABLE booking_guests ADD CONSTRAINT fk_booking_guest_booking FOREIGN KEY (booking_id) REFERENCES bookings(id) ON DELETE CASCADE;

ALTER TABLE booking_tickets ADD CONSTRAINT fk_booking_ticket_booking FOREIGN KEY (booking_id) REFERENCES bookings(id) ON DELETE CASCADE;
ALTER TABLE booking_tickets ADD CONSTRAINT fk_booking_ticket_type FOREIGN KEY (ticket_type_id) REFERENCES event_tickets(id);

ALTER TABLE zoea_cards ADD CONSTRAINT fk_zoea_card_user FOREIGN KEY (user_id) REFERENCES users(id);

ALTER TABLE transactions ADD CONSTRAINT fk_transaction_card FOREIGN KEY (card_id) REFERENCES zoea_cards(id);
ALTER TABLE transactions ADD CONSTRAINT fk_transaction_merchant FOREIGN KEY (merchant_id) REFERENCES merchant_profiles(id);
ALTER TABLE transactions ADD CONSTRAINT fk_transaction_booking FOREIGN KEY (booking_id) REFERENCES bookings(id);

ALTER TABLE payouts ADD CONSTRAINT fk_payout_user FOREIGN KEY (user_id) REFERENCES users(id);

ALTER TABLE reviews ADD CONSTRAINT fk_review_user FOREIGN KEY (user_id) REFERENCES users(id);
ALTER TABLE reviews ADD CONSTRAINT fk_review_listing FOREIGN KEY (listing_id) REFERENCES listings(id);
ALTER TABLE reviews ADD CONSTRAINT fk_review_event FOREIGN KEY (event_id) REFERENCES events(id);
ALTER TABLE reviews ADD CONSTRAINT fk_review_tour FOREIGN KEY (tour_id) REFERENCES tours(id);
ALTER TABLE reviews ADD CONSTRAINT fk_review_booking FOREIGN KEY (booking_id) REFERENCES bookings(id);

ALTER TABLE favorites ADD CONSTRAINT fk_favorite_user FOREIGN KEY (user_id) REFERENCES users(id);
ALTER TABLE favorites ADD CONSTRAINT fk_favorite_listing FOREIGN KEY (listing_id) REFERENCES listings(id);
ALTER TABLE favorites ADD CONSTRAINT fk_favorite_event FOREIGN KEY (event_id) REFERENCES events(id);
ALTER TABLE favorites ADD CONSTRAINT fk_favorite_tour FOREIGN KEY (tour_id) REFERENCES tours(id);

ALTER TABLE referrals ADD CONSTRAINT fk_referral_referrer FOREIGN KEY (referrer_id) REFERENCES users(id);
ALTER TABLE referrals ADD CONSTRAINT fk_referral_referred FOREIGN KEY (referred_id) REFERENCES users(id);

ALTER TABLE notifications ADD CONSTRAINT fk_notification_user FOREIGN KEY (user_id) REFERENCES users(id);

ALTER TABLE scheduled_notifications ADD CONSTRAINT fk_scheduled_template FOREIGN KEY (template_id) REFERENCES notification_templates(id);
ALTER TABLE scheduled_notifications ADD CONSTRAINT fk_scheduled_creator FOREIGN KEY (created_by) REFERENCES users(id);

ALTER TABLE notification_preferences ADD CONSTRAINT fk_notif_pref_user FOREIGN KEY (user_id) REFERENCES users(id);

ALTER TABLE notification_requests ADD CONSTRAINT fk_notif_req_requester FOREIGN KEY (requester_id) REFERENCES users(id);
ALTER TABLE notification_requests ADD CONSTRAINT fk_notif_req_merchant FOREIGN KEY (merchant_id) REFERENCES merchant_profiles(id);
ALTER TABLE notification_requests ADD CONSTRAINT fk_notif_req_organizer FOREIGN KEY (organizer_id) REFERENCES organizer_profiles(id);
ALTER TABLE notification_requests ADD CONSTRAINT fk_notif_req_reviewer FOREIGN KEY (reviewed_by) REFERENCES users(id);

ALTER TABLE content_approvals ADD CONSTRAINT fk_approval_submitter FOREIGN KEY (submitted_by) REFERENCES users(id);
ALTER TABLE content_approvals ADD CONSTRAINT fk_approval_reviewer FOREIGN KEY (reviewed_by) REFERENCES users(id);

ALTER TABLE approval_history ADD CONSTRAINT fk_approval_hist_approval FOREIGN KEY (approval_id) REFERENCES content_approvals(id);
ALTER TABLE approval_history ADD CONSTRAINT fk_approval_hist_user FOREIGN KEY (changed_by) REFERENCES users(id);

ALTER TABLE content_flags ADD CONSTRAINT fk_flag_reporter FOREIGN KEY (reporter_id) REFERENCES users(id);
ALTER TABLE content_flags ADD CONSTRAINT fk_flag_reviewer FOREIGN KEY (reviewed_by) REFERENCES users(id);

ALTER TABLE profile_views ADD CONSTRAINT fk_profile_view_viewer FOREIGN KEY (viewer_id) REFERENCES users(id);

ALTER TABLE content_views ADD CONSTRAINT fk_content_view_user FOREIGN KEY (user_id) REFERENCES users(id);

ALTER TABLE search_analytics ADD CONSTRAINT fk_search_user FOREIGN KEY (user_id) REFERENCES users(id);

ALTER TABLE faqs ADD CONSTRAINT fk_faq_category FOREIGN KEY (category_id) REFERENCES faq_categories(id);

ALTER TABLE support_tickets ADD CONSTRAINT fk_ticket_user FOREIGN KEY (user_id) REFERENCES users(id);
ALTER TABLE support_tickets ADD CONSTRAINT fk_ticket_assignee FOREIGN KEY (assigned_to) REFERENCES users(id);

ALTER TABLE support_messages ADD CONSTRAINT fk_message_ticket FOREIGN KEY (ticket_id) REFERENCES support_tickets(id);
ALTER TABLE support_messages ADD CONSTRAINT fk_message_sender FOREIGN KEY (sender_id) REFERENCES users(id);

ALTER TABLE promotions ADD CONSTRAINT fk_promotion_country FOREIGN KEY (country_id) REFERENCES countries(id);
ALTER TABLE promotions ADD CONSTRAINT fk_promotion_city FOREIGN KEY (city_id) REFERENCES cities(id);

ALTER TABLE coupons ADD CONSTRAINT fk_coupon_country FOREIGN KEY (country_id) REFERENCES countries(id);
ALTER TABLE coupons ADD CONSTRAINT fk_coupon_city FOREIGN KEY (city_id) REFERENCES cities(id);

ALTER TABLE coupon_uses ADD CONSTRAINT fk_coupon_use_coupon FOREIGN KEY (coupon_id) REFERENCES coupons(id);
ALTER TABLE coupon_uses ADD CONSTRAINT fk_coupon_use_user FOREIGN KEY (user_id) REFERENCES users(id);
ALTER TABLE coupon_uses ADD CONSTRAINT fk_coupon_use_booking FOREIGN KEY (booking_id) REFERENCES bookings(id);

ALTER TABLE user_content_preferences ADD CONSTRAINT fk_content_pref_user FOREIGN KEY (user_id) REFERENCES users(id);

ALTER TABLE user_payment_methods ADD CONSTRAINT fk_payment_method_user FOREIGN KEY (user_id) REFERENCES users(id);

ALTER TABLE audit_logs ADD CONSTRAINT fk_audit_user FOREIGN KEY (user_id) REFERENCES users(id);

-- ============================================
-- INDEXES
-- ============================================

CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_phone ON users(phone_number);
CREATE INDEX idx_users_country ON users(country_id);
CREATE INDEX idx_users_city ON users(city_id);
CREATE INDEX idx_users_referral_code ON users(referral_code);

CREATE INDEX idx_listings_merchant ON listings(merchant_id);
CREATE INDEX idx_listings_type ON listings(type);
CREATE INDEX idx_listings_status ON listings(status);
CREATE INDEX idx_listings_country ON listings(country_id);
CREATE INDEX idx_listings_city ON listings(city_id);
CREATE INDEX idx_listings_featured ON listings(is_featured) WHERE is_featured = true;

CREATE INDEX idx_events_organizer ON events(organizer_id);
CREATE INDEX idx_events_status ON events(status);
CREATE INDEX idx_events_dates ON events(start_date, end_date);
CREATE INDEX idx_events_country ON events(country_id);
CREATE INDEX idx_events_city ON events(city_id);
CREATE INDEX idx_events_featured ON events(is_featured) WHERE is_featured = true;

CREATE INDEX idx_tours_operator ON tours(operator_id);
CREATE INDEX idx_tours_status ON tours(status);
CREATE INDEX idx_tours_country ON tours(country_id);
CREATE INDEX idx_tours_city ON tours(city_id);

CREATE INDEX idx_bookings_user ON bookings(user_id);
CREATE INDEX idx_bookings_listing ON bookings(listing_id);
CREATE INDEX idx_bookings_event ON bookings(event_id);
CREATE INDEX idx_bookings_tour ON bookings(tour_id);
CREATE INDEX idx_bookings_status ON bookings(status);
CREATE INDEX idx_bookings_dates ON bookings(check_in_date, check_out_date);

CREATE INDEX idx_transactions_card ON transactions(card_id);
CREATE INDEX idx_transactions_type ON transactions(type);

CREATE INDEX idx_reviews_listing ON reviews(listing_id);
CREATE INDEX idx_reviews_event ON reviews(event_id);
CREATE INDEX idx_reviews_tour ON reviews(tour_id);
CREATE INDEX idx_reviews_user ON reviews(user_id);

CREATE INDEX idx_notifications_user ON notifications(user_id);
CREATE INDEX idx_notifications_read ON notifications(user_id, is_read);

CREATE INDEX idx_content_approvals_status ON content_approvals(status);
CREATE INDEX idx_content_approvals_type ON content_approvals(content_type);

CREATE INDEX idx_content_views_type ON content_views(content_type, content_id);
CREATE INDEX idx_content_views_date ON content_views(viewed_at);

CREATE INDEX idx_daily_stats_date ON daily_stats(date);
CREATE INDEX idx_daily_stats_entity ON daily_stats(entity_type, entity_id);

CREATE INDEX idx_audit_logs_user ON audit_logs(user_id);
CREATE INDEX idx_audit_logs_entity ON audit_logs(entity_type, entity_id);
CREATE INDEX idx_audit_logs_date ON audit_logs(created_at);

-- ============================================
-- FUNCTIONS & TRIGGERS
-- ============================================

CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS \$\$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
\$\$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION generate_booking_number()
RETURNS TRIGGER AS \$\$
BEGIN
    IF NEW.booking_number IS NULL THEN
        NEW.booking_number := 'BK' || TO_CHAR(NOW(), 'YYYYMMDD') || '-' || 
            UPPER(SUBSTRING(REPLACE(NEW.id::text, '-', ''), 1, 8));
    END IF;
    RETURN NEW;
END;
\$\$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION generate_ticket_code()
RETURNS TRIGGER AS \$\$
BEGIN
    IF NEW.ticket_code IS NULL THEN
        NEW.ticket_code := 'TK' || TO_CHAR(NOW(), 'YYYYMMDD') || '-' || 
            UPPER(SUBSTRING(REPLACE(NEW.id::text, '-', ''), 1, 8));
    END IF;
    RETURN NEW;
END;
\$\$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION generate_referral_code()
RETURNS TRIGGER AS \$\$
BEGIN
    IF NEW.referral_code IS NULL THEN
        NEW.referral_code := 'ZOE' || UPPER(SUBSTRING(REPLACE(NEW.id::text, '-', ''), 1, 6));
    END IF;
    RETURN NEW;
END;
\$\$ LANGUAGE plpgsql;

-- Apply triggers
CREATE TRIGGER trigger_users_updated_at BEFORE UPDATE ON users FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER trigger_listings_updated_at BEFORE UPDATE ON listings FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER trigger_events_updated_at BEFORE UPDATE ON events FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER trigger_tours_updated_at BEFORE UPDATE ON tours FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER trigger_bookings_updated_at BEFORE UPDATE ON bookings FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER trigger_generate_booking_number BEFORE INSERT ON bookings FOR EACH ROW EXECUTE FUNCTION generate_booking_number();
CREATE TRIGGER trigger_generate_ticket_code BEFORE INSERT ON booking_tickets FOR EACH ROW EXECUTE FUNCTION generate_ticket_code();
CREATE TRIGGER trigger_generate_referral_code BEFORE INSERT ON users FOR EACH ROW EXECUTE FUNCTION generate_referral_code();

-- ============================================
-- SEED DATA
-- ============================================

INSERT INTO languages (code, name, native_name) VALUES
('en', 'English', 'English'),
('fr', 'French', 'Français'),
('rw', 'Kinyarwanda', 'Ikinyarwanda'),
('sw', 'Swahili', 'Kiswahili');

INSERT INTO currencies (code, name, symbol, decimal_digits, exchange_rate_to_usd) VALUES
('RWF', 'Rwandan Franc', 'FRw', 0, 0.00076),
('USD', 'US Dollar', '\$', 2, 1.0),
('EUR', 'Euro', '€', 2, 1.08),
('KES', 'Kenyan Shilling', 'KSh', 2, 0.0077);

INSERT INTO timezones (name, abbreviation, utc_offset, utc_offset_minutes) VALUES
('Africa/Kigali', 'CAT', '+02:00', 120),
('Africa/Nairobi', 'EAT', '+03:00', 180),
('Europe/London', 'GMT', '+00:00', 0);

INSERT INTO countries (code, name, phone_code, currency_code) VALUES
('RWA', 'Rwanda', '+250', 'RWF'),
('KEN', 'Kenya', '+254', 'KES'),
('UGA', 'Uganda', '+256', 'UGX'),
('TZA', 'Tanzania', '+255', 'TZS');

INSERT INTO regions (country_id, code, name) 
SELECT id, 'KGL', 'Kigali' FROM countries WHERE code = 'RWA';

INSERT INTO cities (country_id, region_id, name, slug, timezone)
SELECT c.id, r.id, 'Kigali', 'kigali', 'Africa/Kigali'
FROM countries c, regions r WHERE c.code = 'RWA' AND r.code = 'KGL';

INSERT INTO categories (name, slug, icon, sort_order) VALUES
('Hotels & Resorts', 'hotels', 'hotel', 1),
('Restaurants & Cafes', 'restaurants', 'restaurant', 2),
('Bars & Nightlife', 'nightlife', 'local_bar', 3),
('Tours & Experiences', 'tours', 'explore', 4),
('Events & Entertainment', 'events', 'event', 5),
('Shopping', 'shopping', 'shopping_bag', 6);

INSERT INTO event_contexts (name, slug, icon) VALUES
('Music & Concerts', 'music', 'music_note'),
('Conferences & Seminars', 'conferences', 'business'),
('Sports & Fitness', 'sports', 'sports'),
('Food & Drink', 'food-drink', 'restaurant'),
('Arts & Culture', 'arts', 'palette'),
('Networking', 'networking', 'people');

INSERT INTO amenities (name, slug, icon, category, applicable_types) VALUES
('WiFi', 'wifi', 'wifi', 'general', '{hotel,restaurant,cafe}'),
('Parking', 'parking', 'local_parking', 'general', '{hotel,restaurant,bar,club}'),
('Pool', 'pool', 'pool', 'property', '{hotel}'),
('Gym', 'gym', 'fitness_center', 'property', '{hotel}'),
('Spa', 'spa', 'spa', 'property', '{hotel}'),
('Air Conditioning', 'ac', 'ac_unit', 'room', '{hotel,restaurant}'),
('Outdoor Seating', 'outdoor-seating', 'deck', 'dining', '{restaurant,cafe,bar}'),
('Live Music', 'live-music', 'music_note', 'entertainment', '{restaurant,bar,club}');

INSERT INTO subscription_plans (name, slug, description, price, currency, interval, features, applicable_roles) VALUES
('Basic', 'basic', 'Perfect for small businesses', 50000, 'RWF', 'monthly', 
 '{"max_listings": 3, "featured_listings": 0, "analytics": false}', '{merchant}'),
('Professional', 'professional', 'For growing businesses', 150000, 'RWF', 'monthly',
 '{"max_listings": 10, "featured_listings": 2, "analytics": true}', '{merchant}'),
('Enterprise', 'enterprise', 'For large organizations', 500000, 'RWF', 'monthly',
 '{"max_listings": -1, "featured_listings": 10, "analytics": true}', '{merchant}');

INSERT INTO commission_rules (name, listing_type, percentage, is_active, priority) VALUES
('Default Hotel Commission', 'hotel', 15.00, true, 0),
('Default Restaurant Commission', 'restaurant', 10.00, true, 0),
('Default Tour Commission', 'tour', 12.00, true, 0);

INSERT INTO notification_templates (code, name, type, title_template, body_template, send_push, send_email) VALUES
('booking_confirmed', 'Booking Confirmed', 'booking', 'Booking Confirmed! 🎉', 'Your booking #{{booking_number}} has been confirmed.', true, true),
('booking_cancelled', 'Booking Cancelled', 'booking', 'Booking Cancelled', 'Your booking #{{booking_number}} has been cancelled.', true, true),
('payment_received', 'Payment Received', 'payment', 'Payment Received', 'We received your payment of {{amount}} {{currency}}.', true, true);

INSERT INTO faq_categories (name, slug, icon, sort_order) VALUES
('Getting Started', 'getting-started', 'rocket_launch', 1),
('Account & Profile', 'account-profile', 'person', 2),
('Bookings & Events', 'bookings-events', 'event', 3),
('Payment & Refunds', 'payment-refunds', 'payment', 4);

INSERT INTO app_config (key, value, description, is_public) VALUES
('default_currency', '"RWF"', 'Default currency for the app', true),
('supported_currencies', '["RWF", "USD", "EUR"]', 'Supported currencies', true),
('booking_fee_percentage', '5', 'Platform booking fee percentage', false),
('min_payout_amount', '10000', 'Minimum payout amount in RWF', false);

