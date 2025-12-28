/**
 * Comprehensive user data cleaning utility
 * Handles all data corruption and quality issues to ensure no user is lost
 */

export interface CleanedUserData {
  email: string | null;
  phoneNumber: string | null;
  firstName: string | null;
  lastName: string | null;
  fullName: string;
  hasValidContact: boolean;
  issues: string[];
}

/**
 * Remove null bytes and invalid UTF-8 characters
 */
function sanitizeString(str: string | null | undefined): string {
  if (!str) return '';
  // Remove null bytes and other invalid UTF-8 characters
  return str.replace(/\0/g, '').replace(/[\x00-\x08\x0B\x0C\x0E-\x1F\x7F]/g, '').trim();
}

/**
 * Clean and normalize user data from V1
 * Handles all edge cases to ensure migration success
 */
export function cleanUserData(v1User: any, userId: number): CleanedUserData {
  const issues: string[] = [];
  let email: string | null = null;
  let phoneNumber: string | null = null;
  let firstName: string | null = null;
  let lastName: string | null = null;
  let fullName: string = '';

  // Step 1: Extract and clean email field (sanitize to remove null bytes)
  const rawEmail = sanitizeString(v1User.user_email);
  const rawPhone = sanitizeString(v1User.user_phone);

  // Step 2: Check for data corruption - email in phone field
  if (rawPhone && rawPhone.includes('@')) {
    // Phone field contains email - this is data corruption
    issues.push('email_in_phone_field');
    
    if (!rawEmail || rawEmail === '') {
      // No email in email field, move phone (which is email) to email
      email = rawPhone;
      phoneNumber = null;
    } else if (rawEmail === rawPhone) {
      // Both fields have same email - keep email, generate placeholder phone
      email = rawEmail;
      phoneNumber = `250999${String(userId).padStart(6, '0')}`;
      issues.push('generated_placeholder_phone');
    } else {
      // Different values - keep email field as email, phone is corrupted
      email = rawEmail;
      phoneNumber = null;
      issues.push('corrupted_phone_removed');
    }
  } else {
    // Phone field is valid (not an email)
    // Check if email field is valid
    if (rawEmail && rawEmail.includes('@')) {
      // Valid email
      email = rawEmail;
    } else if (rawEmail && rawEmail !== '') {
      // Email field has value but no @ - might be invalid, but keep it
      email = rawEmail;
      issues.push('invalid_email_format');
    } else {
      // No email
      email = null;
    }

    // Process phone number
    if (rawPhone && rawPhone !== '' && rawPhone !== '0') {
      // Clean phone number
      let cleanedPhone = rawPhone.replace(/[^\d+]/g, ''); // Remove non-digit chars except +
      
      // Validate phone length (should be at least 8 digits)
      if (cleanedPhone.length >= 8) {
        // Add country code if missing
        if (!cleanedPhone.startsWith('+') && !cleanedPhone.startsWith('250')) {
          const countryCode = v1User.country_code || '250';
          cleanedPhone = countryCode + cleanedPhone.replace(/^0+/, '');
        }
        phoneNumber = cleanedPhone;
      } else {
        // Phone too short - invalid
        phoneNumber = null;
        issues.push('invalid_phone_length');
      }
    } else {
      phoneNumber = null;
    }
  }

  // Step 3: Ensure we have at least one contact method (CHECK constraint requirement)
  // If no email AND no phone, generate placeholder phone
  if (!email && !phoneNumber) {
    phoneNumber = `250999${String(userId).padStart(6, '0')}`;
    issues.push('generated_placeholder_phone_no_contact');
  }

  // Step 4: Clean names (sanitize to remove null bytes)
  firstName = sanitizeString(v1User.user_fname) || null;
  lastName = sanitizeString(v1User.user_lname) || null;
  
  if (firstName || lastName) {
    fullName = [firstName, lastName].filter(Boolean).join(' ').trim();
  } else {
    // Generate placeholder name
    if (email) {
      fullName = email.split('@')[0] || `User ${userId}`;
    } else if (phoneNumber) {
      fullName = `User ${phoneNumber.slice(-4)}`;
    } else {
      fullName = `User ${userId}`;
    }
    issues.push('generated_placeholder_name');
  }

  const hasValidContact = !!(email || phoneNumber);

  return {
    email,
    phoneNumber,
    firstName,
    lastName,
    fullName,
    hasValidContact,
    issues,
  };
}

/**
 * Check if email is valid format
 */
export function isValidEmail(email: string | null): boolean {
  if (!email) return false;
  return email.includes('@') && email.length > 3;
}

/**
 * Check if phone is valid format
 */
export function isValidPhone(phone: string | null): boolean {
  if (!phone) return false;
  // Should be at least 8 digits, no @ symbol
  const digits = phone.replace(/\D/g, '');
  return digits.length >= 8 && !phone.includes('@');
}

