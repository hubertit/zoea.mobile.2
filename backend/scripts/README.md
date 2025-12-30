# Backend Scripts

This directory contains utility scripts for the backend.

## Deployment Scripts

- **sync-all-environments.sh** - Syncs code to all environments (primary and backup servers)
- **verify-environments.sh** - Verifies environment configurations

## Testing Scripts

- **test-all-endpoints.sh** - Comprehensive endpoint testing (creates user, logs in, tests all endpoints)
- **test-endpoints.sh** - Basic endpoint testing with JWT token
- **test-all-admin-endpoints.sh** - Admin endpoints testing script


## Usage

### Deployment

```bash
./scripts/sync-all-environments.sh
```

### Testing

```bash
# Test all endpoints (creates user automatically)
./scripts/test-all-endpoints.sh

# Test with existing token
./scripts/test-endpoints.sh <JWT_TOKEN>
```

## Category Management Scripts

- **move-categories-api.sh** - Move Hiking, National Parks, and Museums under Experiences category (uses API)
- **move-categories-to-experiences.ts** - Move categories under Experiences (uses direct database access)
- **setup-attractions-categories.sh** - Move Museums to Attractions and create subcategories

### Running Category Scripts

```bash
# Move categories under Experiences (recommended - uses API)
./scripts/move-categories-api.sh

# Setup Attractions category with subcategories
./scripts/setup-attractions-categories.sh

# Move categories using direct database access (requires DATABASE_URL)
npx ts-node scripts/move-categories-to-experiences.ts
```

**Note**: 
- API-based scripts (`*.sh`) require admin credentials and use the deployed API
- Database-based scripts (`*.ts`) require DATABASE_URL environment variable

## Requirements

- `curl` - For HTTP requests
- `jq` - For JSON parsing (optional but recommended)
- `sshpass` - For deployment scripts (if using password authentication)
- Node.js and TypeScript for category management scripts

