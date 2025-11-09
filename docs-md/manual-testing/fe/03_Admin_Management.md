# 03. Admin Management Testing (Super Admin Only)

## 🎯 Overview
Test from the **Frontend (FE)** perspective.

**Testing Focus**: UI/UX, form validation, navigation, error messages, user interactions, and frontend behavior.

**Estimated Time**: 45-60 minutes  
**Test Cases**: ~40

---

## Test Case 3.1: View All Admins - Super Admin

**Prerequisites**: 
- Logged in as Super Admin
- Multiple admin accounts exist

**Steps**:
1. Navigate to `/admin/admins` or "Admin Management" menu
2. Check admin list displays

**Expected Result**:
- ✅ List shows all admin accounts
- ✅ Each admin shows: Name, Email, Role, Status, Last Login
- ✅ Table/list is sortable and searchable
- ✅ Pagination works (if many admins)
- ✅ "Create New Admin" button visible

**Pass/Fail**: ☐


---

## Test Case 3.2: View All Admins - Non-Super Admin

**Prerequisites**: 
- Logged in as Product Admin (or any non-super admin)

**Steps**:
1. Try to navigate to `/admin/admins`
2. Check access

**Expected Result**:
- ✅ Access denied message: "You don't have permission to access this page"
- ✅ Redirects to dashboard or 403 page
- ✅ Menu item NOT visible

**Pass/Fail**: ☐


---

## Test Case 3.3: Create New Admin - Valid Data

**Prerequisites**: 
- Logged in as Super Admin

**Steps**:
1. Navigate to Admin Management
2. Click "Create New Admin" or "Add Admin"
3. Fill form:
   - First Name: "John"
   - Last Name: "Doe"
   - Email: "john.doe@luxethreads.com"
   - Password: "SecurePass123!"
   - Role: Select "Product Admin"
4. Submit form

**Expected Result**:
- ✅ Form displays correctly
- ✅ All required fields marked
- ✅ Role dropdown shows available roles
- ✅ Success message: "Admin created successfully"
- ✅ Redirects to admin list or admin details
- ✅ New admin appears in list

**Pass/Fail**: ☐


---

## Test Case 3.4: Create New Admin - Duplicate Email

**Prerequisites**: 
- Logged in as Super Admin
- Admin with email "existing@test.com" exists

**Steps**:
1. Navigate to Create Admin form
2. Enter email: "existing@test.com"
3. Fill other required fields
4. Submit form

**Expected Result**:
- ✅ Validation error: "Email has already been taken"
- ✅ Error shown near email field
- ✅ Form does not submit
- ✅ No admin created

**Pass/Fail**: ☐


---

## Test Case 3.5: Create New Admin - Invalid Email Format

**Prerequisites**: 
- Logged in as Super Admin

**Steps**:
1. Navigate to Create Admin form
2. Enter invalid email: "invalid-email"
3. Fill other fields
4. Submit form

**Expected Result**:
- ✅ Validation error: "Please provide a valid email address"
- ✅ HTML5 validation or custom validation
- ✅ Form does not submit

**Pass/Fail**: ☐


---

## Test Case 3.6: Create New Admin - Weak Password

**Prerequisites**: 
- Logged in as Super Admin

**Steps**:
1. Navigate to Create Admin form
2. Enter weak password: "123"
3. Fill other fields
4. Submit form

**Expected Result**:
- ✅ Validation error: "Password must be at least 8 characters" or similar
- ✅ Password strength indicator (if implemented)
- ✅ Form does not submit

**Pass/Fail**: ☐


---

## Test Case 3.7: Create New Admin - Missing Required Fields

**Prerequisites**: 
- Logged in as Super Admin

**Steps**:
1. Navigate to Create Admin form
2. Leave required fields empty
3. Submit form

**Expected Result**:
- ✅ HTML5 validation prevents submission
- ✅ Browser shows "Please fill out this field" for each empty required field
- ✅ Or custom validation errors shown

