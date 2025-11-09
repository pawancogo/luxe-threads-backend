# 06. Product Management Testing

## 🎯 Overview
Test from the **Frontend (FE)** perspective.

**Testing Focus**: UI/UX, form validation, navigation, error messages, user interactions, and frontend behavior.

**Estimated Time**: 60-75 minutes  
**Test Cases**: ~50

---

## Test Case 6.1: View All Products - Super Admin

**Prerequisites**: 
- Logged in as Super Admin
- Multiple products exist

**Steps**:
1. Navigate to `/admin/products` or "Product Management" menu
2. Check product list displays

**Expected Result**:
- ✅ List shows all products
- ✅ Each product shows: Name, SKU, Price, Status, Supplier, Stock
- ✅ Product images visible (thumbnails)
- ✅ Table/list is sortable and searchable
- ✅ Pagination works
- ✅ Filter options visible (Status, Category, Supplier, etc.)

**Pass/Fail**: ☐


---

## Test Case 6.2: View All Products - Product Admin

**Prerequisites**: 
- Logged in as Product Admin

**Steps**:
1. Navigate to Product Management
2. Check access

**Expected Result**:
- ✅ Product list accessible
- ✅ Full product management features available

**Pass/Fail**: ☐


---

## Test Case 6.3: View Product Details

**Prerequisites**: 
- Logged in as Super Admin or Product Admin
- Product exists

**Steps**:
1. Navigate to Product Management
2. Click on a product from the list
3. View product details page

**Expected Result**:
- ✅ Product details page loads
- ✅ Shows: Basic Info, Description, Images, Variants, Pricing, Inventory
- ✅ Shows: Categories, Attributes, SEO, Status
- ✅ Edit, Delete, Approve/Reject buttons visible

**Pass/Fail**: ☐


---

## Test Case 6.4: Create New Product - Valid Data

**Prerequisites**: 
- Logged in as Super Admin or Product Admin
- Categories and brands exist

**Steps**:
1. Navigate to Product Management
2. Click "Create New Product" or "Add Product"
3. Fill form:
   - Name: "Test Product"
   - Description: "Test description"
   - Category: Select category
   - Brand: Select brand
   - Price: 99.99
   - Stock: 100
4. Submit form

**Expected Result**:
- ✅ Form displays correctly
- ✅ All required fields marked
- ✅ Category and brand dropdowns populated
- ✅ Success message: "Product created successfully"
- ✅ Redirects to product details or list
- ✅ New product appears in list

**Pass/Fail**: ☐


---

## Test Case 6.5: Create New Product - Missing Required Fields

**Prerequisites**: 
- Logged in as Super Admin or Product Admin

**Steps**:
1. Navigate to Create Product form
2. Leave required fields empty
3. Submit form

**Expected Result**:
- ✅ Validation errors shown for empty required fields
- ✅ Form does not submit
- ✅ Errors shown near relevant fields

**Pass/Fail**: ☐


---

## Test Case 6.6: Update Product - Valid Data

**Prerequisites**: 
- Logged in as Super Admin or Product Admin
- Product exists

**Steps**:
1. Navigate to product details
2. Click "Edit" button
3. Update name and description
4. Submit form

**Expected Result**:
- ✅ Edit form pre-filled with current data
- ✅ Success message: "Product updated successfully"
- ✅ Changes reflected in product details

**Pass/Fail**: ☐


---

## Test Case 6.7: Approve Product

**Prerequisites**: 
- Logged in as Super Admin or Product Admin
- Product with status "pending" exists

**Steps**:
1. Navigate to product details
2. Click "Approve" button
3. Confirm approval

**Expected Result**:
- ✅ Success message: "Product approved successfully"
- ✅ Status changes to "approved" or "active"
- ✅ Approved badge visible
- ✅ Product visible in public catalog (if applicable)

**Pass/Fail**: ☐


---

## Test Case 6.8: Reject Product

**Prerequisites**: 
- Logged in as Super Admin or Product Admin
- Product with status "pending" exists

**Steps**:
1. Navigate to product details
2. Click "Reject" button
3. Enter rejection reason
4. Confirm rejection

**Expected Result**:
- ✅ Rejection reason dialog/form appears
- ✅ Success message: "Product rejected"
- ✅ Status changes to "rejected"
- ✅ Rejection reason visible in product details

**Pass/Fail**: ☐


---

## Test Case 6.9: Bulk Approve Products

**Prerequisites**: 
- Logged in as Super Admin or Product Admin
- Multiple pending products exist

**Steps**:
1. Navigate to Product Management
2. Select multiple pending products
3. Click "Bulk Approve"
4. Confirm action

**Expected Result**:
- ✅ Checkboxes visible for each product
- ✅ "Select All" works
- ✅ Success message: "X products approved successfully"
- ✅ Selected products status updated

**Pass/Fail**: ☐


---

## Test Case 6.10: Bulk Reject Products

**Prerequisites**: 
- Logged in as Super Admin or Product Admin
- Multiple pending products exist

