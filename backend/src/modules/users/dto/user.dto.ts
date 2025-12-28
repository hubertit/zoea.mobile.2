import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { IsString, IsOptional, IsEmail, IsBoolean, IsArray, IsNumber, IsUUID, MinLength, IsDateString } from 'class-validator';

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

  @ApiPropertyOptional({ example: 'uuid' })
  @IsUUID() @IsOptional()
  countryId?: string;

  @ApiPropertyOptional({ example: 'uuid' })
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