**Pass/Fail**: ☐


---

## Test Case 3.8: View Admin Details

**Prerequisites**: 
- Logged in as Super Admin
- Admin account exists

**Steps**:
1. Navigate to Admin Management
2. Click on an admin from the list
3. View admin details page

**Expected Result**:
- ✅ Admin details page loads
- ✅ Shows: Name, Email, Role, Status, Created Date, Last Login
- ✅ Shows: Permissions (if RBAC enabled)
- ✅ Edit and Delete buttons visible
- ✅ Activity log section (if implemented)

**Pass/Fail**: ☐


---

## Test Case 3.9: Update Admin - Valid Data

**Prerequisites**: 
- Logged in as Super Admin
- Admin account exists

**Steps**:
1. Navigate to admin details
2. Click "Edit" button
3. Update: First Name to "Jane", Last Name to "Smith"
4. Submit form

**Expected Result**:
- ✅ Edit form pre-filled with current data
- ✅ Success message: "Admin updated successfully"
- ✅ Changes reflected in admin details
- ✅ Changes reflected in admin list

**Pass/Fail**: ☐


---

## Test Case 3.10: Update Admin - Change Email

**Prerequisites**: 
- Logged in as Super Admin
- Admin account exists

**Steps**:
1. Navigate to admin details
2. Click "Edit"
3. Change email to new unique email
4. Submit form

**Expected Result**:
- ✅ Email updated successfully
- ✅ Success message shown
- ✅ New email reflected everywhere

**Pass/Fail**: ☐


---

## Test Case 3.11: Update Admin - Change Role

**Prerequisites**: 
- Logged in as Super Admin
- Admin account exists (e.g., Product Admin)

**Steps**:
1. Navigate to admin details
2. Click "Edit"
3. Change role from "Product Admin" to "Order Admin"
4. Submit form

**Expected Result**:
- ✅ Role updated successfully
- ✅ Success message shown
- ✅ New role reflected in admin list

**Pass/Fail**: ☐


---

## Test Case 3.12: Update Admin - Change Password

**Prerequisites**: 
- Logged in as Super Admin
- Admin account exists

**Steps**:
1. Navigate to admin details
2. Click "Change Password" or similar
3. Enter new password
4. Confirm new password
5. Submit form

**Expected Result**:
- ✅ Password change form displays
- ✅ Success message: "Password changed successfully"
- ✅ Admin can login with new password

**Pass/Fail**: ☐


---

## Test Case 3.13: Delete Admin - Confirm Delete

**Prerequisites**: 
- Logged in as Super Admin
- Admin account exists (not the current logged-in admin)

**Steps**:
1. Navigate to admin details
2. Click "Delete" button
3. Confirm deletion in dialog
4. Submit deletion

**Expected Result**:
- ✅ Confirmation dialog appears: "Are you sure you want to delete this admin?"
- ✅ Success message: "Admin deleted successfully"
- ✅ Redirects to admin list
- ✅ Deleted admin no longer in list

**Pass/Fail**: ☐


---

## Test Case 3.14: Delete Admin - Cancel Delete

**Prerequisites**: 
- Logged in as Super Admin
- Admin account exists

**Steps**:
1. Navigate to admin details
2. Click "Delete" button
3. Click "Cancel" in confirmation dialog

**Expected Result**:
- ✅ Dialog closes
- ✅ Admin not deleted
- ✅ Still on admin details page

**Pass/Fail**: ☐


---

## Test Case 3.15: Delete Admin - Prevent Self-Deletion

**Prerequisites**: 
- Logged in as Super Admin

**Steps**:
1. Navigate to own admin details
2. Try to delete own account

**Expected Result**:
- ✅ Delete button disabled OR
- ✅ Error message: "You cannot delete your own account"
- ✅ Deletion prevented

**Pass/Fail**: ☐


---

## Test Case 3.16: Block Admin Account

**Prerequisites**: 
- Logged in as Super Admin
- Admin account exists

