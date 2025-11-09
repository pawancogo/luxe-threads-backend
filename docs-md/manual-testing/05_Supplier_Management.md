# 05. Supplier Management Testing

## 🎯 Overview
Test supplier account management, supplier profiles, approval/rejection, KYC documents, and supplier-related operations.

**Estimated Time**: 50-60 minutes  
**Test Cases**: ~45

---

## Test Case 5.1: View All Suppliers - Super Admin

**Prerequisites**: 
- Logged in as Super Admin
- Multiple supplier accounts exist

**Steps**:
1. Navigate to `/admin/suppliers` or "Supplier Management" menu
2. Check supplier list displays

**Expected Result (FE)**:
- ✅ List shows all suppliers
- ✅ Each supplier shows: Company Name, Email, Status, Tier, Registration Date, Products Count
- ✅ Table/list is sortable and searchable
- ✅ Pagination works
- ✅ Filter options visible (Status, Tier, etc.)

**Expected Result (BE)**:
- ✅ API: `GET /api/v1/admin/suppliers` returns 200
- ✅ Response contains array of suppliers
- ✅ Each supplier object has complete data

**Pass/Fail**: ☐

---

## Test Case 5.2: View All Suppliers - Supplier Admin

**Prerequisites**: 
- Logged in as Supplier Admin

**Steps**:
1. Navigate to Supplier Management
2. Check access

**Expected Result (FE)**:
- ✅ Supplier list accessible
- ✅ Full supplier management features available

**Expected Result (BE)**:
- ✅ API: `GET /api/v1/admin/suppliers` returns 200
- ✅ Access granted

**Pass/Fail**: ☐

---

## Test Case 5.3: View Supplier Details

**Prerequisites**: 
- Logged in as Super Admin or Supplier Admin
- Supplier account exists

**Steps**:
1. Navigate to Supplier Management
2. Click on a supplier from the list
3. View supplier details page

**Expected Result (FE)**:
- ✅ Supplier details page loads
- ✅ Shows: Company Info, Contact Info, Business Details, Status, Tier
- ✅ Shows: KYC Documents, Products, Statistics tabs
- ✅ Edit, Delete, Approve/Reject buttons visible

**Expected Result (BE)**:
- ✅ API: `GET /api/v1/admin/suppliers/:id` returns 200
- ✅ Response contains complete supplier data
- ✅ Includes supplier profile and related data

**Pass/Fail**: ☐

---

## Test Case 5.4: Create New Supplier - Valid Data

**Prerequisites**: 
- Logged in as Super Admin or Supplier Admin

**Steps**:
1. Navigate to Supplier Management
2. Click "Create New Supplier" or "Add Supplier"
3. Fill form:
   - Company Name: "Test Supplier Co"
   - Email: "supplier@test.com"
   - Phone: "+1234567890"
   - Business Type: "Manufacturer"
   - Address: Complete address
4. Submit form

**Expected Result (FE)**:
- ✅ Form displays correctly
- ✅ All required fields marked
- ✅ Success message: "Supplier created successfully"
- ✅ Redirects to supplier list or details
- ✅ New supplier appears in list

**Expected Result (BE)**:
- ✅ API: `POST /api/v1/admin/suppliers` returns 201 Created
- ✅ Supplier record created
- ✅ SupplierProfile created
- ✅ User account created (if unified user model)
- ✅ Status set to "pending" or "active" (check business rules)

**Pass/Fail**: ☐

---

## Test Case 5.5: Create New Supplier - Duplicate Email

**Prerequisites**: 
- Logged in as Super Admin or Supplier Admin
- Supplier with email "existing@test.com" exists

**Steps**:
1. Navigate to Create Supplier form
2. Enter email: "existing@test.com"
3. Fill other required fields
4. Submit form

**Expected Result (FE)**:
- ✅ Validation error: "Email has already been taken"
- ✅ Form does not submit

**Expected Result (BE)**:
- ✅ API returns 422 with email validation error
- ✅ No supplier created

