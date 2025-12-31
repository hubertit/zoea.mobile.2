// Validation utilities for forms

export interface ValidationRule {
  required?: boolean;
  minLength?: number;
  maxLength?: number;
  pattern?: RegExp;
  custom?: (value: any) => string | null;
  email?: boolean;
  phone?: boolean;
  match?: { field: string; message: string };
}

export interface ValidationErrors {
  [key: string]: string;
}

export function validateField(value: any, rules: ValidationRule, allValues?: any): string | null {
  if (rules.required && (!value || (typeof value === 'string' && value.trim() === ''))) {
    return 'This field is required';
  }

  if (!value && !rules.required) {
    return null; // Optional field, no validation needed
  }

  if (rules.minLength && typeof value === 'string' && value.length < rules.minLength) {
    return `Must be at least ${rules.minLength} characters`;
  }

  if (rules.maxLength && typeof value === 'string' && value.length > rules.maxLength) {
    return `Must be no more than ${rules.maxLength} characters`;
  }

  if (rules.pattern && typeof value === 'string' && !rules.pattern.test(value)) {
    return 'Invalid format';
  }

  if (rules.email && typeof value === 'string') {
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if (!emailRegex.test(value)) {
      return 'Please enter a valid email address';
    }
  }

  if (rules.phone && typeof value === 'string') {
    const phoneRegex = /^\+?[\d\s-()]+$/;
    if (!phoneRegex.test(value) || value.replace(/\D/g, '').length < 8) {
      return 'Please enter a valid phone number';
    }
  }

  if (rules.match && allValues) {
    if (value !== allValues[rules.match.field]) {
      return rules.match.message;
    }
  }

  if (rules.custom) {
    return rules.custom(value);
  }

  return null;
}

export function validateForm(
  values: any,
  rules: { [key: string]: ValidationRule }
): ValidationErrors {
  const errors: ValidationErrors = {};

  Object.keys(rules).forEach((key) => {
    const error = validateField(values[key], rules[key], values);
    if (error) {
      errors[key] = error;
    }
  });

  return errors;
}

// Common validation rules
export const commonRules = {
  email: {
    email: true,
    maxLength: 255,
  } as ValidationRule,
  phone: {
    phone: true,
    minLength: 8,
    maxLength: 20,
  } as ValidationRule,
  password: {
    required: true,
    minLength: 6,
    maxLength: 100,
  } as ValidationRule,
  name: {
    required: true,
    minLength: 2,
    maxLength: 100,
  } as ValidationRule,
  url: {
    pattern: /^https?:\/\/.+/,
  } as ValidationRule,
};

