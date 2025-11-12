# 01. Login & Authentication Testing

## 🎯 Overview
Test from the **Backend (BE)** perspective.

**Testing Focus**: API responses, data persistence, business logic, database operations, and backend behavior.

**Estimated Time**: 30-45 minutes  
**Test Cases**: ~35

---

## Test Case 1.1: Super Admin Login - Valid Credentials => Tested by Pawan 

**Prerequisites**: 
- Backend server running
- Frontend server running
- Super Admin account exists (email: admin@luxethreads.com, password: known)

**Steps**:
1. Navigate to `/admin/login` (Frontend) or `/admin/login` (Backend HTML)
2. Enter valid Super Admin email
3. Enter valid password
4. Click "Login" button

**Expected Result**:
- ✅ API: `POST /admin/login` returns 200 status
- ✅ Response contains: `{ admin: {...}, token: "..." }`
- ✅ Admin data includes: id, email, role, first_name, last_name, permissions
- ✅ Token stored in localStorage (FE) or session (BE)
- ✅ `last_login_at` updated in database
- ✅ Session created (if using session-based auth)

**Pass/Fail**: ☐


---

## Test Case 1.2: Super Admin Login - Invalid Email => Tested by Pawan

**Prerequisites**: Same as 1.1

**Steps**:
1. Navigate to login page
2. Enter invalid email format (e.g., "invalid-email")
3. Enter any password
4. Click "Login"

**Expected Result**:
- ✅ No login attempt logged
- ✅ No session created

**Pass/Fail**: ☐


---

## Test Case 1.3: Super Admin Login - Invalid Password => Tested by Pawan

**Prerequisites**: Same as 1.1

**Steps**:
1. Navigate to login page
2. Enter valid Super Admin email
3. Enter incorrect password
4. Click "Login"

**Expected Result**:
- ✅ API: `POST /admin/login` returns 401 Unauthorized
- ✅ Response: `{ error: "Invalid email or password" }`
- ✅ No session created
- ✅ `last_login_at` NOT updated
- ✅ Failed login attempt logged (if logging implemented)

**Pass/Fail**: ☐


---

## Test Case 1.4: Super Admin Login - Non-existent Email => Tested by Pawan

**Prerequisites**: Same as 1.1

**Steps**:
1. Navigate to login page
2. Enter email that doesn't exist (e.g., "nonexistent@test.com")
3. Enter any password
4. Click "Login"

**Expected Result**:
- ✅ Same as Test 1.3 (security: generic error message)

**Pass/Fail**: ☐


---

## Test Case 1.5: Super Admin Login - Empty Fields => Tested by Pawan

**Prerequisites**: Same as 1.1

**Steps**:
1. Navigate to login page
2. Leave email empty
3. Leave password empty
4. Click "Login"

**Expected Result**:
- ✅ No login attempt

**Pass/Fail**: ☐


---

## Test Case 1.6: Super Admin Login - Email Only => Tested by Pawan

**Prerequisites**: Same as 1.1

**Steps**:
1. Navigate to login page
2. Enter valid email
3. Leave password empty
4. Click "Login"

**Expected Result**:
- ✅ No login attempt

**Pass/Fail**: ☐


---

## Test Case 1.7: Super Admin Login - Password Only => Tested by Pawan

**Prerequisites**: Same as 1.1

**Steps**:
1. Navigate to login page
2. Leave email empty
3. Enter any password
4. Click "Login"

**Expected Result**:
- ✅ No login attempt

**Pass/Fail**: ☐


---

## Test Case 1.8: Product Admin Login - Valid Credentials => Tested by Pawan

**Prerequisites**: 
- Product Admin account exists

**Steps**:
1. Navigate to login page
2. Enter Product Admin email
3. Enter valid password
4. Click "Login"

**Expected Result**:
- ✅ API returns admin with role: "product_admin"
- ✅ Permissions object contains product-related permissions
- ✅ Session created with correct role

**Pass/Fail**: ☐


---

## Test Case 1.9: Order Admin Login - Valid Credentials => Tested by Pawan

**Prerequisites**: 
- Order Admin account exists

**Steps**:
1. Navigate to login page
2. Enter Order Admin email
3. Enter valid password
4. Click "Login"

**Expected Result**:
- ✅ API returns admin with role: "order_admin"
- ✅ Permissions object contains order-related permissions

**Pass/Fail**: ☐


---

## Test Case 1.10: User Admin Login - Valid Credentials => Tested by Pawan

**Prerequisites**: 
- User Admin account exists

**Steps**:
1. Navigate to login page
2. Enter User Admin email
3. Enter valid password
4. Click "Login"

**Expected Result**:
- ✅ API returns admin with role: "user_admin"
- ✅ Permissions object contains user-related permissions

**Pass/Fail**: ☐


---

## Test Case 1.11: Supplier Admin Login - Valid Credentials => Tested by Pawan

