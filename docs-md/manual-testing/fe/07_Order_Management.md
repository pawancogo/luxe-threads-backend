# 07. Order Management Testing

## 🎯 Overview
Test from the **Frontend (FE)** perspective.

**Testing Focus**: UI/UX, form validation, navigation, error messages, user interactions, and frontend behavior.

**Estimated Time**: 50-60 minutes  
**Test Cases**: ~40

---

## Test Case 7.1: View All Orders - Super Admin

**Prerequisites**: 
- Logged in as Super Admin
- Multiple orders exist

**Steps**:
1. Navigate to `/admin/orders` or "Order Management" menu
2. Check order list displays

**Expected Result**:
- ✅ List shows all orders
- ✅ Each order shows: Order Number, Customer, Date, Amount, Status, Payment Status
- ✅ Table/list is sortable and searchable
- ✅ Pagination works
- ✅ Filter options visible (Status, Date Range, Payment Status, etc.)

**Pass/Fail**: ☐


---

## Test Case 7.2: View All Orders - Order Admin

**Prerequisites**: 
- Logged in as Order Admin

**Steps**:
1. Navigate to Order Management
2. Check access

**Expected Result**:
- ✅ Order list accessible
- ✅ Full order management features available

**Pass/Fail**: ☐


---

## Test Case 7.3: View Order Details

**Prerequisites**: 
- Logged in as Super Admin or Order Admin
- Order exists

**Steps**:
1. Navigate to Order Management
2. Click on an order from the list
3. View order details page

**Expected Result**:
- ✅ Order details page loads
- ✅ Shows: Order Info, Customer Info, Items, Shipping, Payment, Status History
- ✅ Shows: Order Notes, Tracking Info, Refund Info
- ✅ Edit, Cancel, Update Status, Refund buttons visible

**Pass/Fail**: ☐


---

## Test Case 7.4: Update Order Status - Valid Status

**Prerequisites**: 
- Logged in as Super Admin or Order Admin
- Order exists (e.g., status: "pending")

**Steps**:
1. Navigate to order details
2. Click "Update Status" or status dropdown
3. Select new status (e.g., "confirmed")
4. Submit

**Expected Result**:
- ✅ Status dropdown/form displays
- ✅ Available statuses shown based on current status
- ✅ Success message: "Order status updated"
- ✅ Status badge updates
- ✅ Status history updated

**Pass/Fail**: ☐


---

## Test Case 7.5: Update Order Status - Invalid Transition

**Prerequisites**: 
- Logged in as Super Admin or Order Admin
- Order with status "delivered" exists

**Steps**:
1. Navigate to order details
2. Try to change status to "pending" (invalid transition)

**Expected Result**:
- ✅ Invalid status option disabled OR
- ✅ Error message: "Cannot change status from delivered to pending"
- ✅ Status not updated

**Pass/Fail**: ☐


---

## Test Case 7.6: Cancel Order

**Prerequisites**: 
- Logged in as Super Admin or Order Admin
- Order with cancellable status exists (e.g., "pending", "confirmed")

**Steps**:
1. Navigate to order details
2. Click "Cancel Order" button
3. Enter cancellation reason
4. Confirm cancellation

**Expected Result**:
- ✅ Cancellation reason dialog/form appears
- ✅ Success message: "Order cancelled successfully"
- ✅ Status changes to "cancelled"
- ✅ Cancellation reason visible
- ✅ Refund processed (if payment made)

**Pass/Fail**: ☐


---

## Test Case 7.7: Cancel Order - Non-Cancellable Status

**Prerequisites**: 
- Logged in as Super Admin or Order Admin
- Order with status "delivered" exists

**Steps**:
1. Navigate to order details
2. Try to cancel order

**Expected Result**:
- ✅ Cancel button disabled OR
- ✅ Error message: "Cannot cancel delivered order"
- ✅ Order not cancelled

**Pass/Fail**: ☐


---

## Test Case 7.8: Add Order Note

**Prerequisites**: 
- Logged in as Super Admin or Order Admin
- Order exists

**Steps**:
1. Navigate to order details
2. Go to "Notes" section
3. Click "Add Note"
4. Enter note text
5. Submit

**Expected Result**:
- ✅ Note form displays
- ✅ Success message: "Note added successfully"
- ✅ Note appears in notes list
- ✅ Note shows: Text, Admin Name, Timestamp

**Pass/Fail**: ☐


---

## Test Case 7.9: View Order Notes

**Prerequisites**: 
- Logged in as Super Admin or Order Admin
- Order with notes exists

**Steps**:
1. Navigate to order details
2. Go to "Notes" section
3. View notes list

**Expected Result**:
- ✅ Notes list displays
- ✅ Each note shows: Text, Admin Name, Date/Time
- ✅ Notes sorted by most recent first
- ✅ Notes are readable and formatted

**Pass/Fail**: ☐


---

## Test Case 7.10: View Order Audit Log

**Prerequisites**: 
- Logged in as Super Admin or Order Admin
- Order with status changes exists

