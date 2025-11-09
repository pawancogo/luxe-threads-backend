# 05. Supplier Management Testing

## 🎯 Overview
Test from the **Frontend (FE)** perspective.

**Testing Focus**: UI/UX, form validation, navigation, error messages, user interactions, and frontend behavior.

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

**Expected Result**:
- ✅ List shows all suppliers
- ✅ Each supplier shows: Company Name, Email, Status, Tier, Registration Date, Products Count
- ✅ Table/list is sortable and searchable
- ✅ Pagination works
- ✅ Filter options visible (Status, Tier, etc.)

**Pass/Fail**: ☐


---

## Test Case 5.2: View All Suppliers - Supplier Admin

**Prerequisites**: 
- Logged in as Supplier Admin

**Steps**:
1. Navigate to Supplier Management
2. Check access

**Expected Result**:
- ✅ Supplier list accessible
- ✅ Full supplier management features available

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

**Expected Result**:
- ✅ Supplier details page loads
- ✅ Shows: Company Info, Contact Info, Business Details, Status, Tier
- ✅ Shows: KYC Documents, Products, Statistics tabs
- ✅ Edit, Delete, Approve/Reject buttons visible

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

**Expected Result**:
- ✅ Form displays correctly
- ✅ All required fields marked
- ✅ Success message: "Supplier created successfully"
- ✅ Redirects to supplier list or details
- ✅ New supplier appears in list

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

**Expected Result**:
- ✅ Validation error: "Email has already been taken"
- ✅ Form does not submit

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

**Expected Result**:
- ✅ Edit form pre-filled with current data
- ✅ Success message: "Supplier updated successfully"
- ✅ Changes reflected in supplier details

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

**Expected Result**:
- ✅ Success message: "Supplier approved successfully"
- ✅ Status changes to "approved" or "active"
- ✅ Approved badge visible
- ✅ Supplier can now access supplier portal

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

**Expected Result**:
- ✅ Rejection reason dialog/form appears
- ✅ Success message: "Supplier application rejected"
- ✅ Status changes to "rejected"
- ✅ Rejection reason visible in supplier details

**Pass/Fail**: ☐


---

## Test Case 5.9: Activate Supplier

**Prerequisites**: 
- Logged in as Super Admin or Supplier Admin
- Inactive supplier exists

**Steps**:
1. Navigate to supplier details
2. Click "Activate" button

**Expected Result**:
- ✅ Success message: "Supplier activated"
- ✅ Status changes to "active"
- ✅ Active badge visible

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

**Expected Result**:
- ✅ Success message: "Supplier deactivated"
- ✅ Status changes to "inactive"
- ✅ Inactive badge visible

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

**Expected Result**:
- ✅ Suspension reason dialog appears
- ✅ Success message: "Supplier suspended"
- ✅ Status changes to "suspended"
- ✅ Suspension reason visible

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

**Expected Result**:
- ✅ Tier update form displays
- ✅ Success message: "Supplier tier updated"
- ✅ New tier reflected in supplier details

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

**Expected Result**:
- ✅ Statistics displayed: Total Products, Active Products, Total Orders, Revenue, etc.
- ✅ Charts/graphs show supplier performance (if implemented)

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

**Expected Result**:
- ✅ Documents list displays
- ✅ Each document shows: Type, Status, Upload Date
- ✅ Documents are downloadable/viewable
- ✅ Approve/Reject buttons for each document (if pending)

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

**Expected Result**:
- ✅ Document opens in viewer or downloads
- ✅ Approve/Reject buttons visible
- ✅ Success message after action
- ✅ Document status updates

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

**Expected Result**:
- ✅ Products list displays
- ✅ Each product shows: Name, SKU, Price, Status, Stock
- ✅ Click on product navigates to product details
- ✅ Products sorted by most recent first

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

**Expected Result**:
- ✅ Confirmation dialog appears
- ✅ Success message: "Supplier deleted successfully"
- ✅ Redirects to supplier list
- ✅ Deleted supplier no longer in list

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

