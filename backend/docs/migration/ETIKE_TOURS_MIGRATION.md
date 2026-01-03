# Etike (Legacy) → Zoea Tours Migration Notes

This document analyzes the legacy dump file located at `~/Desktop/etike.sql` (MariaDB/phpMyAdmin) and proposes a migration strategy into Zoea’s PostgreSQL schema (Prisma).

## What’s in the legacy DB (tour-relevant)

### `users` (tour operators live here)
- Key columns
  - `user_id` (PK)
  - `name`, `phone`, `email`
  - `bio` (often contains the operator description)
  - `profile_pic` (URL, nullable)
  - `role` enum includes `tour_operator`
  - `status` enum includes `active|inactive|banned`
  - `code` (looks like a slug/code sometimes)
- Notes
  - Passwords are inconsistent (some bcrypt `$2y$…`, some plain/empty). Treat as **untrusted**.

### `tour_packages` (the “tour products”)
- Key columns
  - `id` (PK)
  - `code` (URL-friendly slug)
  - `name`
  - `description` (mixed HTML/plain text; contains inclusions/exclusions/itinerary in many rows)
  - `base_price` (decimal)
  - `cover_image` (URL)
  - `seller_id` (tour operator id; appears to match `users.user_id`)
  - `status` enum `active|inactive|draft|deleted`

### `tour_package_categories`
- Key columns: `id`, `code` (slug), `name`, `description`, `cover_image`, `status`

### `tour_package_category_relations`
- Many-to-many between packages and categories:
  - `package_id` → `tour_packages.id`
  - `category_id` → `tour_package_categories.id`

### `tour_package_options` (pricing variants / tiers)
- Key columns
  - `package_id`
  - `name` (e.g. “Standard”, “2 people”, “Half Day – 1 Person”)
  - `description`
  - `price`
- This is not a schedule; it’s closer to **variants**.

### `tour_bookings` (optional to import)
- Key columns
  - `booking_code`
  - `package_id` (tour package)
  - `customer_id` (legacy customers table)
  - `operator_id` (tour operator id)
  - `booking_date`, `travel_date`
  - `number_of_guests`
  - `price_per_person`, `subtotal`, `vat_amount`, `total_amount`
  - `currency` (defaults to `USD` in legacy)
  - `booking_status`, `payment_status`

## How Zoea models this (target)

### Operators
- Target: `User` + `TourOperatorProfile`
  - `User.roles` must include `tour_operator`
  - `TourOperatorProfile.companyName` ← legacy `users.name`
  - `TourOperatorProfile.description` ← legacy `users.bio`
  - `TourOperatorProfile.contactEmail/contactPhone` ← legacy `users.email/phone`
  - `TourOperatorProfile.logoId` ← Media created from legacy `profile_pic` (if present)

**Password handling**
- Recommended: **do not import legacy passwords**.
- Create users with a generated password or an unusable hash, then require a password reset / invite flow.

### Tours (packages)
- Target: `Tour` (primary), not `Listing`
  - `Tour.operatorId` ← mapped `TourOperatorProfile.id` for legacy `seller_id`
  - `Tour.name` ← legacy `tour_packages.name`
  - `Tour.slug` ← legacy `tour_packages.code` (ensure uniqueness; suffix if collision)
  - `Tour.description` ← legacy `tour_packages.description` (ideally sanitize HTML → text)
  - `Tour.shortDescription` ← derived from description (first ~200–300 chars)
  - `Tour.pricePerPerson` ← legacy `base_price`
  - `Tour.currency` ← legacy data suggests `USD` for tour bookings; if unknown, default to `USD`
  - `Tour.status`
    - legacy `active` → `active`
    - legacy `inactive` → `inactive`
    - legacy `draft` → `draft` / `pending_review` (choose policy)
    - legacy `deleted` → skip import or mark `inactive` + set `deletedAt`
  - `TourImage` + `Media` created from legacy `cover_image` (if present)

### Tour categories
- Target: `Category`
  - `Category.slug` ← legacy category `code`
  - `Category.name` ← legacy category `name`
  - `Category.description` ← legacy category `description`
  - `Category.imageId` ← Media created from legacy `cover_image`
  - `Category.legacyId` ← legacy category `id` (helps deterministic mapping)

**Important mismatch**
- Legacy supports **multiple categories per package**, but Zoea `Tour` has only **one** `categoryId`.
- Recommended policy:
  - Choose the “primary” category as the **first** relation by `tour_package_category_relations.created_at` (or the smallest relation id if timestamps are unreliable).
  - Store the full list of legacy categories in `Tour.itinerary` JSON (e.g. `itinerary.etikeCategories = [...]`) for traceability.

### Tour package options (variants)
Zoea doesn’t have a first-class “tour option/variant” table that matches this shape.

Recommended policy (pick one):
1. **Store as JSON** on `Tour.itinerary` (fastest, minimal schema change)
   - `itinerary.etikeOptions = [{name, description, price, currency}]`
2. **Model as `Product` + `ProductVariant`** under a “tour listing” (heavier refactor)
3. **Add a new table** (e.g. `TourOption`) if options must be selectable at checkout for tours

## Migration sequence (safe + deterministic)

1. **Extract operators**
   - Filter legacy `users.role='tour_operator'`
   - Upsert into Zoea `User` by email (preferred) else phone, else generated placeholder (track as “needs review”)
   - Create `TourOperatorProfile` per operator (upsert by `userId`)

2. **Extract categories**
   - Upsert `Category` by `slug`
   - Store legacy `id` in `legacyId`

3. **Extract tours**
   - For each legacy `tour_packages` row:
     - Map `seller_id` → `TourOperatorProfile.id`
     - Choose primary category (see mismatch policy)
     - Create `Tour` with `slug=code`, `pricePerPerson=base_price`, and status mapping
     - Create `Media` + `TourImage` for `cover_image`
     - Attach `itinerary.etikeOptions` from `tour_package_options`

4. (Optional) **Import bookings**
   - Only if we want historical bookings in Zoea.
   - Requires mapping `customers` → Zoea `User` (explorer role).
   - Create `Booking` rows with:
     - `bookingType='tour'`
     - `bookingNumber=booking_code`
     - `tourId` mapped from package
     - `operatorId` mapped from operator profile
     - `bookingDate/travel_date` → `bookingDate` (and/or create `TourSchedule` rows if we want dated inventory)

## Data quality flags to expect
- HTML entities / mojibake in descriptions (e.g. `â€™`, `&amp;`) → needs cleanup/sanitization
- Missing/invalid operator emails/phones → needs manual review
- Duplicate slugs/codes → add deterministic suffixes (e.g. `-etike-{id}`)
- Currency inconsistency (legacy defaults to USD; Zoea defaults to RWF) → decide a single rule per import batch

## Questions to lock down before writing the migration script
1. Do we want to import **bookings** and **customers**, or just operators + tours?
2. For operator onboarding: should `registrationStatus` be set to `approved` and `isVerified=true` automatically?
3. Should tour descriptions allow HTML in the app UI, or should we sanitize to plain text on import?