**Pass/Fail**: ☐

---

## Test Case 5.6: Update Supplier - Valid Data

**Prerequisites**: 
- Logged in as Super Admin or Supplier Admin
- Supplier account exists

**Steps**:
1. Navigate to supplier details
2. Click "Edit" button
3. Update company name and phone
4. Submit form

**Expected Result (FE)**:
- ✅ Edit form pre-filled with current data
- ✅ Success message: "Supplier updated successfully"
- ✅ Changes reflected in supplier details

**Expected Result (BE)**:
- ✅ API: `PATCH /api/v1/admin/suppliers/:id` returns 200
- ✅ Supplier record updated
- ✅ Changes persisted correctly

**Pass/Fail**: ☐

---

## Test Case 5.7: Approve Supplier Application

**Prerequisites**: 
- Logged in as Super Admin or Supplier Admin
- Supplier with status "pending" exists

**Steps**:
1. Navigate to supplier details
2. Click "Approve" button
3. Confirm approval

**Expected Result (FE)**:
- ✅ Success message: "Supplier approved successfully"
- ✅ Status changes to "approved" or "active"
- ✅ Approved badge visible
- ✅ Supplier can now access supplier portal

**Expected Result (BE)**:
- ✅ API: `POST /api/v1/admin/suppliers/:id/approve` returns 200
- ✅ Status updated to "approved" or "active"
- ✅ Approval date/timestamp set
- ✅ Activity logged
- ✅ Notification sent to supplier (if implemented)

**Pass/Fail**: ☐

---

## Test Case 5.8: Reject Supplier Application

**Prerequisites**: 
- Logged in as Super Admin or Supplier Admin
- Supplier with status "pending" exists

**Steps**:
1. Navigate to supplier details
2. Click "Reject" button
3. Enter rejection reason
4. Confirm rejection

**Expected Result (FE)**:
- ✅ Rejection reason dialog/form appears
- ✅ Success message: "Supplier application rejected"
- ✅ Status changes to "rejected"
- ✅ Rejection reason visible in supplier details

**Expected Result (BE)**:
- ✅ API: `POST /api/v1/admin/suppliers/:id/reject` returns 200
- ✅ Status updated to "rejected"
- ✅ Rejection reason saved
- ✅ Rejection date/timestamp set
- ✅ Activity logged
- ✅ Notification sent to supplier (if implemented)

**Pass/Fail**: ☐

---

## Test Case 5.9: Activate Supplier

**Prerequisites**: 
- Logged in as Super Admin or Supplier Admin
- Inactive supplier exists

**Steps**:
1. Navigate to supplier details
2. Click "Activate" button

**Expected Result (FE)**:
- ✅ Success message: "Supplier activated"
- ✅ Status changes to "active"
- ✅ Active badge visible

**Expected Result (BE)**:
- ✅ API: `PATCH /api/v1/admin/suppliers/:id/activate` returns 200
- ✅ `is_active: true` in database
- ✅ Supplier can access portal

**Pass/Fail**: ☐

---

## Test Case 5.10: Deactivate Supplier

**Prerequisites**: 
- Logged in as Super Admin or Supplier Admin
- Active supplier exists

**Steps**:
1. Navigate to supplier details
2. Click "Deactivate" button
3. Confirm deactivation

**Expected Result (FE)**:
- ✅ Success message: "Supplier deactivated"
- ✅ Status changes to "inactive"
- ✅ Inactive badge visible

**Expected Result (BE)**:
- ✅ API: `PATCH /api/v1/admin/suppliers/:id/deactivate` returns 200
- ✅ `is_active: false` in database
- ✅ Supplier cannot access portal

**Pass/Fail**: ☐

---

## Test Case 5.11: Suspend Supplier

**Prerequisites**: 
- Logged in as Super Admin or Supplier Admin
- Active supplier exists

**Steps**:
1. Navigate to supplier details
2. Click "Suspend" button
3. Enter suspension reason
4. Confirm suspension

