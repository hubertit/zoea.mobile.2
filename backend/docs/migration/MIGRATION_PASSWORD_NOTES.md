# Password Migration Strategy

## Overview

All migrated users from V1 will have their passwords reset to a default password: **`Pass123`**

## Rationale

- V1 used SHA1 encryption (insecure)
- V2 uses bcrypt (secure)
- Converting SHA1 to bcrypt is not straightforward
- Simpler to reset all passwords and let users change on first login

## Implementation

1. **During Migration:**
   - All migrated users get password hash for "Pass123" (bcrypt, salt rounds: 10)
   - Original V1 password hash stored in `legacyPasswordHash` field (for reference only)
   - `passwordMigrated` flag set to `true`

2. **User Communication:**
   - Users should be notified via email/SMS that their password has been reset
   - They should be prompted to change password on first login
   - Mobile app should show a password change prompt for migrated users

3. **Security:**
   - Default password "Pass123" is temporary
   - Users must change password on first login
   - Consider adding a "must change password" flag in the future

## Default Password

**Password:** `Pass123`

**Note:** This is a temporary password. All users should change it on first login.

## Future Enhancements

- Add `mustChangePassword` boolean field to User model
- Add password change prompt in mobile app
- Add email notification when password is reset
- Add password strength requirements

