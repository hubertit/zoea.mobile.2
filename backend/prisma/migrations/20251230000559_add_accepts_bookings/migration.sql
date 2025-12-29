-- AlterTable
ALTER TABLE "listings" ADD COLUMN IF NOT EXISTS "accepts_bookings" BOOLEAN DEFAULT false;
