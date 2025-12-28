# Zoea Database Schema

## Overview
Complete PostgreSQL database schema for the Zoea mobile app - a tourism, hospitality, and events platform for Rwanda and beyond.

## Server Details
- **Server IP:** 172.16.40.61
- **Database:** PostgreSQL 16 with PostGIS
- **Container:** Docker (postgis/postgis:16-3.4)
- **Database Name:** main
- **User:** admin
- **Password:** Zoea2025Secure
- **Port:** 5432

## Connection String
```
postgresql://admin:Zoea2025Secure@172.16.40.61:5432/main
```

## Schema Files
- `zoea_complete_schema.sql` - Original comprehensive schema (has dependency ordering issues)
- `zoea_schema_fixed.sql` - Fixed schema with proper table ordering and FK constraints added after table creation

## Database Statistics
- **77 Tables**
- **31 ENUM Types**
- **4 Auto-generation Triggers**
- **43+ Indexes**
- **PostGIS enabled** for geolocation

## Key Features

### User Management
- Multi-role users (explorer, merchant, event_organizer, tour_operator, admin)
- Role-specific profiles (merchant_profiles, organizer_profiles, tour_operator_profiles)
- User preferences, payment methods, referrals

### Listings & Businesses
- Multiple listing types (hotel, restaurant, bar, club, cafe, mall, etc.)
- Room types and availability for hotels
- Restaurant tables and reservation time slots
- Operating hours, amenities, tags

### Events
- Event contexts (music, conferences, sports, etc.)
- Ticket types (free, paid, VIP, early_bird)
- Attendees, likes, comments
- MICE support (Meetings, Incentives, Conferences, Exhibitions)

### Tours & Experiences
- Tour operator profiles
- Tour schedules and availability
- Difficulty levels, group sizes

### Bookings
- Unified booking system for hotels, restaurants, tours, events
- Auto-generated booking numbers (BK20251127-XXXXXXXX)
- Guest management, special requests
- Payment tracking

### Zoea Card (Digital Wallet)
- Balance management
- Transaction history
- Multiple transaction types (deposit, withdrawal, payment, refund, etc.)

### Subscriptions & Payouts
- Subscription plans for merchants/organizers
- Commission rules by listing type
- Payout management

### Content Moderation
- Approval workflow for listings, events, notifications
- Content flags and reporting
- Moderation rules

### Analytics & Reporting
- Profile views, content views
- Search analytics
- Daily stats per entity
- Platform-wide daily stats
- Trending content

### Multi-Country Support
- Countries, regions, cities, districts
- User content preferences by location
- Currency and timezone support

### Notifications
- Notification templates
- Scheduled notifications
- Push/email/SMS preferences
- Business notification requests (with admin approval)

## Auto-Generated Fields
| Table | Field | Format |
|-------|-------|--------|
| users | referral_code | ZOE + 6 chars (e.g., ZOE101097) |
| bookings | booking_number | BK + YYYYMMDD + - + 8 chars |
| booking_tickets | ticket_code | TK + YYYYMMDD + - + 8 chars |

## CHECK Constraints
- `bookings`: check_out >= check_in, guest_count > 0, total_amount >= 0
- `events`: end_date >= start_date, max_attendance > 0
- `event_tickets`: price >= 0, quantity >= 0, max >= min per order
- `tours`: price >= 0, max_group >= min_group, rating 0-5
- `room_types`: base_price >= 0, total_rooms > 0
- `restaurant_tables`: capacity > 0, min_capacity > 0

## Seed Data Included
- Languages (English, French, Kinyarwanda, Swahili)
- Currencies (RWF, USD, EUR, KES)
- Timezones (Africa/Kigali, Africa/Nairobi, Europe/London)
- Countries (Rwanda, Kenya, Uganda, Tanzania)
- Kigali city with region
- Categories (Hotels, Restaurants, Nightlife, Tours, Events, Shopping)
- Event contexts (Music, Conferences, Sports, Food, Arts, Networking)
- Amenities (WiFi, Parking, Pool, Gym, Spa, AC, etc.)
- Subscription plans (Basic, Professional, Enterprise)
- Commission rules (Hotel 15%, Restaurant 10%, Tour 12%)
- Notification templates
- FAQ categories
- App config

## Docker Commands

### Start PostgreSQL
```bash
docker run -d --name postgres --restart always \
  -e POSTGRES_DB=main \
  -e POSTGRES_USER=admin \
  -e POSTGRES_PASSWORD=Zoea2025Secure \
  -p 5432:5432 \
  -v postgres_data:/var/lib/postgresql/data \
  postgis/postgis:16-3.4
```

### Connect to Database
```bash
docker exec -it postgres psql -U admin -d main
```

### Run Schema
```bash
docker cp zoea_schema_fixed.sql postgres:/tmp/
docker exec -i postgres psql -U admin -d main -f /tmp/zoea_schema_fixed.sql
```

## Table Categories

### Core
- users, media, categories, amenities, tags

### Geographic
- countries, regions, cities, districts, languages, currencies, timezones

### Profiles
- merchant_profiles, organizer_profiles, tour_operator_profiles

### Listings
- listings, listing_images, listing_amenities, listing_tags, operating_hours
- room_types, rooms, room_availability
- restaurant_tables, reservation_time_slots

### Events
- events, event_attachments, event_tickets, event_attendees
- event_likes, event_comments, event_contexts

### Tours
- tours, tour_images, tour_schedules

### Bookings
- bookings, booking_guests, booking_tickets

### Payments
- zoea_cards, transactions, payouts, commission_rules
- subscriptions, subscription_plans, subscription_invoices
- coupons, coupon_uses, user_payment_methods

### Reviews & Social
- reviews, favorites, referrals

### Notifications
- notifications, notification_templates, notification_preferences
- scheduled_notifications, notification_requests

### Moderation
- content_approvals, approval_history, moderation_rules, content_flags

### Analytics
- profile_views, content_views, search_analytics
- daily_stats, platform_daily_stats, trending_content

### Support
- faq_categories, faqs, support_tickets, support_messages

### Config
- app_config, promotions, user_content_preferences, audit_logs

## Created
- **Date:** November 27, 2025
- **Version:** 1.0