**Steps**:
1. Navigate to admin details
2. Click "Block" button
3. Confirm blocking

**Expected Result**:
- ✅ Success message: "Admin account blocked"
- ✅ Status changes to "Blocked"
- ✅ Blocked badge/indicator visible
- ✅ "Unblock" button appears

**Pass/Fail**: ☐


---

## Test Case 3.17: Unblock Admin Account

**Prerequisites**: 
- Logged in as Super Admin
- Blocked admin account exists

**Steps**:
1. Navigate to blocked admin details
2. Click "Unblock" button
3. Confirm unblocking

**Expected Result**:
- ✅ Success message: "Admin account unblocked"
- ✅ Status changes to "Active"
- ✅ Blocked indicator removed
- ✅ "Block" button appears

**Pass/Fail**: ☐


---

## Test Case 3.18: Activate Admin Account

**Prerequisites**: 
- Logged in as Super Admin
- Inactive admin account exists

**Steps**:
1. Navigate to inactive admin details
2. Click "Activate" button

**Expected Result**:
- ✅ Success message: "Admin account activated"
- ✅ Status changes to "Active"
- ✅ Active badge visible

**Pass/Fail**: ☐


---

## Test Case 3.19: Deactivate Admin Account

**Prerequisites**: 
- Logged in as Super Admin
- Active admin account exists

**Steps**:
1. Navigate to admin details
2. Click "Deactivate" button
3. Confirm deactivation

**Expected Result**:
- ✅ Success message: "Admin account deactivated"
- ✅ Status changes to "Inactive"
- ✅ Inactive badge visible

**Pass/Fail**: ☐


---

## Test Case 3.20: Assign Role to Admin - RBAC

**Prerequisites**: 
- Logged in as Super Admin
- Admin account exists
- RBAC enabled

**Steps**:
1. Navigate to admin details
2. Click "Assign Role" or "Manage Roles"
3. Select role: "Product Admin"
4. Assign role

**Expected Result**:
- ✅ Role assignment form displays
- ✅ Available roles listed
- ✅ Success message: "Role assigned successfully"
- ✅ Role appears in admin's role list

**Pass/Fail**: ☐


---

## Test Case 3.21: Remove Role from Admin - RBAC

**Prerequisites**: 
- Logged in as Super Admin
- Admin with assigned role exists

**Steps**:
1. Navigate to admin details
2. View assigned roles
3. Click "Remove" on a role
4. Confirm removal

**Expected Result**:
- ✅ Success message: "Role removed successfully"
- ✅ Role removed from list
- ✅ Permissions updated

**Pass/Fail**: ☐


---

## Test Case 3.22: Update Permissions for Admin - RBAC

**Prerequisites**: 
- Logged in as Super Admin
- Admin with role assignment exists

**Steps**:
1. Navigate to admin details
2. Click "Update Permissions"
3. Modify permissions (check/uncheck)
4. Save changes

**Expected Result**:
- ✅ Permission list displays
- ✅ Permissions grouped by category
- ✅ Checkboxes for each permission
- ✅ Success message: "Permissions updated successfully"

**Pass/Fail**: ☐


---

## Test Case 3.23: View Admin Activity Log

**Prerequisites**: 
- Logged in as Super Admin
- Admin with activity history exists

**Steps**:
1. Navigate to admin details
2. Click "Activity Log" tab
3. View activity history

**Expected Result**:
- ✅ Activity log displays
- ✅ Shows: Action, Timestamp, IP Address, User Agent
- ✅ Activities sorted by most recent first
- ✅ Pagination works (if many activities)

**Pass/Fail**: ☐


---

## Test Case 3.24: Search Admins

**Prerequisites**: 
- Logged in as Super Admin
- Multiple admins exist

**Steps**:
1. Navigate to Admin Management
2. Use search bar
3. Search by name or email