**Expected Result**:
- ✅ Search bar visible
- ✅ Results filter as typing
- ✅ Results highlight search term
- ✅ "No results" message if no matches

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

**Expected Result**:
- ✅ Status filter visible
- ✅ Filtering works correctly
- ✅ Status badges visible in list

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

**Expected Result**:
- ✅ Tier filter visible
- ✅ Filtering works correctly
- ✅ Tier badges visible in list

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

**Expected Result**:
- ✅ Column headers are clickable
- ✅ Sort indicator shows
- ✅ List sorts correctly

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

**Expected Result**:
- ✅ Pagination controls visible
- ✅ Current page highlighted
- ✅ Results update correctly

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

**Expected Result**:
- ✅ Checkboxes visible
- ✅ "Select All" works
- ✅ Bulk action dropdown appears
- ✅ Success message: "X suppliers updated"

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

**Expected Result**:
- ✅ Export button visible
- ✅ File downloads (CSV/Excel)
- ✅ File contains supplier data

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

**Expected Result**:
- ✅ Payments list displays
- ✅ Each payment shows: Amount, Date, Status, Payment Method
- ✅ Payments sorted by most recent first

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

**Expected Result**:
- ✅ Payment form displays
- ✅ Success message: "Payment created successfully"
- ✅ Payment appears in list

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

**Expected Result**:
- ✅ Success message: "Payout processed successfully"
- ✅ Payment status changes to "paid"
- ✅ Payment date set

**Pass/Fail**: ☐


---

## Test Case 5.28: Supplier Management - Mobile Responsive

**Prerequisites**: 
- Logged in as Super Admin or Supplier Admin

**Steps**:
1. Open Supplier Management on mobile device
2. Test all features

**Expected Result**:
- ✅ List displays correctly on mobile
- ✅ Forms are usable
- ✅ Buttons properly sized
- ✅ No horizontal scrolling

**Pass/Fail**: ☐


---

## Test Case 5.29: Supplier Management - Error Handling

**Prerequisites**: 
- Logged in as Super Admin or Supplier Admin

**Steps**:
1. Stop backend server
2. Try to load supplier list
3. Check error handling

**Expected Result**:
- ✅ Error message: "Unable to load suppliers"
- ✅ User-friendly error

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

**Expected Result**:
- ✅ All validations work
- ✅ Error messages clear
- ✅ Form doesn't submit with errors

**Pass/Fail**: ☐


---

## Test Case 5.31: Supplier Management - Loading States

**Prerequisites**: 
- Logged in as Super Admin or Supplier Admin

**Steps**:
1. Navigate to Supplier Management
2. Perform actions
3. Observe loading states

**Expected Result**:
- ✅ Loading indicators show
- ✅ Buttons disabled during submission
- ✅ No double submissions

**Pass/Fail**: ☐


---

## Test Case 5.32: Supplier Management - Success Messages

**Prerequisites**: 
- Logged in as Super Admin or Supplier Admin

**Steps**:
1. Create/Update/Delete suppliers
2. Check success messages

**Expected Result**:
- ✅ Success messages appear
- ✅ Messages are clear
- ✅ Messages auto-dismiss

**Pass/Fail**: ☐


---

## Test Case 5.33: Supplier Management - Audit Trail

**Prerequisites**: 
- Logged in as Super Admin or Supplier Admin

**Steps**:
1. Perform supplier management actions
2. Check activity log

**Expected Result**:
- ✅ Activity log shows actions
- ✅ Shows: Action, Admin, Target Supplier, Timestamp

**Pass/Fail**: ☐


---

## Test Case 5.34: Supplier Management - Empty State

**Prerequisites**: 
- Logged in as Super Admin or Supplier Admin
- No suppliers exist

**Steps**:
1. Navigate to Supplier Management
2. Check empty state

**Expected Result**:
- ✅ Empty state message: "No suppliers found"
- ✅ Helpful message
- ✅ No errors

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

**Expected Result**:
- ✅ Page loads in reasonable time
- ✅ Search/filter/sort work efficiently
- ✅ No performance issues

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

**Pass/Fail**: ☐ (for each)


---

