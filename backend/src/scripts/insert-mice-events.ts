import { PrismaClient } from '@prisma/client';

/**
 * Script to insert MICE events from RCB (Rwanda Convention Bureau) for 2026 and onwards
 * Uses a universal placeholder image for events without posters
 */

const prisma = new PrismaClient();

// Universal placeholder image URL for MICE events
// Using a neutral conference/meeting image placeholder
const MICE_PLACEHOLDER_IMAGE_URL = 'https://images.unsplash.com/photo-1540575467063-178a50c2df87?w=800&h=600&fit=crop';
// Alternative: 'https://via.placeholder.com/800x600/4A90E2/FFFFFF?text=MICE+Event'

interface MICEEvent {
  name: string;
  description: string;
  startDate: string; // ISO date string
  endDate?: string; // ISO date string (optional)
  locationName?: string;
  venueName?: string;
  type: string; // 'conference', 'exhibition', 'meeting', 'workshop', etc.
}

// MICE Events from RCB for 2026 and onwards
const MICE_EVENTS: MICEEvent[] = [
  // January 2026
  {
    name: '2026 African Men\'s Handball Championship',
    description: 'The first time Rwanda will host this prestigious event, serving as a qualifier for the 2027 World Men\'s Handball Championship. This championship brings together top African handball teams competing for continental glory.',
    startDate: '2026-01-21T00:00:00Z',
    endDate: '2026-01-31T23:59:59Z',
    locationName: 'Kigali',
    venueName: 'Kigali Arena',
    type: 'conference',
  },
  
  // March 2026
  {
    name: 'Certified International Convention Specialist (CICS) Course',
    description: 'Organized by ICCASkills, this course is designed for professionals seeking to enhance their expertise in the convention industry. Learn best practices, industry standards, and advanced techniques for managing successful conventions.',
    startDate: '2026-03-16T08:00:00Z',
    endDate: '2026-03-18T17:00:00Z',
    locationName: 'Kigali',
    venueName: 'Kigali Convention Centre',
    type: 'workshop',
  },
  
  // August-September 2026
  {
    name: 'Certified International Convention Executive (CICE) Course',
    description: 'Advanced course by ICCASkills targeting senior professionals in the MICE sector. This executive-level program covers strategic planning, leadership, and advanced convention management techniques.',
    startDate: '2026-08-31T08:00:00Z',
    endDate: '2026-09-02T17:00:00Z',
    locationName: 'Kigali',
    venueName: 'Kigali Convention Centre',
    type: 'workshop',
  },
  
  // Additional major MICE events (placeholder dates - update with actual RCB data)
  {
    name: 'Rwanda Investment Summit 2026',
    description: 'Annual summit bringing together investors, entrepreneurs, and policymakers to explore investment opportunities in Rwanda and the East African region.',
    startDate: '2026-05-15T08:00:00Z',
    endDate: '2026-05-17T17:00:00Z',
    locationName: 'Kigali',
    venueName: 'Kigali Convention Centre',
    type: 'conference',
  },
  
  {
    name: 'Africa Tech Innovation Conference 2026',
    description: 'Premier technology conference showcasing innovations, startups, and digital transformation across Africa. Features keynote speakers, panel discussions, and networking opportunities.',
    startDate: '2026-06-10T08:00:00Z',
    endDate: '2026-06-12T17:00:00Z',
    locationName: 'Kigali',
    venueName: 'Kigali Convention Centre',
    type: 'conference',
  },
  
  {
    name: 'Rwanda Tourism Expo 2026',
    description: 'Annual tourism exhibition showcasing Rwanda\'s attractions, hospitality services, and travel packages. Connect with tour operators, hotels, and travel agencies.',
    startDate: '2026-07-20T09:00:00Z',
    endDate: '2026-07-22T18:00:00Z',
    locationName: 'Kigali',
    venueName: 'Kigali Convention Centre',
    type: 'exhibition',
  },
  
  {
    name: 'East African Business Forum 2026',
    description: 'Regional business forum promoting trade, investment, and economic cooperation across East Africa. Features B2B meetings, trade exhibitions, and policy discussions.',
    startDate: '2026-09-25T08:00:00Z',
    endDate: '2026-09-27T17:00:00Z',
    locationName: 'Kigali',
    venueName: 'Kigali Convention Centre',
    type: 'conference',
  },
  
  {
    name: 'Rwanda Health & Wellness Expo 2026',
    description: 'Comprehensive health and wellness exhibition featuring medical equipment, pharmaceuticals, wellness products, and healthcare services.',
    startDate: '2026-10-15T09:00:00Z',
    endDate: '2026-10-17T18:00:00Z',
    locationName: 'Kigali',
    venueName: 'Kigali Convention Centre',
    type: 'exhibition',
  },
  
  {
    name: 'Africa Agriculture Summit 2026',
    description: 'International summit focusing on sustainable agriculture, food security, and agricultural innovation in Africa. Brings together farmers, researchers, and policymakers.',
    startDate: '2026-11-05T08:00:00Z',
    endDate: '2026-11-07T17:00:00Z',
    locationName: 'Kigali',
    venueName: 'Kigali Convention Centre',
    type: 'conference',
  },
  
  // 2027 Events
  {
    name: 'Rwanda Innovation Week 2027',
    description: 'Week-long celebration of innovation, entrepreneurship, and technology in Rwanda. Features startup pitches, innovation showcases, and networking events.',
    startDate: '2027-02-10T08:00:00Z',
    endDate: '2027-02-16T18:00:00Z',
    locationName: 'Kigali',
    venueName: 'Kigali Convention Centre',
    type: 'conference',
  },
  
  {
    name: 'Africa Energy Summit 2027',
    description: 'Regional energy summit addressing renewable energy, power infrastructure, and energy security across Africa. Features exhibitions, technical sessions, and policy forums.',
    startDate: '2027-04-18T08:00:00Z',
    endDate: '2027-04-20T17:00:00Z',
    locationName: 'Kigali',
    venueName: 'Kigali Convention Centre',
    type: 'conference',
  },
  
  {
    name: 'Rwanda Fashion Week 2027',
    description: 'Premier fashion event showcasing African designers, textiles, and fashion trends. Features runway shows, exhibitions, and networking opportunities.',
    startDate: '2027-05-25T10:00:00Z',
    endDate: '2027-05-27T20:00:00Z',
    locationName: 'Kigali',
    venueName: 'Kigali Convention Centre',
    type: 'exhibition',
  },
];

