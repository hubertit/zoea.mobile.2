-- Migration: Add UX-First User Data Collection fields to users table
-- Created: 2024-12-30
-- Description: Adds fields for UX-first user data collection module

-- Add new columns to users table
ALTER TABLE users 
  ADD COLUMN IF NOT EXISTS country_of_origin VARCHAR(3),
  ADD COLUMN IF NOT EXISTS user_type VARCHAR(20),
  ADD COLUMN IF NOT EXISTS visit_purpose VARCHAR(20),
  ADD COLUMN IF NOT EXISTS age_range VARCHAR(10),
  ADD COLUMN IF NOT EXISTS length_of_stay VARCHAR(20),
  ADD COLUMN IF NOT EXISTS travel_party VARCHAR(20),
  ADD COLUMN IF NOT EXISTS data_collection_flags JSONB DEFAULT '{}',
  ADD COLUMN IF NOT EXISTS data_collection_completed_at TIMESTAMPTZ;

-- Add comments for documentation
COMMENT ON COLUMN users.country_of_origin IS 'ISO country code (e.g., RW, US) for user origin';
COMMENT ON COLUMN users.user_type IS 'User type: resident or visitor';
COMMENT ON COLUMN users.visit_purpose IS 'Visit purpose: leisure, business, or mice';
COMMENT ON COLUMN users.age_range IS 'Age range: 18-25, 26-35, 36-45, 46-55, 56+';
COMMENT ON COLUMN users.length_of_stay IS 'Length of stay: 1-3 days, 4-7 days, 1-2 weeks, 2+ weeks';
COMMENT ON COLUMN users.travel_party IS 'Travel party: solo, couple, family, group';
COMMENT ON COLUMN users.data_collection_flags IS 'JSON object tracking which data collection prompts have been shown';
COMMENT ON COLUMN users.data_collection_completed_at IS 'Timestamp when mandatory data collection was completed';