**Expected Result (FE)**:
- ✅ Suspension reason dialog appears
- ✅ Success message: "Supplier suspended"
- ✅ Status changes to "suspended"
- ✅ Suspension reason visible

**Expected Result (BE)**:
- ✅ API: `PATCH /api/v1/admin/suppliers/:id/suspend` returns 200
- ✅ `is_suspended: true` in database
- ✅ Suspension reason saved
- ✅ Suspension date/timestamp set
- ✅ Supplier products may be hidden (check business rules)

**Pass/Fail**: ☐

---

## Test Case 5.12: Update Supplier Tier

**Prerequisites**: 
- Logged in as Super Admin or Supplier Admin
- Supplier exists

**Steps**:
1. Navigate to supplier details
2. Click "Update Tier" or "Change Tier"
3. Select new tier (e.g., "Premium")
4. Submit

**Expected Result (FE)**:
- ✅ Tier update form displays
- ✅ Success message: "Supplier tier updated"
- ✅ New tier reflected in supplier details

**Expected Result (BE)**:
- ✅ API: `PATCH /api/v1/admin/suppliers/:id/update_role` returns 200
- ✅ Supplier tier updated
- ✅ Tier upgrade date set
- ✅ Permissions/features updated based on tier

**Pass/Fail**: ☐

---

## Test Case 5.13: View Supplier Statistics

**Prerequisites**: 
- Logged in as Super Admin or Supplier Admin
- Supplier with activity exists

**Steps**:
1. Navigate to supplier details
2. Click "Statistics" tab
3. View supplier stats

**Expected Result (FE)**:
- ✅ Statistics displayed: Total Products, Active Products, Total Orders, Revenue, etc.
- ✅ Charts/graphs show supplier performance (if implemented)

**Expected Result (BE)**:
- ✅ API: `GET /api/v1/admin/suppliers/:id/stats` returns 200
- ✅ Statistics calculated correctly
- ✅ Data aggregated from products and orders

**Pass/Fail**: ☐

---

## Test Case 5.14: View Supplier KYC Documents

**Prerequisites**: 
- Logged in as Super Admin or Supplier Admin
- Supplier with uploaded documents exists

**Steps**:
1. Navigate to supplier details
2. Click "KYC Documents" tab
3. View documents

**Expected Result (FE)**:
- ✅ Documents list displays
- ✅ Each document shows: Type, Status, Upload Date
- ✅ Documents are downloadable/viewable
- ✅ Approve/Reject buttons for each document (if pending)

**Expected Result (BE)**:
- ✅ API returns supplier documents
- ✅ Documents linked to supplier correctly
- ✅ Document URLs are accessible

**Pass/Fail**: ☐

---

## Test Case 5.15: Review KYC Document

**Prerequisites**: 
- Logged in as Super Admin or Supplier Admin
- Supplier with pending KYC document exists

**Steps**:
1. Navigate to supplier KYC documents
2. Click on a pending document
3. Review document
4. Click "Approve" or "Reject"

**Expected Result (FE)**:
- ✅ Document opens in viewer or downloads
- ✅ Approve/Reject buttons visible
- ✅ Success message after action
- ✅ Document status updates

**Expected Result (BE)**:
- ✅ Document status updated
- ✅ Review date/timestamp set
- ✅ Reviewer admin ID saved
- ✅ Activity logged

**Pass/Fail**: ☐

---

## Test Case 5.16: View Supplier Products

**Prerequisites**: 
- Logged in as Super Admin or Supplier Admin
- Supplier with products exists

**Steps**:
1. Navigate to supplier details
2. Click "Products" tab
3. View supplier's products

**Expected Result (FE)**:
- ✅ Products list displays
- ✅ Each product shows: Name, SKU, Price, Status, Stock
- ✅ Click on product navigates to product details
- ✅ Products sorted by most recent first

**Expected Result (BE)**:
- ✅ API returns supplier products
- ✅ Products filtered by supplier_id correctly

**Pass/Fail**: ☐

---

