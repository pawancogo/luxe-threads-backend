# 02. Dashboard Testing

## 🎯 Overview
Test from the **Backend (BE)** perspective.

**Testing Focus**: API responses, data persistence, business logic, database operations, and backend behavior.

**Estimated Time**: 20-30 minutes  
**Test Cases**: ~25

---

## Test Case 2.1: Dashboard - Super Admin Access => Tested by pawan 

**Prerequisites**: 
- Logged in as Super Admin

**Steps**:
1. After login, verify redirect to `/admin/dashboard`
2. Check dashboard loads

**Expected Result**:
- ✅ API: `GET /api/v1/admin/dashboard` returns 200
- ✅ Response contains dashboard data: metrics, stats, recent items
- ✅ Response time < 2 seconds

**Pass/Fail**: ☐


---

## Test Case 2.2: Dashboard - Metrics Cards Display => Tested by pawan 

**Prerequisites**: 
- Logged in as Super Admin
- Some test data exists (users, orders, products, suppliers)

**Steps**:
1. Navigate to dashboard
2. Check all metric cards display

**Expected Result**:
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

**Expected Result**:
- ✅ Revenue calculated correctly from orders
- ✅ Only paid/completed orders counted
- ✅ Currency conversion correct (if multi-currency)

**Pass/Fail**: ☐


---

## Test Case 2.4: Dashboard - Recent Orders List => Tested by pawan 

**Prerequisites**: 
- Logged in as Super Admin
- Recent orders exist

**Steps**:
1. Navigate to dashboard
2. Check "Recent Orders" section

**Expected Result**:
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

**Expected Result**:
- ✅ API returns recent users ordered by `created_at DESC`
- ✅ Limit applied correctly

**Pass/Fail**: ☐


---

## Test Case 2.6: Dashboard - Recent Products List => Tested by pawan 

**Prerequisites**: 
- Logged in as Super Admin
- Recent products exist

**Steps**:
1. Navigate to dashboard
2. Check "Recent Products" section

**Expected Result**:
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

**Expected Result**:
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

**Expected Result**:
- ✅ API accepts date range parameters
- ✅ Metrics filtered correctly by date range
- ✅ Response time acceptable

**Pass/Fail**: ☐


---

## Test Case 2.9: Dashboard - Product Admin View =>Tested by pawan 

**Prerequisites**: 
- Logged in as Product Admin

**Steps**:
1. Navigate to dashboard
2. Check dashboard content

**Expected Result**:
- ✅ API returns only product-related metrics
- ✅ Role-based filtering applied

**Pass/Fail**: ☐


---

## Test Case 2.10: Dashboard - Order Admin View =>Tested by pawan 

**Prerequisites**: 
- Logged in as Order Admin

**Steps**:
1. Navigate to dashboard
2. Check dashboard content

**Expected Result**:
- ✅ API returns only order-related metrics
- ✅ Role-based filtering applied

**Pass/Fail**: ☐


---

## Test Case 2.11: Dashboard - User Admin View =>Tested by pawan 

**Prerequisites**: 
- Logged in as User Admin

**Steps**:
1. Navigate to dashboard
2. Check dashboard content

**Expected Result**:
- ✅ API returns only user-related metrics
- ✅ Role-based filtering applied

**Pass/Fail**: ☐


---

## Test Case 2.12: Dashboard - Supplier Admin View =>Tested by pawan 

**Prerequisites**: 
- Logged in as Supplier Admin

**Steps**:
1. Navigate to dashboard
2. Check dashboard content

**Expected Result**:
- ✅ API returns only supplier-related metrics
- ✅ Role-based filtering applied

**Pass/Fail**: ☐


---

## Test Case 2.13: Dashboard - Empty State (No Data) =>Tested by pawan 

**Prerequisites**: 
- Logged in as Super Admin
- Fresh database with no data

**Steps**:
1. Navigate to dashboard
2. Check empty state

**Expected Result**:
- ✅ API returns 0 values or empty arrays
- ✅ No errors thrown
- ✅ Response structure consistent

**Pass/Fail**: ☐


---

## Test Case 2.14: Dashboard - Real-time Updates =>Tested by pawan 

**Prerequisites**: 
- Logged in as Super Admin
- Dashboard open in browser

**Steps**:
1. Create a new order (via API or another browser)
2. Check if dashboard updates automatically

**Expected Result**:
- ✅ API returns latest data on each request
- ✅ No caching issues

**Pass/Fail**: ☐


---

## Test Case 2.15: Dashboard - Navigation Menu =>Tested by pawan 

**Prerequisites**: 
- Logged in as Super Admin

**Steps**:
1. Navigate to dashboard
2. Check navigation menu

**Expected Result**:
- ✅ Menu items based on user permissions
- ✅ API returns available menu items

**Pass/Fail**: ☐


---
 
## Test Case 2.16: Dashboard - Quick Actions =>Tested by pawan 

**Prerequisites**: 
- Logged in as Super Admin

**Steps**:
1. Navigate to dashboard
2. Check quick action buttons/links

**Expected Result**:
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

**Expected Result**:
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

**Expected Result**:
- ✅ N/A (server not responding)

**Pass/Fail**: ☐


---

## Test Case 2.19: Dashboard - Mobile Responsive => tested by pawan

**Prerequisites**: 
- Logged in as Super Admin

**Steps**:
1. Open dashboard on mobile device or resize to mobile
2. Check layout

**Expected Result**:
- ✅ Same as desktop (backend doesn't change)

**Pass/Fail**: ☐


---

## Test Case 2.20: Dashboard - Export Data=> tested by pawan

**Prerequisites**: 
- Logged in as Super Admin

**Steps**:
1. Navigate to dashboard
2. Click "Export" button (if exists)
3. Check export functionality

**Expected Result**:
- ✅ API: `GET /api/v1/admin/reports/export` returns file
- ✅ File format correct
- ✅ Data accurate

**Pass/Fail**: ☐


---

## Test Case 2.21: Dashboard - Activity Log=> tested by pawan

**Prerequisites**: 
- Logged in as Super Admin
- Some admin activities exist

**Steps**:
1. Navigate to dashboard
2. Check "Recent Activity" or "Activity Log" section

**Expected Result**:
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

**Expected Result**:
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

**Expected Result**:
- ✅ API: `GET /api/v1/admin/search?q=...` returns results
- ✅ Search works across multiple models
- ✅ Results ranked by relevance

**Pass/Fail**: ☐


---

## Test Case 2.24: Dashboard - Refresh Data => Tested by pawan

**Prerequisites**: 
- Logged in as Super Admin

**Steps**:
1. Navigate to dashboard
2. Click refresh button (if exists) or refresh page
3. Check data updates

**Expected Result**:
- ✅ API returns fresh data (not cached)
- ✅ Response time acceptable

**Pass/Fail**: ☐


---

## Test Case 2.25: Dashboard - Logout from Dashboard => Tested by pawan


**Prerequisites**: 
- Logged in as Super Admin
- On dashboard page

**Steps**:
1. Click logout button from dashboard
2. Verify logout

**Expected Result**:
- ✅ Session destroyed
- ✅ Token invalidated

**Pass/Fail**: ☐


---

