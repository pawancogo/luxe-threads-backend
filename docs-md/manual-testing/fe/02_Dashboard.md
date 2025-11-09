# 02. Dashboard Testing

## 🎯 Overview
Test from the **Frontend (FE)** perspective.

**Testing Focus**: UI/UX, form validation, navigation, error messages, user interactions, and frontend behavior.

**Estimated Time**: 20-30 minutes  
**Test Cases**: ~25

---

## Test Case 2.1: Dashboard - Super Admin Access

**Prerequisites**: 
- Logged in as Super Admin

**Steps**:
1. After login, verify redirect to `/admin/dashboard`
2. Check dashboard loads

**Expected Result**:
- ✅ Dashboard page loads successfully
- ✅ All sections visible: metrics, charts, recent activity
- ✅ Navigation menu visible
- ✅ Admin name/email shown in header
- ✅ No console errors

**Pass/Fail**: ☐


---

## Test Case 2.2: Dashboard - Metrics Cards Display

**Prerequisites**: 
- Logged in as Super Admin
- Some test data exists (users, orders, products, suppliers)

**Steps**:
1. Navigate to dashboard
2. Check all metric cards display

**Expected Result**:
- ✅ Cards show: Total Users, Total Orders, Total Products, Total Suppliers
- ✅ Cards show: Revenue, Pending Orders, Active Products, etc.
- ✅ Numbers formatted correctly (e.g., 1,234)
- ✅ Icons/colors appropriate for each metric
- ✅ Cards are responsive (mobile/desktop)

**Pass/Fail**: ☐


---

## Test Case 2.3: Dashboard - Revenue Metrics

**Prerequisites**: 
- Logged in as Super Admin
- Orders with payments exist

**Steps**:
1. Navigate to dashboard
2. Check revenue metrics

**Expected Result**:
- ✅ Today's Revenue displays
- ✅ This Week's Revenue displays
- ✅ This Month's Revenue displays
- ✅ Total Revenue displays
- ✅ Currency formatted correctly (e.g., $1,234.56 or ₹1,234.56)

**Pass/Fail**: ☐


---

## Test Case 2.4: Dashboard - Recent Orders List

**Prerequisites**: 
- Logged in as Super Admin
- Recent orders exist

**Steps**:
1. Navigate to dashboard
2. Check "Recent Orders" section

**Expected Result**:
- ✅ List shows last 5-10 orders
- ✅ Each order shows: Order ID, Customer Name, Amount, Status, Date
- ✅ Orders sorted by most recent first
- ✅ Click on order navigates to order details
- ✅ Status badges colored appropriately

**Pass/Fail**: ☐


---

## Test Case 2.5: Dashboard - Recent Users List

**Prerequisites**: 
- Logged in as Super Admin
- Recent users exist

**Steps**:
1. Navigate to dashboard
2. Check "Recent Users" section

**Expected Result**:
- ✅ List shows last 5-10 users
- ✅ Each user shows: Name, Email, Registration Date, Status
- ✅ Users sorted by most recent first
- ✅ Click on user navigates to user details

**Pass/Fail**: ☐


---

## Test Case 2.6: Dashboard - Recent Products List

**Prerequisites**: 
- Logged in as Super Admin
- Recent products exist

**Steps**:
1. Navigate to dashboard
2. Check "Recent Products" section

**Expected Result**:
- ✅ List shows last 5-10 products
- ✅ Each product shows: Name, SKU, Price, Status, Supplier
- ✅ Products sorted by most recent first
- ✅ Click on product navigates to product details

**Pass/Fail**: ☐


---

## Test Case 2.7: Dashboard - Charts/Graphs Display

**Prerequisites**: 
- Logged in as Super Admin
- Historical data exists (orders, revenue over time)

**Steps**:
1. Navigate to dashboard
2. Check charts/graphs section

**Expected Result**:
- ✅ Sales chart displays (line/bar chart)
- ✅ Chart shows data for selected period (Last 7 days, 30 days, etc.)
- ✅ Chart is interactive (hover shows values)
- ✅ Chart is responsive
- ✅ Chart library loads correctly (no errors)

