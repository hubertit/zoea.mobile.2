# Merchant Profile Strategy Recommendation

## Analysis

### V1 Data Structure
Looking at the V1 database:
- Each venue has its own:
  - `venue_name` (e.g., "ANDA", "14TH AVENUE RESTAURANT", "17 Blocks Restaurant")
  - `venue_email` (different emails per venue)
  - `venue_phone` (different phones per venue)
  - `venue_website` (different websites per venue)
  - `venue_address` (different locations)
  - `venue_coordinates` (different locations)

- User ID 1 has multiple venues (6, 8, 9, 10, 11, 12, 14, 15, 16, 17, etc.)
- Each venue appears to be an independent business entity

### V2 Structure
- `MerchantProfile` represents a business
- `Listing` represents a location/venue of that business
- User can have multiple `MerchantProfiles` (multiple businesses)
- Each `MerchantProfile` can have multiple `Listings` (multiple locations)

---

## Recommendation: **`one_per_venue`** ✅

### Why This Is Best

1. **Matches V1 Structure**
   - Each venue in V1 has independent business details
   - Each venue has its own name, email, phone, website
   - Treating each as a separate business aligns with existing data

2. **Maximum Flexibility**
   - Users can manage each business independently
   - Different commission rates per business
   - Different verification statuses
   - Different business registration numbers (if added later)

3. **Future-Proof**
   - If a user wants to add more locations to a business later, they can
   - If they want to merge businesses, they can (easier to merge than split)
   - Supports complex business structures

4. **Data Integrity**
   - Each venue's business details are preserved
   - No data loss or assumptions about grouping
   - Clear 1:1 mapping from V1 venue → V2 merchant profile + listing

5. **Mobile App Compatibility**
   - Users can see all their businesses in the app
   - Each business can be managed separately
   - Matches user expectations (each venue = one business)

### Migration Result

```
V1: User 1 → Venues [6, 8, 9, 10, 11, ...]
V2: User 1 → MerchantProfiles [MP1, MP2, MP3, MP4, MP5, ...]
     MP1 → Listing (venue 6)
     MP2 → Listing (venue 8)
     MP3 → Listing (venue 9)
     ...
```

### Alternative: If You Want Grouping

If you discover that some venues should be grouped (e.g., same business name, same owner, multiple locations), you can:

1. **Post-Migration Script:** Analyze merchant profiles and merge duplicates
2. **Manual Review:** Review and merge merchant profiles in admin panel
3. **User Self-Service:** Let users merge their businesses in the app

But starting with `one_per_venue` gives you the most accurate migration.

---

## Implementation

The migration will:
1. For each venue, create a merchant profile with:
   - `businessName` = venue name
   - `businessEmail` = venue email
   - `businessPhone` = venue phone
   - `website` = venue website
   - `countryId` = mapped from venue country_id
   - `cityId` = mapped from venue location_id
   - `isVerified` = true (since venue was active in V1)
   - `registrationStatus` = 'approved'

2. Create listing linked to that merchant profile

3. Result: Clean 1:1 mapping, maximum flexibility

---

## Decision

**Recommended Strategy:** `one_per_venue`

**Reason:** Best matches existing data structure, maximum flexibility, future-proof, and aligns with V2's design where businesses and locations are separate concepts.