## Test Case 5.17: Delete Supplier

**Prerequisites**: 
- Logged in as Super Admin or Supplier Admin
- Supplier account exists

**Steps**:
1. Navigate to supplier details
2. Click "Delete" button
3. Confirm deletion

**Expected Result (FE)**:
- ✅ Confirmation dialog appears
- ✅ Success message: "Supplier deleted successfully"
- ✅ Redirects to supplier list
- ✅ Deleted supplier no longer in list

**Expected Result (BE)**:
- ✅ API: `DELETE /api/v1/admin/suppliers/:id` returns 200
- ✅ Supplier record deleted (or soft-deleted)
- ✅ Related records handled (products, orders - check business rules)
- ✅ Activity logged

**Pass/Fail**: ☐

---

## Test Case 5.18: Search Suppliers

**Prerequisites**: 
- Logged in as Super Admin or Supplier Admin
- Multiple suppliers exist

**Steps**:
1. Navigate to Supplier Management
2. Use search bar
3. Search by company name or email

**Expected Result (FE)**:
- ✅ Search bar visible
- ✅ Results filter as typing
- ✅ Results highlight search term
- ✅ "No results" message if no matches

**Expected Result (BE)**:
- ✅ API: `GET /api/v1/admin/suppliers?search=...` returns filtered results
- ✅ Search works on company name and email fields
- ✅ Case-insensitive search

**Pass/Fail**: ☐

---

## Test Case 5.19: Filter Suppliers by Status

**Prerequisites**: 
- Logged in as Super Admin or Supplier Admin
- Suppliers with different statuses exist

**Steps**:
1. Navigate to Supplier Management
2. Use status filter dropdown
3. Select status (Pending, Active, Suspended, etc.)
4. Check filtered results

**Expected Result (FE)**:
- ✅ Status filter visible
- ✅ Filtering works correctly
- ✅ Status badges visible in list

**Expected Result (BE)**:
- ✅ API: `GET /api/v1/admin/suppliers?status=active` returns filtered results
- ✅ Filter works correctly

**Pass/Fail**: ☐

---

## Test Case 5.20: Filter Suppliers by Tier

**Prerequisites**: 
- Logged in as Super Admin or Supplier Admin
- Suppliers with different tiers exist

**Steps**:
1. Navigate to Supplier Management
2. Use tier filter dropdown
3. Select tier (Basic, Premium, Enterprise, etc.)
4. Check filtered results

**Expected Result (FE)**:
- ✅ Tier filter visible
- ✅ Filtering works correctly
- ✅ Tier badges visible in list

**Expected Result (BE)**:
- ✅ API: `GET /api/v1/admin/suppliers?tier=premium` returns filtered results
- ✅ Filter works correctly

**Pass/Fail**: ☐

---

## Test Case 5.21: Sort Suppliers

**Prerequisites**: 
- Logged in as Super Admin or Supplier Admin
- Multiple suppliers exist

**Steps**:
1. Navigate to Supplier Management
2. Click column header to sort
3. Check sorting

**Expected Result (FE)**:
- ✅ Column headers are clickable
- ✅ Sort indicator shows
- ✅ List sorts correctly

**Expected Result (BE)**:
- ✅ API: `GET /api/v1/admin/suppliers?sort=company_name&order=asc` returns sorted results
- ✅ Sorting works on all sortable columns

**Pass/Fail**: ☐

---

## Test Case 5.22: Pagination - Supplier List

**Prerequisites**: 
- Logged in as Super Admin or Supplier Admin
- More than 20 suppliers exist

**Steps**:
1. Navigate to Supplier Management
2. Check pagination controls
3. Navigate to next page

**Expected Result (FE)**:
- ✅ Pagination controls visible
- ✅ Current page highlighted
- ✅ Results update correctly

**Expected Result (BE)**:
- ✅ API: `GET /api/v1/admin/suppliers?page=2` returns correct page
- ✅ Pagination metadata included

**Pass/Fail**: ☐

---

