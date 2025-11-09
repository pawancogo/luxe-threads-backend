# 07. Order Management Testing

## 🎯 Overview
Test from the **Backend (BE)** perspective.

**Testing Focus**: API responses, data persistence, business logic, database operations, and backend behavior.

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
- ✅ API: `GET /api/v1/admin/orders` returns 200
- ✅ Response contains array of orders
- ✅ Each order object has complete data

**Pass/Fail**: ☐


---

## Test Case 7.2: View All Orders - Order Admin

**Prerequisites**: 
- Logged in as Order Admin

**Steps**:
1. Navigate to Order Management
2. Check access

**Expected Result**:
- ✅ API: `GET /api/v1/admin/orders` returns 200
- ✅ Access granted

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
- ✅ API: `GET /api/v1/admin/orders/:id` returns 200
- ✅ Response contains complete order data
- ✅ Includes order items, customer, shipping, payment details

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
- ✅ API: `PATCH /api/v1/admin/orders/:id/update_status` returns 200
- ✅ Order status updated in database
- ✅ Status history entry created
- ✅ Status updated timestamp set
- ✅ Activity logged
- ✅ Notification sent to customer (if implemented)

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
- ✅ API returns 422 with validation error
- ✅ Status transition validation enforced
- ✅ Order status unchanged

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
- ✅ API: `PATCH /api/v1/admin/orders/:id/cancel` returns 200
- ✅ Order status updated to "cancelled"
- ✅ Cancellation reason saved
- ✅ Cancellation date/timestamp set
- ✅ Inventory restored (if applicable)
- ✅ Refund initiated (if payment made)
- ✅ Activity logged
- ✅ Notification sent to customer

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
- ✅ API returns 422 with validation error
- ✅ Business rule enforced
- ✅ Order status unchanged

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
- ✅ API: `POST /api/v1/admin/orders/:id/notes` returns 201
- ✅ Note saved in database
- ✅ Linked to order correctly
- ✅ Admin ID saved
- ✅ Timestamp set

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
- ✅ API returns order notes
- ✅ Notes filtered by order_id
- ✅ Includes admin information

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
- ✅ API: `GET /api/v1/admin/orders/:id/audit_log` returns 200
- ✅ Returns status history from `status_history` JSONB or audit log table
- ✅ Complete history included

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
- ✅ API: `PATCH /api/v1/admin/orders/:id/refund` returns 200
- ✅ Refund record created
- ✅ Payment refunded via payment gateway
- ✅ Refund amount saved
- ✅ Refund status tracked
- ✅ Activity logged
- ✅ Notification sent to customer

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
- ✅ API returns 422 with validation error
- ✅ No refund processed

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
- ✅ API: `PATCH /api/v1/admin/orders/:id` returns 200
- ✅ Shipping address updated
- ✅ Changes persisted
- ✅ Activity logged

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
- ✅ API returns 200
- ✅ Order items updated
- ✅ Order total recalculated
- ✅ Inventory adjusted (if applicable)
- ✅ Activity logged

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
- ✅ API returns 422 with validation error
- ✅ Business rule enforced
- ✅ Order unchanged

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
- ✅ API: `DELETE /api/v1/admin/orders/:id` returns 200 (if allowed)
- ✅ OR returns 422 if deletion not allowed
- ✅ Order deleted or soft-deleted
- ✅ Activity logged

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
- ✅ API: `GET /api/v1/admin/orders?search=...` returns filtered results
- ✅ Search works on order number, customer name, email
- ✅ Case-insensitive search

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
- ✅ API: `GET /api/v1/admin/orders?status=pending` returns filtered results
- ✅ Filter works correctly

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
- ✅ API: `GET /api/v1/admin/orders?payment_status=paid` returns filtered results
- ✅ Filter works correctly

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
- ✅ API: `GET /api/v1/admin/orders?start_date=...&end_date=...` returns filtered results
- ✅ Date filtering works correctly

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
- ✅ API: `GET /api/v1/admin/orders?sort=created_at&order=desc` returns sorted results
- ✅ Sorting works on all sortable columns

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
- ✅ API: `GET /api/v1/admin/orders?page=2` returns correct page
- ✅ Pagination metadata included

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
- ✅ API returns tracking information
- ✅ Tracking data from shipping provider (if integrated)

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
- ✅ API: `PATCH /api/v1/admin/orders/:id/tracking` returns 200
- ✅ Tracking information saved
- ✅ Activity logged

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
- ✅ API: `GET /api/v1/admin/orders/export` returns file
- ✅ File format correct
- ✅ All orders included (or filtered based on current view)

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
- ✅ API returns return requests for order
- ✅ Returns filtered by order_id

**Pass/Fail**: ☐


---

## Test Case 7.27: Order Management - Mobile Responsive

**Prerequisites**: 
- Logged in as Super Admin or Order Admin

**Steps**:
1. Open Order Management on mobile device
2. Test all features

**Expected Result**:
- ✅ Same as desktop

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
- ✅ N/A (server not responding)

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
- ✅ Requests processed normally

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
- ✅ Actions complete successfully

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

