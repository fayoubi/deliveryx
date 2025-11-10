/**
 * Validation utilities for form fields
 * Matches backend validation patterns
 */

// Phone number validation: allows digits, spaces, dashes, plus signs, parentheses
const phoneRegex = /^[\d\s\-\+\(\)]+$/;

// URL validation: must start with http:// or https://
const urlRegex = /^https?:\/\/.+/i;

/**
 * Validate phone number format
 * @param {string} phone - Phone number to validate
 * @returns {string|true} - Error message or true if valid
 */
export const validatePhone = (phone) => {
  if (!phone || phone.trim() === '') {
    return 'Phone number is required';
  }

  if (!phoneRegex.test(phone)) {
    return 'Phone number contains invalid characters';
  }

  // Check if phone has at least one digit
  if (!/\d/.test(phone)) {
    return 'Phone number must contain at least one digit';
  }

  return true;
};

/**
 * Validate URL format (optional field)
 * @param {string} url - URL to validate
 * @returns {string|true} - Error message or true if valid
 */
export const validateUrl = (url) => {
  // Empty is valid (optional field)
  if (!url || url.trim() === '') {
    return true;
  }

  if (!urlRegex.test(url)) {
    return 'URL must start with http:// or https://';
  }

  return true;
};

/**
 * Validate latitude range
 * @param {number} lat - Latitude value
 * @returns {string|true} - Error message or true if valid
 */
export const validateLatitude = (lat) => {
  // Empty is valid (optional field)
  if (lat === undefined || lat === null || lat === '') {
    return true;
  }

  const numLat = parseFloat(lat);

  if (isNaN(numLat)) {
    return 'Latitude must be a number';
  }

  if (numLat < -90 || numLat > 90) {
    return 'Latitude must be between -90 and 90';
  }

  return true;
};

/**
 * Validate longitude range
 * @param {number} lng - Longitude value
 * @returns {string|true} - Error message or true if valid
 */
export const validateLongitude = (lng) => {
  // Empty is valid (optional field)
  if (lng === undefined || lng === null || lng === '') {
    return true;
  }

  const numLng = parseFloat(lng);

  if (isNaN(numLng)) {
    return 'Longitude must be a number';
  }

  if (numLng < -180 || numLng > 180) {
    return 'Longitude must be between -180 and 180';
  }

  return true;
};

/**
 * Validate field length
 * @param {string} value - Value to validate
 * @param {number} maxLength - Maximum allowed length
 * @param {string} fieldName - Name of field for error message
 * @returns {string|true} - Error message or true if valid
 */
export const validateLength = (value, maxLength, fieldName = 'Field') => {
  if (!value) {
    return true; // Let required validation handle empty values
  }

  if (value.length > maxLength) {
    return `${fieldName} must not exceed ${maxLength} characters`;
  }

  return true;
};

/**
 * Get store initials for placeholder logo
 * @param {string} storeName - Store name
 * @returns {string} - Initials (max 2 characters)
 */
export const getStoreInitials = (storeName) => {
  if (!storeName) return '?';

  const words = storeName.trim().split(/\s+/);
  if (words.length === 1) {
    return words[0].substring(0, 2).toUpperCase();
  }

  return (words[0][0] + words[1][0]).toUpperCase();
};