**Prerequisites**: 
- Supplier Admin account exists

**Steps**:
1. Navigate to login page
2. Enter Supplier Admin email
3. Enter valid password
4. Click "Login"

**Expected Result**:
- ✅ API returns admin with role: "supplier_admin"
- ✅ Permissions object contains supplier-related permissions

**Pass/Fail**: ☐


---

## Test Case 1.12: Login - Blocked Admin Account => Tested by Pawan

**Prerequisites**: 
- Admin account exists with `is_blocked: true`

**Steps**:
1. Navigate to login page
2. Enter blocked admin email
3. Enter valid password
4. Click "Login"

**Expected Result**:
- ✅ API: `POST /admin/login` returns 403 Forbidden
- ✅ Response: `{ error: "Account is blocked" }`
- ✅ No session created

**Pass/Fail**: ☐


---

## Test Case 1.13: Login - Inactive Admin Account => Tested by Pawan

**Prerequisites**: 
- Admin account exists with `is_active: false`

**Steps**:
1. Navigate to login page
2. Enter inactive admin email
3. Enter valid password
4. Click "Login"

**Expected Result**:
- ✅ API: `POST /admin/login` returns 403 Forbidden
- ✅ Response: `{ error: "Account is inactive" }`
- ✅ No session created

**Pass/Fail**: ☐


---

## Test Case 1.14: Session Persistence - Page Refresh => Tested by Pawan

**Prerequisites**: 
- Logged in as Super Admin

**Steps**:
1. After successful login, refresh the page (F5)
2. Check if still logged in

**Expected Result**:
- ✅ Token/session still valid
- ✅ No new login required

**Pass/Fail**: ☐


---

## Test Case 1.15: Session Persistence - New Tab => Tested by Pawan

**Prerequisites**: 
- Logged in as Super Admin

**Steps**:
1. Open new tab
2. Navigate to `/admin/dashboard`

**Expected Result**:
- ✅ Token validated automatically
- ✅ Session shared across tabs

**Pass/Fail**: ☐


---

## Test Case 1.16: Logout - Button Click => Tested by Pawan

**Prerequisites**: 
- Logged in as Super Admin

**Steps**:
1. Click "Logout" button in header/navbar
2. Confirm logout (if confirmation dialog exists)

**Expected Result**:
- ✅ API: `DELETE /admin/logout` returns 200
- ✅ Session destroyed (if session-based)
- ✅ Token invalidated (if token-based)

**Pass/Fail**: ☐


---

## Test Case 1.17: Logout - Direct API Call

**Prerequisites**: 
- Logged in as Super Admin

**Steps**:
1. Open browser DevTools Network tab
2. Click logout button
3. Verify API call

**Expected Result**:
- ✅ API endpoint responds correctly
- ✅ Session/token invalidated

**Pass/Fail**: ☐


---

## Test Case 1.18: Token Expiration - Expired Token

**Prerequisites**: 
- Logged in as Super Admin
- Token expiration time configured (e.g., 24 hours)

**Steps**:
1. Wait for token to expire OR manually expire token in database
2. Try to access protected route (e.g., `/admin/dashboard`)

**Expected Result**:
- ✅ API: Protected endpoints return 401 Unauthorized
- ✅ Response: `{ error: "Token expired" }`

**Pass/Fail**: ☐


---

## Test Case 1.19: Protected Route Access - Without Login => Tested by Pawan 

**Prerequisites**: 
- Not logged in
- Clear localStorage/session

**Steps**:
1. Navigate directly to `/admin/dashboard` (or any protected route)
2. Check behavior

**Expected Result**:
- ✅ API: Protected endpoints return 401 Unauthorized
- ✅ Response: `{ error: "Authentication required" }`

**Pass/Fail**: ☐


---

## Test Case 1.20: Password Reset - Forgot Password Link => Tested by Pawan 

**Prerequisites**: 
- Admin account exists

**Steps**:
1. Navigate to login page
2. Click "Forgot Password?" link
3. Enter admin email
4. Submit form

**Expected Result**:
- ✅ API: `POST /admin_auth/forgot_password` returns 200
- ✅ Password reset token generated
- ✅ Email sent with reset link
- ✅ Token stored in database

**Pass/Fail**: ☐


---

## Test Case 1.21: Password Reset - Invalid Email => Tested by Pawan 

**Prerequisites**: Same as 1.20

**Steps**:
1. Navigate to forgot password page
2. Enter non-existent email
3. Submit form

**Expected Result**:
- ✅ API returns 200 (generic success)
- ✅ No email sent
- ✅ No token generated

**Pass/Fail**: ☐


---

## Test Case 1.22: Password Reset - Reset Link Click => Tested by Pawan 

**Prerequisites**: 
- Password reset email received

**Steps**:
1. Open password reset email
2. Click reset link
3. Verify redirect

**Expected Result**:
- ✅ Token validated from URL
- ✅ Token not expired
- ✅ Reset page loads

