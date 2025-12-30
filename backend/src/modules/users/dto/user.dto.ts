import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { IsString, IsOptional, IsEmail, IsBoolean, IsArray, IsNumber, IsUUID, MinLength, IsDateString, IsIn, Matches } from 'class-validator';

export class UpdateUserDto {
  @ApiPropertyOptional({ example: 'John Doe' })
  @IsString() @IsOptional()
  fullName?: string;

  @ApiPropertyOptional({ example: 'John' })
  @IsString() @IsOptional()
  firstName?: string;

  @ApiPropertyOptional({ example: 'Doe' })
  @IsString() @IsOptional()
  lastName?: string;

  @ApiPropertyOptional({ example: 'johndoe' })
  @IsString() @IsOptional()
  username?: string;

  @ApiPropertyOptional({ example: 'Travel enthusiast' })
  @IsString() @IsOptional()
  bio?: string;

  @ApiPropertyOptional({ example: '1990-01-15' })
  @IsDateString() @IsOptional()
  dateOfBirth?: string;

  @ApiPropertyOptional({ example: 'male', enum: ['male', 'female', 'other', 'prefer_not_to_say'] })
  @IsString() @IsOptional()
  gender?: string;

  @ApiPropertyOptional({ 
    example: '123e4567-e89b-12d3-a456-426614174000',
    description: 'UUID of the country where the user is located (operational country, not country of origin)'
  })
  @IsUUID() @IsOptional()
  countryId?: string;

  @ApiPropertyOptional({ 
    example: '123e4567-e89b-12d3-a456-426614174001',
    description: 'UUID of the city where the user is located'
  })
  @IsUUID() @IsOptional()
  cityId?: string;

  @ApiPropertyOptional({ example: '123 Main St' })
  @IsString() @IsOptional()
  address?: string;

  @ApiPropertyOptional({ example: '12345' })
  @IsString() @IsOptional()
  postalCode?: string;

  @ApiPropertyOptional({ example: 'Software Developer' })
  @IsString() @IsOptional()
  profession?: string;

  @ApiPropertyOptional({ example: 'Tech Corp' })
  @IsString() @IsOptional()
  company?: string;

  @ApiPropertyOptional({ example: 'Technology' })
  @IsString() @IsOptional()
  industry?: string;

  @ApiPropertyOptional({ example: ['travel', 'food', 'music'], type: [String] })
  @IsArray() @IsOptional()
  interests?: string[];

  @ApiPropertyOptional({ example: ['vegetarian'], type: [String] })
  @IsArray() @IsOptional()
  dietaryPreferences?: string[];

  @ApiPropertyOptional({ example: ['wheelchair'], type: [String] })
  @IsArray() @IsOptional()
  accessibilityNeeds?: string[];

  @ApiPropertyOptional({ example: 'USD' })
  @IsString() @IsOptional()
  preferredCurrency?: string;

  @ApiPropertyOptional({ example: 'en' })
  @IsString() @IsOptional()
  preferredLanguage?: string;

  @ApiPropertyOptional({ example: 'Africa/Kigali' })
  @IsString() @IsOptional()
  timezone?: string;

  @ApiPropertyOptional({ example: 50 })
  @IsNumber() @IsOptional()
  maxDistance?: number;

  @ApiPropertyOptional({ example: false })
  @IsBoolean() @IsOptional()
  isPrivate?: boolean;

  @ApiPropertyOptional({ example: true })
  @IsBoolean() @IsOptional()
  marketingConsent?: boolean;
}

export class UpdateEmailDto {
  @ApiProperty({ example: 'newemail@example.com' })
  @IsEmail()
  email: string;

  @ApiProperty({ example: 'currentPassword123' })
  @IsString()
  password: string;
}

export class UpdatePhoneDto {
  @ApiProperty({ example: '+250788000000' })
  @IsString()
  phoneNumber: string;

  @ApiProperty({ example: 'currentPassword123' })
  @IsString()
  password: string;
}

export class ChangePasswordDto {
  @ApiProperty({ example: 'currentPassword123' })
  @IsString()
  currentPassword: string;

  @ApiProperty({ example: 'newPassword456', minLength: 6 })
  @IsString() @MinLength(6)
  newPassword: string;
}

