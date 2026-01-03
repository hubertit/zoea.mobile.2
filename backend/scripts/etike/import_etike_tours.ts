/**
 * Etike → Zoea onboarding importer (Prisma).
 *
 * - Upserts tour operators (User + TourOperatorProfile)
 * - Upserts tour packages as Tours (Tour + Media + TourImage)
 * - Upserts legacy categories as Categories (by slug)
 * - Stores multi-price/options metadata in Tour.itinerary JSON (no schema changes)
 *
 * Safety:
 * - Dry-run by default. Use --commit to write.
 *
 * Run:
 *   cd backend
 *   DATABASE_URL="..." node -r ts-node/register scripts/etike/import_etike_tours.ts \
 *     --input ./scripts/etike/out/etike_tours_normalized.json \
 *     --countryCode2 RW \
 *     --commit
 */

import { PrismaClient, user_role, tour_status } from '@prisma/client';
import * as fs from 'fs';
import * as path from 'path';
import * as bcrypt from 'bcrypt';

type EtikeCategory = { slug: string; name: string };
type EtikeOption = { name: string; description?: string | null; price_usd?: string | null; price_rwf?: number | null };

type EtikeTourRow = {
  package_legacy_id: number;
  slug: string;
  name: string;
  status?: string | null;
  seller_legacy_id: number;
  seller_name?: string | null;
  seller_email?: string | null;
  seller_phone?: string | null;
  seller_profile_pic?: string | null;
  seller_bio?: string | null;
  categories?: EtikeCategory[];
  cover_image?: string | null;
  currency: 'RWF';
  fx_rate_usd_to_rwf: number;
  rounding_step_rwf: number;
  rounding_mode: 'ceil' | 'nearest' | 'floor';
  price_points_rwf: number[];
  min_price_rwf: number;
  max_price_rwf: number;
  description_clean?: string;
  description_raw?: string;
  options?: EtikeOption[];
};

function getArg(name: string): string | undefined {
  const idx = process.argv.indexOf(name);
  if (idx === -1) return undefined;
  return process.argv[idx + 1];
}

function hasFlag(name: string): boolean {
  return process.argv.includes(name);
}

function clampSlug(slug: string): string {
  const s = (slug || '').trim();
  return s.length > 240 ? s.slice(0, 240) : s;
}

function deriveDurationDays(name: string): number | null {
  const m = name.match(/^\s*(\d+)\s*day/i);
  if (!m) return null;
  const n = Number(m[1]);
  return Number.isFinite(n) && n > 0 ? n : null;
}

function mapTourStatus(legacy: string | null | undefined): tour_status {
  switch ((legacy || '').toLowerCase()) {
    case 'active':
      return 'active';
    case 'inactive':
      return 'inactive';
    case 'draft':
      return 'draft';
    case 'pending_review':
      return 'pending_review';
    default:
      return 'draft';
  }
}

function ensureRole(roles: user_role[] | null | undefined, role: user_role): user_role[] {
  const r = roles && Array.isArray(roles) ? roles : [];
  return r.includes(role) ? r : [...r, role];
}

function makeTempPassword(): string {
  // Simple, human-shareable temp password. Admin can rotate later.
  // (We avoid special chars that often get mangled in copy/paste/SMS.)
  const part = Math.random().toString(36).slice(2, 8).toUpperCase();
  return `Zoea${part}24`;
}

