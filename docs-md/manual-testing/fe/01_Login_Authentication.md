# 01. Login & Authentication Testing

## 🎯 Overview
Test from the **Frontend (FE)** perspective.

**Testing Focus**: UI/UX, form validation, navigation, error messages, user interactions, and frontend behavior.

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
- ✅ Login form displays correctly
- ✅ Form validation works (required fields)
- ✅ Loading state shows during login
- ✅ Success message appears: "Welcome! You have successfully logged in as admin."
- ✅ Redirects to `/admin/dashboard`
- ✅ Admin name/email visible in header/navbar
- ✅ Logout button visible

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
- ✅ Email validation error shows: "Please provide a valid email address"
- ✅ Form does not submit
- ✅ No API call made

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
- ✅ Loading state shows
- ✅ Error message displays: "Invalid email or password" or similar
- ✅ Error message styled as error/destructive
- ✅ User remains on login page
- ✅ Password field cleared or remains (check UX)

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
- ✅ Same as Test 1.3 (don't reveal if email exists)

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
- ✅ HTML5 validation prevents submission
- ✅ Browser shows "Please fill out this field" or similar
- ✅ No API call made

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
- ✅ Password field validation error
- ✅ Form does not submit

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
- ✅ Email field validation error
- ✅ Form does not submit

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
- ✅ Login successful
- ✅ Redirects to dashboard
- ✅ Dashboard shows product-focused metrics
- ✅ Navigation shows only product-related menus

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
- ✅ Login successful
- ✅ Dashboard shows order-focused metrics
- ✅ Navigation shows only order-related menus

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
- ✅ Login successful
- ✅ Dashboard shows user-focused metrics
- ✅ Navigation shows only user-related menus

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
- ✅ Login successful
- ✅ Dashboard shows supplier-focused metrics
- ✅ Navigation shows only supplier-related menus

**Pass/Fail**: ☐


---

## Test Case 1.12: Login - Blocked Admin Account

**Prerequisites**: 
- Admin account exists with `is_blocked: true`

**Steps**:
1. Navigate to login page
2. Enter blocked admin email
3. Enter valid password
4. Click "Login"

**Expected Result**:
- ✅ Error message: "Your account has been blocked. Please contact administrator."
- ✅ User remains on login page

**Pass/Fail**: ☐


---

## Test Case 1.13: Login - Inactive Admin Account

**Prerequisites**: 
- Admin account exists with `is_active: false`

**Steps**:
1. Navigate to login page
2. Enter inactive admin email
3. Enter valid password
4. Click "Login"

**Expected Result**:
- ✅ Error message: "Your account is inactive. Please contact administrator."
- ✅ User remains on login page

**Pass/Fail**: ☐


---

## Test Case 1.14: Session Persistence - Page Refresh => Tested by Pawan

**Prerequisites**: 
- Logged in as Super Admin

**Steps**:
1. After successful login, refresh the page (F5)
2. Check if still logged in

**Expected Result**:
- ✅ User remains logged in
- ✅ Dashboard still visible
- ✅ No redirect to login page
- ✅ Admin data still available

**Pass/Fail**: ☐


---

## Test Case 1.15: Session Persistence - New Tab => Tested by Pawan

**Prerequisites**: 
- Logged in as Super Admin

**Steps**:
1. Open new tab
2. Navigate to `/admin/dashboard`

**Expected Result**:
- ✅ User automatically logged in (via localStorage/session)
- ✅ Dashboard loads without login prompt

**Pass/Fail**: ☐


---

## Test Case 1.16: Logout - Button Click => Tested by Pawan

**Prerequisites**: 
- Logged in as Super Admin

**Steps**:
1. Click "Logout" button in header/navbar
2. Confirm logout (if confirmation dialog exists)

**Expected Result**:
- ✅ Success message: "You have been logged out successfully"
- ✅ Redirects to `/admin/login`
- ✅ Admin data cleared from localStorage
- ✅ Token removed from localStorage
- ✅ Cannot access protected routes

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
- ✅ API call visible in Network tab
- ✅ Request: `DELETE /admin/logout` or `POST /admin/logout`

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
- ✅ Automatic redirect to login page
- ✅ Error message: "Your session has expired. Please login again."
- ✅ Token removed from localStorage

**Pass/Fail**: ☐


---

## Test Case 1.19: Protected Route Access - Without Login

**Prerequisites**: 
- Not logged in
- Clear localStorage/session

**Steps**:
1. Navigate directly to `/admin/dashboard` (or any protected route)
2. Check behavior

**Expected Result**:
- ✅ Automatic redirect to `/admin/login`
- ✅ Error message: "Please login to access this page"
- ✅ Original URL saved for redirect after login

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

**Expected Result**:
- ✅ Forgot password form displays
- ✅ Success message: "Password reset instructions sent to your email"
- ✅ Email sent (check email inbox)

**Pass/Fail**: ☐


---

## Test Case 1.21: Password Reset - Invalid Email

**Prerequisites**: Same as 1.20

**Steps**:
1. Navigate to forgot password page
2. Enter non-existent email
3. Submit form

**Expected Result**:
- ✅ Same success message (security: don't reveal if email exists)
- ✅ No email sent (but user doesn't know)

**Pass/Fail**: ☐


---

## Test Case 1.22: Password Reset - Reset Link Click

**Prerequisites**: 
- Password reset email received

**Steps**:
1. Open password reset email
2. Click reset link
3. Verify redirect

**Expected Result**:
- ✅ Redirects to password reset page
- ✅ Reset token validated
- ✅ Form displays for new password

**Pass/Fail**: ☐


---

## Test Case 1.23: Password Reset - Set New Password

**Prerequisites**: 
- On password reset page with valid token

**Steps**:
1. Enter new password (meets requirements)
2. Confirm new password (matches)
3. Submit form

**Expected Result**:
- ✅ Success message: "Password reset successfully"
- ✅ Redirects to login page
- ✅ Can login with new password

**Pass/Fail**: ☐


---

## Test Case 1.24: Password Reset - Weak Password

**Prerequisites**: 
- On password reset page with valid token

**Steps**:
1. Enter weak password (e.g., "123")
2. Submit form

**Expected Result**:
- ✅ Validation error: "Password must be at least 8 characters" or similar
- ✅ Form does not submit

**Pass/Fail**: ☐


---

## Test Case 1.25: Password Reset - Expired Token

**Prerequisites**: 
- Password reset token expired (past expiration time)

**Steps**:
1. Click expired reset link
2. Try to reset password

**Expected Result**:
- ✅ Error message: "Reset link has expired. Please request a new one."
- ✅ Redirects to forgot password page

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
- ✅ Script tags escaped/removed
- ✅ No JavaScript execution
- ✅ Email field shows sanitized value

**Pass/Fail**: ☐


---

## Test Case 1.27: Login - SQL Injection Protection

**Prerequisites**: Same as 1.1

**Steps**:
1. Navigate to login page
2. Enter email: `admin@test.com' OR '1'='1`
3. Enter password: `' OR '1'='1`
4. Submit form

**Expected Result**:
- ✅ Login fails (as expected)
- ✅ No database error exposed

**Pass/Fail**: ☐


---

## Test Case 1.28: Login - Rate Limiting

**Prerequisites**: Same as 1.1

**Steps**:
1. Attempt login with wrong password 5+ times rapidly
2. Check behavior

**Expected Result**:
- ✅ After N failed attempts, account temporarily locked
- ✅ Error message: "Too many failed attempts. Please try again in X minutes."

**Pass/Fail**: ☐


---

## Test Case 1.29: Login - CSRF Protection

**Prerequisites**: Same as 1.1

**Steps**:
1. Open login page
2. Check for CSRF token in form
3. Try to submit without CSRF token (via API directly)

**Expected Result**:
- ✅ CSRF token present in form (hidden field or header)

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
- ✅ User still logged in (if remember me works)
- ✅ Token persists across browser sessions

**Pass/Fail**: ☐


---

## Test Case 1.31: Login - Mobile Responsive

**Prerequisites**: Same as 1.1

**Steps**:
1. Open login page on mobile device or resize browser to mobile size
2. Test login functionality

**Expected Result**:
- ✅ Login form displays correctly on mobile
- ✅ Form fields are easily accessible
- ✅ Buttons are properly sized
- ✅ No horizontal scrolling

**Pass/Fail**: ☐


---

## Test Case 1.32: Login - Browser Back Button

**Prerequisites**: 
- Logged in as Super Admin

**Steps**:
1. After login, click browser back button
2. Check if redirected back to login

**Expected Result**:
- ✅ Browser back doesn't allow access to login page when logged in
- ✅ Or redirects back to dashboard
- ✅ Prevents back-button access to login

**Pass/Fail**: ☐


---

## Test Case 1.33: Login - Network Error Handling

**Prerequisites**: Same as 1.1

**Steps**:
1. Disconnect internet or stop backend server
2. Try to login
3. Check error handling

**Expected Result**:
- ✅ Error message: "Network error. Please check your connection."
- ✅ User-friendly error message
- ✅ No technical error exposed

**Pass/Fail**: ☐


---

## Test Case 1.34: Login - Loading States

**Prerequisites**: Same as 1.1

**Steps**:
1. Navigate to login page
2. Enter credentials
3. Click login
4. Observe loading state

**Expected Result**:
- ✅ Button shows "Logging in..." or spinner
- ✅ Button disabled during request
- ✅ Form fields disabled during request
- ✅ Loading indicator visible

**Pass/Fail**: ☐


---

## Test Case 1.35: Login - Accessibility

**Prerequisites**: Same as 1.1

**Steps**:
1. Navigate to login page
2. Test with keyboard navigation (Tab, Enter)
3. Test with screen reader (if available)

**Expected Result**:
- ✅ All form fields accessible via keyboard
- ✅ Tab order is logical
- ✅ Labels properly associated with inputs
- ✅ Error messages announced by screen reader
- ✅ Focus indicators visible

**Pass/Fail**: ☐


---