**Expected Result**:
- ✅ Search bar visible
- ✅ Results filter as typing
- ✅ Results highlight search term
- ✅ "No results" message if no matches

**Pass/Fail**: ☐


---

## Test Case 3.25: Filter Admins by Role

**Prerequisites**: 
- Logged in as Super Admin
- Admins with different roles exist

**Steps**:
1. Navigate to Admin Management
2. Use role filter dropdown
3. Select "Product Admin"
4. Check filtered results

**Expected Result**:
- ✅ Filter dropdown visible
- ✅ Selecting role filters list
- ✅ Only admins with selected role shown
- ✅ Filter can be cleared

**Pass/Fail**: ☐


---

## Test Case 3.26: Filter Admins by Status

**Prerequisites**: 
- Logged in as Super Admin
- Admins with different statuses exist

**Steps**:
1. Navigate to Admin Management
2. Use status filter
3. Select "Active" or "Blocked"
4. Check filtered results

**Expected Result**:
- ✅ Status filter visible
- ✅ Filtering works correctly
- ✅ Status badges visible in list

**Pass/Fail**: ☐


---

## Test Case 3.27: Sort Admins

**Prerequisites**: 
- Logged in as Super Admin
- Multiple admins exist

**Steps**:
1. Navigate to Admin Management
2. Click column header to sort (e.g., "Name", "Email", "Last Login")
3. Check sorting

**Expected Result**:
- ✅ Column headers are clickable
- ✅ Sort indicator shows (arrow up/down)
- ✅ List sorts correctly
- ✅ Toggle between ascending/descending

**Pass/Fail**: ☐


---

## Test Case 3.28: Pagination - Admin List

**Prerequisites**: 
- Logged in as Super Admin
- More than 20 admins exist (or page size)

**Steps**:
1. Navigate to Admin Management
2. Check pagination controls
3. Navigate to next page
4. Check results

**Expected Result**:
- ✅ Pagination controls visible (Previous, Next, page numbers)
- ✅ Current page highlighted
- ✅ Total pages/records shown
- ✅ Clicking page number loads that page
- ✅ Results update correctly

**Pass/Fail**: ☐


---

## Test Case 3.29: Bulk Actions - Select Multiple Admins

**Prerequisites**: 
- Logged in as Super Admin
- Multiple admins exist

**Steps**:
1. Navigate to Admin Management
2. Check checkboxes for multiple admins
3. Select bulk action (e.g., "Activate", "Deactivate", "Delete")
4. Confirm action

**Expected Result**:
- ✅ Checkboxes visible for each admin
- ✅ "Select All" checkbox works
- ✅ Bulk action dropdown appears when admins selected
- ✅ Success message: "X admins updated"
- ✅ Selected admins updated

**Pass/Fail**: ☐


---

## Test Case 3.30: Export Admins List

**Prerequisites**: 
- Logged in as Super Admin
- Admins exist

**Steps**:
1. Navigate to Admin Management
2. Click "Export" button
3. Check downloaded file

**Expected Result**:
- ✅ Export button visible
- ✅ File downloads (CSV/Excel)
- ✅ File name includes date/timestamp
- ✅ File contains admin data

**Pass/Fail**: ☐


---

## Test Case 3.31: View RBAC Roles List

**Prerequisites**: 
- Logged in as Super Admin
- RBAC enabled

**Steps**:
1. Navigate to "RBAC Management" or "Roles & Permissions"
2. View roles list

**Expected Result**:
- ✅ List shows all roles: Super Admin, Product Admin, Order Admin, etc.
- ✅ Each role shows: Name, Slug, Description, Permission Count
- ✅ "View Permissions" link for each role

**Pass/Fail**: ☐


---

## Test Case 3.32: View RBAC Permissions List

**Prerequisites**: 
- Logged in as Super Admin
- RBAC enabled

**Steps**:
1. Navigate to RBAC Management
2. Click "Permissions" tab
3. View permissions list

