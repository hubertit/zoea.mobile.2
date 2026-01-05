# African Cities Added to Database

**Date:** January 5, 2026  
**Status:** ✅ **COMPLETED**

---

## Summary

Added major cities for all African countries in the database to enable users to see cities when they change countries in the app.

---

## Cities Added by Country

### ✅ Burundi (5 cities)
- Bujumbura (Capital)
- Gitega
- Muyinga
- Ngozi
- Ruyigi

### ✅ Democratic Republic of Congo (7 cities)
- Kinshasa (Capital)
- Lubumbashi
- Mbuji-Mayi
- Kananga
- Kisangani
- Bukavu
- Goma

### ✅ Ethiopia (6 cities)
- Addis Ababa (Capital)
- Dire Dawa
- Mekelle
- Gondar
- Bahir Dar
- Hawassa

### ✅ Ghana (6 cities)
- Accra (Capital)
- Kumasi
- Tamale
- Sekondi-Takoradi
- Cape Coast
- Tema

### ⚠️ Kenya (11 cities - includes 5 old Rwandan cities)
**New Kenyan Cities:**
- Nairobi (Capital)
- Mombasa
- Kisumu
- Nakuru
- Eldoret
- Malindi

**Legacy Cities (Should be Rwandan, but kept due to foreign key constraints):**
- Kigali
- Musanze
- Rubavu
- Rusizi
- Karongi

**Note:** Kenya had Rwandan cities incorrectly assigned. These couldn't be deleted due to existing merchant profiles referencing them. New proper Kenyan cities were added.

### ✅ Nigeria (7 cities)
- Lagos (Largest city)
- Abuja (Capital)
- Kano
- Ibadan
- Port Harcourt
- Benin City
- Kaduna

### ✅ South Africa (6 cities)
- Johannesburg (Largest city)
- Cape Town (Legislative capital)
- Durban
- Pretoria (Administrative capital)
- Port Elizabeth
- Bloemfontein (Judicial capital)

### ✅ Tanzania (6 cities)
- Dar es Salaam (Largest city)
- Dodoma (Capital)
- Arusha
- Mwanza
- Zanzibar City
- Mbeya

### ✅ Uganda (6 cities)
- Kampala (Capital)
- Entebbe
- Jinja
- Mbarara
- Gulu
- Fort Portal

### ✅ Rwanda (5 cities - Already existed)
- Kigali (Capital)
- Musanze
- Rubavu
- Rusizi
- Karongi

---

## Implementation Details

### SQL Script
**File:** `add-african-cities-v2.sql`

**Features:**
- Uses `ON CONFLICT (country_id, slug) DO NOTHING` to avoid duplicates
- Includes proper timezones for each city
- Generates UUID for each city
- Transaction-based (BEGIN/COMMIT) for safety

### Database Schema
```sql
CREATE TABLE cities (
  id UUID PRIMARY KEY,
  country_id UUID REFERENCES countries(id),
  name VARCHAR(100),
  slug VARCHAR(100),
  timezone VARCHAR(50),
  created_at TIMESTAMP,
  UNIQUE(country_id, slug)
);
```

---

## Known Issues

### Kenya - Duplicate Rwandan Cities
**Problem:** Kenya has 5 Rwandan cities (Kigali, Musanze, Rubavu, Rusizi, Karongi) that are incorrectly assigned to Kenya.

**Cause:** These cities were likely copied from Rwanda during initial setup.

**Why Not Fixed:** Foreign key constraints prevent deletion:
```
ERROR: update or delete on table "cities" violates foreign key 
constraint "merchant_profiles_city_id_fkey" on table "merchant_profiles"
```

**Impact:** 
- Users selecting Kenya will see both Kenyan and Rwandan cities
- Merchant profiles are currently referencing these cities
- Does not break functionality, just shows extra cities

**Solution Options:**
1. **Leave as-is** (current) - Users get more city options, even if incorrect
2. **Update merchant profiles** to use correct Kenyan cities, then delete Rwandan ones
3. **Hide in UI** - Filter out Rwandan cities when displaying Kenyan cities

**Recommended:** Leave as-is for now. Fix when cleaning up merchant data.

---

## Verification

### Test Query:
```sql
SELECT 
    c.name as country,
    COUNT(ci.id) as city_count
FROM countries c
LEFT JOIN cities ci ON c.id = ci.country_id
WHERE c.code IN ('BDI', 'COD', 'ETH', 'GHA', 'KEN', 'NGA', 'ZAF', 'TZA', 'UGA', 'RWA')
GROUP BY c.name
ORDER BY c.name;
```

### Result:
```
           country            | city_count 
------------------------------+------------
 Burundi                      |          5
 Democratic Republic of Congo |          7
 Ethiopia                     |          6
 Ghana                        |          6
 Kenya                        |         11  ⚠️ (6 Kenyan + 5 Rwandan)
 Nigeria                      |          7
 Rwanda                       |          5
 South Africa                 |          6
 Tanzania                     |          6
 Uganda                       |          6
```

✅ **All countries now have cities!**

---

## API Testing

Users can now fetch cities by country using the API:

```bash
# Get cities for Nigeria
curl "https://zoea-africa.qtsoftwareltd.com/api/cities?countryCode=NGA"

# Get cities for Kenya
curl "https://zoea-africa.qtsoftwareltd.com/api/cities?countryCode=KEN"
```

---

## Mobile App Impact

### What Works Now:
1. ✅ Users can select any African country
2. ✅ Cities will appear when a country is selected
3. ✅ Registration/profile forms will show relevant cities
4. ✅ Search and filters will work for all countries

### No App Changes Needed:
The mobile app already has the functionality to fetch cities by country. This was purely a data issue.

---

## Future Improvements

1. **Add More Cities:** Currently only major cities are included. Can add more as needed.

2. **Fix Kenya Duplicate Cities:** Clean up merchant profiles and remove Rwandan cities from Kenya.

3. **Add Coordinates:** Cities currently don't have lat/long coordinates. Add these for:
   - Map displays
   - Distance calculations
   - Geolocation features

4. **Add City Images:** Add representative images for each city.

5. **Add Population Data:** Useful for sorting and displaying city importance.

---

## Files Created

1. `add-african-cities.sql` - Initial script (failed due to foreign key constraints)
2. `add-african-cities-v2.sql` - Successful script (no deletion, just insertion)
3. `AFRICAN_CITIES_ADDED.md` - This documentation file

---

**Added By:** AI Assistant  
**Executed:** January 5, 2026, 9:35 AM UTC  
**Database:** PostgreSQL on 172.16.40.61  
**Total Cities Added:** 54 new cities across 9 countries

