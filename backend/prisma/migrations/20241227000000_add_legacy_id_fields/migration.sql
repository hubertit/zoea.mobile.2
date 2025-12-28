-- AlterTable: Add legacy_id and password migration fields to users
ALTER TABLE "users" ADD COLUMN IF NOT EXISTS "legacy_id" INTEGER;
ALTER TABLE "users" ADD COLUMN IF NOT EXISTS "legacy_password_hash" VARCHAR(255);
ALTER TABLE "users" ADD COLUMN IF NOT EXISTS "password_migrated" BOOLEAN DEFAULT false;

-- Create unique index on legacy_id for users
CREATE UNIQUE INDEX IF NOT EXISTS "idx_users_legacy_id" ON "users"("legacy_id") WHERE "legacy_id" IS NOT NULL;

-- AlterTable: Add legacy_id to listings
ALTER TABLE "listings" ADD COLUMN IF NOT EXISTS "legacy_id" INTEGER;

-- Create unique index on legacy_id for listings
CREATE UNIQUE INDEX IF NOT EXISTS "idx_listings_legacy_id" ON "listings"("legacy_id") WHERE "legacy_id" IS NOT NULL;

-- AlterTable: Add legacy_id to bookings
ALTER TABLE "bookings" ADD COLUMN IF NOT EXISTS "legacy_id" INTEGER;

-- Create unique index on legacy_id for bookings
CREATE UNIQUE INDEX IF NOT EXISTS "idx_bookings_legacy_id" ON "bookings"("legacy_id") WHERE "legacy_id" IS NOT NULL;

-- AlterTable: Add legacy_id to reviews
ALTER TABLE "reviews" ADD COLUMN IF NOT EXISTS "legacy_id" INTEGER;

-- Create unique index on legacy_id for reviews
CREATE UNIQUE INDEX IF NOT EXISTS "idx_reviews_legacy_id" ON "reviews"("legacy_id") WHERE "legacy_id" IS NOT NULL;

-- AlterTable: Add legacy_id to favorites
ALTER TABLE "favorites" ADD COLUMN IF NOT EXISTS "legacy_id" INTEGER;

-- Create unique index on legacy_id for favorites
CREATE UNIQUE INDEX IF NOT EXISTS "idx_favorites_legacy_id" ON "favorites"("legacy_id") WHERE "legacy_id" IS NOT NULL;

-- AlterTable: Add legacy_id to events
ALTER TABLE "events" ADD COLUMN IF NOT EXISTS "legacy_id" INTEGER;

-- Create unique index on legacy_id for events
CREATE UNIQUE INDEX IF NOT EXISTS "idx_events_legacy_id" ON "events"("legacy_id") WHERE "legacy_id" IS NOT NULL;

-- AlterTable: Add legacy_id to event_attendees
ALTER TABLE "event_attendees" ADD COLUMN IF NOT EXISTS "legacy_id" INTEGER;

-- Create unique index on legacy_id for event_attendees
CREATE UNIQUE INDEX IF NOT EXISTS "idx_event_attendees_legacy_id" ON "event_attendees"("legacy_id") WHERE "legacy_id" IS NOT NULL;

