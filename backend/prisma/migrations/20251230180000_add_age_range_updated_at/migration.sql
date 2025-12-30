-- Migration: Add age_range_updated_at field to users table
-- Created: 2024-12-30
-- Description: Tracks when age range was last updated for auto-update functionality

-- Add age_range_updated_at column
ALTER TABLE users 
  ADD COLUMN IF NOT EXISTS age_range_updated_at TIMESTAMPTZ;

-- Add comment for documentation
COMMENT ON COLUMN users.age_range_updated_at IS 'Timestamp when age range was last calculated/updated. Used for auto-updating age range from date of birth.';

-- Set initial value for existing users with ageRange
UPDATE users 
SET age_range_updated_at = updated_at 
WHERE age_range IS NOT NULL AND age_range_updated_at IS NULL;

