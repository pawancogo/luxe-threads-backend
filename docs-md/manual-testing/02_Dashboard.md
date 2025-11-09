# 02. Dashboard Testing

## 🎯 Overview
Test admin dashboard, metrics, statistics, charts, and navigation.

**Estimated Time**: 20-30 minutes  
**Test Cases**: ~25

---

## Test Case 2.1: Dashboard - Super Admin Access

**Prerequisites**: 
- Logged in as Super Admin

**Steps**:
1. After login, verify redirect to `/admin/dashboard`
2. Check dashboard loads

**Expected Result (FE)**:
- ✅ Dashboard page loads successfully
- ✅ All sections visible: metrics, charts, recent activity
- ✅ Navigation menu visible
- ✅ Admin name/email shown in header
- ✅ No console errors

**Expected Result (BE)**:
- ✅ API: `GET /api/v1/admin/dashboard` returns 200
- ✅ Response contains dashboard data: metrics, stats, recent items
- ✅ Response time < 2 seconds

**Pass/Fail**: ☐

---

## Test Case 2.2: Dashboard - Metrics Cards Display

**Prerequisites**: 
- Logged in as Super Admin
- Some test data exists (users, orders, products, suppliers)

**Steps**:
1. Navigate to dashboard
2. Check all metric cards display

**Expected Result (FE)**:
- ✅ Cards show: Total Users, Total Orders, Total Products, Total Suppliers
- ✅ Cards show: Revenue, Pending Orders, Active Products, etc.
- ✅ Numbers formatted correctly (e.g., 1,234)
- ✅ Icons/colors appropriate for each metric
- ✅ Cards are responsive (mobile/desktop)

**Expected Result (BE)**:
- ✅ API returns correct counts from database
- ✅ Calculations are accurate
- ✅ Data is current (not cached incorrectly)

**Pass/Fail**: ☐

---

## Test Case 2.3: Dashboard - Revenue Metrics

**Prerequisites**: 
- Logged in as Super Admin
- Orders with payments exist

**Steps**:
1. Navigate to dashboard
2. Check revenue metrics

**Expected Result (FE)**:
- ✅ Today's Revenue displays
- ✅ This Week's Revenue displays
- ✅ This Month's Revenue displays
- ✅ Total Revenue displays
- ✅ Currency formatted correctly (e.g., $1,234.56 or ₹1,234.56)

**Expected Result (BE)**:
- ✅ Revenue calculated correctly from orders
- ✅ Only paid/completed orders counted
- ✅ Currency conversion correct (if multi-currency)

**Pass/Fail**: ☐

---

## Test Case 2.4: Dashboard - Recent Orders List

**Prerequisites**: 
- Logged in as Super Admin
- Recent orders exist

**Steps**:
1. Navigate to dashboard
2. Check "Recent Orders" section

**Expected Result (FE)**:
- ✅ List shows last 5-10 orders
- ✅ Each order shows: Order ID, Customer Name, Amount, Status, Date
- ✅ Orders sorted by most recent first
- ✅ Click on order navigates to order details
- ✅ Status badges colored appropriately

**Expected Result (BE)**:
- ✅ API returns recent orders ordered by `created_at DESC`
- ✅ Limit applied correctly (e.g., limit 10)
- ✅ Order data includes all necessary fields

**Pass/Fail**: ☐

---

## Test Case 2.5: Dashboard - Recent Users List

**Prerequisites**: 
- Logged in as Super Admin
- Recent users exist

**Steps**:
1. Navigate to dashboard
2. Check "Recent Users" section

**Expected Result (FE)**:
- ✅ List shows last 5-10 users
- ✅ Each user shows: Name, Email, Registration Date, Status
- ✅ Users sorted by most recent first
- ✅ Click on user navigates to user details

**Expected Result (BE)**:
- ✅ API returns recent users ordered by `created_at DESC`
- ✅ Limit applied correctly

**Pass/Fail**: ☐

---

## Test Case 2.6: Dashboard - Recent Products List

**Prerequisites**: 
- Logged in as Super Admin
- Recent products exist