**Steps**:
1. Navigate to order details
2. Click "Audit Log" or "Status History" tab
3. View audit log

**Expected Result**:
- ✅ Audit log displays
- ✅ Shows: Action, Old Status, New Status, Admin, Timestamp
- ✅ History sorted by most recent first
- ✅ Complete change history visible

**Pass/Fail**: ☐


---

## Test Case 7.11: Process Refund

**Prerequisites**: 
- Logged in as Super Admin or Order Admin
- Paid order exists

**Steps**:
1. Navigate to order details
2. Click "Process Refund" button
3. Enter refund amount (full or partial)
4. Enter refund reason
5. Confirm refund

**Expected Result**:
- ✅ Refund form displays
- ✅ Order total and paid amount shown
- ✅ Refund amount validation (cannot exceed paid amount)
- ✅ Success message: "Refund processed successfully"
- ✅ Refund status updated
- ✅ Refund amount visible in order details

**Pass/Fail**: ☐


---

## Test Case 7.12: Process Refund - Amount Exceeds Paid

**Prerequisites**: 
- Logged in as Super Admin or Order Admin
- Paid order exists (e.g., paid: $100)

**Steps**:
1. Navigate to order details
2. Click "Process Refund"
3. Enter refund amount: $150 (exceeds paid)
4. Submit

**Expected Result**:
- ✅ Validation error: "Refund amount cannot exceed paid amount"
- ✅ Form does not submit
- ✅ Error shown near refund amount field

**Pass/Fail**: ☐


---

## Test Case 7.13: Edit Order - Update Shipping Address

**Prerequisites**: 
- Logged in as Super Admin or Order Admin
- Order with status "pending" exists

**Steps**:
1. Navigate to order details
2. Click "Edit" button
3. Update shipping address
4. Submit

**Expected Result**:
- ✅ Edit form displays
- ✅ Address fields editable
- ✅ Success message: "Order updated successfully"
- ✅ New address reflected in order details

**Pass/Fail**: ☐


---

## Test Case 7.14: Edit Order - Update Order Items

**Prerequisites**: 
- Logged in as Super Admin or Order Admin
- Order with status "pending" exists

**Steps**:
1. Navigate to order details
2. Click "Edit"
3. Add/remove/update order items
4. Submit

**Expected Result**:
- ✅ Order items editable
- ✅ Can add items from product catalog
- ✅ Can remove items
- ✅ Can update quantities
- ✅ Order total recalculated
- ✅ Success message: "Order updated successfully"

**Pass/Fail**: ☐


---

## Test Case 7.15: Edit Order - Non-Editable Status

**Prerequisites**: 
- Logged in as Super Admin or Order Admin
- Order with status "shipped" exists

**Steps**:
1. Navigate to order details
2. Try to edit order

**Expected Result**:
- ✅ Edit button disabled OR
- ✅ Error message: "Cannot edit shipped order"
- ✅ Order not editable

**Pass/Fail**: ☐


---

## Test Case 7.16: Delete Order

**Prerequisites**: 
- Logged in as Super Admin or Order Admin
- Order exists (check business rules - may not allow deletion)

**Steps**:
1. Navigate to order details
2. Click "Delete" button (if available)
3. Confirm deletion

**Expected Result**:
- ✅ Confirmation dialog appears
- ✅ Success message: "Order deleted successfully" (if deletion allowed)
- ✅ OR error: "Orders cannot be deleted" (if soft-delete only)

**Pass/Fail**: ☐


---

## Test Case 7.17: Search Orders

**Prerequisites**: 
- Logged in as Super Admin or Order Admin
- Multiple orders exist

**Steps**:
1. Navigate to Order Management
2. Use search bar
3. Search by order number, customer name, or email

**Expected Result**:
- ✅ Search bar visible
- ✅ Results filter as typing
- ✅ Results highlight search term
- ✅ "No results" message if no matches

**Pass/Fail**: ☐


---

## Test Case 7.18: Filter Orders by Status

**Prerequisites**: 
- Logged in as Super Admin or Order Admin
- Orders with different statuses exist

**Steps**:
1. Navigate to Order Management
2. Use status filter dropdown
3. Select status (Pending, Confirmed, Shipped, Delivered, etc.)
4. Check filtered results

**Expected Result**:
- ✅ Status filter visible
- ✅ Filtering works correctly
- ✅ Status badges visible in list

**Pass/Fail**: ☐


---

## Test Case 7.19: Filter Orders by Payment Status

**Prerequisites**: 
- Logged in as Super Admin or Order Admin
- Orders with different payment statuses exist

**Steps**:
1. Navigate to Order Management
2. Use payment status filter
3. Select payment status (Paid, Pending, Failed, Refunded)
4. Check filtered results

**Expected Result**:
- ✅ Payment status filter visible
- ✅ Filtering works correctly

**Pass/Fail**: ☐


---

## Test Case 7.20: Filter Orders by Date Range

**Prerequisites**: 
- Logged in as Super Admin or Order Admin
- Orders from different dates exist