## Test Case 5.23: Bulk Actions - Suppliers

**Prerequisites**: 
- Logged in as Super Admin or Supplier Admin
- Multiple suppliers exist

**Steps**:
1. Navigate to Supplier Management
2. Select multiple suppliers
3. Select bulk action (Activate, Deactivate, Approve, etc.)
4. Confirm action

**Expected Result (FE)**:
- ✅ Checkboxes visible
- ✅ "Select All" works
- ✅ Bulk action dropdown appears
- ✅ Success message: "X suppliers updated"

**Expected Result (BE)**:
- ✅ API: `POST /api/v1/admin/suppliers/bulk_action` returns 200
- ✅ All selected suppliers updated
- ✅ Transaction used

**Pass/Fail**: ☐

---

## Test Case 5.24: Export Suppliers List

**Prerequisites**: 
- Logged in as Super Admin or Supplier Admin
- Suppliers exist

**Steps**:
1. Navigate to Supplier Management
2. Click "Export" button
3. Check downloaded file

**Expected Result (FE)**:
- ✅ Export button visible
- ✅ File downloads (CSV/Excel)
- ✅ File contains supplier data

**Expected Result (BE)**:
- ✅ API: `GET /api/v1/admin/suppliers/export` returns file
- ✅ File format correct

**Pass/Fail**: ☐

---

## Test Case 5.25: View Supplier Payments

**Prerequisites**: 
- Logged in as Super Admin or Supplier Admin
- Supplier with payment history exists

**Steps**:
1. Navigate to supplier details
2. Click "Payments" tab
3. View payment history

**Expected Result (FE)**:
- ✅ Payments list displays
- ✅ Each payment shows: Amount, Date, Status, Payment Method
- ✅ Payments sorted by most recent first

**Expected Result (BE)**:
- ✅ API: `GET /api/v1/admin/supplier_payments?supplier_id=:id` returns 200
- ✅ Payments filtered by supplier_id

**Pass/Fail**: ☐

---

## Test Case 5.26: Create Supplier Payment

**Prerequisites**: 
- Logged in as Super Admin or Supplier Admin
- Supplier exists

**Steps**:
1. Navigate to supplier payments
2. Click "Create Payment" or "Add Payment"
3. Fill form: Amount, Payment Method, Notes
4. Submit

**Expected Result (FE)**:
- ✅ Payment form displays
- ✅ Success message: "Payment created successfully"
- ✅ Payment appears in list

**Expected Result (BE)**:
- ✅ API: `POST /api/v1/admin/supplier_payments` returns 201
- ✅ Payment record created
- ✅ Linked to supplier correctly

**Pass/Fail**: ☐

---

## Test Case 5.27: Process Supplier Payout

**Prerequisites**: 
- Logged in as Super Admin or Supplier Admin
- Supplier with pending payout exists

**Steps**:
1. Navigate to supplier payments
2. Find pending payout
3. Click "Process Payout"
4. Confirm processing

**Expected Result (FE)**:
- ✅ Success message: "Payout processed successfully"
- ✅ Payment status changes to "paid"
- ✅ Payment date set

**Expected Result (BE)**:
- ✅ API: `PATCH /api/v1/admin/supplier_payments/:id/process` returns 200
- ✅ Payment status updated
- ✅ Payout processed date set
- ✅ Activity logged

**Pass/Fail**: ☐

---

## Test Case 5.28: Supplier Management - Mobile Responsive

**Prerequisites**: 
- Logged in as Super Admin or Supplier Admin

**Steps**:
1. Open Supplier Management on mobile device
2. Test all features

**Expected Result (FE)**:
- ✅ List displays correctly on mobile
- ✅ Forms are usable
- ✅ Buttons properly sized
- ✅ No horizontal scrolling

**Expected Result (BE)**:
- ✅ Same as desktop

**Pass/Fail**: ☐

---

## Test Case 5.29: Supplier Management - Error Handling

**Prerequisites**: 
- Logged in as Super Admin or Supplier Admin