**Steps**:
1. Navigate to dashboard
2. Check "Recent Products" section

**Expected Result (FE)**:
- ✅ List shows last 5-10 products
- ✅ Each product shows: Name, SKU, Price, Status, Supplier
- ✅ Products sorted by most recent first
- ✅ Click on product navigates to product details

**Expected Result (BE)**:
- ✅ API returns recent products ordered by `created_at DESC`
- ✅ Limit applied correctly

**Pass/Fail**: ☐

---

## Test Case 2.7: Dashboard - Charts/Graphs Display

**Prerequisites**: 
- Logged in as Super Admin
- Historical data exists (orders, revenue over time)

**Steps**:
1. Navigate to dashboard
2. Check charts/graphs section

**Expected Result (FE)**:
- ✅ Sales chart displays (line/bar chart)
- ✅ Chart shows data for selected period (Last 7 days, 30 days, etc.)
- ✅ Chart is interactive (hover shows values)
- ✅ Chart is responsive
- ✅ Chart library loads correctly (no errors)

**Expected Result (BE)**:
- ✅ API returns chart data in correct format
- ✅ Data aggregated correctly by date
- ✅ Date range filtering works

**Pass/Fail**: ☐

---

## Test Case 2.8: Dashboard - Date Range Filter

**Prerequisites**: 
- Logged in as Super Admin

**Steps**:
1. Navigate to dashboard
2. Select different date range (Last 7 days, 30 days, 90 days, Custom)
3. Check metrics update

**Expected Result (FE)**:
- ✅ Date range selector visible
- ✅ Selecting range updates metrics
- ✅ Loading state shows during update
- ✅ Charts update with new data

**Expected Result (BE)**:
- ✅ API accepts date range parameters
- ✅ Metrics filtered correctly by date range
- ✅ Response time acceptable

**Pass/Fail**: ☐

---

## Test Case 2.9: Dashboard - Product Admin View

**Prerequisites**: 
- Logged in as Product Admin

**Steps**:
1. Navigate to dashboard
2. Check dashboard content

**Expected Result (FE)**:
- ✅ Dashboard shows product-focused metrics
- ✅ Shows: Total Products, Pending Products, Active Products, Low Stock Alerts
- ✅ Recent Products section visible
- ✅ User/Order metrics NOT visible (if restricted)
- ✅ Navigation shows only product-related menus

**Expected Result (BE)**:
- ✅ API returns only product-related metrics
- ✅ Role-based filtering applied

**Pass/Fail**: ☐

---

## Test Case 2.10: Dashboard - Order Admin View

**Prerequisites**: 
- Logged in as Order Admin

**Steps**:
1. Navigate to dashboard
2. Check dashboard content

**Expected Result (FE)**:
- ✅ Dashboard shows order-focused metrics
- ✅ Shows: Total Orders, Pending Orders, Shipped Orders, Returns
- ✅ Recent Orders section visible
- ✅ Product/User metrics NOT visible (if restricted)

**Expected Result (BE)**:
- ✅ API returns only order-related metrics
- ✅ Role-based filtering applied

**Pass/Fail**: ☐

---

## Test Case 2.11: Dashboard - User Admin View

**Prerequisites**: 
- Logged in as User Admin

**Steps**:
1. Navigate to dashboard
2. Check dashboard content

**Expected Result (FE)**:
- ✅ Dashboard shows user-focused metrics
- ✅ Shows: Total Users, Active Users, New Users (this month)
- ✅ Recent Users section visible
- ✅ Product/Order metrics NOT visible (if restricted)

**Expected Result (BE)**:
- ✅ API returns only user-related metrics
- ✅ Role-based filtering applied

**Pass/Fail**: ☐

---

## Test Case 2.12: Dashboard - Supplier Admin View

**Prerequisites**: 
- Logged in as Supplier Admin

**Steps**:
1. Navigate to dashboard
2. Check dashboard content

**Expected Result (FE)**:
- ✅ Dashboard shows supplier-focused metrics
- ✅ Shows: Total Suppliers, Active Suppliers, Pending Approvals
- ✅ Recent Suppliers section visible
- ✅ Other metrics NOT visible (if restricted)