**Steps**:
1. Navigate to Product Management
2. Select multiple pending products
3. Click "Bulk Reject"
4. Enter rejection reason
5. Confirm action

**Expected Result**:
- ✅ Rejection reason dialog appears
- ✅ Success message: "X products rejected successfully"
- ✅ Selected products status updated

**Pass/Fail**: ☐


---

## Test Case 6.11: Delete Product

**Prerequisites**: 
- Logged in as Super Admin or Product Admin
- Product exists

**Steps**:
1. Navigate to product details
2. Click "Delete" button
3. Confirm deletion

**Expected Result**:
- ✅ Confirmation dialog appears
- ✅ Success message: "Product deleted successfully"
- ✅ Redirects to product list
- ✅ Deleted product no longer in list

**Pass/Fail**: ☐


---

## Test Case 6.12: Add Product Variant

**Prerequisites**: 
- Logged in as Super Admin or Product Admin
- Product exists

**Steps**:
1. Navigate to product details
2. Click "Add Variant" or go to Variants tab
3. Fill variant form:
   - SKU: "VAR-001"
   - Size: "Large"
   - Color: "Red"
   - Price: 109.99
   - Stock: 50
4. Submit form

**Expected Result**:
- ✅ Variant form displays
- ✅ Success message: "Variant added successfully"
- ✅ Variant appears in variants list

**Pass/Fail**: ☐


---

## Test Case 6.13: Update Product Variant

**Prerequisites**: 
- Logged in as Super Admin or Product Admin
- Product with variant exists

**Steps**:
1. Navigate to product variants
2. Click "Edit" on a variant
3. Update price and stock
4. Submit form

**Expected Result**:
- ✅ Variant form pre-filled
- ✅ Success message: "Variant updated successfully"
- ✅ Changes reflected

**Pass/Fail**: ☐


---

## Test Case 6.14: Delete Product Variant

**Prerequisites**: 
- Logged in as Super Admin or Product Admin
- Product with variant exists

**Steps**:
1. Navigate to product variants
2. Click "Delete" on a variant
3. Confirm deletion

**Expected Result**:
- ✅ Confirmation dialog appears
- ✅ Success message: "Variant deleted successfully"
- ✅ Variant removed from list

**Pass/Fail**: ☐


---

## Test Case 6.15: Upload Product Images

**Prerequisites**: 
- Logged in as Super Admin or Product Admin
- Product exists

**Steps**:
1. Navigate to product details
2. Go to "Images" tab or section
3. Click "Upload Images"
4. Select image files
5. Upload

**Expected Result**:
- ✅ Image upload interface displays
- ✅ Drag-and-drop or file picker works
- ✅ Progress indicator shows during upload
- ✅ Success message: "Images uploaded successfully"
- ✅ Images appear in gallery
- ✅ Primary image can be set

**Pass/Fail**: ☐


---

## Test Case 6.16: Delete Product Image

**Prerequisites**: 
- Logged in as Super Admin or Product Admin
- Product with images exists

**Steps**:
1. Navigate to product images
2. Click "Delete" on an image
3. Confirm deletion

**Expected Result**:
- ✅ Confirmation dialog appears
- ✅ Success message: "Image deleted successfully"
- ✅ Image removed from gallery

**Pass/Fail**: ☐


---

## Test Case 6.17: Set Primary Product Image

**Prerequisites**: 
- Logged in as Super Admin or Product Admin
- Product with multiple images exists

**Steps**:
1. Navigate to product images
2. Click "Set as Primary" on an image

**Expected Result**:
- ✅ Success message: "Primary image updated"
- ✅ Primary image indicator visible
- ✅ Image order updated

**Pass/Fail**: ☐


---

## Test Case 6.18: Assign Product to Category

**Prerequisites**: 
- Logged in as Super Admin or Product Admin
- Product and categories exist

**Steps**:
1. Navigate to product details
2. Go to "Categories" section
3. Select category from dropdown
4. Add category

**Expected Result**:
- ✅ Category dropdown populated
- ✅ Success message: "Category assigned"
- ✅ Category appears in product's category list

**Pass/Fail**: ☐


---

## Test Case 6.19: Remove Product from Category

**Prerequisites**: 
- Logged in as Super Admin or Product Admin
- Product with assigned category exists

**Steps**:
1. Navigate to product categories
2. Click "Remove" on a category
3. Confirm removal

**Expected Result**:
- ✅ Success message: "Category removed"
- ✅ Category removed from list

**Pass/Fail**: ☐


---

## Test Case 6.20: Search Products

**Prerequisites**: 
- Logged in as Super Admin or Product Admin
- Multiple products exist

**Steps**:
1. Navigate to Product Management
2. Use search bar
3. Search by name, SKU, or description

**Expected Result**:
- ✅ Search bar visible
- ✅ Results filter as typing
- ✅ Results highlight search term
- ✅ "No results" message if no matches

**Pass/Fail**: ☐


---

## Test Case 6.21: Filter Products by Status

