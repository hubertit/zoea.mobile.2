import { PrismaClient } from '@prisma/client';
import { normalizeJsonDeep, normalizeText } from '../utils/text-normalize';

type Mode = 'dry-run' | 'apply';

type Target = {
  name: string;
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  findMany: (args: any) => Promise<any[]>;
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  update: (args: any) => Promise<any>;
  where: Record<string, unknown>;
  fields: string[];
  jsonFields?: string[];
};

function parseArg(flag: string): string | undefined {
  const idx = process.argv.indexOf(flag);
  if (idx === -1) return undefined;
  return process.argv[idx + 1];
}

function hasFlag(flag: string): boolean {
  return process.argv.includes(flag);
}

function pick(obj: Record<string, unknown>, keys: string[]): Record<string, unknown> {
  const out: Record<string, unknown> = {};
  for (const k of keys) out[k] = obj[k];
  return out;
}

async function main() {
  const prisma = new PrismaClient();

  const mode: Mode = hasFlag('--apply') ? 'apply' : 'dry-run';
  const batchSize = Number.parseInt(parseArg('--batch') ?? '200', 10) || 200;
  const limit = parseArg('--limit') ? Number.parseInt(parseArg('--limit')!, 10) : undefined;
  const modelsFilter = (parseArg('--models') ?? '')
    .split(',')
    .map((s) => s.trim())
    .filter(Boolean);

  const targets: Target[] = [
    {
      name: 'Listing',
      findMany: prisma.listing.findMany.bind(prisma.listing),
      update: prisma.listing.update.bind(prisma.listing),
      where: { deletedAt: null },
      fields: ['name', 'description', 'shortDescription', 'address', 'locationName', 'metaTitle', 'metaDescription'],
    },
    {
      name: 'Tour',
      findMany: prisma.tour.findMany.bind(prisma.tour),
      update: prisma.tour.update.bind(prisma.tour),
      where: { deletedAt: null },
      fields: ['name', 'description', 'shortDescription', 'startLocationName', 'endLocationName'],
      jsonFields: ['itinerary'],
    },
    {
      name: 'Event',
      findMany: prisma.event.findMany.bind(prisma.event),
      update: prisma.event.update.bind(prisma.event),
      where: { deletedAt: null },
      fields: ['name', 'description', 'locationName', 'venueName', 'address', 'cancellationReason'],
    },
    {
      name: 'User',
      findMany: prisma.user.findMany.bind(prisma.user),
      update: prisma.user.update.bind(prisma.user),
      where: { deletedAt: null },
      fields: ['username', 'fullName', 'firstName', 'lastName', 'bio', 'address', 'profession', 'company', 'industry'],
    },
    {
      name: 'MerchantProfile',
      findMany: prisma.merchantProfile.findMany.bind(prisma.merchantProfile),
      update: prisma.merchantProfile.update.bind(prisma.merchantProfile),
      where: { deletedAt: null },
      fields: ['businessName', 'description', 'address', 'rejectionReason', 'revisionNotes'],
    },
    {
      name: 'OrganizerProfile',
      findMany: prisma.organizerProfile.findMany.bind(prisma.organizerProfile),
      update: prisma.organizerProfile.update.bind(prisma.organizerProfile),
      where: { deletedAt: null },
      fields: ['organizationName', 'description', 'address', 'rejectionReason', 'revisionNotes'],
    },
    {
      name: 'TourOperatorProfile',
      findMany: prisma.tourOperatorProfile.findMany.bind(prisma.tourOperatorProfile),
      update: prisma.tourOperatorProfile.update.bind(prisma.tourOperatorProfile),
      where: { deletedAt: null },
      fields: ['companyName', 'description', 'address', 'rejectionReason', 'revisionNotes'],
    },
  ].filter((t) => (modelsFilter.length ? modelsFilter.includes(t.name) : true));

  // Validate early
  if (mode === 'apply') {
    // eslint-disable-next-line no-console
    console.log('⚠️  Running in APPLY mode. This will update production data if DATABASE_URL points to prod.');
  } else {
    // eslint-disable-next-line no-console
    console.log('Running in DRY-RUN mode (no DB writes).');
  }
  // eslint-disable-next-line no-console
  console.log(`Targets: ${targets.map((t) => t.name).join(', ') || '(none)'}`);
  // eslint-disable-next-line no-console
  console.log(`Batch size: ${batchSize}${limit ? `, Limit: ${limit}` : ''}`);

  const globalStats = {
    scanned: 0,
    changed: 0,
    fieldChanges: 0,
  };

  for (const target of targets) {
    // eslint-disable-next-line no-console
    console.log(`\n=== ${target.name} ===`);

    let cursorId: string | undefined;
    let scanned = 0;
    let changed = 0;
    let fieldChanges = 0;
    let printed = 0;

    while (true) {
      const take = limit ? Math.min(batchSize, limit - scanned) : batchSize;
      if (take <= 0) break;

      const rows = await target.findMany({
        where: target.where,
        take,
        ...(cursorId ? { skip: 1, cursor: { id: cursorId } } : {}),
        orderBy: { id: 'asc' },
        select: {
          id: true,
          ...Object.fromEntries(target.fields.map((f) => [f, true])),
          ...(target.jsonFields ? Object.fromEntries(target.jsonFields.map((f) => [f, true])) : {}),
        },
      });

      if (rows.length === 0) break;

      for (const row of rows) {
        scanned++;
        cursorId = row.id;

        const data: Record<string, unknown> = {};
        let rowChanged = false;

        for (const field of target.fields) {
          const val = row[field];
          if (typeof val !== 'string' || !val) continue;
          const fixed = normalizeText(val);
          if (fixed !== val) {
            data[field] = fixed;
            rowChanged = true;
            fieldChanges++;
            if (printed < 15) {
              printed++;
              // eslint-disable-next-line no-console
              console.log(
                `- ${field}: ${JSON.stringify(val).slice(0, 120)} -> ${JSON.stringify(fixed).slice(0, 120)}`,
              );
            }
          }
        }

        for (const field of target.jsonFields ?? []) {
          const val = row[field];
          if (val == null) continue;
          const fixed = normalizeJsonDeep(val);
          const before = JSON.stringify(val);
          const after = JSON.stringify(fixed);
          if (before !== after) {
            data[field] = fixed;
            rowChanged = true;
            fieldChanges++;
            if (printed < 15) {
              printed++;
              // eslint-disable-next-line no-console
              console.log(`- ${field}: (json updated)`);
            }
          }
        }

        if (rowChanged) {
          changed++;
          if (mode === 'apply') {
            await target.update({
              where: { id: row.id },
              data,
            });
          }
        }
      }

      if (limit && scanned >= limit) break;
    }

    globalStats.scanned += scanned;
    globalStats.changed += changed;
    globalStats.fieldChanges += fieldChanges;

    // eslint-disable-next-line no-console
    console.log(
      `Done ${target.name}: scanned=${scanned}, changed_records=${changed}, field_changes=${fieldChanges}`,
    );
  }

  // eslint-disable-next-line no-console
  console.log(
    `\n✅ Finished (${mode}). Total: scanned=${globalStats.scanned}, changed_records=${globalStats.changed}, field_changes=${globalStats.fieldChanges}`,
  );

  await prisma.$disconnect();
}

main().catch((e) => {
  // eslint-disable-next-line no-console
  console.error(e);
  process.exit(1);
});


