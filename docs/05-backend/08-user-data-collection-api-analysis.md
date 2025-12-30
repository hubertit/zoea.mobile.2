# User Data Collection API - Analysis & Improvements

**Date**: December 30, 2024  
**Purpose**: Comprehensive analysis of user data collection APIs, identify gaps, and propose improvements

---

## Current API Patterns (Learning from Codebase)

### 1. **Controller Structure**
```typescript
@ApiTags('Users')
@Controller('users')
export class UsersController {
  @Get('me/preferences')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Get user preferences' })
  async getPreferences(@Request() req) {
    return this.usersService.getPreferences(req.user.id);
  }
}
```

**Patterns:**
- ✅ All controllers use `@ApiTags` for Swagger grouping
- ✅ All protected routes use `@UseGuards(JwtAuthGuard)` and `@ApiBearerAuth()`
- ✅ All endpoints have `@ApiOperation` with summary
- ✅ User-specific endpoints use `/me` prefix
- ✅ Direct return from service (no response wrapper)

### 2. **DTO Validation**
```typescript
export class UpdatePreferencesDto {
  @ApiPropertyOptional({ example: 'RW', description: 'ISO country code' })
  @IsString() @IsOptional()
  countryOfOrigin?: string;

  @ApiPropertyOptional({ example: 'resident', enum: ['resident', 'visitor'] })
  @IsString() @IsOptional()
  userType?: string;
}
```

**Patterns:**
- ✅ Uses `class-validator` decorators (`@IsString`, `@IsOptional`, etc.)
- ✅ Uses `@ApiPropertyOptional` for Swagger docs
- ✅ Includes examples and descriptions
- ✅ Enum values documented in `@ApiPropertyOptional`

### 3. **Service Layer**
```typescript
async updatePreferences(userId: string, data: UpdatePreferencesDto) {
  return this.prisma.user.update({
    where: { id: userId },
    data: updateData,
    select: { /* fields */ },
  });
}
```

**Patterns:**
- ✅ Services throw exceptions (`BadRequestException`, `NotFoundException`)
- ✅ Uses Prisma for database operations
- ✅ Explicit `select` for returned fields
- ✅ Direct return (no wrapper)

### 4. **Error Handling**
- Exceptions thrown from services are automatically handled by NestJS
- Standard HTTP status codes:
  - `400` - BadRequestException
  - `401` - Unauthorized (via JwtAuthGuard)
  - `404` - NotFoundException
  - `409` - ConflictException

---

## Current User Data Collection APIs

### ✅ Existing Endpoints

#### 1. **GET /users/me/preferences**
**Status**: ✅ Complete  
**Purpose**: Get all user preferences including UX-first data collection fields

**Response:**
```json
{
  "preferredCurrency": "RWF",
  "preferredLanguage": "en",
  "countryOfOrigin": "RW",
  "userType": "resident",
  "visitPurpose": "leisure",
  "ageRange": "26-35",
  "gender": "male",
  "lengthOfStay": "1-3 days",
  "travelParty": "solo",
  "dataCollectionFlags": {
    "countryAsked": true,
    "ageAsked": true
  },
  "dataCollectionCompletedAt": "2024-12-30T10:00:00Z"
}
```

**Issues**: None ✅

---

#### 2. **PUT /users/me/preferences**
**Status**: ✅ Complete  
**Purpose**: Update user preferences including UX-first data collection fields

**Request Body:**
```json
{
  "countryOfOrigin": "RW",
  "userType": "resident",
  "visitPurpose": "leisure",
  "ageRange": "26-35",
  "gender": "male",
  "lengthOfStay": "1-3 days",
  "travelParty": "solo",
  "dataCollectionFlags": {
    "ageAsked": true
  },
  "dataCollectionCompletedAt": "2024-12-30T10:00:00Z"
}
```

**Issues**: 
- ⚠️ **Enum validation missing** - Should validate enum values
- ⚠️ **Country code validation** - Should validate ISO country codes

---

## Identified Gaps & Improvements

### 1. **Missing Validation**

#### Issue: Enum Values Not Validated
**Current**: DTO accepts any string for enum fields  
**Problem**: Invalid values like `"invalid"` for `userType` are accepted

**Solution**: Add custom validators or use `@IsIn()` decorator

```typescript
@ApiPropertyOptional({ example: 'resident', enum: ['resident', 'visitor'] })
@IsString() 
@IsIn(['resident', 'visitor'])  // ✅ Add this
@IsOptional()
userType?: string;
```

#### Issue: Country Code Not Validated
**Current**: Any string accepted for `countryOfOrigin`  
**Problem**: Invalid country codes accepted

**Solution**: Add custom validator or use regex pattern