**Expected Result**:
- ✅ List shows all permissions
- ✅ Permissions grouped by category (Products, Orders, Users, etc.)
- ✅ Each permission shows: Name, Slug, Description, Category

**Pass/Fail**: ☐


---

## Test Case 3.33: View Admin Role Assignments

**Prerequisites**: 
- Logged in as Super Admin
- Admin with role assignments exists

**Steps**:
1. Navigate to admin details
2. View "Role Assignments" section
3. Check assigned roles

**Expected Result**:
- ✅ Assigned roles listed
- ✅ Each assignment shows: Role Name, Assigned Date, Expiration Date (if any)
- ✅ Permissions for each role visible
- ✅ "Remove Role" button for each

**Pass/Fail**: ☐


---

## Test Case 3.34: Admin Management - Mobile Responsive

**Prerequisites**: 
- Logged in as Super Admin

**Steps**:
1. Open Admin Management on mobile device
2. Test all features (view, create, edit, delete)

**Expected Result**:
- ✅ List displays correctly on mobile
- ✅ Forms are usable on mobile
- ✅ Buttons are properly sized
- ✅ No horizontal scrolling
- ✅ Touch interactions work

**Pass/Fail**: ☐


---

## Test Case 3.35: Admin Management - Error Handling

**Prerequisites**: 
- Logged in as Super Admin

**Steps**:
1. Stop backend server
2. Try to load admin list
3. Check error handling

**Expected Result**:
- ✅ Error message: "Unable to load admins"
- ✅ User-friendly error
- ✅ Retry option (if implemented)

**Pass/Fail**: ☐


---

## Test Case 3.36: Admin Management - Form Validation

**Prerequisites**: 
- Logged in as Super Admin

**Steps**:
1. Navigate to Create Admin form
2. Test all validation rules:
   - Empty fields
   - Invalid email
   - Weak password
   - Duplicate email
3. Check error messages

**Expected Result**:
- ✅ All validations work
- ✅ Error messages clear and helpful
- ✅ Errors shown near relevant fields
- ✅ Form doesn't submit with errors

**Pass/Fail**: ☐


---

## Test Case 3.37: Admin Management - Loading States

**Prerequisites**: 
- Logged in as Super Admin

**Steps**:
1. Navigate to Admin Management
2. Perform actions (create, update, delete)
3. Observe loading states

**Expected Result**:
- ✅ Loading indicators show during API calls
- ✅ Buttons disabled during submission
- ✅ Forms show loading state
- ✅ No double submissions possible

**Pass/Fail**: ☐


---

## Test Case 3.38: Admin Management - Success Messages

**Prerequisites**: 
- Logged in as Super Admin

**Steps**:
1. Create a new admin
2. Update an admin
3. Delete an admin
4. Check success messages

**Expected Result**:
- ✅ Success messages appear after each action
- ✅ Messages are clear: "Admin created successfully", etc.
- ✅ Messages auto-dismiss after few seconds (if implemented)
- ✅ Messages can be manually dismissed

**Pass/Fail**: ☐


---

## Test Case 3.39: Admin Management - Cancel Actions

**Prerequisites**: 
- Logged in as Super Admin

**Steps**:
1. Navigate to Create Admin form
2. Fill some fields
3. Click "Cancel" button
4. Check behavior

**Expected Result**:
- ✅ Cancel button visible
- ✅ Clicking cancel closes form/dialog
- ✅ Returns to admin list
- ✅ Unsaved changes discarded
- ✅ No confirmation needed (or confirmation shown)

**Pass/Fail**: ☐


---

## Test Case 3.40: Admin Management - Audit Trail

**Prerequisites**: 
- Logged in as Super Admin
- Admin management actions performed

**Steps**:
1. Create/Update/Delete admins
2. Check activity log or audit trail
3. Verify actions logged

**Expected Result**:
- ✅ Activity log shows admin management actions
- ✅ Shows: Action, Admin (who performed), Target Admin, Timestamp

**Pass/Fail**: ☐


---