export class UpdatePreferencesDto {
  @ApiPropertyOptional({ example: 'USD' })
  @IsString() @IsOptional()
  preferredCurrency?: string;

  @ApiPropertyOptional({ example: 'en' })
  @IsString() @IsOptional()
  preferredLanguage?: string;

  @ApiPropertyOptional({ example: 'Africa/Kigali' })
  @IsString() @IsOptional()
  timezone?: string;

  @ApiPropertyOptional({ example: 50 })
  @IsNumber() @IsOptional()
  maxDistance?: number;

  @ApiPropertyOptional({ example: { email: true, push: true, sms: false } })
  @IsOptional()
  notificationPreferences?: any;

  @ApiPropertyOptional({ example: true })
  @IsBoolean() @IsOptional()
  marketingConsent?: boolean;

  @ApiPropertyOptional({ example: ['travel', 'food'], type: [String] })
  @IsArray() @IsOptional()
  interests?: string[];

  @ApiPropertyOptional({ example: false })
  @IsBoolean() @IsOptional()
  isPrivate?: boolean;

  // UX-First User Data Collection fields
  @ApiPropertyOptional({ example: 'RW', description: 'ISO 2-letter country code' })
  @IsString()
  @Matches(/^[A-Z]{2}$/, { message: 'countryOfOrigin must be a valid ISO 2-letter country code (e.g., RW, US, KE)' })
  @IsOptional()
  countryOfOrigin?: string;

  @ApiPropertyOptional({ example: 'resident', enum: ['resident', 'visitor'] })
  @IsString()
  @IsIn(['resident', 'visitor'], { message: 'userType must be either "resident" or "visitor"' })
  @IsOptional()
  userType?: string;

  @ApiPropertyOptional({ example: 'leisure', enum: ['leisure', 'business', 'mice'] })
  @IsString()
  @IsIn(['leisure', 'business', 'mice'], { message: 'visitPurpose must be one of: leisure, business, mice' })
  @IsOptional()
  visitPurpose?: string;

  @ApiPropertyOptional({ example: '18-25', enum: ['under-18', '18-25', '26-35', '36-45', '46-55', '56+'] })
  @IsString()
  @IsIn(['under-18', '18-25', '26-35', '36-45', '46-55', '56+'], { message: 'ageRange must be one of: under-18, 18-25, 26-35, 36-45, 46-55, 56+' })
  @IsOptional()
  ageRange?: string;

  @ApiPropertyOptional({ example: 'male', enum: ['male', 'female', 'other', 'prefer_not_to_say'] })
  @IsString()
  @IsIn(['male', 'female', 'other', 'prefer_not_to_say'], { message: 'gender must be one of: male, female, other, prefer_not_to_say' })
  @IsOptional()
  gender?: string;

  @ApiPropertyOptional({ 
    example: '1-3 days', 
    enum: ['1-3 days', '4-7 days', '1-2 weeks', '2+ weeks'],
    description: 'Length of stay in Rwanda. Only applicable for visitors, not residents.' 
  })
  @IsString()
  @IsIn(['1-3 days', '4-7 days', '1-2 weeks', '2+ weeks'], { message: 'lengthOfStay must be one of: 1-3 days, 4-7 days, 1-2 weeks, 2+ weeks' })
  @IsOptional()
  lengthOfStay?: string;

  @ApiPropertyOptional({ example: 'solo', enum: ['solo', 'couple', 'family', 'group'] })
  @IsString()
  @IsIn(['solo', 'couple', 'family', 'group'], { message: 'travelParty must be one of: solo, couple, family, group' })
  @IsOptional()
  travelParty?: string;

  @ApiPropertyOptional({ 
    example: { 'ageAsked': true, 'genderAsked': false, 'interestsAsked': true },
    type: Object,
    description: 'JSON object tracking which data collection prompts have been shown to the user. Keys are prompt identifiers (e.g., "ageAsked", "genderAsked"), values are booleans indicating if the prompt was shown.'
  })
  @IsOptional()
  dataCollectionFlags?: Record<string, boolean>;

  @ApiPropertyOptional({ 
    description: 'ISO 8601 timestamp when mandatory data collection was completed',
    example: '2024-01-15T10:30:00Z'
  })
  @IsDateString() @IsOptional()
  dataCollectionCompletedAt?: string;
}

