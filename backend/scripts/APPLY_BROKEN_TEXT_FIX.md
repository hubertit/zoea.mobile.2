# Apply Broken Text Fix

## Quick Commands

Once VPN is connected and stable, run these commands:

### 1. Apply the broken text fix:

```bash
sshpass -p "Easy2Use$" ssh -o StrictHostKeyChecking=no qt@172.16.40.61 "cd ~/zoea-backend && docker-compose exec -T api node dist/scripts/fix-broken-text.js --apply"
```

### 2. Verify the fix worked (run dry-run again):

```bash
sshpass -p "Easy2Use$" ssh -o StrictHostKeyChecking=no qt@172.16.40.61 "cd ~/zoea-backend && docker-compose exec -T api node dist/scripts/fix-broken-text.js --limit 100"
```

Expected: Should show 0 or very few remaining broken characters.

### 3. Clean up Docker images:

```bash
cd backend
./scripts/cleanup-docker.sh
```

Or manually:

```bash
sshpass -p "Easy2Use$" ssh -o StrictHostKeyChecking=no qt@172.16.40.61 "cd ~/zoea-backend && docker image prune -a -f && docker container prune -f && docker system df"
```

## What the fix does:

- Fixes mojibake characters (e.g., `â€™` → `'`, `â€"` → `–`)
- Fixes HTML entities (e.g., `&amp;` → `&`, `&quot;` → `"`)
- Updates: Listings, Tours, Events, Users, MerchantProfiles, OrganizerProfiles, TourOperatorProfiles
- Safe: Only updates fields that actually changed
- Handles errors gracefully (skips records with schema mismatches)

## Notes:

- The script will skip any records that have schema issues (like missing `favorite_count` column)
- It processes in batches of 200 records
- Progress is shown in real-time
- All changes are logged