**Steps**:
1. Navigate to Order Management
2. Use date range filter
3. Select date range (Today, Last 7 days, Last 30 days, Custom)
4. Check filtered results

**Expected Result**:
- ✅ Date range picker visible
- ✅ Filtering works correctly
- ✅ Results show only orders in date range

**Pass/Fail**: ☐


---

## Test Case 7.21: Sort Orders

**Prerequisites**: 
- Logged in as Super Admin or Order Admin
- Multiple orders exist

**Steps**:
1. Navigate to Order Management
2. Click column header to sort
3. Check sorting

**Expected Result**:
- ✅ Column headers are clickable
- ✅ Sort indicator shows
- ✅ List sorts correctly

**Pass/Fail**: ☐


---

## Test Case 7.22: Pagination - Order List

**Prerequisites**: 
- Logged in as Super Admin or Order Admin
- More than 20 orders exist

**Steps**:
1. Navigate to Order Management
2. Check pagination controls
3. Navigate to next page

**Expected Result**:
- ✅ Pagination controls visible
- ✅ Current page highlighted
- ✅ Results update correctly

**Pass/Fail**: ☐


---

## Test Case 7.23: View Order Tracking Information

**Prerequisites**: 
- Logged in as Super Admin or Order Admin
- Shipped order with tracking exists

**Steps**:
1. Navigate to order details
2. Go to "Tracking" section
3. View tracking information

**Expected Result**:
- ✅ Tracking number displayed
- ✅ Tracking URL/link visible (if available)
- ✅ Tracking events/history shown (if available)
- ✅ Estimated delivery date shown

**Pass/Fail**: ☐


---

## Test Case 7.24: Update Tracking Information

**Prerequisites**: 
- Logged in as Super Admin or Order Admin
- Shipped order exists

**Steps**:
1. Navigate to order details
2. Go to "Tracking" section
3. Click "Update Tracking"
4. Enter tracking number and carrier
5. Submit

**Expected Result**:
- ✅ Tracking form displays
- ✅ Success message: "Tracking updated successfully"
- ✅ Tracking information updated

**Pass/Fail**: ☐


---

## Test Case 7.25: Export Orders

**Prerequisites**: 
- Logged in as Super Admin or Order Admin
- Orders exist

**Steps**:
1. Navigate to Order Management
2. Click "Export" button
3. Check downloaded file

**Expected Result**:
- ✅ Export button visible
- ✅ File downloads (CSV/Excel)
- ✅ File contains order data

**Pass/Fail**: ☐


---

## Test Case 7.26: View Return Requests for Order

**Prerequisites**: 
- Logged in as Super Admin or Order Admin
- Order with return request exists

**Steps**:
1. Navigate to order details
2. Go to "Returns" section
3. View return requests

**Expected Result**:
- ✅ Return requests list displays
- ✅ Each return shows: Return ID, Item, Reason, Status, Date
- ✅ Click on return navigates to return details

**Pass/Fail**: ☐


---

## Test Case 7.27: Order Management - Mobile Responsive

**Prerequisites**: 
- Logged in as Super Admin or Order Admin

**Steps**:
1. Open Order Management on mobile device
2. Test all features

**Expected Result**:
- ✅ List displays correctly on mobile
- ✅ Forms are usable
- ✅ Buttons properly sized
- ✅ No horizontal scrolling

**Pass/Fail**: ☐


---

## Test Case 7.28: Order Management - Error Handling

**Prerequisites**: 
- Logged in as Super Admin or Order Admin

**Steps**:
1. Stop backend server
2. Try to load order list
3. Check error handling

**Expected Result**:
- ✅ Error message: "Unable to load orders"
- ✅ User-friendly error

**Pass/Fail**: ☐


---

## Test Case 7.29: Order Management - Loading States

**Prerequisites**: 
- Logged in as Super Admin or Order Admin

**Steps**:
1. Navigate to Order Management
2. Perform actions
3. Observe loading states

**Expected Result**:
- ✅ Loading indicators show
- ✅ Buttons disabled during submission
- ✅ No double submissions

**Pass/Fail**: ☐


---

## Test Case 7.30: Order Management - Success Messages

**Prerequisites**: 
- Logged in as Super Admin or Order Admin

**Steps**:
1. Update order status
2. Cancel order
3. Process refund
4. Check success messages

**Expected Result**:
- ✅ Success messages appear
- ✅ Messages are clear
- ✅ Messages auto-dismiss

**Pass/Fail**: ☐


---

## Test Case 7.31-7.40: Additional Order Features

**Test additional features:**
- Order printing/invoice generation
- Order email notifications
- Order status webhooks
- Order analytics
- Order fulfillment workflow
- Multi-item order management
- Order splitting
- Order merging
- Order notes history
- Order attachments

**Pass/Fail**: ☐ (for each)

---

## 📝 Notes Section

**Issues Found**:
- 

**Suggestions**:
- 

**Completed By**: _______________  
**Date**: _______________  
**Total Passed**: ___/40  
**Total Failed**: ___/40

**Pass/Fail**: ☐ (for each)


---