export class CreateMerchantProfileDto {
  @ApiProperty({ example: 'My Hotel Business' })
  @IsString()
  businessName: string;

  @ApiProperty({ example: 'hotel', enum: ['hotel', 'restaurant', 'attraction', 'activity', 'rental', 'other'] })
  @IsString()
  businessType: string;

  @ApiPropertyOptional({ example: 'REG123456' })
  @IsString() @IsOptional()
  businessRegistrationNumber?: string;

  @ApiPropertyOptional({ example: 'TAX789' })
  @IsString() @IsOptional()
  taxId?: string;

  @ApiPropertyOptional({ example: 'Premier hotel in Kigali' })
  @IsString() @IsOptional()
  description?: string;

  @ApiPropertyOptional({ example: 'contact@hotel.com' })
  @IsEmail() @IsOptional()
  businessEmail?: string;

  @ApiPropertyOptional({ example: '+250788000000' })
  @IsString() @IsOptional()
  businessPhone?: string;

  @ApiPropertyOptional({ example: 'https://myhotel.com' })
  @IsString() @IsOptional()
  website?: string;

  @ApiPropertyOptional({ example: { facebook: 'url', instagram: 'url' } })
  @IsOptional()
  socialLinks?: any;

  @ApiPropertyOptional()
  @IsUUID() @IsOptional()
  countryId?: string;

  @ApiPropertyOptional()
  @IsUUID() @IsOptional()
  cityId?: string;

  @ApiPropertyOptional({ example: '123 Business Ave' })
  @IsString() @IsOptional()
  address?: string;
}

export class CreateOrganizerProfileDto {
  @ApiProperty({ example: 'Event Masters' })
  @IsString()
  organizationName: string;

  @ApiPropertyOptional({ example: 'company' })
  @IsString() @IsOptional()
  organizationType?: string;

  @ApiPropertyOptional({ example: 'Premier event organizers' })
  @IsString() @IsOptional()
  description?: string;

  @ApiPropertyOptional({ example: 'events@company.com' })
  @IsEmail() @IsOptional()
  contactEmail?: string;

  @ApiPropertyOptional({ example: '+250788000000' })
  @IsString() @IsOptional()
  contactPhone?: string;

  @ApiPropertyOptional({ example: 'https://events.com' })
  @IsString() @IsOptional()
  website?: string;

  @ApiPropertyOptional()
  @IsOptional()
  socialLinks?: any;

  @ApiPropertyOptional()
  @IsUUID() @IsOptional()
  countryId?: string;

  @ApiPropertyOptional()
  @IsUUID() @IsOptional()
  cityId?: string;
}

export class CreateTourOperatorProfileDto {
  @ApiProperty({ example: 'Safari Adventures' })
  @IsString()
  companyName: string;

  @ApiPropertyOptional({ example: 'LIC123' })
  @IsString() @IsOptional()
  licenseNumber?: string;

  @ApiPropertyOptional({ example: 'Best safari tours in East Africa' })
  @IsString() @IsOptional()
  description?: string;

  @ApiPropertyOptional({ example: ['wildlife', 'hiking', 'cultural'], type: [String] })
  @IsArray() @IsOptional()
  specializations?: string[];

  @ApiPropertyOptional({ example: ['en', 'fr', 'sw'], type: [String] })
  @IsArray() @IsOptional()
  languagesOffered?: string[];

  @ApiPropertyOptional({ example: 'tours@safari.com' })
  @IsEmail() @IsOptional()
  contactEmail?: string;

  @ApiPropertyOptional({ example: '+250788000000' })
  @IsString() @IsOptional()
  contactPhone?: string;

  @ApiPropertyOptional({ example: 'https://safari.com' })
  @IsString() @IsOptional()
  website?: string;

  @ApiPropertyOptional()
  @IsOptional()
  socialLinks?: any;

  @ApiPropertyOptional()
  @IsUUID() @IsOptional()
  countryId?: string;

  @ApiPropertyOptional()
  @IsUUID() @IsOptional()
  cityId?: string;

  @ApiPropertyOptional({ example: ['Rwanda', 'Uganda', 'Kenya'], type: [String] })
  @IsArray() @IsOptional()
  operatingRegions?: string[];
}

