# 01. Login & Authentication Testing

## 🎯 Overview
Test admin login, authentication, session management, and security features.

**Estimated Time**: 55-70 minutes  
**Test Cases**: ~47

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

**Expected Result (FE)**:
- ✅ Login form displays correctly
- ✅ Form validation works (required fields)
- ✅ Loading state shows during login
- ✅ Success message appears: "Welcome! You have successfully logged in as admin."
- ✅ Redirects to `/admin/dashboard`
- ✅ Admin name/email visible in header/navbar
- ✅ Logout button visible

**Expected Result (BE)**:
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

**Expected Result (FE)**:
- ✅ Email validation error shows: "Please provide a valid email address"
- ✅ Form does not submit
- ✅ No API call made

**Expected Result (BE)**:
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

**Expected Result (FE)**:
- ✅ Loading state shows
- ✅ Error message displays: "Invalid email or password" or similar
- ✅ Error message styled as error/destructive
- ✅ User remains on login page
- ✅ Password field cleared or remains (check UX)

**Expected Result (BE)**:
- ✅ API: `POST /admin/login` returns 401 Unauthorized
- ✅ Response: `{ error: "Invalid email or password" }`
- ✅ No session created
- ✅ `last_login_at` NOT updated
- ✅ Failed login attempt logged (if logging implemented)

**Pass/Fail**: ☐

---


## Test Case 1.4: Super Admin Login - Empty Fields => Tested by Pawan

**Prerequisites**: Same as 1.1

**Steps**:
1. Navigate to login page
2. Leave email empty
3. Leave password empty
4. Click "Login"

**Expected Result (FE)**:
- ✅ HTML5 validation prevents submission
- ✅ Browser shows "Please fill out this field" or similar
- ✅ No API call made

**Expected Result (BE)**:
- ✅ No login attempt

**Pass/Fail**: ☐

---

## Test Case 1.5: Super Admin Login - Email Only => Tested by Pawan

**Prerequisites**: Same as 1.1

**Steps**:
1. Navigate to login page
2. Enter valid email
3. Leave password empty
4. Click "Login"

**Expected Result (FE)**:
- ✅ Password field validation error
- ✅ Form does not submit

**Expected Result (BE)**:
- ✅ No login attempt

**Pass/Fail**: ☐

---

## Test Case 1.6: Super Admin Login - Password Only => Tested by Pawan

**Prerequisites**: Same as 1.1

**Steps**:
1. Navigate to login page
2. Leave email empty
3. Enter any password
4. Click "Login"

**Expected Result (FE)**:
- ✅ Email field validation error
- ✅ Form does not submit

**Expected Result (BE)**:
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

**Expected Result (FE)**:
- ✅ Login successful
- ✅ Redirects to dashboard
- ✅ Dashboard shows product-focused metrics
- ✅ Navigation shows only product-related menus

**Expected Result (BE)**:
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

**Expected Result (FE)**:
- ✅ Login successful
- ✅ Dashboard shows order-focused metrics
- ✅ Navigation shows only order-related menus

**Expected Result (BE)**:
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

**Expected Result (FE)**:
- ✅ Login successful
- ✅ Dashboard shows user-focused metrics
- ✅ Navigation shows only user-related menus

**Expected Result (BE)**:
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

**Expected Result (FE)**:
- ✅ Login successful
- ✅ Dashboard shows supplier-focused metrics
- ✅ Navigation shows only supplier-related menus

**Expected Result (BE)**:
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

**Expected Result (FE)**:
- ✅ Error message: "Your account has been blocked. Please contact administrator."
- ✅ User remains on login page

**Expected Result (BE)**:
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

**Expected Result (FE)**:
- ✅ Error message: "Your account is inactive. Please contact administrator."
- ✅ User remains on login page

**Expected Result (BE)**:
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

**Expected Result (FE)**:
- ✅ User remains logged in
- ✅ Dashboard still visible
- ✅ No redirect to login page
- ✅ Admin data still available

