# 04. User Management Testing

## 🎯 Overview
Test from the **Frontend (FE)** perspective.

**Testing Focus**: UI/UX, form validation, navigation, error messages, user interactions, and frontend behavior.

**Estimated Time**: 40-50 minutes  
**Test Cases**: ~35

---

## Test Case 4.1: View All Users - Super Admin

**Prerequisites**: 
- Logged in as Super Admin
- Multiple user accounts exist

**Steps**:
1. Navigate to `/admin/users` or "User Management" menu
2. Check user list displays

**Expected Result**:
- ✅ List shows all user accounts
- ✅ Each user shows: Name, Email, Phone, Status, Registration Date, Last Login
- ✅ Table/list is sortable and searchable
- ✅ Pagination works (if many users)
- ✅ Filter options visible (Status, Date Range, etc.)

**Pass/Fail**: ☐


---

## Test Case 4.2: View All Users - User Admin

**Prerequisites**: 
- Logged in as User Admin

**Steps**:
1. Navigate to User Management
2. Check access

**Expected Result**:
- ✅ User list accessible
- ✅ Full user management features available

**Pass/Fail**: ☐


---

## Test Case 4.3: View All Users - Non-User Admin

**Prerequisites**: 
- Logged in as Product Admin (doesn't have user management permission)

**Steps**:
1. Try to navigate to `/admin/users`
2. Check access

**Expected Result**:
- ✅ Access denied OR view-only access
- ✅ Menu item may not be visible

**Pass/Fail**: ☐


---

## Test Case 4.4: View User Details

**Prerequisites**: 
- Logged in as Super Admin or User Admin
- User account exists

**Steps**:
1. Navigate to User Management
2. Click on a user from the list
3. View user details page

**Expected Result**:
- ✅ User details page loads
- ✅ Shows: Personal Info, Contact Info, Account Status, Registration Date, Last Login
- ✅ Shows: Addresses, Orders, Activity Log tabs
- ✅ Edit and Delete buttons visible
- ✅ Activate/Deactivate button visible

**Pass/Fail**: ☐


---

## Test Case 4.5: Update User - Valid Data

**Prerequisites**: 
- Logged in as Super Admin or User Admin
- User account exists

**Steps**:
1. Navigate to user details
2. Click "Edit" button
3. Update: First Name to "Updated", Last Name to "Name"
4. Submit form

**Expected Result**:
- ✅ Edit form pre-filled with current data
- ✅ Success message: "User updated successfully"
- ✅ Changes reflected in user details
- ✅ Changes reflected in user list

**Pass/Fail**: ☐


---

## Test Case 4.6: Update User - Change Email

**Prerequisites**: 
- Logged in as Super Admin or User Admin
- User account exists

**Steps**:
1. Navigate to user details
2. Click "Edit"
3. Change email to new unique email
4. Submit form

**Expected Result**:
- ✅ Email updated successfully
- ✅ Success message shown
- ✅ New email reflected everywhere

**Pass/Fail**: ☐


---

## Test Case 4.7: Update User - Change Phone

**Prerequisites**: 
- Logged in as Super Admin or User Admin
- User account exists

**Steps**:
1. Navigate to user details
2. Click "Edit"
3. Update phone number
4. Submit form

**Expected Result**:
- ✅ Phone updated successfully
- ✅ Success message shown

**Pass/Fail**: ☐


---

## Test Case 4.8: Update User - Invalid Email Format

**Prerequisites**: 
- Logged in as Super Admin or User Admin
- User account exists

**Steps**:
1. Navigate to user details
2. Click "Edit"
3. Enter invalid email: "invalid-email"
4. Submit form

**Expected Result**:
- ✅ Validation error: "Please provide a valid email address"
- ✅ Form does not submit
- ✅ Error shown near email field

**Pass/Fail**: ☐


---

## Test Case 4.9: Update User - Duplicate Email

**Prerequisites**: 
- Logged in as Super Admin or User Admin
- Two user accounts exist

**Steps**:
1. Navigate to user A details
2. Click "Edit"
3. Change email to user B's email
4. Submit form

**Expected Result**:
- ✅ Validation error: "Email has already been taken"
- ✅ Form does not submit

**Pass/Fail**: ☐


---

## Test Case 4.10: Delete User - Confirm Delete

**Prerequisites**: 
- Logged in as Super Admin or User Admin
- User account exists

**Steps**:
1. Navigate to user details
2. Click "Delete" button
3. Confirm deletion in dialog
4. Submit deletion

**Expected Result**:
- ✅ Confirmation dialog: "Are you sure you want to delete this user?"
- ✅ Success message: "User deleted successfully"
- ✅ Redirects to user list
- ✅ Deleted user no longer in list

**Pass/Fail**: ☐


---

## Test Case 4.11: Delete User - Cancel Delete

**Prerequisites**: 
- Logged in as Super Admin or User Admin
- User account exists

**Steps**:
1. Navigate to user details
2. Click "Delete" button
3. Click "Cancel" in confirmation dialog

**Expected Result**:
- ✅ Dialog closes
- ✅ User not deleted
- ✅ Still on user details page

**Pass/Fail**: ☐


---

## Test Case 4.12: Activate User Account

**Prerequisites**: 
- Logged in as Super Admin or User Admin
- Inactive user account exists

**Steps**:
1. Navigate to user details
2. Click "Activate" button

**Expected Result**:
- ✅ Success message: "User account activated"
- ✅ Status changes to "Active"
- ✅ Active badge visible
- ✅ "Deactivate" button appears

**Pass/Fail**: ☐


---

## Test Case 4.13: Deactivate User Account

**Prerequisites**: 
- Logged in as Super Admin or User Admin
- Active user account exists

**Steps**:
1. Navigate to user details
2. Click "Deactivate" button
3. Confirm deactivation

**Expected Result**:
- ✅ Success message: "User account deactivated"
- ✅ Status changes to "Inactive"
- ✅ Inactive badge visible
- ✅ "Activate" button appears

**Pass/Fail**: ☐


---

## Test Case 4.14: Block User Account

**Prerequisites**: 
- Logged in as Super Admin or User Admin
- User account exists

**Steps**:
1. Navigate to user details
2. Click "Block" button
3. Confirm blocking

**Expected Result**:
- ✅ Success message: "User account blocked"
- ✅ Status changes to "Blocked"
- ✅ Blocked badge visible
- ✅ "Unblock" button appears

**Pass/Fail**: ☐


---

## Test Case 4.15: Unblock User Account

**Prerequisites**: 
- Logged in as Super Admin or User Admin
- Blocked user account exists

**Steps**:
1. Navigate to user details
2. Click "Unblock" button
3. Confirm unblocking

**Expected Result**:
- ✅ Success message: "User account unblocked"
- ✅ Status changes to "Active"
- ✅ Blocked indicator removed

**Pass/Fail**: ☐


---

## Test Case 4.16: View User Orders

**Prerequisites**: 
- Logged in as Super Admin or User Admin
- User with orders exists

**Steps**:
1. Navigate to user details
2. Click "Orders" tab
3. View user's orders

**Expected Result**:
- ✅ Orders list displays
- ✅ Each order shows: Order ID, Date, Amount, Status
- ✅ Click on order navigates to order details
- ✅ Orders sorted by most recent first

**Pass/Fail**: ☐


---

## Test Case 4.17: View User Activity Log

**Prerequisites**: 
- Logged in as Super Admin or User Admin
- User with activity history exists

**Steps**:
1. Navigate to user details
2. Click "Activity" tab
3. View activity log

**Expected Result**:
- ✅ Activity log displays
- ✅ Shows: Action, Timestamp, IP Address, Details
- ✅ Activities sorted by most recent first
- ✅ Pagination works (if many activities)

**Pass/Fail**: ☐


---

## Test Case 4.18: View User Addresses

**Prerequisites**: 
- Logged in as Super Admin or User Admin
- User with addresses exists

**Steps**:
1. Navigate to user details
2. Click "Addresses" tab
3. View user's addresses

**Expected Result**:
- ✅ Addresses list displays
- ✅ Each address shows: Label, Full Address, Type (Home/Work), Default
- ✅ Addresses are editable/deletable

**Pass/Fail**: ☐


---

## Test Case 4.19: Bulk Delete Users

**Prerequisites**: 
- Logged in as Super Admin or User Admin
- Multiple users exist

**Steps**:
1. Navigate to User Management
2. Select multiple users (checkboxes)
3. Click "Bulk Delete" or select from bulk actions
4. Confirm deletion

**Expected Result**:
- ✅ Checkboxes visible for each user
- ✅ "Select All" checkbox works
- ✅ Bulk action dropdown appears when users selected
- ✅ Success message: "X users deleted successfully"
- ✅ Selected users removed from list

**Pass/Fail**: ☐


---

## Test Case 4.20: Search Users

**Prerequisites**: 
- Logged in as Super Admin or User Admin
- Multiple users exist

**Steps**:
1. Navigate to User Management
2. Use search bar
3. Search by name or email

**Expected Result**:
- ✅ Search bar visible
- ✅ Results filter as typing
- ✅ Results highlight search term
- ✅ "No results" message if no matches
- ✅ Search works on name and email fields

**Pass/Fail**: ☐


---

## Test Case 4.21: Filter Users by Status

**Prerequisites**: 
- Logged in as Super Admin or User Admin
- Users with different statuses exist

**Steps**:
1. Navigate to User Management
2. Use status filter dropdown
3. Select "Active", "Inactive", or "Blocked"
4. Check filtered results

**Expected Result**:
- ✅ Status filter visible
- ✅ Filtering works correctly
- ✅ Status badges visible in list
- ✅ Filter can be cleared

**Pass/Fail**: ☐


---

## Test Case 4.22: Filter Users by Date Range

**Prerequisites**: 
- Logged in as Super Admin or User Admin
- Users registered on different dates exist

**Steps**:
1. Navigate to User Management
2. Use date range filter
3. Select date range (e.g., Last 30 days)
4. Check filtered results

**Expected Result**:
- ✅ Date range picker visible
- ✅ Filtering works correctly
- ✅ Results show only users in date range

**Pass/Fail**: ☐


---

## Test Case 4.23: Sort Users

**Prerequisites**: 
- Logged in as Super Admin or User Admin
- Multiple users exist

**Steps**:
1. Navigate to User Management
2. Click column header to sort (e.g., "Name", "Email", "Registration Date")
3. Check sorting

**Expected Result**:
- ✅ Column headers are clickable
- ✅ Sort indicator shows (arrow up/down)
- ✅ List sorts correctly
- ✅ Toggle between ascending/descending

**Pass/Fail**: ☐


---

## Test Case 4.24: Pagination - User List

**Prerequisites**: 
- Logged in as Super Admin or User Admin
- More than 20 users exist (or page size)

**Steps**:
1. Navigate to User Management
2. Check pagination controls
3. Navigate to next page
4. Check results

**Expected Result**:
- ✅ Pagination controls visible
- ✅ Current page highlighted
- ✅ Total pages/records shown
- ✅ Clicking page number loads that page
- ✅ Results update correctly

**Pass/Fail**: ☐


---

## Test Case 4.25: Export Users List

**Prerequisites**: 
- Logged in as Super Admin or User Admin
- Users exist

**Steps**:
1. Navigate to User Management
2. Click "Export" button
3. Check downloaded file

**Expected Result**:
- ✅ Export button visible
- ✅ File downloads (CSV/Excel)
- ✅ File name includes date/timestamp
- ✅ File contains user data

**Pass/Fail**: ☐


---

## Test Case 4.26: View User Statistics

**Prerequisites**: 
- Logged in as Super Admin or User Admin
- User with activity exists

**Steps**:
1. Navigate to user details
2. Check statistics section (if exists)

**Expected Result**:
- ✅ Statistics displayed: Total Orders, Total Spent, Average Order Value, etc.
- ✅ Charts/graphs show user activity over time (if implemented)

**Pass/Fail**: ☐


---

## Test Case 4.27: User Management - Mobile Responsive

**Prerequisites**: 
- Logged in as Super Admin or User Admin

**Steps**:
1. Open User Management on mobile device
2. Test all features (view, edit, delete)

**Expected Result**:
- ✅ List displays correctly on mobile
- ✅ Forms are usable on mobile
- ✅ Buttons are properly sized
- ✅ No horizontal scrolling
- ✅ Touch interactions work

**Pass/Fail**: ☐


---

## Test Case 4.28: User Management - Error Handling

**Prerequisites**: 
- Logged in as Super Admin or User Admin

**Steps**:
1. Stop backend server
2. Try to load user list
3. Check error handling

**Expected Result**:
- ✅ Error message: "Unable to load users"
- ✅ User-friendly error
- ✅ Retry option (if implemented)

**Pass/Fail**: ☐


---

## Test Case 4.29: User Management - Loading States

**Prerequisites**: 
- Logged in as Super Admin or User Admin

**Steps**:
1. Navigate to User Management
2. Perform actions (update, delete)
3. Observe loading states

**Expected Result**:
- ✅ Loading indicators show during API calls
- ✅ Buttons disabled during submission
- ✅ Forms show loading state
- ✅ No double submissions possible

**Pass/Fail**: ☐


---

## Test Case 4.30: User Management - Form Validation

**Prerequisites**: 
- Logged in as Super Admin or User Admin

**Steps**:
1. Navigate to Edit User form
2. Test all validation rules:
   - Empty required fields
   - Invalid email
   - Invalid phone format
   - Duplicate email
3. Check error messages

**Expected Result**:
- ✅ All validations work
- ✅ Error messages clear and helpful
- ✅ Errors shown near relevant fields
- ✅ Form doesn't submit with errors

**Pass/Fail**: ☐


---

## Test Case 4.31: User Management - Success Messages

**Prerequisites**: 
- Logged in as Super Admin or User Admin

**Steps**:
1. Update a user
2. Delete a user
3. Activate/deactivate a user
4. Check success messages

**Expected Result**:
- ✅ Success messages appear after each action
- ✅ Messages are clear: "User updated successfully", etc.
- ✅ Messages auto-dismiss after few seconds (if implemented)

**Pass/Fail**: ☐


---

## Test Case 4.32: User Management - Cancel Actions

**Prerequisites**: 
- Logged in as Super Admin or User Admin

**Steps**:
1. Navigate to Edit User form
2. Make some changes
3. Click "Cancel" button
4. Check behavior

**Expected Result**:
- ✅ Cancel button visible
- ✅ Clicking cancel closes form
- ✅ Returns to user list or details
- ✅ Unsaved changes discarded

**Pass/Fail**: ☐


---

## Test Case 4.33: User Management - Audit Trail

**Prerequisites**: 
- Logged in as Super Admin or User Admin
- User management actions performed

**Steps**:
1. Update/Delete users
2. Check activity log or audit trail
3. Verify actions logged

**Expected Result**:
- ✅ Activity log shows user management actions
- ✅ Shows: Action, Admin (who performed), Target User, Timestamp

**Pass/Fail**: ☐


---

## Test Case 4.34: User Management - Empty State

**Prerequisites**: 
- Logged in as Super Admin or User Admin
- No users exist (fresh database)

**Steps**:
1. Navigate to User Management
2. Check empty state

**Expected Result**:
- ✅ Empty state message: "No users found"
- ✅ Helpful message or illustration
- ✅ No errors displayed

**Pass/Fail**: ☐


---

## Test Case 4.35: User Management - Performance

**Prerequisites**: 
- Logged in as Super Admin or User Admin
- Large number of users exist (1000+)

**Steps**:
1. Navigate to User Management
2. Measure load time
3. Test search, filter, sort with large dataset

**Expected Result**:
- ✅ Page loads in reasonable time (< 3 seconds)
- ✅ Search/filter/sort work efficiently
- ✅ Pagination works correctly
- ✅ No performance issues

**Pass/Fail**: ☐


---