**Pass/Fail**: ☐


---

## Test Case 2.8: Dashboard - Date Range Filter

**Prerequisites**: 
- Logged in as Super Admin

**Steps**:
1. Navigate to dashboard
2. Select different date range (Last 7 days, 30 days, 90 days, Custom)
3. Check metrics update

**Expected Result**:
- ✅ Date range selector visible
- ✅ Selecting range updates metrics
- ✅ Loading state shows during update
- ✅ Charts update with new data

**Pass/Fail**: ☐


---

## Test Case 2.9: Dashboard - Product Admin View

**Prerequisites**: 
- Logged in as Product Admin

**Steps**:
1. Navigate to dashboard
2. Check dashboard content

**Expected Result**:
- ✅ Dashboard shows product-focused metrics
- ✅ Shows: Total Products, Pending Products, Active Products, Low Stock Alerts
- ✅ Recent Products section visible
- ✅ User/Order metrics NOT visible (if restricted)
- ✅ Navigation shows only product-related menus

**Pass/Fail**: ☐


---

## Test Case 2.10: Dashboard - Order Admin View

**Prerequisites**: 
- Logged in as Order Admin

**Steps**:
1. Navigate to dashboard
2. Check dashboard content

**Expected Result**:
- ✅ Dashboard shows order-focused metrics
- ✅ Shows: Total Orders, Pending Orders, Shipped Orders, Returns
- ✅ Recent Orders section visible
- ✅ Product/User metrics NOT visible (if restricted)

**Pass/Fail**: ☐


---

## Test Case 2.11: Dashboard - User Admin View

**Prerequisites**: 
- Logged in as User Admin

**Steps**:
1. Navigate to dashboard
2. Check dashboard content

**Expected Result**:
- ✅ Dashboard shows user-focused metrics
- ✅ Shows: Total Users, Active Users, New Users (this month)
- ✅ Recent Users section visible
- ✅ Product/Order metrics NOT visible (if restricted)

**Pass/Fail**: ☐


---

## Test Case 2.12: Dashboard - Supplier Admin View

**Prerequisites**: 
- Logged in as Supplier Admin

**Steps**:
1. Navigate to dashboard
2. Check dashboard content

**Expected Result**:
- ✅ Dashboard shows supplier-focused metrics
- ✅ Shows: Total Suppliers, Active Suppliers, Pending Approvals
- ✅ Recent Suppliers section visible
- ✅ Other metrics NOT visible (if restricted)

**Pass/Fail**: ☐


---

## Test Case 2.13: Dashboard - Empty State (No Data)

**Prerequisites**: 
- Logged in as Super Admin
- Fresh database with no data

**Steps**:
1. Navigate to dashboard
2. Check empty state

**Expected Result**:
- ✅ Metrics show 0 or "No data"
- ✅ Empty state message: "No data available" or similar
- ✅ No errors displayed
- ✅ Dashboard still loads successfully

**Pass/Fail**: ☐


---

## Test Case 2.14: Dashboard - Real-time Updates

**Prerequisites**: 
- Logged in as Super Admin
- Dashboard open in browser

**Steps**:
1. Create a new order (via API or another browser)
2. Check if dashboard updates automatically

**Expected Result**:
- ✅ Dashboard auto-refreshes (if implemented)
- ✅ Or manual refresh button available
- ✅ New data appears after refresh

**Pass/Fail**: ☐


---

## Test Case 2.15: Dashboard - Navigation Menu

**Prerequisites**: 
- Logged in as Super Admin

**Steps**:
1. Navigate to dashboard
2. Check navigation menu

**Expected Result**:
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

**Pass/Fail**: ☐


---

## Test Case 2.16: Dashboard - Quick Actions

**Prerequisites**: 
- Logged in as Super Admin

**Steps**:
1. Navigate to dashboard
2. Check quick action buttons/links

**Expected Result**:
- ✅ Quick actions visible: "Add Product", "Create Order", "Add User", etc.
- ✅ Clicking actions navigates to correct page
- ✅ Actions are role-appropriate

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

