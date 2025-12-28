// Database Model Types

export interface User {
  user_id: number;
  venue_id?: number;
  account_type: string;
  user_fname?: string;
  user_lname?: string;
  user_email?: string;
  user_phone?: string;
  user_status: string;
  user_reg_date: string;
}

export interface Admin {
  admin_id: number;
  admin_email: string;
  admin_phone: string;
  admin_name: string;
  admin_status: string;
}

export interface Venue {
  venue_id: number;
  user_id: number;
  category_id: number;
  venue_name: string;
  venue_about: string;
  venue_rating: number;
  venue_reviews: number;
  venue_status: string;
  venue_price: number;
  venue_address: string;
  venue_coordinates: string;
}

export interface Property {
  property_id: number;
  location_id: string;
  agent_id?: number;
  category: 'Apartment' | 'House' | 'Commercial' | 'Land' | 'Development';
  bedrooms?: number;
  bathrooms?: number;
  size?: number;
  price: number;
  property_type: 'sale' | 'rent' | 'booking';
  status: 'available' | 'sold' | 'rented';
  title: string;
  address?: string;
}

export interface Application {
  id: number;
  event: string;
  title: string;
  first_name: string;
  last_name: string;
  organization: string;
  work_title: string;
  phone: string;
  email: string;
  status: string;
  updated_date: string;
}

export interface Order {
  id: number;
  order_no: string;
  customer_id: number;
  seller_id: number;
  total_amount: number;
  currency: string;
  status: 'pending' | 'confirmed' | 'processing' | 'shipped' | 'delivered' | 'cancelled';
  order_date: string;
}

export interface Merchant {
  merchant_id: number;
  user_id?: number;
  merchant_name: string;
  merchant_types: ('hotel' | 'restaurant' | 'venue' | 'shop' | 'service' | 'other')[];
  business_email: string;
  business_phone: string;
  business_address: string;
  business_description?: string;
  tax_id?: string;
  license_number?: string;
  rating: number;
  total_reviews: number;
  total_listings: number;
  status: 'active' | 'inactive' | 'pending' | 'suspended';
  created_date: string;
  updated_date?: string;
}

export interface MerchantListing {
  listing_id: number;
  merchant_id: number;
  listing_type: 'hotel' | 'restaurant' | 'venue' | 'product' | 'service';
  listing_name: string;
  description: string;
  price: number;
  currency: string;
  category?: string;
  images?: string[];
  amenities?: string[];
  capacity?: number;
  availability: 'available' | 'unavailable' | 'booked';
  rating: number;
  reviews_count: number;
  status: 'active' | 'inactive' | 'draft';
  created_date: string;
  updated_date?: string;
}

// Dashboard Data Types

export interface DashboardStats {
  totalUsers: number;
  activeUsers: number;
  totalVenues: number;
  activeVenues: number;
  totalProperties: number;
  totalEvents: number;
  totalOrders: number;
  totalRevenue: number;
}

export interface ChartDataPoint {
  name: string;
  value: number;
  [key: string]: string | number;
}