**Steps**:
1. Stop backend server
2. Try to load supplier list
3. Check error handling

**Expected Result (FE)**:
- ✅ Error message: "Unable to load suppliers"
- ✅ User-friendly error

**Expected Result (BE)**:
- ✅ N/A (server not responding)

**Pass/Fail**: ☐

---

## Test Case 5.30: Supplier Management - Form Validation

**Prerequisites**: 
- Logged in as Super Admin or Supplier Admin

**Steps**:
1. Navigate to Create Supplier form
2. Test validations:
   - Empty required fields
   - Invalid email
   - Invalid phone
   - Duplicate email
3. Check error messages

**Expected Result (FE)**:
- ✅ All validations work
- ✅ Error messages clear
- ✅ Form doesn't submit with errors

**Expected Result (BE)**:
- ✅ API validates all fields
- ✅ Returns appropriate errors

**Pass/Fail**: ☐

---

## Test Case 5.31: Supplier Management - Loading States

**Prerequisites**: 
- Logged in as Super Admin or Supplier Admin

**Steps**:
1. Navigate to Supplier Management
2. Perform actions
3. Observe loading states

**Expected Result (FE)**:
- ✅ Loading indicators show
- ✅ Buttons disabled during submission
- ✅ No double submissions

**Expected Result (BE)**:
- ✅ Requests processed normally

**Pass/Fail**: ☐

---

## Test Case 5.32: Supplier Management - Success Messages

**Prerequisites**: 
- Logged in as Super Admin or Supplier Admin

**Steps**:
1. Create/Update/Delete suppliers
2. Check success messages

**Expected Result (FE)**:
- ✅ Success messages appear
- ✅ Messages are clear
- ✅ Messages auto-dismiss

**Expected Result (BE)**:
- ✅ Actions complete successfully

**Pass/Fail**: ☐

---

## Test Case 5.33: Supplier Management - Audit Trail

**Prerequisites**: 
- Logged in as Super Admin or Supplier Admin

**Steps**:
1. Perform supplier management actions
2. Check activity log

**Expected Result (FE)**:
- ✅ Activity log shows actions
- ✅ Shows: Action, Admin, Target Supplier, Timestamp

**Expected Result (BE)**:
- ✅ Actions logged in `admin_activities` table
- ✅ All actions tracked

**Pass/Fail**: ☐

---

## Test Case 5.34: Supplier Management - Empty State

**Prerequisites**: 
- Logged in as Super Admin or Supplier Admin
- No suppliers exist

**Steps**:
1. Navigate to Supplier Management
2. Check empty state

**Expected Result (FE)**:
- ✅ Empty state message: "No suppliers found"
- ✅ Helpful message
- ✅ No errors

**Expected Result (BE)**:
- ✅ API returns empty array
- ✅ No errors thrown

**Pass/Fail**: ☐

---

## Test Case 5.35: Supplier Management - Performance

**Prerequisites**: 
- Logged in as Super Admin or Supplier Admin
- Large number of suppliers exist

**Steps**:
1. Navigate to Supplier Management
2. Measure load time
3. Test search, filter, sort

**Expected Result (FE)**:
- ✅ Page loads in reasonable time
- ✅ Search/filter/sort work efficiently
- ✅ No performance issues

**Expected Result (BE)**:
- ✅ API response time acceptable
- ✅ Queries optimized
- ✅ No N+1 problems

**Pass/Fail**: ☐

---

## Test Case 5.36-5.45: Additional Supplier Features

**Test additional features as needed:**
- Supplier invitations
- Supplier team members
- Supplier settings
- Supplier notifications
- Supplier reports
- Supplier analytics
- Supplier commission settings
- Supplier shipping settings
- Supplier return policies
- Supplier communication

**Pass/Fail**: ☐ (for each)

---

## 📝 Notes Section

**Issues Found**:
- 

**Suggestions**:
- 

**Completed By**: _______________  
**Date**: _______________  
**Total Passed**: ___/45  
**Total Failed**: ___/45

