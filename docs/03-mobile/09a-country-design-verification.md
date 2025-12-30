# Country Design Verification

**Date**: December 30, 2024  
**Purpose**: Verify correct distinction between user country of origin and app/listing countries

---

## ✅ Design is Correct!

The codebase correctly distinguishes between two different country concepts:

### 1. **User Country of Origin** (Where user is FROM)

**Purpose**: UX-first data collection - understanding user demographics

**Storage:**
- **Database**: `users.country_of_origin` (VARCHAR(3)) - ISO country code string
- **Mobile Model**: `UserPreferences.countryOfOrigin` (String) - ISO code like "RW", "US", "KE"
- **Backend**: `users.countryOfOrigin` (String) - ISO code

**Usage:**
- Collected during onboarding via `CountrySelector` widget
- Used for personalization and analytics
- Inferred from device locale via `DataInferenceService`
- Stored as ISO 2-letter or 3-letter country code (e.g., "RW", "US")

**Example Values:**
- "RW" - Rwanda (user's home country)
- "US" - United States (user's home country)
- "KE" - Kenya (user's home country)

---

### 2. **App/Listing Countries** (Where app operates / Where listings are)

**Purpose**: Geographic scope of the app - where listings, events, tours are located

**Storage:**
- **Database**: `users.country_id` (UUID) - Foreign key to `countries` table
- **Database**: `listings.country_id` (UUID) - Foreign key to `countries` table
- **Database**: `events.country_id` (UUID) - Foreign key to `countries` table
- **Database**: `cities.country_id` (UUID) - Foreign key to `countries` table
- **Backend**: References `Country` model via UUID

**Usage:**
- Defines where the app operates (Rwanda, Kenya, Tanzania, etc.)
- Used for filtering listings, events, tours by location
- Used for city/region selection
- Stored as UUID reference to `countries` table

**Countries Table Structure:**
```prisma
model Country {
  id                   String    @id @default(uuid_generate_v4()) @db.Uuid
  name                 String    @db.VarChar(100)  // "Rwanda", "Kenya", "Tanzania"
  code                 String    @unique @db.VarChar(3)  // "RWA", "KEN", "TZA"
  code2                String    @unique @db.VarChar(2)  // "RW", "KE", "TZ"
  isActive             Boolean?  @default(false)  // Is app operating here?
  launchedAt           DateTime?  // When did we launch in this country?
  // ... other fields
}
```

**Example Values:**
- UUID reference to "Rwanda" country record
- UUID reference to "Kenya" country record (when app expands)
- UUID reference to "Tanzania" country record (when app expands)

---

## Database Schema Verification

### User Table - Both Fields Present ✅

```prisma
model User {
  // ... other fields
  
  // App/Listing Country (where user is located/exploring)
  countryId            String?   @map("country_id") @db.Uuid
  country              Country?  @relation(fields: [countryId], references: [id])
  
  // User Country of Origin (where user is FROM)
  countryOfOrigin      String?   @map("country_of_origin") @db.VarChar(3)
  
  // ... other fields
}
```

**✅ Correct!** Both fields exist and serve different purposes:
- `countryId` → UUID → Countries table → Where app operates
- `countryOfOrigin` → ISO code string → User's origin country

---

## Mobile App Verification

### UserPreferences Model ✅

```dart
class UserPreferences {
  // User's country of origin (ISO code)
  final String? countryOfOrigin; // "RW", "US", "KE"
  
  // ... other fields
}
```

**✅ Correct!** Uses ISO code string for country of origin.

### CountrySelector Widget ✅

```dart
class CountrySelector extends StatelessWidget {
  final String? selectedCountry;  // ISO code like "RW"
  final Function(String) onCountrySelected;  // Returns ISO code
  
  // Common countries list uses ISO codes
  this.commonCountries = const [
    'RW', 'US', 'GB', 'KE', 'UG', 'TZ', // ISO codes
  ];
}
```

**✅ Correct!** Widget uses ISO codes for country of origin selection.

### DataInferenceService ✅

```dart
class DataInferenceService {
  // Returns ISO country code (e.g., "RW", "US")
  Future<String?> inferCountryFromLocale() async {
    // Returns ISO 2-letter code
    return countryCode; // "RW", "US", etc.
  }
}
```

**✅ Correct!** Service infers and returns ISO codes for country of origin.

---

## Backend API Verification

### UpdatePreferencesDto ✅

```typescript
export class UpdatePreferencesDto {
  // User country of origin (ISO code)
  @ApiPropertyOptional({ example: 'RW', description: 'ISO country code' })
  @IsString() @IsOptional()
  countryOfOrigin?: string;  // ISO code string
  
  // ... other fields
}
```

**✅ Correct!** DTO accepts ISO code string for country of origin.

### UsersService ✅

```typescript
async updatePreferences(userId: string, data: {
  countryOfOrigin?: string;  // ISO code
  // ... other fields
}) {
  return this.prisma.user.update({
    where: { id: userId },
    data: {
      countryOfOrigin: data.countryOfOrigin,  // Stored as VARCHAR(3)
      // ... other fields
    },
  });
}
```

**✅ Correct!** Service stores ISO code string in `country_of_origin` column.

---

## Summary

| Aspect | User Country of Origin | App/Listing Countries |
|--------|----------------------|----------------------|
| **Purpose** | User demographics | Geographic scope |
| **Storage Type** | ISO code string (VARCHAR(3)) | UUID (foreign key) |
| **Database Column** | `country_of_origin` | `country_id` |
| **Table Reference** | None (just string) | `countries` table |
| **Example Values** | "RW", "US", "KE" | UUID of Rwanda, Kenya, etc. |
| **Used For** | Personalization, analytics | Filtering listings, events |
| **Collected Via** | CountrySelector widget | Country selection for listings |
| **Inferred From** | Device locale | User selection / app settings |

---

## ✅ Conclusion

**The design is 100% correct!** 

- ✅ User country of origin uses ISO code strings (VARCHAR(3))
- ✅ App/listing countries use UUID foreign keys to countries table
- ✅ No confusion or mixing of concepts
- ✅ Both fields serve distinct purposes
- ✅ Mobile app correctly uses ISO codes for country of origin
- ✅ Backend correctly stores ISO codes in separate column

**No changes needed!** The implementation correctly distinguishes between:
1. **Where the user is FROM** (country of origin - ISO code)
2. **Where the app operates** (listing countries - UUID reference)

---

**Status**: ✅ Verified and Correct

