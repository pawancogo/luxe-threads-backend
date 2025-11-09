# 04. User Management Testing

## 🎯 Overview
Test from the **Backend (BE)** perspective.

**Testing Focus**: API responses, data persistence, business logic, database operations, and backend behavior.

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
- ✅ API: `GET /api/v1/admin/users` returns 200
- ✅ Response contains array of users
- ✅ Each user object has: id, email, first_name, last_name, phone, is_active, created_at, last_login_at

**Pass/Fail**: ☐


---

## Test Case 4.2: View All Users - User Admin

**Prerequisites**: 
- Logged in as User Admin

**Steps**:
1. Navigate to User Management
2. Check access

**Expected Result**:
- ✅ API: `GET /api/v1/admin/users` returns 200
- ✅ Access granted (User Admin has permission)

**Pass/Fail**: ☐


---

## Test Case 4.3: View All Users - Non-User Admin

**Prerequisites**: 
- Logged in as Product Admin (doesn't have user management permission)

**Steps**:
1. Try to navigate to `/admin/users`
2. Check access

**Expected Result**:
- ✅ API: `GET /api/v1/admin/users` returns 403 Forbidden OR 200 with limited data
- ✅ Depends on permission configuration

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
- ✅ API: `GET /api/v1/admin/users/:id` returns 200
- ✅ Response contains complete user data
- ✅ Includes related data (addresses, orders count)

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
- ✅ API: `PATCH /api/v1/admin/users/:id` returns 200
- ✅ User record updated in database
- ✅ `updated_at` timestamp updated
- ✅ Changes persisted correctly

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
- ✅ API returns 200
- ✅ Email updated in database
- ✅ Email uniqueness validated
- ✅ User can login with new email

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
- ✅ API returns 200
- ✅ Phone updated in database
- ✅ Phone format validated (if validation exists)

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
- ✅ API returns 422 with email validation error
- ✅ No update made

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
- ✅ API returns 422 with email validation error
- ✅ No update made

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
- ✅ API: `DELETE /api/v1/admin/users/:id` returns 200
- ✅ User record deleted (or soft-deleted)
- ✅ Related records handled (addresses, orders - check business rules)
- ✅ Activity logged

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
- ✅ No API call made
- ✅ User record unchanged

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
- ✅ API: `PATCH /api/v1/admin/users/:id/activate` returns 200
- ✅ `is_active: true` in database
- ✅ User can login

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
- ✅ API: `PATCH /api/v1/admin/users/:id/deactivate` returns 200
- ✅ `is_active: false` in database
- ✅ User cannot login

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
- ✅ API: `PATCH /api/v1/admin/users/:id/block` returns 200
- ✅ `is_blocked: true` in database
- ✅ `blocked_at` timestamp set
- ✅ Blocked user cannot login

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
- ✅ API: `PATCH /api/v1/admin/users/:id/unblock` returns 200
- ✅ `is_blocked: false` in database
- ✅ User can login again

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
- ✅ API: `GET /api/v1/admin/users/:id/orders` returns 200
- ✅ Returns orders filtered by user_id
- ✅ Orders include necessary details

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
- ✅ API: `GET /api/v1/admin/users/:id/activity` returns 200
- ✅ Returns activities from activity log table
- ✅ Filtered by user_id

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
- ✅ API returns user addresses
- ✅ Addresses linked to user correctly

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
- ✅ API: `POST /api/v1/admin/users/bulk_delete` returns 200
- ✅ All selected users deleted
- ✅ Transaction used (all or nothing)
- ✅ Activity logged for each deletion

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
- ✅ API: `GET /api/v1/admin/users?search=...` returns filtered results
- ✅ Case-insensitive search
- ✅ Search works on multiple fields

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
- ✅ API: `GET /api/v1/admin/users?status=active` returns filtered results
- ✅ Filter works correctly

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
- ✅ API: `GET /api/v1/admin/users?start_date=...&end_date=...` returns filtered results
- ✅ Date filtering works correctly

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
- ✅ API: `GET /api/v1/admin/users?sort=name&order=asc` returns sorted results
- ✅ Sorting works on all sortable columns

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
- ✅ API: `GET /api/v1/admin/users?page=2` returns correct page
- ✅ Pagination metadata included
- ✅ Results limited to per_page count

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
- ✅ API: `GET /api/v1/admin/users/export` returns file
- ✅ File format correct
- ✅ All users included (or filtered based on current view)

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
- ✅ Statistics calculated correctly
- ✅ Data aggregated from orders and activities

**Pass/Fail**: ☐


---

## Test Case 4.27: User Management - Mobile Responsive

**Prerequisites**: 
- Logged in as Super Admin or User Admin

**Steps**:
1. Open User Management on mobile device
2. Test all features (view, edit, delete)

**Expected Result**:
- ✅ Same as desktop (backend doesn't change)

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
- ✅ N/A (server not responding)

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
- ✅ Requests processed normally

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
- ✅ API validates all fields
- ✅ Returns appropriate error codes and messages

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
- ✅ Actions complete successfully
- ✅ Appropriate status codes returned

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
- ✅ No API call made
- ✅ No data saved

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
- ✅ Actions logged in `admin_activities` table
- ✅ IP address and user agent logged
- ✅ All user management actions tracked

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
- ✅ API returns empty array
- ✅ No errors thrown

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
- ✅ API response time acceptable
- ✅ Database queries optimized
- ✅ Indexes used correctly
- ✅ No N+1 query problems

**Pass/Fail**: ☐


---