async function main() {
  const input = getArg('--input') || path.join(process.cwd(), 'scripts/etike/out/etike_tours_normalized.json');
  const commit = hasFlag('--commit');
  const outDir = getArg('--outDir') || path.join(process.cwd(), 'scripts/etike/out');
  const countryCode2 = (getArg('--countryCode2') || 'RW').toUpperCase();
  const dryRun = !commit;

  if (!fs.existsSync(input)) {
    throw new Error(`Input not found: ${input}`);
  }

  const raw = fs.readFileSync(input, 'utf-8');
  const rows: EtikeTourRow[] = JSON.parse(raw);

  const prisma = new PrismaClient();

  const rwanda = await prisma.country.findFirst({
    where: { code2: countryCode2 },
    select: { id: true, code: true, code2: true, name: true },
  });
  if (!rwanda) {
    throw new Error(`Country not found for code2=${countryCode2}. Create it first or pass a different --countryCode2.`);
  }
  const country = rwanda;

  const credsOut: Array<{ seller_legacy_id: number; seller_name: string; email: string; phone: string; temp_password: string }> = [];

  const stats = {
    inputRows: rows.length,
    skippedDeleted: 0,
    uniqueSellers: 0,
    usersWouldCreate: 0,
    usersWouldUpdateRoles: 0,
    operatorProfilesWouldCreate: 0,
    toursWouldCreate: 0,
    toursWouldUpdate: 0,
    categoriesWouldCreate: 0,
    mediaWouldCreate: 0,
    tourImagesWouldCreate: 0,
  };

  // Cache categories by slug
  const categoryIdBySlug = new Map<string, string>();
  // Cache seller onboarding to avoid redoing work per row
  const operatorCache = new Map<number, { userId: string; operatorProfileId: string }>();
  const sellerSeen = new Set<number>();

  async function getOrCreateCategory(slug: string, name: string): Promise<string> {
    const s = slug.trim();
    if (categoryIdBySlug.has(s)) return categoryIdBySlug.get(s)!;

    const existing = await prisma.category.findUnique({ where: { slug: s }, select: { id: true } });
    if (existing) {
      categoryIdBySlug.set(s, existing.id);
      return existing.id;
    }

    if (dryRun) {
      stats.categoriesWouldCreate += 1;
      const fake = `dryrun:${s}`;
      categoryIdBySlug.set(s, fake);
      return fake;
    }

    const created = await prisma.category.create({
      data: {
        slug: s,
        name: name.trim() || s,
        description: null,
        isActive: true,
      },
      select: { id: true },
    });
    // committed create
    categoryIdBySlug.set(s, created.id);
    return created.id;
  }

  async function getOrCreateMediaByUrl(url: string | null | undefined): Promise<string | null> {
    const u = (url || '').trim();
    if (!u) return null;
    const existing = await prisma.media.findFirst({
      where: { url: u, deletedAt: null },
      select: { id: true },
    });
    if (existing) return existing.id;

    if (dryRun) {
      stats.mediaWouldCreate += 1;
      return `dryrun-media:${u}`;
    }

    const created = await prisma.media.create({
      data: {
        url: u,
        mediaType: 'image',
        storageProvider: 'primary',
      },
      select: { id: true },
    });
    // committed create
    return created.id;
  }

  // Helper: upsert a tour operator user + profile for seller_legacy_id
  async function upsertOperator(row: EtikeTourRow): Promise<{ userId: string; operatorProfileId: string }> {
    const sellerLegacyId = row.seller_legacy_id;
    if (operatorCache.has(sellerLegacyId)) return operatorCache.get(sellerLegacyId)!;
    sellerSeen.add(sellerLegacyId);

    const sellerName = (row.seller_name || `Etike Seller #${sellerLegacyId}`).trim();
    let email = (row.seller_email || '').trim() || null;
    const phone = (row.seller_phone || '').trim() || null;
    // DB has a users_contact_check constraint; ensure at least one contact method exists.
    if (!email && !phone) {
      email = `etike-seller-${sellerLegacyId}@zoea.invalid`;
    }

    // Find user by email or phone (prefer email).
    const existingUser = await prisma.user.findFirst({
      where: {
        OR: [
          ...(email ? [{ email }] : []),
          ...(phone ? [{ phoneNumber: phone }] : []),
        ],
      },
      select: { id: true, roles: true, email: true, phoneNumber: true },
    });

    let userId: string;
    if (!existingUser) {
      if (dryRun) {
        stats.usersWouldCreate += 1;
        stats.operatorProfilesWouldCreate += 1;
        const cached = {
          userId: `dryrun-user:${sellerLegacyId}`,
          operatorProfileId: `dryrun-operator:${sellerLegacyId}`,
        };
        operatorCache.set(sellerLegacyId, cached);
        return cached;
      } else {
        const tempPassword = makeTempPassword();
        const passwordHash = await bcrypt.hash(tempPassword, 10);

        const u = await prisma.user.create({
          data: {
            email,
            phoneNumber: phone,
            fullName: sellerName,
            bio: row.seller_bio || null,
            roles: [user_role.tour_operator],
            accountType: 'business',
            preferredCurrency: 'RWF',
            countryId: country.id,
            passwordHash,
          },
          select: { id: true },
        });
        userId = u.id;
        // committed create
        credsOut.push({
          seller_legacy_id: sellerLegacyId,
          seller_name: sellerName,
          email: email || '',
          phone: phone || '',
          temp_password: tempPassword,
        });
      }
    } else {
      userId = existingUser.id;
      // Ensure tour_operator role is present.
      const newRoles = ensureRole(existingUser.roles as user_role[], user_role.tour_operator);
      if (newRoles.length !== (existingUser.roles as user_role[]).length) {
        if (dryRun) stats.usersWouldUpdateRoles += 1;
        else await prisma.user.update({ where: { id: userId }, data: { roles: newRoles } });
      }
    }

    // Upsert TourOperatorProfile for user
    // (If we’re in dry-run and user didn’t exist, we already returned above with a fake ID.)
    const existingProfile = await prisma.tourOperatorProfile.findFirst({ where: { userId }, select: { id: true } });

    if (existingProfile) {
      const cached = { userId, operatorProfileId: existingProfile.id };
      operatorCache.set(sellerLegacyId, cached);
      return cached;
    }

    if (dryRun) {
      stats.operatorProfilesWouldCreate += 1;
      const cached = { userId, operatorProfileId: `dryrun-operator:${sellerLegacyId}` };
      operatorCache.set(sellerLegacyId, cached);
      return cached;
    }

    const logoId = await getOrCreateMediaByUrl(row.seller_profile_pic || null);

    const createdProfile = await prisma.tourOperatorProfile.create({
      data: {
        userId,
        companyName: sellerName,
        description: row.seller_bio || null,
        contactEmail: email,
        contactPhone: phone,
        countryId: country.id,
        logoId,
        specializations: [],
        operatingRegions: [],
        registrationStatus: 'approved',
        isVerified: true,
      },
      select: { id: true },
    });
    const cached = { userId, operatorProfileId: createdProfile.id };
    operatorCache.set(sellerLegacyId, cached);
    return cached;
  }

  for (const row of rows) {
    if ((row.status || '').toLowerCase() === 'deleted') {
      stats.skippedDeleted += 1;
      continue;
    }

    // Ensure category exists (pick primary)
    const cats = row.categories || [];
    const primaryCat = cats[0];
    const categoryId = primaryCat ? await getOrCreateCategory(primaryCat.slug, primaryCat.name) : null;

    const { operatorProfileId } = await upsertOperator(row);

    // Determine slug (avoid collisions deterministically).
    // If the tour already exists (by legacy package id), keep the current slug to avoid unique conflicts.
    let desiredSlug = clampSlug(row.slug || `etike-tour-${row.package_legacy_id}`);
    if (!desiredSlug) desiredSlug = `etike-tour-${row.package_legacy_id}`;

    const description = (row.description_clean || row.description_raw || '').trim() || null;
    const shortDescription = description ? (description.length > 280 ? description.slice(0, 277) + '...' : description) : null;

    const durationDays = deriveDurationDays(row.name);

    const itinerary: any = {
      source: 'etike',
      legacy: {
        packageId: row.package_legacy_id,
        sellerId: row.seller_legacy_id,
      },
      pricing: {
        currency: 'RWF',
        fxRateUsdToRwf: row.fx_rate_usd_to_rwf,
        stepRwf: row.rounding_step_rwf,
        roundingMode: row.rounding_mode,
        pricePointsRwf: row.price_points_rwf || [],
        minPriceRwf: row.min_price_rwf,
        maxPriceRwf: row.max_price_rwf,
      },
      categories: cats,
      options: (row.options || []).map((o) => ({
        name: o.name,
        description: o.description || null,
        priceRwf: o.price_rwf ?? null,
        priceUsd: o.price_usd ?? null,
      })),
      coverImage: row.cover_image || null,
    };

    // Idempotency key: Etike legacy package id stored in itinerary. This lets us re-run safely.
    // NOTE: We use raw SQL because Prisma JSON filters can be finicky across versions.
    const existingEtikeTours: Array<{ id: string; slug: string; created_at: Date }> = await prisma.$queryRaw`
      SELECT id, slug, created_at
      FROM tours
      WHERE itinerary->>'source' = 'etike'
        AND (itinerary->'legacy'->>'packageId')::int = ${row.package_legacy_id}
      ORDER BY created_at ASC
    `;

    if (existingEtikeTours.length) {
      desiredSlug = existingEtikeTours[0].slug;
    } else {
      const slugExists = await prisma.tour.findUnique({ where: { slug: desiredSlug }, select: { id: true } });
      if (slugExists) desiredSlug = clampSlug(`${desiredSlug}-etike-${row.package_legacy_id}`);
    }

    if (!dryRun && existingEtikeTours.length > 1) {
      // Keep the oldest, soft-delete the rest for cleanliness.
      const keep = existingEtikeTours[0];
      const toDelete = existingEtikeTours.slice(1);
      for (const d of toDelete) {
        await prisma.tour.update({
          where: { id: d.id },
          data: { deletedAt: new Date(), status: 'inactive' },
        });
      }
    }

    const canonicalExisting = existingEtikeTours.length ? { id: existingEtikeTours[0].id } : null;
    const existingTour = canonicalExisting
      ? canonicalExisting
      : await prisma.tour.findUnique({
          where: { slug: desiredSlug },
          select: { id: true },
        });
    if (dryRun) {
      if (existingTour) stats.toursWouldUpdate += 1;
      else stats.toursWouldCreate += 1;
      // Cover image + media + tour image counts (approximate)
      if (row.cover_image) {
        await getOrCreateMediaByUrl(row.cover_image);
        stats.tourImagesWouldCreate += 1;
      }
      continue;
    }

    const tourData = {
      operatorId: operatorProfileId,
      name: row.name,
      slug: desiredSlug,
      description,
      shortDescription,
      categoryId: categoryId && categoryId.startsWith('dryrun:') ? null : categoryId,
      type: 'package',
      durationDays: durationDays || null,
      countryId: country.id,
      operating_regions: [],
      pricePerPerson: row.min_price_rwf ? row.min_price_rwf.toString() : null,
      currency: 'RWF',
      includes: [],
      excludes: [],
      requirements: [],
      status: mapTourStatus(row.status),
      itinerary,
    } as any;

    let tourId: string;
    if (!existingTour) {
      const created = await prisma.tour.create({ data: tourData, select: { id: true } });
      tourId = created.id;
      // committed create
    } else {
      tourId = existingTour.id;
      await prisma.tour.update({ where: { id: tourId }, data: tourData });
      // committed update
    }

    // Cover image -> Media + TourImage
    const mediaId = await getOrCreateMediaByUrl(row.cover_image || null);
    if (mediaId && !mediaId.startsWith('dryrun-media:')) {
      const existingImg = await prisma.tourImage.findFirst({
        where: { tourId, mediaId },
        select: { id: true },
      });
      if (!existingImg) {
        await prisma.tourImage.create({
          data: { tourId, mediaId, isPrimary: true, sortOrder: 0 },
          select: { id: true },
        });
        // committed create
      }
    }
  }

  if (!dryRun) {
    fs.mkdirSync(outDir, { recursive: true });
    const credsPath = path.join(outDir, 'etike_onboarding_credentials.csv');
    const header = 'seller_legacy_id,seller_name,email,phone,temp_password\n';
    const rowsCsv = credsOut
      .map((c) =>
        [
          c.seller_legacy_id,
          JSON.stringify(c.seller_name),
          JSON.stringify(c.email),
          JSON.stringify(c.phone),
          JSON.stringify(c.temp_password),
        ].join(','),
      )
      .join('\n');
    fs.writeFileSync(credsPath, header + rowsCsv + '\n', 'utf-8');
    // eslint-disable-next-line no-console
    console.log(`🔐 Wrote operator temp passwords: ${credsPath}`);
  }

  await prisma.$disconnect();

  // eslint-disable-next-line no-console
  console.log(`Country used: ${country.name} (${country.code2}/${country.code})`);
  // eslint-disable-next-line no-console
  stats.uniqueSellers = sellerSeen.size;
  console.log(dryRun ? 'DRY RUN (no DB writes)' : 'COMMIT MODE (DB updated)');
  // eslint-disable-next-line no-console
  console.log(JSON.stringify(stats, null, 2));
}

main().catch((e) => {
  // eslint-disable-next-line no-console
  console.error(e);
  process.exit(1);
});


