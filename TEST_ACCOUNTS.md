# Test Accounts for Zoea Admin Portal

## Super Admin Account
**Email:** `hubert@zoea.africa`  
**Phone:** `250788606765`  
**Role:** `super_admin`  
**Password:** (Please set/reset password if needed)

## Test Merchant Account
To create a test merchant account, you can:

### Option 1: Use Admin Portal (Recommended)
1. Login as super admin (`hubert@zoea.africa`)
2. Go to **Users** → **Create User**
3. Fill in:
   - **Email:** `merchant@test.com` (or any email)
   - **Phone:** `250788000000` (or any phone)
   - **Full Name:** `Test Merchant`
   - **Password:** `Test123456`
   - **Roles:** Select `MERCHANT`
4. Click **Create User**
5. Login with the new credentials

### Option 2: Direct API Call
```bash
# Register the user
curl -X POST https://zoea-africa.qtsoftwareltd.com/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "merchant@test.com",
    "phoneNumber": "250788000000",
    "password": "Test123456",
    "fullName": "Test Merchant"
  }'

# Then assign merchant role (requires admin token)
curl -X PATCH https://zoea-africa.qtsoftwareltd.com/api/admin/users/{userId}/roles \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer {admin_token}" \
  -d '{
    "roles": ["MERCHANT"]
  }'
```

## Quick Test Credentials

### Super Admin
- **Email:** `hubert@zoea.africa`
- **Phone:** `250788606765`
- **Password:** (Contact admin to reset if needed)

### Test Merchant (Create via Admin Portal)
- **Email:** `merchant@test.com`
- **Phone:** `250788000000`
- **Password:** `Test123456`
- **Role:** `MERCHANT`

## How to Verify if Accounts Exist

### Option 1: Via Admin Portal
1. Try logging in with the credentials
2. If login fails with "Invalid credentials", the account exists but password is wrong
3. If login fails with "User not found", the account doesn't exist

### Option 2: Via API
```bash
# Check if super admin account exists (will return 401 if exists, 404 if not)
curl -X POST https://zoea-africa.qtsoftwareltd.com/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "identifier": "hubert@zoea.africa",
    "password": "test"
  }'
```

### Option 3: Run Check Script
```bash
./check-accounts.sh
```

## Notes
- The admin portal supports login by **email OR phone number**
- After creating a merchant account, the user needs to create a business profile to access merchant portal features
- Merchant portal features are only visible to users with `MERCHANT` role
- Super admin can access all features including merchant portal
- **If accounts don't exist**, you can create them via the admin portal's "Create User" feature

