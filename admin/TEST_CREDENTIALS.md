# Test Credentials for Zoea Admin

## Admin Login

The login system currently uses mock authentication for development/testing purposes.

### Test Credentials

**Email:** `admin@zoea.ai`  
**Password:** `password` (or any password - currently accepts any non-empty value)

**Alternative Test Credentials:**

- **Email:** `test@zoea.ai`  
- **Password:** `test123`

- **Email:** `admin@example.com`  
- **Password:** `admin`

### Notes

- Currently, the login page accepts **any email and password combination** as long as both fields are filled
- The authentication is stored in `sessionStorage` with key `zoeaAdminAuth`
- After login, you'll be redirected to `/admin/dashboard`
- To logout, click the user menu in the header and select "Logout"

### Development Mode

In development mode, the authentication is simplified:
- No actual database validation
- No password hashing
- Session stored in browser's sessionStorage
- Session persists until browser is closed

### Production Notes

⚠️ **Important:** Before deploying to production, you must:
1. Implement proper authentication with database validation
2. Add password hashing (bcrypt, argon2, etc.)
3. Implement secure session management (JWT tokens or secure cookies)
4. Add rate limiting for login attempts
5. Implement proper error handling