**Prerequisites**: 
- Logged in as Super Admin or Product Admin
- Products with different statuses exist

**Steps**:
1. Navigate to Product Management
2. Use status filter dropdown
3. Select status (Pending, Active, Rejected, etc.)
4. Check filtered results

**Expected Result**:
- ✅ Status filter visible
- ✅ Filtering works correctly
- ✅ Status badges visible in list

**Pass/Fail**: ☐


---

## Test Case 6.22: Filter Products by Category

**Prerequisites**: 
- Logged in as Super Admin or Product Admin
- Products in different categories exist

**Steps**:
1. Navigate to Product Management
2. Use category filter dropdown
3. Select category
4. Check filtered results

**Expected Result**:
- ✅ Category filter visible
- ✅ Filtering works correctly

**Pass/Fail**: ☐


---

## Test Case 6.23: Filter Products by Supplier

**Prerequisites**: 
- Logged in as Super Admin or Product Admin
- Products from different suppliers exist

**Steps**:
1. Navigate to Product Management
2. Use supplier filter dropdown
3. Select supplier
4. Check filtered results

**Expected Result**:
- ✅ Supplier filter visible
- ✅ Filtering works correctly

**Pass/Fail**: ☐


---

## Test Case 6.24: Sort Products

**Prerequisites**: 
- Logged in as Super Admin or Product Admin
- Multiple products exist

**Steps**:
1. Navigate to Product Management
2. Click column header to sort
3. Check sorting

**Expected Result**:
- ✅ Column headers are clickable
- ✅ Sort indicator shows
- ✅ List sorts correctly

**Pass/Fail**: ☐


---

## Test Case 6.25: Pagination - Product List

**Prerequisites**: 
- Logged in as Super Admin or Product Admin
- More than 20 products exist

**Steps**:
1. Navigate to Product Management
2. Check pagination controls
3. Navigate to next page

**Expected Result**:
- ✅ Pagination controls visible
- ✅ Current page highlighted
- ✅ Results update correctly

**Pass/Fail**: ☐


---

## Test Case 6.26: Export Products

**Prerequisites**: 
- Logged in as Super Admin or Product Admin
- Products exist

**Steps**:
1. Navigate to Product Management
2. Click "Export" button
3. Check downloaded file

**Expected Result**:
- ✅ Export button visible
- ✅ File downloads (CSV/Excel)
- ✅ File contains product data

**Pass/Fail**: ☐


---

## Test Case 6.27: Bulk Upload Products

**Prerequisites**: 
- Logged in as Super Admin or Product Admin
- CSV/Excel template file ready

**Steps**:
1. Navigate to Product Management
2. Click "Bulk Upload" or "Import Products"
3. Select CSV/Excel file
4. Upload file
5. Review import results

**Expected Result**:
- ✅ File upload interface displays
- ✅ File picker works
- ✅ Progress indicator shows
- ✅ Success message with import summary
- ✅ Errors listed (if any)

**Pass/Fail**: ☐


---

## Test Case 6.28: Download Product Export Template

**Prerequisites**: 
- Logged in as Super Admin or Product Admin

**Steps**:
1. Navigate to Product Management
2. Click "Download Template" or "Export Template"
3. Check downloaded file

**Expected Result**:
- ✅ Template file downloads
- ✅ File is CSV/Excel format
- ✅ File contains column headers

**Pass/Fail**: ☐


---

## Test Case 6.29: Feature Product

**Prerequisites**: 
- Logged in as Super Admin or Product Admin
- Product exists

**Steps**:
1. Navigate to product details
2. Click "Feature Product" or toggle feature flag
3. Check feature status

**Expected Result**:
- ✅ Success message: "Product featured"
- ✅ Featured badge/indicator visible
- ✅ Product appears in featured products section

**Pass/Fail**: ☐


---

## Test Case 6.30: Unfeature Product

**Prerequisites**: 
- Logged in as Super Admin or Product Admin
- Featured product exists

**Steps**:
1. Navigate to product details
2. Click "Unfeature Product"
3. Check feature status

**Expected Result**:
- ✅ Success message: "Product unfeatured"
- ✅ Featured badge removed

**Pass/Fail**: ☐


---

## Test Case 6.31-6.50: Additional Product Features

**Test additional features:**
- Product attributes management
- Product SEO settings
- Product tags
- Product reviews moderation
- Product inventory management
- Low stock alerts
- Product variants with attributes
- Product pricing rules
- Product discounts
- Product bundles
- Product recommendations
- Product analytics
- Product performance metrics
- Product copy/duplicate
- Product archive
- Product restore
- Product versioning
- Product approval workflow
- Product status history
- Product audit log

**Pass/Fail**: ☐ (for each)

---

## 📝 Notes Section

**Issues Found**:
- 

**Suggestions**:
- 

**Completed By**: _______________  
**Date**: _______________  
**Total Passed**: ___/50  
**Total Failed**: ___/50

**Pass/Fail**: ☐ (for each)


---