```typescript
@ApiPropertyOptional({ example: 'RW', description: 'ISO 2-letter country code' })
@IsString()
@Matches(/^[A-Z]{2}$/, { message: 'countryOfOrigin must be a valid ISO 2-letter country code' })
@IsOptional()
countryOfOrigin?: string;
```

---

### 2. **Missing Helper Endpoints**

#### Gap: Mandatory Data Completion Check
**Mobile App Needs**: `isMandatoryDataComplete()` method checks locally  
**API Missing**: No endpoint to check completion status server-side

**Proposed Endpoint:**
```typescript
@Get('me/preferences/completion-status')
@UseGuards(JwtAuthGuard)
@ApiBearerAuth()
@ApiOperation({ summary: 'Get data collection completion status' })
async getCompletionStatus(@Request() req) {
  return this.usersService.getCompletionStatus(req.user.id);
}
```

**Response:**
```json
{
  "isMandatoryComplete": true,
  "isOptionalComplete": false,
  "completionPercentage": 70,
  "missingMandatoryFields": [],
  "missingOptionalFields": ["ageRange", "gender"]
}
```

#### Gap: Profile Completion Percentage
**Mobile App Needs**: `getProfileCompletionPercentage()` calculates locally  
**API Missing**: No endpoint for server-side calculation

**Proposed Endpoint:**
```typescript
@Get('me/profile/completion')
@UseGuards(JwtAuthGuard)
@ApiBearerAuth()
@ApiOperation({ summary: 'Get profile completion percentage' })
async getProfileCompletion(@Request() req) {
  return this.usersService.getProfileCompletion(req.user.id);
}
```

**Response:**
```json
{
  "percentage": 70,
  "completedFields": 7,
  "totalFields": 10,
  "missingFields": ["ageRange", "gender", "lengthOfStay"]
}
```

---

### 3. **API Design Improvements**

#### Improvement: Better Error Messages
**Current**: Generic validation errors  
**Better**: Specific field-level error messages

**Example:**
```json
{
  "statusCode": 400,
  "message": "Validation failed",
  "errors": [
    {
      "field": "userType",
      "message": "userType must be one of: resident, visitor"
    },
    {
      "field": "countryOfOrigin",
      "message": "countryOfOrigin must be a valid ISO 2-letter country code"
    }
  ]
}
```

#### Improvement: Batch Update Endpoint
**Current**: Single PUT endpoint for all preferences  
**Better**: Separate endpoint for onboarding data (optional)

**Proposed:**
```typescript
@Post('me/preferences/onboarding')
@UseGuards(JwtAuthGuard)
@ApiBearerAuth()
@ApiOperation({ summary: 'Complete onboarding data collection' })
async completeOnboarding(@Request() req, @Body() data: OnboardingDataDto) {
  return this.usersService.completeOnboarding(req.user.id, data);
}
```

**Benefits:**
- Clearer intent
- Can set `dataCollectionCompletedAt` automatically
- Better validation for mandatory fields

---

## Recommended Actions

### Priority 1: Critical (Do Now)
1. ✅ **Add enum validation** to `UpdatePreferencesDto`
2. ✅ **Add country code validation** to `UpdatePreferencesDto`
3. ✅ **Add completion status endpoint** (`GET /users/me/preferences/completion-status`)
4. ✅ **Add profile completion endpoint** (`GET /users/me/profile/completion`)

### Priority 2: Important (Do Soon)
5. ⚠️ **Improve error messages** with field-level details
6. ⚠️ **Add onboarding endpoint** (`POST /users/me/preferences/onboarding`)

### Priority 3: Nice to Have (Future)
7. 📋 **Add validation for dataCollectionFlags** structure
8. 📋 **Add bulk update endpoint** for multiple fields
9. 📋 **Add data collection analytics endpoint** (for admin)

---

## Implementation Plan

### Step 1: Add Validation to DTO
- Add `@IsIn()` for enum fields
- Add `@Matches()` for country code
- Test with invalid values

### Step 2: Add Helper Endpoints
- Implement `getCompletionStatus()` in service
- Implement `getProfileCompletion()` in service
- Add controller endpoints
- Update Swagger docs

### Step 3: Test & Verify
- Test all endpoints
- Verify error handling
- Check mobile app integration

---

## API Consistency Checklist

| Aspect | Status | Notes |
|--------|--------|-------|
| Swagger Documentation | ✅ | All endpoints documented |
| Authentication | ✅ | All protected routes use JwtAuthGuard |
| DTO Validation | ⚠️ | Missing enum/country validation |
| Error Handling | ✅ | Uses standard exceptions |
| Response Format | ✅ | Direct return (consistent) |
| Endpoint Naming | ✅ | Follows `/me` pattern |
| Helper Endpoints | ❌ | Missing completion status endpoints |

---

**Next Steps**: Implement Priority 1 improvements

