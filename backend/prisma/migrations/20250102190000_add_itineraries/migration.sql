-- CreateEnum (only if not exists)
DO $$ BEGIN
    CREATE TYPE "itinerary_item_type" AS ENUM ('listing', 'event', 'tour', 'custom');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

-- CreateTable
CREATE TABLE "itineraries" (
    "id" UUID NOT NULL DEFAULT uuid_generate_v4(),
    "user_id" UUID NOT NULL,
    "title" VARCHAR(255) NOT NULL,
    "description" TEXT,
    "start_date" TIMESTAMPTZ(6) NOT NULL,
    "end_date" TIMESTAMPTZ(6) NOT NULL,
    "location" VARCHAR(255),
    "country_id" UUID,
    "city_id" UUID,
    "is_public" BOOLEAN DEFAULT false,
    "share_token" VARCHAR(100),
    "created_at" TIMESTAMPTZ(6) DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) DEFAULT CURRENT_TIMESTAMP,
    "deleted_at" TIMESTAMPTZ(6),

    CONSTRAINT "itineraries_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "itinerary_items" (
    "id" UUID NOT NULL DEFAULT uuid_generate_v4(),
    "itinerary_id" UUID NOT NULL,
    "type" "itinerary_item_type" NOT NULL,
    "listing_id" UUID,
    "event_id" UUID,
    "tour_id" UUID,
    "custom_name" VARCHAR(255),
    "custom_description" TEXT,
    "custom_location" VARCHAR(255),
    "start_time" TIMESTAMPTZ(6) NOT NULL,
    "end_time" TIMESTAMPTZ(6),
    "duration_minutes" INTEGER,
    "order" INTEGER NOT NULL DEFAULT 0,
    "notes" TEXT,
    "metadata" JSONB,
    "created_at" TIMESTAMPTZ(6) DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "itinerary_items_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "itinerary_shares" (
    "id" UUID NOT NULL DEFAULT uuid_generate_v4(),
    "itinerary_id" UUID NOT NULL,
    "shared_with" VARCHAR(255),
    "created_at" TIMESTAMPTZ(6) DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "itinerary_shares_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE INDEX "itineraries_user_id_idx" ON "itineraries"("user_id");

-- CreateIndex
CREATE UNIQUE INDEX "itineraries_share_token_key" ON "itineraries"("share_token");

-- CreateIndex
CREATE INDEX "itineraries_share_token_idx" ON "itineraries"("share_token");

-- CreateIndex
CREATE INDEX "itinerary_items_itinerary_id_idx" ON "itinerary_items"("itinerary_id");

-- CreateIndex
CREATE INDEX "itinerary_items_listing_id_idx" ON "itinerary_items"("listing_id");

-- CreateIndex
CREATE INDEX "itinerary_items_event_id_idx" ON "itinerary_items"("event_id");

-- CreateIndex
CREATE INDEX "itinerary_items_tour_id_idx" ON "itinerary_items"("tour_id");

-- CreateIndex
CREATE INDEX "itinerary_shares_itinerary_id_idx" ON "itinerary_shares"("itinerary_id");

-- AddForeignKey
ALTER TABLE "itineraries" ADD CONSTRAINT "itineraries_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "itineraries" ADD CONSTRAINT "itineraries_country_id_fkey" FOREIGN KEY ("country_id") REFERENCES "countries"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "itineraries" ADD CONSTRAINT "itineraries_city_id_fkey" FOREIGN KEY ("city_id") REFERENCES "cities"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "itinerary_items" ADD CONSTRAINT "itinerary_items_itinerary_id_fkey" FOREIGN KEY ("itinerary_id") REFERENCES "itineraries"("id") ON DELETE CASCADE ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "itinerary_items" ADD CONSTRAINT "itinerary_items_listing_id_fkey" FOREIGN KEY ("listing_id") REFERENCES "listings"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "itinerary_items" ADD CONSTRAINT "itinerary_items_event_id_fkey" FOREIGN KEY ("event_id") REFERENCES "events"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "itinerary_items" ADD CONSTRAINT "itinerary_items_tour_id_fkey" FOREIGN KEY ("tour_id") REFERENCES "tours"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "itinerary_shares" ADD CONSTRAINT "itinerary_shares_itinerary_id_fkey" FOREIGN KEY ("itinerary_id") REFERENCES "itineraries"("id") ON DELETE CASCADE ON UPDATE NO ACTION;

