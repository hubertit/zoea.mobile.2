# Merchants Management Module

## Overview
Comprehensive merchants management system for hotels, restaurants, venues, shops, and service providers with full CRUD operations and listings management.

## Features

### 1. Merchant Management
- **List View**: Display all merchants with filtering and sorting
- **Create**: Add new merchants with detailed business information
- **Read**: View merchant details and their listings
- **Update**: Edit merchant information
- **Delete**: Soft delete merchants (sets status to inactive)

### 2. Merchant Listings
- Create multiple listings per merchant
- Support for different listing types:
  - **Hotels**: Rooms, suites, accommodations
  - **Restaurants**: Tables, dining spaces, menus
  - **Venues**: Event spaces, conference halls
  - **Products**: Shop items
  - **Services**: Various services offered

### 3. Filtering & Search
- Filter by merchant type (hotel, restaurant, venue, shop, service)
- Filter by status (active, pending, inactive, suspended)
- Sort by any column
- View ratings and reviews

## Database Schema

### Tables Created

#### 1. `merchants` Table
Stores merchant/business information:
- `merchant_id` (Primary Key)
- `user_id` (Optional link to user account)
- `merchant_name` (Business name)
- `merchant_type` (hotel, restaurant, venue, shop, service, other)
- `business_email`
- `business_phone`
- `business_address`
- `business_description`
- `tax_id`
- `license_number`
- `rating` (0.00 - 5.00)
- `total_reviews`
- `status` (active, inactive, pending, suspended)
- `created_date`
- `updated_date`

#### 2. `merchant_listings` Table
Stores listings for each merchant:
- `listing_id` (Primary Key)
- `merchant_id` (Foreign Key)
- `listing_type` (hotel, restaurant, venue, product, service)
- `listing_name`
- `description`
- `price`
- `currency` (RWF, USD, EUR, GBP)
- `category`
- `capacity`
- `availability` (available, unavailable, booked)
- `rating` (0.00 - 5.00)
- `reviews_count`
- `status` (active, inactive, draft)
- `created_date`
- `updated_date`

#### 3. `merchant_images` Table
Stores images for merchants and listings:
- `image_id` (Primary Key)
- `merchant_id` (Foreign Key, optional)
- `listing_id` (Foreign Key, optional)
- `image_url`
- `image_type` (logo, cover, gallery, listing)
- `is_primary`
- `sort_order`
- `created_date`

## Installation

### 1. Run Database Migration
Execute the SQL schema file to create the necessary tables:
```bash
mysql -u your_username -p your_database < db/merchants_schema.sql
```

Or manually run the SQL in phpMyAdmin or your preferred database tool.

### 2. Sample Data
The schema file includes sample data for 5 merchants and 10 listings to help you get started.

## API Endpoints

### Merchants

#### GET `/api/merchants`
Fetch all merchants with optional filtering:
- Query params: `status`, `type`, `limit`
- Example: `/api/merchants?status=active&type=hotel&limit=50`

#### GET `/api/merchants/[id]`
Fetch a single merchant by ID

#### POST `/api/merchants`
Create a new merchant
```json
{
  "merchant_name": "Amazing Hotel",
  "merchant_type": "hotel",
  "business_email": "info@hotel.com",
  "business_phone": "+250788123456",
  "business_address": "KN 123 St, Kigali",
  "business_description": "Luxury hotel...",
  "tax_id": "TAX123",
  "license_number": "LIC123",
  "status": "pending"
}
```

#### PUT `/api/merchants`
Update a merchant
```json
{
  "merchant_id": 1,
  "merchant_name": "Updated Name",
  "status": "active"
}
```

#### DELETE `/api/merchants?merchant_id=[id]`
Soft delete a merchant (sets status to inactive)

### Merchant Listings

#### GET `/api/merchants/[id]/listings`
Fetch all listings for a merchant
- Query params: `type`, `status`
- Example: `/api/merchants/1/listings?type=hotel&status=active`

