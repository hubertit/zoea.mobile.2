# Testing Documentation Index

## Overview

This directory contains all testing-related documentation for the backend API endpoints.

## Documentation Files

### Test Results

- **[ENDPOINT_TEST_RESULTS.md](./ENDPOINT_TEST_RESULTS.md)**  
  Complete test results for user data collection endpoints including:
  - GET /api/users/me/preferences
  - PUT /api/users/me/preferences
  - GET /api/users/me/preferences/completion-status
  - GET /api/users/me/profile/completion

- **[TRACKING_ENDPOINTS_TEST_RESULTS.md](./TRACKING_ENDPOINTS_TEST_RESULTS.md)**  
  Test results for analytics/tracking endpoints:
  - POST /api/analytics/content-view (Listing)
  - POST /api/analytics/content-view (Event)
  - POST /api/analytics/events (Batched - pending)

### Guides

- **[TESTING_GUIDE.md](./TESTING_GUIDE.md)**  
  Comprehensive guide for testing endpoints with:
  - Swagger UI instructions
  - curl command examples
  - Expected response structures
  - Verification checklists

- **[ENDPOINT_TESTING_PLAN.md](./ENDPOINT_TESTING_PLAN.md)**  
  Testing checklist and plan for systematic endpoint testing

## Test Scripts

Test scripts are located in `/scripts` directory:
- `test-all-endpoints.sh` - Comprehensive automated testing
- `test-endpoints.sh` - Basic endpoint testing with token
- `test-all-admin-endpoints.sh` - Admin endpoints testing

See `/scripts/README.md` for usage instructions.

## Quick Start

1. Read [TESTING_GUIDE.md](./TESTING_GUIDE.md) for testing instructions
2. Review [ENDPOINT_TEST_RESULTS.md](./ENDPOINT_TEST_RESULTS.md) for test results
3. Use test scripts in `/scripts` for automated testing

