# Database Seeding Guide

## Integrations Seeding

The `seed-integrations.ts` script seeds the initial integration configurations into the database.

### Prerequisites

Before running the seed script, you need to set the following environment variables:

```bash
export OPENAI_API_KEY="your-openai-api-key-here"
```

### Running the Seed Script

#### Option 1: Using Node (Recommended)

```bash
# Set the environment variable
export OPENAI_API_KEY="sk-proj-..."

# Run the seed script
cd backend
npx ts-node prisma/seed-integrations.ts
```

#### Option 2: Via Docker Container

```bash
# Set the environment variable on the server
export OPENAI_API_KEY="sk-proj-..."

# Run inside the Docker container
docker-compose exec -T api node -e "
const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

async function main() {
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
  
  console.log('OpenAI integration seeded successfully!');
}

main().then(() => prisma.\$disconnect()).catch(e => { console.error(e); process.exit(1); });
"
```

### What Gets Seeded

1. **OpenAI Integration**
   - Name: `openai`
   - Display Name: `OpenAI`
   - Description: `OpenAI API for AI assistant (Ask Zoea)`
   - Config:
     - `apiKey`: From `OPENAI_API_KEY` environment variable
     - `model`: `gpt-4-turbo-preview`
     - `maxTokens`: `1000`
     - `temperature`: `0.7`
   - Status: Active if API key is provided, inactive otherwise

2. **Visit Rwanda Events Integration** (Placeholder)
   - Name: `visit_rwanda`
   - Display Name: `Visit Rwanda Events`
   - Description: `External events feed from Visit Rwanda`
   - Config:
     - `eventsUrl`: Empty (to be configured)
     - `syncInterval`: `3600` (1 hour)
     - `lastSyncAt`: `null`
   - Status: Inactive (awaiting configuration)

### Security Notes

⚠️ **IMPORTANT**: Never commit API keys directly to the repository. Always use environment variables.

- The seed script reads from `process.env.OPENAI_API_KEY`
- If the environment variable is not set, the integration will be created but marked as inactive
- Update the API key later via the Integrations API or admin panel

### Updating Integrations

After seeding, you can update integrations via:

1. **API Endpoints**:
   ```bash
   PATCH /api/integrations/openai
   ```

2. **Admin Panel**:
   - Navigate to Settings > Integrations
   - Edit the OpenAI integration
   - Update the API key and other settings

3. **Direct Database Update**:
   ```sql
   UPDATE "Integration" 
   SET config = jsonb_set(config, '{apiKey}', '"sk-proj-..."')
   WHERE name = 'openai';
   ```

### Verification

After seeding, verify the integrations were created:

```bash
# Via API
curl https://zoea-africa.qtsoftwareltd.com/api/integrations

# Via Database
psql -h 172.16.40.61 -U admin -d zoea_db -c "SELECT name, \"displayName\", \"isActive\" FROM \"Integration\";"
```

### Troubleshooting

**Issue**: Integration created but inactive
- **Solution**: Ensure `OPENAI_API_KEY` environment variable is set before running the seed script

**Issue**: API key not working
- **Solution**: Verify the API key is valid and has the necessary permissions on OpenAI's platform

**Issue**: Seed script fails with connection error
- **Solution**: Check that the database is accessible and `DATABASE_URL` is correctly configured