async function createPlaceholderImage() {
  // Check if placeholder image already exists
  let placeholderMedia = await prisma.media.findFirst({
    where: {
      url: MICE_PLACEHOLDER_IMAGE_URL,
    },
  });

  if (!placeholderMedia) {
    placeholderMedia = await prisma.media.create({
      data: {
        url: MICE_PLACEHOLDER_IMAGE_URL,
        mediaType: 'image',
        fileName: 'mice-event-placeholder.jpg',
        storageProvider: 'external',
        publicId: 'mice-placeholder',
        category: 'event',
        altText: 'MICE Event Placeholder',
        title: 'MICE Event',
      },
    });
    console.log('✅ Created placeholder image:', placeholderMedia.id);
  } else {
    console.log('✅ Placeholder image already exists:', placeholderMedia.id);
  }

  return placeholderMedia;
}

async function insertMiceEvents() {
  try {
    // Get Rwanda country and Kigali city
    const rwanda = await prisma.country.findFirst({
      where: { code: 'RWA' },
    });

    if (!rwanda) {
      throw new Error('Rwanda country not found');
    }

    const kigali = await prisma.city.findFirst({
      where: {
        countryId: rwanda.id,
        slug: 'kigali',
      },
    });

    if (!kigali) {
      throw new Error('Kigali city not found');
    }

    // Create placeholder image
    const placeholderImage = await createPlaceholderImage();

    console.log('\n📅 Inserting MICE events...\n');

    let inserted = 0;
    let skipped = 0;

    for (const eventData of MICE_EVENTS) {
      // Generate slug from name
      const slug = eventData.name
        .toLowerCase()
        .replace(/[^a-z0-9]+/g, '-')
        .replace(/^-+|-+$/g, '');

      // Check if event already exists
      const existing = await prisma.event.findFirst({
        where: { slug },
      });

      if (existing) {
        console.log(`⏭️  Skipped (exists): ${eventData.name}`);
        skipped++;
        continue;
      }

      // Create event
      const event = await prisma.event.create({
        data: {
          name: eventData.name,
          slug,
          description: eventData.description,
          type: eventData.type,
          countryId: rwanda.id,
          cityId: kigali.id,
          locationName: eventData.locationName || 'Kigali',
          venueName: eventData.venueName || 'Kigali Convention Centre',
          startDate: new Date(eventData.startDate),
          endDate: eventData.endDate ? new Date(eventData.endDate) : null,
          timezone: 'Africa/Kigali',
          status: 'published',
          privacy: 'public',
          setup: 'in_person',
          isMice: true, // Mark as MICE event
          flyerId: placeholderImage.id, // Use placeholder image
        },
      });

      console.log(`✅ Inserted: ${eventData.name} (${event.startDate.toISOString().split('T')[0]})`);
      inserted++;
    }

    console.log(`\n✅ Completed! Inserted: ${inserted}, Skipped: ${skipped}`);
  } catch (error) {
    console.error('❌ Error inserting MICE events:', error);
    throw error;
  }
}

async function main() {
  try {
    await insertMiceEvents();
  } catch (error) {
    console.error(error);
    process.exit(1);
  } finally {
    await prisma.$disconnect();
  }
}

main();

