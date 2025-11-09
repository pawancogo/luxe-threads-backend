# 06. Product Management Testing

## 🎯 Overview
Test product creation, editing, approval/rejection, variants, images, categories, and product-related operations.

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

**Expected Result (FE)**:
- ✅ List shows all products
- ✅ Each product shows: Name, SKU, Price, Status, Supplier, Stock
- ✅ Product images visible (thumbnails)
- ✅ Table/list is sortable and searchable
- ✅ Pagination works
- ✅ Filter options visible (Status, Category, Supplier, etc.)

**Expected Result (BE)**:
- ✅ API: `GET /api/v1/admin/products` returns 200
- ✅ Response contains array of products
- ✅ Each product object has complete data

**Pass/Fail**: ☐

---

## Test Case 6.2: View All Products - Product Admin

**Prerequisites**: 
- Logged in as Product Admin

**Steps**:
1. Navigate to Product Management
2. Check access

**Expected Result (FE)**:
- ✅ Product list accessible
- ✅ Full product management features available

**Expected Result (BE)**:
- ✅ API: `GET /api/v1/admin/products` returns 200
- ✅ Access granted

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

**Expected Result (FE)**:
- ✅ Product details page loads
- ✅ Shows: Basic Info, Description, Images, Variants, Pricing, Inventory
- ✅ Shows: Categories, Attributes, SEO, Status
- ✅ Edit, Delete, Approve/Reject buttons visible

**Expected Result (BE)**:
- ✅ API: `GET /api/v1/admin/products/:id` returns 200
- ✅ Response contains complete product data
- ✅ Includes variants, images, categories

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

**Expected Result (FE)**:
- ✅ Form displays correctly
- ✅ All required fields marked
- ✅ Category and brand dropdowns populated
- ✅ Success message: "Product created successfully"
- ✅ Redirects to product details or list
- ✅ New product appears in list

**Expected Result (BE)**:
- ✅ API: `POST /api/v1/admin/products` returns 201 Created
- ✅ Product record created
- ✅ Status set to "pending" or "draft" (check business rules)
- ✅ Slug generated (if implemented)
- ✅ All fields saved correctly

**Pass/Fail**: ☐

---

## Test Case 6.5: Create New Product - Missing Required Fields

**Prerequisites**: 
- Logged in as Super Admin or Product Admin

**Steps**:
1. Navigate to Create Product form
2. Leave required fields empty
3. Submit form

**Expected Result (FE)**:
- ✅ Validation errors shown for empty required fields
- ✅ Form does not submit
- ✅ Errors shown near relevant fields

**Expected Result (BE)**:
- ✅ API returns 422 with validation errors
- ✅ No product created

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

**Expected Result (FE)**:
- ✅ Edit form pre-filled with current data
- ✅ Success message: "Product updated successfully"
- ✅ Changes reflected in product details

**Expected Result (BE)**:
- ✅ API: `PATCH /api/v1/admin/products/:id` returns 200
- ✅ Product record updated
- ✅ Changes persisted correctly

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

**Expected Result (FE)**:
- ✅ Success message: "Product approved successfully"
- ✅ Status changes to "approved" or "active"
- ✅ Approved badge visible
- ✅ Product visible in public catalog (if applicable)

**Expected Result (BE)**:
- ✅ API: `PATCH /api/v1/admin/products/:id/approve` returns 200
- ✅ Status updated to "approved" or "active"
- ✅ Approval date/timestamp set
- ✅ Approved by admin ID saved
- ✅ Activity logged

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

**Expected Result (FE)**:
- ✅ Rejection reason dialog/form appears
- ✅ Success message: "Product rejected"
- ✅ Status changes to "rejected"
- ✅ Rejection reason visible in product details

**Expected Result (BE)**:
- ✅ API: `PATCH /api/v1/admin/products/:id/reject` returns 200
- ✅ Status updated to "rejected"
- ✅ Rejection reason saved
- ✅ Rejection date/timestamp set
- ✅ Activity logged

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

