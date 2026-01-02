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