// Update DTOs (all fields optional)
export class UpdateMerchantProfileDto {
  @ApiPropertyOptional({ example: 'My Hotel Business' })
  @IsString() @IsOptional()
  businessName?: string;

  @ApiPropertyOptional({ example: 'hotel', enum: ['hotel', 'restaurant', 'attraction', 'activity', 'rental', 'other'] })
  @IsString() @IsOptional()
  businessType?: string;

  @ApiPropertyOptional({ example: 'REG123456' })
  @IsString() @IsOptional()
  businessRegistrationNumber?: string;

  @ApiPropertyOptional({ example: 'TAX789' })
  @IsString() @IsOptional()
  taxId?: string;

  @ApiPropertyOptional({ example: 'Premier hotel in Kigali' })
  @IsString() @IsOptional()
  description?: string;

  @ApiPropertyOptional({ example: 'contact@hotel.com' })
  @IsEmail() @IsOptional()
  businessEmail?: string;

  @ApiPropertyOptional({ example: '+250788000000' })
  @IsString() @IsOptional()
  businessPhone?: string;

  @ApiPropertyOptional({ example: 'https://myhotel.com' })
  @IsString() @IsOptional()
  website?: string;

  @ApiPropertyOptional({ example: { facebook: 'url', instagram: 'url' } })
  @IsOptional()
  socialLinks?: any;

  @ApiPropertyOptional()
  @IsUUID() @IsOptional()
  countryId?: string;

  @ApiPropertyOptional()
  @IsUUID() @IsOptional()
  cityId?: string;

  @ApiPropertyOptional({ example: '123 Business Ave' })
  @IsString() @IsOptional()
  address?: string;
}

export class UpdateOrganizerProfileDto {
  @ApiPropertyOptional({ example: 'Event Masters' })
  @IsString() @IsOptional()
  organizationName?: string;

  @ApiPropertyOptional({ example: 'company' })
  @IsString() @IsOptional()
  organizationType?: string;

  @ApiPropertyOptional({ example: 'Premier event organizers' })
  @IsString() @IsOptional()
  description?: string;

  @ApiPropertyOptional({ example: 'events@company.com' })
  @IsEmail() @IsOptional()
  contactEmail?: string;

  @ApiPropertyOptional({ example: '+250788000000' })
  @IsString() @IsOptional()
  contactPhone?: string;

  @ApiPropertyOptional({ example: 'https://events.com' })
  @IsString() @IsOptional()
  website?: string;

  @ApiPropertyOptional()
  @IsOptional()
  socialLinks?: any;

  @ApiPropertyOptional()
  @IsUUID() @IsOptional()
  countryId?: string;

  @ApiPropertyOptional()
  @IsUUID() @IsOptional()
  cityId?: string;
}

export class UpdateTourOperatorProfileDto {
  @ApiPropertyOptional({ example: 'Safari Adventures' })
  @IsString() @IsOptional()
  companyName?: string;

  @ApiPropertyOptional({ example: 'LIC123' })
  @IsString() @IsOptional()
  licenseNumber?: string;

  @ApiPropertyOptional({ example: 'Best safari tours in East Africa' })
  @IsString() @IsOptional()
  description?: string;

  @ApiPropertyOptional({ example: ['wildlife', 'hiking', 'cultural'], type: [String] })
  @IsArray() @IsOptional()
  specializations?: string[];

  @ApiPropertyOptional({ example: ['en', 'fr', 'sw'], type: [String] })
  @IsArray() @IsOptional()
  languagesOffered?: string[];

  @ApiPropertyOptional({ example: 'tours@safari.com' })
  @IsEmail() @IsOptional()
  contactEmail?: string;

  @ApiPropertyOptional({ example: '+250788000000' })
  @IsString() @IsOptional()
  contactPhone?: string;

  @ApiPropertyOptional({ example: 'https://safari.com' })
  @IsString() @IsOptional()
  website?: string;

  @ApiPropertyOptional()
  @IsOptional()
  socialLinks?: any;

  @ApiPropertyOptional()
  @IsUUID() @IsOptional()
  countryId?: string;

  @ApiPropertyOptional()
  @IsUUID() @IsOptional()
  cityId?: string;

  @ApiPropertyOptional({ example: ['Rwanda', 'Uganda', 'Kenya'], type: [String] })
  @IsArray() @IsOptional()
  operatingRegions?: string[];
}

