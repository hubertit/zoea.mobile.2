# Broken Text Cleanup (Mojibake + HTML Entities)

Some content in the database may contain **broken special characters** due to encoding issues (mojibake), for example:

- `parkâ€™s` → `park’s`
- `Sept 21st â€“ 23rd` → `Sept 21st – 23rd`
- `ðŸ˜Š` → `😊`

This repo includes a script that can **scan** and **fix** these issues safely.

## What the script fixes

- **Mojibake** (UTF‑8 text decoded as Windows‑1252/CP1252)
- **HTML entities** (e.g. `&amp;`, `&#39;`, `&#x1F600;`)

## Target tables/fields (default)

- `Listing`: `name`, `description`, `shortDescription`, `address`, `locationName`, `metaTitle`, `metaDescription`
- `Tour`: `name`, `description`, `shortDescription`, `startLocationName`, `endLocationName`, plus JSON `itinerary`
- `Event`: `name`, `description`, `locationName`, `venueName`, `address`, `cancellationReason`
- `User`: `username`, `fullName`, `firstName`, `lastName`, `bio`, `address`, `profession`, `company`, `industry`
- `MerchantProfile`: `businessName`, `description`, `address`, `rejectionReason`, `revisionNotes`
- `OrganizerProfile`: `organizationName`, `description`, `address`, `rejectionReason`, `revisionNotes`
- `TourOperatorProfile`: `companyName`, `description`, `address`, `rejectionReason`, `revisionNotes`

## Usage

Build first (script runs from `dist/`):

```bash
cd backend
npm run build
```

### Dry-run (recommended)

Prints a sample of changes and summary counts. **No DB writes**.

```bash
node dist/scripts/fix-broken-text.js --limit 200
```

### Apply changes

⚠️ This updates DB content for the `DATABASE_URL` environment.

```bash
node dist/scripts/fix-broken-text.js --apply
```

### Options

- `--apply`: perform updates (default is dry-run)
- `--batch 200`: pagination batch size
- `--limit 1000`: limit total rows scanned per model
- `--models Listing,Tour`: run only specific models