**Pass/Fail**: ☐


---

## Test Case 1.23: Password Reset - Set New Password => Tested by Pawan 

**Prerequisites**: 
- On password reset page with valid token

**Steps**:
1. Enter new password (meets requirements)
2. Confirm new password (matches)
3. Submit form

**Expected Result**:
- ✅ API: `POST /admin_auth/reset_password` returns 200
- ✅ Password hashed and updated in database
- ✅ Reset token invalidated
- ✅ `password_changed_at` updated

**Pass/Fail**: ☐


---

## Test Case 1.24: Password Reset - Weak Password

**Prerequisites**: 
- On password reset page with valid token

**Steps**:
1. Enter weak password (e.g., "123")
2. Submit form

**Expected Result**:
- ✅ No password update
- ✅ Token still valid

**Pass/Fail**: ☐


---

## Test Case 1.25: Password Reset - Expired Token

**Prerequisites**: 
- Password reset token expired (past expiration time)

**Steps**:
1. Click expired reset link
2. Try to reset password

**Expected Result**:
- ✅ API returns 400 Bad Request
- ✅ Response: `{ error: "Token expired" }`

**Pass/Fail**: ☐


---

## Test Case 1.26: Login - XSS Protection

**Prerequisites**: Same as 1.1

**Steps**:
1. Navigate to login page
2. Enter email: `<script>alert('xss')</script>@test.com`
3. Enter password
4. Submit form

**Expected Result**:
- ✅ Input sanitized before processing
- ✅ No script execution
- ✅ Security headers present

**Pass/Fail**: ☐


---

## Test Case 1.27: Login - SQL Injection Protection => tested pawan 

**Prerequisites**: Same as 1.1

**Steps**:
1. Navigate to login page
2. Enter email: `admin@test.com' OR '1'='1`
3. Enter password: `' OR '1'='1`
4. Submit form

**Expected Result**:
- ✅ Parameterized queries used
- ✅ No SQL injection possible
- ✅ Returns generic error

**Pass/Fail**: ☐


---

## Test Case 1.28: Login - Rate Limiting

**Prerequisites**: Same as 1.1

**Steps**:
1. Attempt login with wrong password 5+ times rapidly
2. Check behavior

**Expected Result**:
- ✅ Rate limiting applied
- ✅ Failed attempts tracked
- ✅ Temporary lockout implemented

**Pass/Fail**: ☐


---

## Test Case 1.29: Login - CSRF Protection

**Prerequisites**: Same as 1.1

**Steps**:
1. Open login page
2. Check for CSRF token in form
3. Try to submit without CSRF token (via API directly)

**Expected Result**:
- ✅ API rejects requests without valid CSRF token
- ✅ Returns 422 Unprocessable Entity or 403 Forbidden

**Pass/Fail**: ☐


---

## Test Case 1.30: Login - Remember Me (if implemented)

**Prerequisites**: Same as 1.1

**Steps**:
1. Navigate to login page
2. Enter credentials
3. Check "Remember Me" checkbox
4. Login
5. Close browser completely
6. Reopen and navigate to admin panel

**Expected Result**:
- ✅ Long-lived token created (if implemented)
- ✅ Token stored securely

**Pass/Fail**: ☐


---

## Test Case 1.31: Login - Mobile Responsive => Tested by pawan 

**Prerequisites**: Same as 1.1

**Steps**:
1. Open login page on mobile device or resize browser to mobile size
2. Test login functionality

**Expected Result**:
- ✅ Same as desktop (backend doesn't change)

**Pass/Fail**: ☐


---

## Test Case 1.32: Login - Browser Back Button => Tested by pawan 

**Prerequisites**: 
- Logged in as Super Admin

**Steps**:
1. After login, click browser back button
2. Check if redirected back to login

**Expected Result**:
- ✅ Session still valid

**Pass/Fail**: ☐


---

## Test Case 1.33: Login - Network Error Handling => Tested by pawan 

**Prerequisites**: Same as 1.1

**Steps**:
1. Disconnect internet or stop backend server
2. Try to login
3. Check error handling

**Expected Result**:
- ✅ N/A (server not responding)

**Pass/Fail**: ☐


---

## Test Case 1.34: Login - Loading States => Tested by pawan 

**Prerequisites**: Same as 1.1

**Steps**:
1. Navigate to login page
2. Enter credentials
3. Click login
4. Observe loading state

**Expected Result**:
- ✅ Request processed normally

**Pass/Fail**: ☐


---

## Test Case 1.35: Login - Accessibility => Tested by pawan 

**Prerequisites**: Same as 1.1

**Steps**:
1. Navigate to login page
2. Test with keyboard navigation (Tab, Enter)
3. Test with screen reader (if available)

**Expected Result**:
- ✅ N/A (backend doesn't affect accessibility)

**Pass/Fail**: ☐


---