#### POST `/api/merchants/[id]/listings`
Create a new listing for a merchant
```json
{
  "listing_type": "hotel",
  "listing_name": "Deluxe Suite",
  "description": "Spacious suite with...",
  "price": 300000,
  "currency": "RWF",
  "category": "Deluxe",
  "capacity": 2,
  "availability": "available",
  "status": "active"
}
```

## Admin Pages

### Main Merchants Page
**Path**: `/admin/merchants`
- Lists all merchants with stats
- Filtering by type and status
- Sorting capabilities
- Quick actions: View, Edit, Delete

### Create Merchant
**Path**: `/admin/merchants/create`
- Form to add new merchant
- All required and optional fields
- Validation

### Merchant Detail
**Path**: `/admin/merchants/[id]`
- View complete merchant information
- Display all listings for the merchant
- Quick link to add new listings
- Edit merchant button

### Edit Merchant
**Path**: `/admin/merchants/[id]/edit`
- Form to update merchant information
- Pre-filled with current data
- Validation

### Create Listing
**Path**: `/admin/merchants/[id]/listings/create`
- Form to add new listing for a merchant
- Support for all listing types
- Helpful examples and guidance

## Usage Examples

### Hotels
- Create merchant with type "hotel"
- Add listings for different room types:
  - Standard Room (2 capacity, $150/night)
  - Deluxe Suite (2 capacity, $300/night)
  - Presidential Suite (4 capacity, $600/night)

### Restaurants
- Create merchant with type "restaurant"
- Add listings for:
  - Table for 2 (free or reservation fee)
  - Table for 4
  - Private dining room (with fee)

### Venues
- Create merchant with type "venue"
- Add listings for:
  - Conference Hall (500 capacity, $5000/day)
  - Meeting Room A (30 capacity, $1500/day)
  - Wedding Venue (200 capacity, $8000/event)

### Shops
- Create merchant with type "shop"
- Add product listings with prices

### Service Providers
- Create merchant with type "service"
- Add service listings (spa, tours, activities)

## Color Coding

The interface uses color-coded badges for better UX:

### Status Colors
- **Active**: Green
- **Pending**: Yellow
- **Inactive**: Gray
- **Suspended**: Red

### Type Colors
- **Hotel**: Blue
- **Restaurant**: Orange
- **Venue**: Purple
- **Shop**: Pink
- **Service**: Teal
- **Other**: Gray

## Navigation

The Merchants module is accessible from the admin sidebar:
- **Merchants** (main menu item)
  - All Merchants
  - Add Merchant

## Future Enhancements

Potential features to add:
1. Image upload functionality
2. Merchant analytics dashboard
3. Review management
4. Booking integration
5. Payment processing
6. Multi-language support
7. Advanced search with location-based filtering
8. Merchant verification system
9. Commission and fee management
10. Integration with existing venues/users system

## File Structure

```
src/
├── app/
│   ├── admin/
│   │   └── merchants/
│   │       ├── page.tsx                      # List all merchants
│   │       ├── create/
│   │       │   └── page.tsx                  # Create merchant
│   │       └── [id]/
│   │           ├── page.tsx                  # View merchant
│   │           ├── edit/
│   │           │   └── page.tsx              # Edit merchant
│   │           └── listings/
│   │               └── create/
│   │                   └── page.tsx          # Create listing
│   ├── api/
│   │   └── merchants/
│   │       ├── route.ts                      # Merchants CRUD
│   │       ├── [id]/
│   │       │   ├── route.ts                  # Single merchant
│   │       │   └── listings/
│   │       │       └── route.ts              # Listings CRUD
│   └── components/
│       └── AdminSidebar.tsx                  # Updated with merchants link
├── types/
│   └── index.ts                              # Merchant & MerchantListing types
└── db/
    └── merchants_schema.sql                  # Database schema & sample data
```

## Support

For questions or issues with the Merchants Management Module, please refer to:
- Database schema: `db/merchants_schema.sql`
- API documentation: This file
- Type definitions: `src/types/index.ts`

## Project Color Scheme

Primary color: `#004643` (as per project settings)

