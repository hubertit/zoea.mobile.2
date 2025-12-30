# Backend Scripts

This directory contains utility scripts for the backend.

## Deployment Scripts

- **sync-all-environments.sh** - Syncs code to all environments (primary and backup servers)
- **verify-environments.sh** - Verifies environment configurations

## Testing Scripts

- **test-all-endpoints.sh** - Comprehensive endpoint testing (creates user, logs in, tests all endpoints)
- **test-endpoints.sh** - Basic endpoint testing with JWT token
- **test-all-admin-endpoints.sh** - Admin endpoints testing script

## Category Management Scripts

- **check-category-structure.ts** - Check current category structure (parent categories and subcategories)
- **reorganize-hiking-category.ts** - Move Hiking category to be a subcategory of Experiences

### Running Category Scripts

```bash
# Check current category structure
npx ts-node scripts/check-category-structure.ts

# Reorganize Hiking to be under Experiences
npx ts-node scripts/reorganize-hiking-category.ts
```

**Note**: These scripts require:
- Database connection (DATABASE_URL environment variable)
- Node.js and TypeScript
- All dependencies installed (`npm install`)

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

## Requirements

- `curl` - For HTTP requests
- `jq` - For JSON parsing (optional but recommended)
- `sshpass` - For deployment scripts (if using password authentication)