**Expected Result (BE)**:
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

**Expected Result (FE)**:
- ✅ User automatically logged in (via localStorage/session)
- ✅ Dashboard loads without login prompt

**Expected Result (BE)**:
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

**Expected Result (FE)**:
- ✅ Success message: "You have been logged out successfully"
- ✅ Redirects to `/admin/login`
- ✅ Admin data cleared from localStorage
- ✅ Token removed from localStorage
- ✅ Cannot access protected routes

**Expected Result (BE)**:
- ✅ API: `DELETE /admin/logout` returns 200
- ✅ Session destroyed (if session-based)
- ✅ Token invalidated (if token-based)

**Pass/Fail**: ☐

---


## Test Case 1.17: Token Expiration - Expired Token

**Prerequisites**: 
- Logged in as Super Admin
- Token expiration time configured (e.g., 24 hours)

**Steps**:
1. Wait for token to expire OR manually expire token in database
2. Try to access protected route (e.g., `/admin/dashboard`)

**Expected Result (FE)**:
- ✅ Automatic redirect to login page
- ✅ Error message: "Your session has expired. Please login again."
- ✅ Token removed from localStorage

**Expected Result (BE)**:
- ✅ API: Protected endpoints return 401 Unauthorized
- ✅ Response: `{ error: "Token expired" }`

**Pass/Fail**: ☐

---

## Test Case 1.18: Protected Route Access - Without Login

**Prerequisites**: 
- Not logged in
- Clear localStorage/session

**Steps**:
1. Navigate directly to `/admin/dashboard` (or any protected route)
2. Check behavior

**Expected Result (FE)**:
- ✅ Automatic redirect to `/admin/login`
- ✅ Error message: "Please login to access this page"
- ✅ Original URL saved for redirect after login

**Expected Result (BE)**:
- ✅ API: Protected endpoints return 401 Unauthorized
- ✅ Response: `{ error: "Authentication required" }`

**Pass/Fail**: ☐

---

## Test Case 1.20: Password Reset - Forgot Password Link

**Prerequisites**: 
- Admin account exists

**Steps**:
1. Navigate to login page
2. Click "Forgot Password?" link
3. Enter admin email
4. Submit form

**Expected Result (FE)**:
- ✅ Forgot password form displays
- ✅ Success message: "Password reset instructions sent to your email"
- ✅ Email sent (check email inbox)

**Expected Result (BE)**:
- ✅ API: `POST /admin_auth/forgot_password` returns 200
- ✅ Password reset token generated
- ✅ Email sent with reset link
- ✅ Token stored in database

**Pass/Fail**: ☐

---

## Test Case 1.21: Password Reset - Invalid Email

**Prerequisites**: Same as 1.20

**Steps**:
1. Navigate to forgot password page
2. Enter non-existent email
3. Submit form