**Expected Result (BE)**:
- ✅ API returns only supplier-related metrics
- ✅ Role-based filtering applied

**Pass/Fail**: ☐

---

## Test Case 2.13: Dashboard - Empty State (No Data)

**Prerequisites**: 
- Logged in as Super Admin
- Fresh database with no data

**Steps**:
1. Navigate to dashboard
2. Check empty state

**Expected Result (FE)**:
- ✅ Metrics show 0 or "No data"
- ✅ Empty state message: "No data available" or similar
- ✅ No errors displayed
- ✅ Dashboard still loads successfully

**Expected Result (BE)**:
- ✅ API returns 0 values or empty arrays
- ✅ No errors thrown
- ✅ Response structure consistent

**Pass/Fail**: ☐

---

## Test Case 2.14: Dashboard - Real-time Updates

**Prerequisites**: 
- Logged in as Super Admin
- Dashboard open in browser

**Steps**:
1. Create a new order (via API or another browser)
2. Check if dashboard updates automatically

**Expected Result (FE)**:
- ✅ Dashboard auto-refreshes (if implemented)
- ✅ Or manual refresh button available
- ✅ New data appears after refresh

**Expected Result (BE)**:
- ✅ API returns latest data on each request
- ✅ No caching issues

**Pass/Fail**: ☐

---

## Test Case 2.15: Dashboard - Navigation Menu

**Prerequisites**: 
- Logged in as Super Admin

**Steps**:
1. Navigate to dashboard
2. Check navigation menu

**Expected Result (FE)**:
- ✅ Menu shows all available sections:
  - Dashboard (active)
  - Users
  - Suppliers
  - Products
  - Orders
  - Reports
  - Settings
  - etc.
- ✅ Menu items are clickable
- ✅ Active page highlighted
- ✅ Menu is responsive (mobile hamburger menu)

**Expected Result (BE)**:
- ✅ Menu items based on user permissions
- ✅ API returns available menu items

**Pass/Fail**: ☐

---

## Test Case 2.16: Dashboard - Quick Actions

**Prerequisites**: 
- Logged in as Super Admin

**Steps**:
1. Navigate to dashboard
2. Check quick action buttons/links

**Expected Result (FE)**:
- ✅ Quick actions visible: "Add Product", "Create Order", "Add User", etc.
- ✅ Clicking actions navigates to correct page
- ✅ Actions are role-appropriate

**Expected Result (BE)**:
- ✅ Navigation routes work correctly
- ✅ Permissions checked for actions

**Pass/Fail**: ☐

---

## Test Case 2.17: Dashboard - Performance

**Prerequisites**: 
- Logged in as Super Admin
- Large dataset exists

**Steps**:
1. Navigate to dashboard
2. Measure load time
3. Check browser console for errors

**Expected Result (FE)**:
- ✅ Dashboard loads in < 3 seconds
- ✅ No JavaScript errors in console
- ✅ No slow queries warnings
- ✅ Smooth scrolling and interactions

**Expected Result (BE)**:
- ✅ API response time < 2 seconds
- ✅ Database queries optimized
- ✅ No N+1 query problems

**Pass/Fail**: ☐

---

## Test Case 2.18: Dashboard - Error Handling

**Prerequisites**: 
- Logged in as Super Admin

**Steps**:
1. Stop backend server
2. Navigate to dashboard
3. Check error handling

**Expected Result (FE)**:
- ✅ Error message displays: "Unable to load dashboard data"
- ✅ User-friendly error message
- ✅ Retry button available (if implemented)
- ✅ No technical error exposed

**Expected Result (BE)**:
- ✅ N/A (server not responding)

**Pass/Fail**: ☐

---

## Test Case 2.19: Dashboard - Mobile Responsive

**Prerequisites**: 
- Logged in as Super Admin

**Steps**:
1. Open dashboard on mobile device or resize to mobile
2. Check layout

**Expected Result (FE)**:
- ✅ Dashboard displays correctly on mobile
- ✅ Metrics cards stack vertically
- ✅ Charts resize appropriately
- ✅ Navigation menu becomes hamburger menu
- ✅ No horizontal scrolling
- ✅ Touch interactions work

