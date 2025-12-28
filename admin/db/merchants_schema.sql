-- Merchants Management Module Database Schema
-- This file contains the necessary tables for the merchants management system

-- Table: merchants
-- Stores merchant/business information
CREATE TABLE IF NOT EXISTS `merchants` (
  `merchant_id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) DEFAULT NULL,
  `merchant_name` varchar(255) NOT NULL,
  `merchant_type` enum('hotel','restaurant','venue','shop','service','other') NOT NULL DEFAULT 'other',
  `business_email` varchar(255) NOT NULL,
  `business_phone` varchar(50) NOT NULL,
  `business_address` text NOT NULL,
  `business_description` text DEFAULT NULL,
  `tax_id` varchar(100) DEFAULT NULL,
  `license_number` varchar(100) DEFAULT NULL,
  `rating` decimal(3,2) NOT NULL DEFAULT 0.00,
  `total_reviews` int(11) NOT NULL DEFAULT 0,
  `status` enum('active','inactive','pending','suspended') NOT NULL DEFAULT 'pending',
  `created_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_date` timestamp NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`merchant_id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_merchant_type` (`merchant_type`),
  KEY `idx_status` (`status`),
  KEY `idx_created_date` (`created_date`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Table: merchant_listings
-- Stores listings for merchants (hotel rooms, restaurant tables, venue spaces, etc.)
CREATE TABLE IF NOT EXISTS `merchant_listings` (
  `listing_id` int(11) NOT NULL AUTO_INCREMENT,
  `merchant_id` int(11) NOT NULL,
  `listing_type` enum('hotel','restaurant','venue','product','service') NOT NULL,
  `listing_name` varchar(255) NOT NULL,
  `description` text NOT NULL,
  `price` decimal(10,2) NOT NULL,
  `currency` varchar(10) NOT NULL DEFAULT 'RWF',
  `category` varchar(100) DEFAULT NULL,
  `capacity` int(11) DEFAULT NULL,
  `availability` enum('available','unavailable','booked') NOT NULL DEFAULT 'available',
  `rating` decimal(3,2) NOT NULL DEFAULT 0.00,
  `reviews_count` int(11) NOT NULL DEFAULT 0,
  `status` enum('active','inactive','draft') NOT NULL DEFAULT 'draft',
  `created_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_date` timestamp NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`listing_id`),
  KEY `idx_merchant_id` (`merchant_id`),
  KEY `idx_listing_type` (`listing_type`),
  KEY `idx_status` (`status`),
  KEY `idx_availability` (`availability`),
  CONSTRAINT `fk_merchant_listings_merchant` FOREIGN KEY (`merchant_id`) REFERENCES `merchants` (`merchant_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Table: merchant_images
-- Stores images for merchants and their listings
CREATE TABLE IF NOT EXISTS `merchant_images` (
  `image_id` int(11) NOT NULL AUTO_INCREMENT,
  `merchant_id` int(11) DEFAULT NULL,
  `listing_id` int(11) DEFAULT NULL,
  `image_url` text NOT NULL,
  `image_type` enum('logo','cover','gallery','listing') NOT NULL DEFAULT 'gallery',
  `is_primary` tinyint(1) NOT NULL DEFAULT 0,
  `sort_order` int(11) NOT NULL DEFAULT 0,
  `created_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`image_id`),
  KEY `idx_merchant_id` (`merchant_id`),
  KEY `idx_listing_id` (`listing_id`),
  CONSTRAINT `fk_merchant_images_merchant` FOREIGN KEY (`merchant_id`) REFERENCES `merchants` (`merchant_id`) ON DELETE CASCADE,
  CONSTRAINT `fk_merchant_images_listing` FOREIGN KEY (`listing_id`) REFERENCES `merchant_listings` (`listing_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Sample data for testing
INSERT INTO `merchants` (`merchant_name`, `merchant_type`, `business_email`, `business_phone`, `business_address`, `business_description`, `tax_id`, `license_number`, `rating`, `total_reviews`, `status`) VALUES
('Serena Hotel Kigali', 'hotel', 'info@serenahotel.rw', '+250788123456', 'KN 3 Ave, Kigali', 'Luxury 5-star hotel in the heart of Kigali with world-class amenities and service.', 'TAX001', 'HTL001', 4.80, 245, 'active'),
('Heaven Restaurant', 'restaurant', 'contact@heavenrestaurant.rw', '+250788234567', 'KG 7 Ave, Kimihurura', 'Fine dining restaurant offering international cuisine with a beautiful city view.', 'TAX002', 'RST001', 4.50, 189, 'active'),
('Kigali Conference Center', 'venue', 'bookings@kcc.rw', '+250788345678', 'KN 4 Ave, Kigali', 'State-of-the-art conference and event center with multiple halls and meeting rooms.', 'TAX003', 'VEN001', 4.70, 156, 'active'),
('Lake Kivu Serena Hotel', 'hotel', 'lakeserena@serenahotel.rw', '+250788456789', 'Gisenyi, Lake Kivu', 'Beautiful lakeside resort hotel with stunning views and premium facilities.', 'TAX004', 'HTL002', 4.60, 198, 'active'),
('The Hut Restaurant', 'restaurant', 'info@thehut.rw', '+250788567890', 'KG 5 Ave, Kigali', 'Cozy restaurant serving authentic Rwandan cuisine and international dishes.', 'TAX005', 'RST002', 4.30, 134, 'active');

-- Sample listings for the merchants
INSERT INTO `merchant_listings` (`merchant_id`, `listing_type`, `listing_name`, `description`, `price`, `currency`, `category`, `capacity`, `availability`, `rating`, `reviews_count`, `status`) VALUES
(1, 'hotel', 'Standard Room', 'Comfortable room with queen bed, ensuite bathroom, and city view.', 150000, 'RWF', 'Standard', 2, 'available', 4.50, 89, 'active'),
(1, 'hotel', 'Deluxe Suite', 'Spacious suite with king bed, living area, and premium amenities.', 300000, 'RWF', 'Deluxe', 2, 'available', 4.90, 67, 'active'),
(1, 'hotel', 'Presidential Suite', 'Luxurious presidential suite with panoramic views and exclusive services.', 600000, 'RWF', 'Premium', 4, 'available', 5.00, 23, 'active'),
(2, 'restaurant', 'Table for 2', 'Intimate table for two in our main dining area.', 0, 'RWF', 'Standard', 2, 'available', 4.40, 45, 'active'),
(2, 'restaurant', 'Private Dining Room', 'Exclusive private dining room for special occasions.', 50000, 'RWF', 'Premium', 8, 'available', 4.70, 28, 'active'),
(3, 'venue', 'Main Conference Hall', 'Large conference hall with seating for up to 500 people.', 500000, 'RWF', 'Large', 500, 'available', 4.80, 56, 'active'),
(3, 'venue', 'Meeting Room A', 'Medium-sized meeting room perfect for corporate meetings.', 150000, 'RWF', 'Medium', 30, 'available', 4.60, 34, 'active'),
(4, 'hotel', 'Lakeside Room', 'Room with direct lake view and private balcony.', 180000, 'RWF', 'Standard', 2, 'available', 4.70, 78, 'active'),
(4, 'hotel', 'Family Suite', 'Spacious suite with two bedrooms, perfect for families.', 350000, 'RWF', 'Family', 4, 'available', 4.60, 45, 'active'),
(5, 'restaurant', 'Outdoor Terrace Table', 'Table on our beautiful outdoor terrace.', 0, 'RWF', 'Standard', 4, 'available', 4.30, 67, 'active');