**Expected Result**:
- ✅ Dashboard loads in < 3 seconds
- ✅ No JavaScript errors in console
- ✅ No slow queries warnings
- ✅ Smooth scrolling and interactions

**Pass/Fail**: ☐


---

## Test Case 2.18: Dashboard - Error Handling

**Prerequisites**: 
- Logged in as Super Admin

**Steps**:
1. Stop backend server
2. Navigate to dashboard
3. Check error handling

**Expected Result**:
- ✅ Error message displays: "Unable to load dashboard data"
- ✅ User-friendly error message
- ✅ Retry button available (if implemented)
- ✅ No technical error exposed

**Pass/Fail**: ☐


---

## Test Case 2.19: Dashboard - Mobile Responsive

**Prerequisites**: 
- Logged in as Super Admin

**Steps**:
1. Open dashboard on mobile device or resize to mobile
2. Check layout

**Expected Result**:
- ✅ Dashboard displays correctly on mobile
- ✅ Metrics cards stack vertically
- ✅ Charts resize appropriately
- ✅ Navigation menu becomes hamburger menu
- ✅ No horizontal scrolling
- ✅ Touch interactions work

**Pass/Fail**: ☐


---

## Test Case 2.20: Dashboard - Export Data

**Prerequisites**: 
- Logged in as Super Admin

**Steps**:
1. Navigate to dashboard
2. Click "Export" button (if exists)
3. Check export functionality

**Expected Result**:
- ✅ Export button visible
- ✅ Clicking export downloads file (CSV/Excel)
- ✅ File contains dashboard data
- ✅ File name includes date/timestamp

**Pass/Fail**: ☐


---

## Test Case 2.21: Dashboard - Activity Log

**Prerequisites**: 
- Logged in as Super Admin
- Some admin activities exist

**Steps**:
1. Navigate to dashboard
2. Check "Recent Activity" or "Activity Log" section

**Expected Result**:
- ✅ Activity log displays recent admin actions
- ✅ Shows: Action, Admin Name, Timestamp, IP Address (if shown)
- ✅ Activities sorted by most recent first
- ✅ Click to view details (if implemented)

**Pass/Fail**: ☐


---

## Test Case 2.22: Dashboard - Notifications

**Prerequisites**: 
- Logged in as Super Admin
- Pending items exist (pending orders, pending products, etc.)

**Steps**:
1. Navigate to dashboard
2. Check notification badges/alerts

**Expected Result**:
- ✅ Notification badges show counts (e.g., "5 pending orders")
- ✅ Badges are visible and styled
- ✅ Clicking badge navigates to relevant section
- ✅ Notifications clear after action

**Pass/Fail**: ☐


---

## Test Case 2.23: Dashboard - Search Functionality

**Prerequisites**: 
- Logged in as Super Admin

**Steps**:
1. Navigate to dashboard
2. Use search bar (if exists) to search for orders/users/products
3. Check results

**Expected Result**:
- ✅ Search bar visible in header/navbar
- ✅ Search works across entities
- ✅ Results display in dropdown or separate page
- ✅ Search is responsive (shows results as typing)

**Pass/Fail**: ☐


---

## Test Case 2.24: Dashboard - Refresh Data

**Prerequisites**: 
- Logged in as Super Admin

**Steps**:
1. Navigate to dashboard
2. Click refresh button (if exists) or refresh page
3. Check data updates

**Expected Result**:
- ✅ Refresh button visible (if implemented)
- ✅ Clicking refresh reloads data
- ✅ Loading indicator shows during refresh
- ✅ Data updates correctly

**Pass/Fail**: ☐


---

## Test Case 2.25: Dashboard - Logout from Dashboard

**Prerequisites**: 
- Logged in as Super Admin
- On dashboard page

**Steps**:
1. Click logout button from dashboard
2. Verify logout

**Expected Result**:
- ✅ Logout button accessible from dashboard
- ✅ Logout works correctly
- ✅ Redirects to login page

**Pass/Fail**: ☐


---