**Expected Result (FE)**:
- ✅ Same success message (security: don't reveal if email exists)
- ✅ No email sent (but user doesn't know)

**Expected Result (BE)**:
- ✅ API returns 200 (generic success)
- ✅ No email sent
- ✅ No token generated

**Pass/Fail**: ☐

---

## Test Case 1.22: Password Reset - Reset Link Click

**Prerequisites**: 
- Password reset email received

**Steps**:
1. Open password reset email
2. Click reset link
3. Verify redirect

**Expected Result (FE)**:
- ✅ Redirects to password reset page
- ✅ Reset token validated
- ✅ Form displays for new password

**Expected Result (BE)**:
- ✅ Token validated from URL
- ✅ Token not expired
- ✅ Reset page loads

**Pass/Fail**: ☐

---

## Test Case 1.23: Password Reset - Set New Password

**Prerequisites**: 
- On password reset page with valid token

**Steps**:
1. Enter new password (meets requirements)
2. Confirm new password (matches)
3. Submit form

**Expected Result (FE)**:
- ✅ Success message: "Password reset successfully"
- ✅ Redirects to login page
- ✅ Can login with new password

**Expected Result (BE)**:
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

**Expected Result (FE)**:
- ✅ Validation error: "Password must be at least 8 characters" or similar
- ✅ Form does not submit

**Expected Result (BE)**:
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

**Expected Result (FE)**:
- ✅ Error message: "Reset link has expired. Please request a new one."
- ✅ Redirects to forgot password page

**Expected Result (BE)**:
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

**Expected Result (FE)**:
- ✅ Script tags escaped/removed
- ✅ No JavaScript execution
- ✅ Email field shows sanitized value

**Expected Result (BE)**:
- ✅ Input sanitized before processing
- ✅ No script execution
- ✅ Security headers present

**Pass/Fail**: ☐

---

## Test Case 1.27: Login - SQL Injection Protection

**Prerequisites**: Same as 1.1

**Steps**:
1. Navigate to login page
2. Enter email: `admin@test.com' OR '1'='1`
3. Enter password: `' OR '1'='1`
4. Submit form

**Expected Result (FE)**:
- ✅ Login fails (as expected)
- ✅ No database error exposed

**Expected Result (BE)**:
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

**Expected Result (FE)**:
- ✅ After N failed attempts, account temporarily locked
- ✅ Error message: "Too many failed attempts. Please try again in X minutes."

**Expected Result (BE)**:
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

**Expected Result (FE)**:
- ✅ CSRF token present in form (hidden field or header)

**Expected Result (BE)**:
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

**Expected Result (FE)**:
- ✅ User still logged in (if remember me works)
- ✅ Token persists across browser sessions

**Expected Result (BE)**:
- ✅ Long-lived token created (if implemented)
- ✅ Token stored securely

**Pass/Fail**: ☐

---

## Test Case 1.31: Login - Mobile Responsive

**Prerequisites**: Same as 1.1

**Steps**:
1. Open login page on mobile device or resize browser to mobile size
2. Test login functionality

**Expected Result (FE)**:
- ✅ Login form displays correctly on mobile
- ✅ Form fields are easily accessible
- ✅ Buttons are properly sized
- ✅ No horizontal scrolling

**Expected Result (BE)**:
- ✅ Same as desktop (backend doesn't change)

**Pass/Fail**: ☐

---

## Test Case 1.32: Login - Browser Back Button

**Prerequisites**: 
- Logged in as Super Admin

**Steps**:
1. After login, click browser back button
2. Check if redirected back to login

**Expected Result (FE)**:
- ✅ Browser back doesn't allow access to login page when logged in
- ✅ Or redirects back to dashboard
- ✅ Prevents back-button access to login

**Expected Result (BE)**:
- ✅ Session still valid

**Pass/Fail**: ☐

---

## Test Case 1.33: Login - Network Error Handling

**Prerequisites**: Same as 1.1

**Steps**:
1. Disconnect internet or stop backend server
2. Try to login
3. Check error handling

**Expected Result (FE)**:
- ✅ Error message: "Network error. Please check your connection."
- ✅ User-friendly error message
- ✅ No technical error exposed

**Expected Result (BE)**:
- ✅ N/A (server not responding)

**Pass/Fail**: ☐

---

## Test Case 1.34: Login - Loading States

**Prerequisites**: Same as 1.1

**Steps**:
1. Navigate to login page
2. Enter credentials
3. Click login
4. Observe loading state

**Expected Result (FE)**:
- ✅ Button shows "Logging in..." or spinner
- ✅ Button disabled during request
- ✅ Form fields disabled during request
- ✅ Loading indicator visible

**Expected Result (BE)**:
- ✅ Request processed normally

**Pass/Fail**: ☐

---

## Test Case 1.35: Login - Accessibility

**Prerequisites**: Same as 1.1

**Steps**:
1. Navigate to login page
2. Test with keyboard navigation (Tab, Enter)
3. Test with screen reader (if available)

**Expected Result (FE)**:
- ✅ All form fields accessible via keyboard
- ✅ Tab order is logical
- ✅ Labels properly associated with inputs
- ✅ Error messages announced by screen reader
- ✅ Focus indicators visible

**Expected Result (BE)**:
- ✅ N/A (backend doesn't affect accessibility)

**Pass/Fail**: ☐

---

## 🔐 Admin Invite Flow Testing

### Overview
Test the complete admin invitation flow: sending invitations, accepting invitations, and logging in after acceptance.

---

## Test Case 1.36: Admin Invitation - Send Invitation (Super Admin) => Tested by Pawan

**Prerequisites**: 
- Super Admin logged in
- Access to Admin Management section

**Steps**:
1. Navigate to `/admin/admins`
2. Click **"Invite Admin"** button
3. Fill invitation form:
   - Enter email address (e.g., `newadmin@luxethreads.com`)
   - Select role from dropdown (e.g., Product Admin)
4. Click **"Send Invitation"**

**Expected Result (FE)**:
- ✅ Invitation form displays correctly
- ✅ Email field accepts valid email format
- ✅ Role dropdown shows all available roles
- ✅ Success message: "Invitation sent to [email]"
- ✅ Redirects to admin list or shows success notification
- ✅ New admin appears in list with status "Pending Invitation"
- ✅ "Resend Invitation" button available for pending admins

**Expected Result (BE)**:
- ✅ API: `POST /api/v1/admin/admins/invite` returns 201 Created
- ✅ Admin record created with:
  - `email`: Provided email
  - `role`: Selected role
  - `status`: "pending_invitation"
  - `invitation_token`: Secure random token (32+ characters)
  - `invitation_expires_at`: 7 days from now
  - `invited_by_id`: Current Super Admin ID
  - `is_active`: false
- ✅ Invitation email sent successfully
- ✅ Activity logged: "Admin invited"

**Pass/Fail**: ☐

---

## Test Case 1.37: Admin Invitation - Invalid Email Format => Tested by Pawan

**Prerequisites**: 
- Super Admin logged in

**Steps**:
1. Navigate to invite admin form
2. Enter invalid email (e.g., `invalid-email`)
3. Select role
4. Click "Send Invitation"

**Expected Result (FE)**:
- ✅ Email validation error: "Please provide a valid email address"
- ✅ Form does not submit
- ✅ No API call made

**Expected Result (BE)**:
- ✅ No admin record created
- ✅ No email sent

**Pass/Fail**: ☐

---

## Test Case 1.38: Admin Invitation - Duplicate Email => Tested by Pawan

**Prerequisites**: 
- Super Admin logged in
- Admin with email `existing@luxethreads.com` already exists

**Steps**:
1. Navigate to invite admin form
2. Enter existing admin email
3. Select role
4. Click "Send Invitation"

**Expected Result (FE)**:
- ✅ Error message: "Admin with this email already exists"
- ✅ Form shows validation error
- ✅ No invitation sent

**Expected Result (BE)**:
- ✅ API returns 422 Unprocessable Entity
- ✅ Response: `{ error: "Email has already been taken" }`
- ✅ No duplicate admin created

**Pass/Fail**: ☐

---

## Test Case 1.39: Admin Invitation - Non-Super Admin Attempt => Tested by Pawan

**Prerequisites**: 
- Product Admin (or other non-super admin) logged in

**Steps**:
1. Try to navigate to `/admin/admins/invite`
2. Or try to access invite functionality

**Expected Result (FE)**:
- ✅ Access denied or 403 Forbidden error
- ✅ Error message: "You don't have permission to perform this action"
- ✅ Redirects to dashboard or shows access denied page

**Expected Result (BE)**:
- ✅ API: `POST /api/v1/admin/admins/invite` returns 403 Forbidden
- ✅ Response: `{ error: "Access denied" }`
- ✅ No invitation sent

**Pass/Fail**: ☐

---

## Test Case 1.40: Admin Invitation - Email Received => Tested by Pawan

**Prerequisites**: 
- Invitation sent successfully (from Test 1.36)

**Steps**:
1. Check email inbox for invitation email
2. Verify email content

**Expected Result**:
- ✅ Email received at specified address
- ✅ Subject: "You've been invited to join Luxe Threads Admin Panel"
- ✅ Email body includes:
  - Welcome message
  - Invitation link with token
  - Expiration notice (7 days)
  - Instructions to complete registration
- ✅ Invitation link format: `/admin/invitations/accept?token=ABC123...`
- ✅ Link is clickable and properly formatted

**Pass/Fail**: ☐

---

## Test Case 1.41: Admin Invitation - Click Invitation Link => Tested by Pawan

**Prerequisites**: 
- Invitation email received
- Valid invitation token

**Steps**:
1. Click invitation link from email
2. Verify redirect to acceptance page

**Expected Result (FE)**:
- ✅ Redirects to invitation acceptance page
- ✅ Page shows: "Welcome! Complete your admin account setup"
- ✅ Form displays with:
  - Email (pre-filled, read-only)
  - Role (pre-filled, read-only)
  - First Name (required field)
  - Last Name (required field)
  - Phone Number (required field)
  - Password (required field)
  - Password Confirmation (required field)
- ✅ Form validation visible

**Expected Result (BE)**:
- ✅ API: `GET /admin/invitations/accept?token=...` validates token
- ✅ Token checked:
  - Token exists
  - Token not expired
  - Token not already used
- ✅ If valid: Form displayed
- ✅ If invalid: Error shown

**Pass/Fail**: ☐

---

## Test Case 1.42: Admin Invitation - Expired Token => Tested by Pawan

**Prerequisites**: 
- Invitation token expired (past 7 days) OR manually expired in database

**Steps**:
1. Click expired invitation link
2. Try to access acceptance page

**Expected Result (FE)**:
- ✅ Error message: "Invitation link has expired. Please request a new invitation."
- ✅ Link to request new invitation or contact admin
- ✅ Cannot access registration form

**Expected Result (BE)**:
- ✅ API returns 400 Bad Request
- ✅ Response: `{ error: "Invitation token expired" }`
- ✅ Token validation fails

**Pass/Fail**: ☐

---

## Test Case 1.43: Admin Invitation - Invalid Token => Tested by Pawan

**Prerequisites**: 
- Invalid or non-existent invitation token

**Steps**:
1. Navigate to `/admin/invitations/accept?token=INVALID123`
2. Try to access acceptance page

**Expected Result (FE)**:
- ✅ Error message: "Invalid invitation link. Please contact administrator."
- ✅ Cannot access registration form

**Expected Result (BE)**:
- ✅ API returns 404 Not Found or 400 Bad Request
- ✅ Response: `{ error: "Invalid invitation token" }`

**Pass/Fail**: ☐

---

## Test Case 1.44: Admin Invitation - Complete Registration => Tested by Pawan

**Prerequisites**: 
- On invitation acceptance page with valid token

**Steps**:
1. Fill registration form:
   - First Name: "John"
   - Last Name: "Doe"
   - Phone Number: "+1234567890"
   - Password: "SecurePass123!"
   - Password Confirmation: "SecurePass123!"
2. Click **"Complete Registration"** or **"Accept Invitation"**

**Expected Result (FE)**:
- ✅ Form validation works correctly
- ✅ Success message: "Account created successfully! You can now login."
- ✅ Redirects to `/admin/login`
- ✅ All fields validated before submission

**Expected Result (BE)**:
- ✅ API: `POST /admin/invitations/accept` returns 200 OK
- ✅ Admin record updated:
  - `first_name`: "John"
  - `last_name`: "Doe"
  - `phone_number`: "+1234567890"
  - `password_digest`: Hashed password stored
  - `status`: "active" (changed from "pending_invitation")
  - `is_active`: true
  - `invitation_token`: NULL (cleared)
  - `invitation_accepted_at`: Current timestamp
- ✅ Activity logged: "Admin invitation accepted"
- ✅ Welcome email sent (optional)

**Pass/Fail**: ☐

---

## Test Case 1.45: Admin Invitation - Registration Validation Errors => Tested by Pawan

**Prerequisites**: 
- On invitation acceptance page with valid token

**Steps**:
1. Try to submit form with:
   - Empty first name
   - Empty last name
   - Invalid phone number
   - Weak password (e.g., "123")
   - Password mismatch
2. Click "Complete Registration"

**Expected Result (FE)**:
- ✅ Validation errors displayed for each invalid field:
  - "First name is required"
  - "Last name is required"
  - "Phone number is invalid"
  - "Password must be at least 8 characters"
  - "Password confirmation doesn't match"
- ✅ Form does not submit
- ✅ Error messages clear and helpful

**Expected Result (BE)**:
- ✅ API returns 422 Unprocessable Entity
- ✅ Response contains validation errors
- ✅ Admin record not updated
- ✅ Invitation token still valid

**Pass/Fail**: ☐

---


## Test Case 1.46: Admin Invitation - Resend Invitation => Tested by Pawan

**Prerequisites**: 
- Super Admin logged in
- Admin with pending invitation exists

**Steps**:
1. Navigate to `/admin/admins`
2. Find admin with "Pending Invitation" status
3. Click **"Resend Invitation"** button
4. Confirm resend (if confirmation required)

**Expected Result (FE)**:
- ✅ Success message: "Invitation resent successfully"
- ✅ New invitation email sent
- ✅ Invitation expiry date updated

**Expected Result (BE)**:
- ✅ API: `POST /api/v1/admin/admins/:id/resend_invitation` returns 200 OK
- ✅ New invitation token generated
- ✅ `invitation_expires_at` updated to 7 days from now
- ✅ `invitation_sent_at` updated
- ✅ New invitation email sent
- ✅ Old token invalidated (if configured)

**Pass/Fail**: ☐

---

## Test Case 1.47: Admin Invitation - Already Used Token => Tested by Pawan

**Prerequisites**: 
- Invitation already accepted (token used)
- Try to use same token again

**Steps**:
1. Use invitation link that was already used
2. Try to access acceptance page

**Expected Result (FE)**:
- ✅ Error message: "This invitation has already been accepted."
- ✅ Link to login page or contact admin

**Expected Result (BE)**:
- ✅ API returns 400 Bad Request
- ✅ Response: `{ error: "Invitation already accepted" }`
- ✅ Token validation fails (token cleared after acceptance)

**Pass/Fail**: ☐

---

## Test Case 1.48: Admin Invitation - Pending Admin Cannot Login => Tested by Pawan

**Prerequisites**: 
- Admin with pending invitation (not yet accepted)

**Steps**:
1. Navigate to `/admin/login`
2. Enter email of pending admin
3. Enter any password (since no password set yet)
4. Try to login

**Expected Result (FE)**:
- ✅ Error message: "Invalid email or password" or "Please accept your invitation first"
- ✅ Cannot login until invitation accepted

**Expected Result (BE)**:
- ✅ API: `POST /admin/login` returns 401 Unauthorized or 403 Forbidden
- ✅ Response: `{ error: "Please accept your invitation first" }` or similar
- ✅ No session created

**Pass/Fail**: ☐

---

## Test Case 1.49: Admin Invitation - Email Link Security => Tested by Pawan

**Prerequisites**: 
- Invitation email received

**Steps**:
1. Check invitation link in email
2. Verify token format and security

**Expected Result**:
- ✅ Token is long and random (32+ characters)
- ✅ Token uses secure random generation
- ✅ Token is URL-safe (base64 encoded)
- ✅ Token is unique (not predictable)
- ✅ Link uses HTTPS in production
- ✅ Token not exposed in server logs

**Pass/Fail**: ☐

---

## 📝 Notes Section

**Issues Found**:
- 

**Suggestions**:
- 

**Completed By**: _______________  
**Date**: _______________  
**Total Passed**: ___/47  
**Total Failed**: ___/47