**Expected Result (BE)**:
- ✅ Same as desktop (backend doesn't change)

**Pass/Fail**: ☐

---

## Test Case 2.20: Dashboard - Export Data

**Prerequisites**: 
- Logged in as Super Admin

**Steps**:
1. Navigate to dashboard
2. Click "Export" button (if exists)
3. Check export functionality

**Expected Result (FE)**:
- ✅ Export button visible
- ✅ Clicking export downloads file (CSV/Excel)
- ✅ File contains dashboard data
- ✅ File name includes date/timestamp

**Expected Result (BE)**:
- ✅ API: `GET /api/v1/admin/reports/export` returns file
- ✅ File format correct
- ✅ Data accurate

**Pass/Fail**: ☐

---

## Test Case 2.21: Dashboard - Activity Log

**Prerequisites**: 
- Logged in as Super Admin
- Some admin activities exist

**Steps**:
1. Navigate to dashboard
2. Check "Recent Activity" or "Activity Log" section

**Expected Result (FE)**:
- ✅ Activity log displays recent admin actions
- ✅ Shows: Action, Admin Name, Timestamp, IP Address (if shown)
- ✅ Activities sorted by most recent first
- ✅ Click to view details (if implemented)

**Expected Result (BE)**:
- ✅ API returns recent activities from `admin_activities` table
- ✅ Activities logged correctly

**Pass/Fail**: ☐

---

## Test Case 2.22: Dashboard - Notifications

**Prerequisites**: 
- Logged in as Super Admin
- Pending items exist (pending orders, pending products, etc.)

**Steps**:
1. Navigate to dashboard
2. Check notification badges/alerts

**Expected Result (FE)**:
- ✅ Notification badges show counts (e.g., "5 pending orders")
- ✅ Badges are visible and styled
- ✅ Clicking badge navigates to relevant section
- ✅ Notifications clear after action

**Expected Result (BE)**:
- ✅ Counts calculated correctly
- ✅ Real-time updates (if implemented)

**Pass/Fail**: ☐

---

## Test Case 2.23: Dashboard - Search Functionality

**Prerequisites**: 
- Logged in as Super Admin

**Steps**:
1. Navigate to dashboard
2. Use search bar (if exists) to search for orders/users/products
3. Check results

**Expected Result (FE)**:
- ✅ Search bar visible in header/navbar
- ✅ Search works across entities
- ✅ Results display in dropdown or separate page
- ✅ Search is responsive (shows results as typing)

**Expected Result (BE)**:
- ✅ API: `GET /api/v1/admin/search?q=...` returns results
- ✅ Search works across multiple models
- ✅ Results ranked by relevance

**Pass/Fail**: ☐

---

## Test Case 2.24: Dashboard - Refresh Data

**Prerequisites**: 
- Logged in as Super Admin

**Steps**:
1. Navigate to dashboard
2. Click refresh button (if exists) or refresh page
3. Check data updates

**Expected Result (FE)**:
- ✅ Refresh button visible (if implemented)
- ✅ Clicking refresh reloads data
- ✅ Loading indicator shows during refresh
- ✅ Data updates correctly

**Expected Result (BE)**:
- ✅ API returns fresh data (not cached)
- ✅ Response time acceptable

**Pass/Fail**: ☐

---

## Test Case 2.25: Dashboard - Logout from Dashboard

**Prerequisites**: 
- Logged in as Super Admin
- On dashboard page

**Steps**:
1. Click logout button from dashboard
2. Verify logout

**Expected Result (FE)**:
- ✅ Logout button accessible from dashboard
- ✅ Logout works correctly
- ✅ Redirects to login page

**Expected Result (BE)**:
- ✅ Session destroyed
- ✅ Token invalidated

**Pass/Fail**: ☐

---

## 📝 Notes Section

**Issues Found**:
- 

**Suggestions**:
- 

**Completed By**: _______________  
**Date**: _______________  
**Total Passed**: ___/25  
**Total Failed**: ___/25

