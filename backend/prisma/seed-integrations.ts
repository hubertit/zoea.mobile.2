import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

async function main() {
  console.log('Seeding integrations...');

  // OpenAI Integration
  // Note: Set OPENAI_API_KEY environment variable before running this seed
  const openaiApiKey = process.env.OPENAI_API_KEY || '';
  
  await prisma.integration.upsert({
    where: { name: 'openai' },
    update: {
      config: {
        apiKey: openaiApiKey,
        model: 'gpt-4-turbo-preview',
        maxTokens: 1000,
        temperature: 0.7,
      },
      isActive: openaiApiKey !== '',
    },
    create: {
      name: 'openai',
      displayName: 'OpenAI',
      description: 'OpenAI API for AI assistant (Ask Zoea)',
      isActive: openaiApiKey !== '',
      config: {
        apiKey: openaiApiKey,
        model: 'gpt-4-turbo-preview',
        maxTokens: 1000,
        temperature: 0.7,
      },
    },
  });

  // Visit Rwanda Events Integration
  await prisma.integration.upsert({
    where: { name: 'visit_rwanda' },
    update: {},
    create: {
      name: 'visit_rwanda',
      displayName: 'Visit Rwanda Events',
      description: 'External events feed from Visit Rwanda',
      isActive: false, // Set to false until URL is configured
      config: {
        eventsUrl: '', // To be configured by admin
        syncInterval: 3600, // Sync every hour (in seconds)
        lastSyncAt: null,
      },
    },
  });

  // Google Places API Integration
  // Note: Set GOOGLE_PLACES_API_KEY environment variable before running this seed
  const googlePlacesApiKey = process.env.GOOGLE_PLACES_API_KEY || '';
  
  await prisma.integration.upsert({
    where: { name: 'google_places' },
    update: {
      config: {
        apiKey: googlePlacesApiKey,
      },
      isActive: googlePlacesApiKey !== '',
    },
    create: {
      name: 'google_places',
      displayName: 'Google Places API',
      description: 'Google Places API for address autocomplete and location services',
      isActive: googlePlacesApiKey !== '',
      config: {
        apiKey: googlePlacesApiKey,
      },
    },
  });

  // Cloudinary Integration
  // Note: Set CLOUDINARY_CLOUD_NAME, CLOUDINARY_API_KEY, CLOUDINARY_API_SECRET environment variables before running this seed
  // Default values for Zoea account
  const cloudinaryCloudName = process.env.CLOUDINARY_CLOUD_NAME || 'dzcvbnvh3';
  const cloudinaryApiKey = process.env.CLOUDINARY_API_KEY || '752864623346824';
  const cloudinaryApiSecret = process.env.CLOUDINARY_API_SECRET || 'CceWTvKzJ1hTnZ81L80aps7neUc';
  
  await prisma.integration.upsert({
    where: { name: 'cloudinary' },
    update: {
      config: {
        cloudName: cloudinaryCloudName,
        apiKey: cloudinaryApiKey,
        apiSecret: cloudinaryApiSecret,
      },
      isActive: cloudinaryCloudName !== '' && cloudinaryApiKey !== '' && cloudinaryApiSecret !== '',
    },
    create: {
      name: 'cloudinary',
      displayName: 'Cloudinary',
      description: 'Cloudinary for image and media storage and optimization',
      isActive: cloudinaryCloudName !== '' && cloudinaryApiKey !== '' && cloudinaryApiSecret !== '',
      config: {
        cloudName: cloudinaryCloudName,
        apiKey: cloudinaryApiKey,
        apiSecret: cloudinaryApiSecret,
        maxStorageGB: 25,
      },
    },
  });

  console.log('Integrations seeded successfully!');
}

main()
  .catch((e) => {
    console.error('Error seeding integrations:', e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });

