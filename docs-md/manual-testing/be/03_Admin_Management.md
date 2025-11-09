# 03. Admin Management Testing (Super Admin Only)

## 🎯 Overview
Test from the **Backend (BE)** perspective.

**Testing Focus**: API responses, data persistence, business logic, database operations, and backend behavior.

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
- ✅ API: `GET /api/v1/admin/admins` returns 200
- ✅ Response contains array of admins
- ✅ Each admin object has: id, email, role, first_name, last_name, is_active, is_blocked, last_login_at

**Pass/Fail**: ☐


---

## Test Case 3.2: View All Admins - Non-Super Admin

**Prerequisites**: 
- Logged in as Product Admin (or any non-super admin)

**Steps**:
1. Try to navigate to `/admin/admins`
2. Check access

**Expected Result**:
- ✅ API: `GET /api/v1/admin/admins` returns 403 Forbidden
- ✅ Response: `{ error: "Access denied" }`

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
- ✅ API: `POST /api/v1/admin/admins` returns 201 Created
- ✅ Admin record created in database
- ✅ Password hashed (bcrypt)
- ✅ Role assigned correctly
- ✅ `is_active: true` by default
- ✅ `is_blocked: false` by default
- ✅ Email is unique

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
- ✅ API returns 422 Unprocessable Entity
- ✅ Response: `{ errors: { email: ["has already been taken"] } }`
- ✅ No admin record created

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
- ✅ API returns 422 with email validation error
- ✅ No admin created

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
- ✅ API returns 422 with password validation error
- ✅ No admin created

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
- ✅ No API call made (if frontend validation)
- ✅ Or API returns 422 with validation errors

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
- ✅ API: `GET /api/v1/admin/admins/:id` returns 200
- ✅ Response contains complete admin data
- ✅ Includes related data (roles, permissions)

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
- ✅ API: `PATCH /api/v1/admin/admins/:id` returns 200
- ✅ Admin record updated in database
- ✅ `updated_at` timestamp updated
- ✅ Changes persisted correctly

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
- ✅ API returns 200
- ✅ Email updated in database
- ✅ Email uniqueness validated
- ✅ If email used for login, admin can login with new email

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
- ✅ API returns 200
- ✅ Role updated in database
- ✅ Permissions updated based on new role
- ✅ RBAC role assignment updated (if using RBAC)

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
- ✅ API: `PATCH /api/v1/admin/admins/:id/change_password` returns 200
- ✅ Password hashed and updated
- ✅ `password_changed_at` updated
- ✅ Old password invalidated

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
- ✅ API: `DELETE /api/v1/admin/admins/:id` returns 200
- ✅ Admin record deleted (or soft-deleted)
- ✅ Related records handled (roles, permissions)
- ✅ Activity logged

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
- ✅ No API call made
- ✅ Admin record unchanged

**Pass/Fail**: ☐


---

## Test Case 3.15: Delete Admin - Prevent Self-Deletion

**Prerequisites**: 
- Logged in as Super Admin

**Steps**:
1. Navigate to own admin details
2. Try to delete own account

**Expected Result**:
- ✅ API returns 422 or 403
- ✅ Response: `{ error: "Cannot delete own account" }`
- ✅ Admin not deleted

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
- ✅ API: `PATCH /api/v1/admin/admins/:id/block` returns 200
- ✅ `is_blocked: true` in database
- ✅ `blocked_at` timestamp set
- ✅ Blocked admin cannot login

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
- ✅ API: `PATCH /api/v1/admin/admins/:id/unblock` returns 200
- ✅ `is_blocked: false` in database
- ✅ `blocked_at` cleared
- ✅ Admin can login again

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
- ✅ API: `PATCH /api/v1/admin/admins/:id/activate` returns 200
- ✅ `is_active: true` in database
- ✅ Admin can login

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
- ✅ API: `PATCH /api/v1/admin/admins/:id/deactivate` returns 200
- ✅ `is_active: false` in database
- ✅ Admin cannot login

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
- ✅ API: `POST /api/v1/admin/rbac/admins/:id/assign_role` returns 200
- ✅ `AdminRoleAssignment` record created
- ✅ Permissions updated based on role
- ✅ Activity logged

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
- ✅ API: `DELETE /api/v1/admin/rbac/admins/:id/remove_role/:role_slug` returns 200
- ✅ `AdminRoleAssignment` record deleted
- ✅ Permissions recalculated
- ✅ Activity logged

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
- ✅ API: `PATCH /api/v1/admin/rbac/admins/:id/update_permissions` returns 200
- ✅ Custom permissions saved
- ✅ Permission cache invalidated
- ✅ Activity logged

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
- ✅ API: `GET /api/v1/admin/admins/:id/activities` returns 200
- ✅ Returns activities from `admin_activities` table
- ✅ Filtered by admin_id

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
- ✅ API: `GET /api/v1/admin/admins?search=...` returns filtered results
- ✅ Search works on name and email fields
- ✅ Case-insensitive search

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
- ✅ API: `GET /api/v1/admin/admins?role=product_admin` returns filtered results
- ✅ Filter works correctly

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
- ✅ API: `GET /api/v1/admin/admins?status=active` returns filtered results
- ✅ Filter works correctly

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
- ✅ API: `GET /api/v1/admin/admins?sort=name&order=asc` returns sorted results
- ✅ Sorting works on all sortable columns

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
- ✅ API: `GET /api/v1/admin/admins?page=2` returns correct page
- ✅ Pagination metadata included: total_pages, current_page, per_page
- ✅ Results limited to per_page count

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
- ✅ API: `POST /api/v1/admin/admins/bulk_action` returns 200
- ✅ All selected admins updated
- ✅ Transaction used (all or nothing)
- ✅ Activity logged for each

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
- ✅ API: `GET /api/v1/admin/admins/export` returns file
- ✅ File format correct
- ✅ All admins included (or filtered based on current view)

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
- ✅ API: `GET /api/v1/admin/rbac/roles` returns 200
- ✅ Returns all roles from `rbac_roles` table

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
- ✅ API: `GET /api/v1/admin/rbac/permissions` returns 200
- ✅ Returns all permissions from `rbac_permissions` table
- ✅ Grouped by category

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
- ✅ API: `GET /api/v1/admin/rbac/admins/:id/roles` returns 200
- ✅ Returns role assignments from `admin_role_assignments` table
- ✅ Includes role and permission details

**Pass/Fail**: ☐


---

## Test Case 3.34: Admin Management - Mobile Responsive

**Prerequisites**: 
- Logged in as Super Admin

**Steps**:
1. Open Admin Management on mobile device
2. Test all features (view, create, edit, delete)

**Expected Result**:
- ✅ Same as desktop (backend doesn't change)

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
- ✅ N/A (server not responding)

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
- ✅ API validates all fields
- ✅ Returns appropriate error codes and messages

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
- ✅ Requests processed normally

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
- ✅ Actions complete successfully
- ✅ Appropriate status codes returned

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
- ✅ No API call made
- ✅ No data saved

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
- ✅ Actions logged in `admin_activities` table
- ✅ IP address and user agent logged
- ✅ All admin management actions tracked

**Pass/Fail**: ☐


---