**Expected Result (FE)**:
- ✅ Checkboxes visible for each product
- ✅ "Select All" works
- ✅ Success message: "X products approved successfully"
- ✅ Selected products status updated

**Expected Result (BE)**:
- ✅ API: `POST /api/v1/admin/products/bulk_approve` returns 200
- ✅ All selected products approved
- ✅ Transaction used (all or nothing)
- ✅ Activity logged for each

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

**Expected Result (FE)**:
- ✅ Rejection reason dialog appears
- ✅ Success message: "X products rejected successfully"
- ✅ Selected products status updated

**Expected Result (BE)**:
- ✅ API: `POST /api/v1/admin/products/bulk_reject` returns 200
- ✅ All selected products rejected
- ✅ Rejection reason saved for each

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

**Expected Result (FE)**:
- ✅ Confirmation dialog appears
- ✅ Success message: "Product deleted successfully"
- ✅ Redirects to product list
- ✅ Deleted product no longer in list

**Expected Result (BE)**:
- ✅ API: `DELETE /api/v1/admin/products/:id` returns 200
- ✅ Product record deleted (or soft-deleted)
- ✅ Related records handled (variants, images - check business rules)
- ✅ Activity logged

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

**Expected Result (FE)**:
- ✅ Variant form displays
- ✅ Success message: "Variant added successfully"
- ✅ Variant appears in variants list

**Expected Result (BE)**:
- ✅ API: `POST /api/v1/admin/products/:product_id/product_variants` returns 201
- ✅ Variant record created
- ✅ Linked to product correctly
- ✅ Inventory tracked separately

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

**Expected Result (FE)**:
- ✅ Variant form pre-filled
- ✅ Success message: "Variant updated successfully"
- ✅ Changes reflected

**Expected Result (BE)**:
- ✅ API: `PATCH /api/v1/admin/products/:product_id/product_variants/:id` returns 200
- ✅ Variant updated correctly

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

**Expected Result (FE)**:
- ✅ Confirmation dialog appears
- ✅ Success message: "Variant deleted successfully"
- ✅ Variant removed from list

**Expected Result (BE)**:
- ✅ API: `DELETE /api/v1/admin/products/:product_id/product_variants/:id` returns 200
- ✅ Variant deleted
- ✅ Check business rules (can't delete if in orders)

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

**Expected Result (FE)**:
- ✅ Image upload interface displays
- ✅ Drag-and-drop or file picker works
- ✅ Progress indicator shows during upload
- ✅ Success message: "Images uploaded successfully"
- ✅ Images appear in gallery
- ✅ Primary image can be set

**Expected Result (BE)**:
- ✅ API: `POST /api/v1/admin/products/:id/images` returns 201
- ✅ Images uploaded to storage (S3, local, etc.)
- ✅ Image records created in database
- ✅ URLs stored correctly

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

**Expected Result (FE)**:
- ✅ Confirmation dialog appears
- ✅ Success message: "Image deleted successfully"
- ✅ Image removed from gallery

**Expected Result (BE)**:
- ✅ API: `DELETE /api/v1/admin/products/:id/images/:image_id` returns 200
- ✅ Image record deleted
- ✅ Image file deleted from storage (if implemented)

**Pass/Fail**: ☐

---

## Test Case 6.17: Set Primary Product Image

**Prerequisites**: 
- Logged in as Super Admin or Product Admin
- Product with multiple images exists

**Steps**:
1. Navigate to product images
2. Click "Set as Primary" on an image

**Expected Result (FE)**:
- ✅ Success message: "Primary image updated"
- ✅ Primary image indicator visible
- ✅ Image order updated

**Expected Result (BE)**:
- ✅ API: `PATCH /api/v1/admin/products/:id/images/:image_id/set_primary` returns 200
- ✅ Primary image flag updated
- ✅ Previous primary image flag cleared

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

**Expected Result (FE)**:
- ✅ Category dropdown populated
- ✅ Success message: "Category assigned"
- ✅ Category appears in product's category list

**Expected Result (BE)**:
- ✅ API: `POST /api/v1/admin/products/:id/categories` returns 200
- ✅ Product-category association created
- ✅ Product appears in category's product list

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

**Expected Result (FE)**:
- ✅ Success message: "Category removed"
- ✅ Category removed from list

**Expected Result (BE)**:
- ✅ API: `DELETE /api/v1/admin/products/:id/categories/:category_id` returns 200
- ✅ Product-category association deleted

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

**Expected Result (FE)**:
- ✅ Search bar visible
- ✅ Results filter as typing
- ✅ Results highlight search term
- ✅ "No results" message if no matches

**Expected Result (BE)**:
- ✅ API: `GET /api/v1/admin/products?search=...` returns filtered results
- ✅ Search works on multiple fields
- ✅ Case-insensitive search

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

**Expected Result (FE)**:
- ✅ Status filter visible
- ✅ Filtering works correctly
- ✅ Status badges visible in list

**Expected Result (BE)**:
- ✅ API: `GET /api/v1/admin/products?status=active` returns filtered results
- ✅ Filter works correctly

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

**Expected Result (FE)**:
- ✅ Category filter visible
- ✅ Filtering works correctly

**Expected Result (BE)**:
- ✅ API: `GET /api/v1/admin/products?category_id=...` returns filtered results
- ✅ Filter works correctly

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

**Expected Result (FE)**:
- ✅ Supplier filter visible
- ✅ Filtering works correctly

**Expected Result (BE)**:
- ✅ API: `GET /api/v1/admin/products?supplier_id=...` returns filtered results
- ✅ Filter works correctly

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

**Expected Result (FE)**:
- ✅ Column headers are clickable
- ✅ Sort indicator shows
- ✅ List sorts correctly

**Expected Result (BE)**:
- ✅ API: `GET /api/v1/admin/products?sort=name&order=asc` returns sorted results
- ✅ Sorting works on all sortable columns

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

**Expected Result (FE)**:
- ✅ Pagination controls visible
- ✅ Current page highlighted
- ✅ Results update correctly

**Expected Result (BE)**:
- ✅ API: `GET /api/v1/admin/products?page=2` returns correct page
- ✅ Pagination metadata included

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

**Expected Result (FE)**:
- ✅ Export button visible
- ✅ File downloads (CSV/Excel)
- ✅ File contains product data

**Expected Result (BE)**:
- ✅ API: `GET /api/v1/admin/products/export` returns file
- ✅ File format correct
- ✅ All products included (or filtered based on current view)

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

**Expected Result (FE)**:
- ✅ File upload interface displays
- ✅ File picker works
- ✅ Progress indicator shows
- ✅ Success message with import summary
- ✅ Errors listed (if any)

**Expected Result (BE)**:
- ✅ API: `POST /api/v1/admin/products/bulk_upload` returns 200
- ✅ Products imported correctly
- ✅ Validation errors returned for invalid rows
- ✅ Import log created

**Pass/Fail**: ☐

---

## Test Case 6.28: Download Product Export Template

**Prerequisites**: 
- Logged in as Super Admin or Product Admin

**Steps**:
1. Navigate to Product Management
2. Click "Download Template" or "Export Template"
3. Check downloaded file

**Expected Result (FE)**:
- ✅ Template file downloads
- ✅ File is CSV/Excel format
- ✅ File contains column headers

**Expected Result (BE)**:
- ✅ API: `GET /api/v1/admin/products/export_template` returns file
- ✅ Template format correct

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

**Expected Result (FE)**:
- ✅ Success message: "Product featured"
- ✅ Featured badge/indicator visible
- ✅ Product appears in featured products section

**Expected Result (BE)**:
- ✅ API: `PATCH /api/v1/admin/products/:id/feature` returns 200
- ✅ `is_featured: true` in database
- ✅ Product appears in featured products query

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

**Expected Result (FE)**:
- ✅ Success message: "Product unfeatured"
- ✅ Featured badge removed

**Expected Result (BE)**:
- ✅ API: `PATCH /api/v1/admin/products/:id/unfeature` returns 200
- ✅ `is_featured: false` in database

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

