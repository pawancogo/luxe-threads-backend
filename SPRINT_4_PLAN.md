# Sprint 4 Execution Plan: Product Discovery & Search

**Goal:** Implement a powerful product search and filtering system for customers using Elasticsearch.

---

## Part 1: Backend (Rails API)

### Step 1: Integrate Searchkick into the Product Model
We will use the `searchkick` gem to handle all interactions with Elasticsearch. Configure the `Product` model to specify which fields should be indexed.

**File: [`app/models/product.rb`](app/models/product.rb)**
```ruby
class Product < ApplicationRecord
  searchkick

  # ... existing associations and enums ...

  # Define the data that will be sent to Elasticsearch
  def search_data
    {
      id: id,
      name: name,
      description: description,
      status: status,
      brand_name: brand.name,
      category_name: category.name,
      supplier_name: supplier_profile.company_name,
      # We will index variant prices and attributes here
      variants: product_variants.map do |variant|
        {
          price: variant.price,
          discounted_price: variant.discounted_price,
          # Assuming you have attribute models set up from Sprint 1
          # attributes: variant.attribute_values.map { |av| { name: av.attribute_type.name, value: av.value } }
        }
      end
    }
  end
end
```
*Note: This setup automatically creates callbacks. When a `Product` is saved or destroyed, Searchkick will automatically update the Elasticsearch index.*

### Step 2: Perform the Initial Data Import
After setting up the model, you need to import all existing products into your Elasticsearch index for the first time.

**Command to run:**
```bash
bundle exec rails searchkick:reindex:all
```
*(This will reindex all models that have `searchkick` enabled. You can also specify a class: `bundle exec rails searchkick:reindex CLASS=Product`)*

### Step 3: Create the Search Controller
Generate a new controller specifically for handling product search requests.

**Command to run:**
```bash
bundle exec rails g controller api/v1/Search search
```

### Step 4: Define the Search Route
Add the search endpoint to your routes file.

**File: [`config/routes.rb`](config/routes.rb)** (Add this within the `api/v1` namespace)
```ruby
namespace :api do
  namespace :v1 do
    # ... other routes
    get 'search', to: 'search#search'
  end
end
```

### Step 5: Implement the Search Logic
This controller will take query parameters, execute a search against Elasticsearch using Searchkick, and return the products, facets (for filtering UI), and pagination data.

**File: [`app/controllers/api/v1/search_controller.rb`](app/controllers/api/v1/search_controller.rb)**
```ruby
class Api::V1::SearchController < ApplicationController
  skip_before_action :authenticate_request, only: [:search]

  def search
    # Build the filters from query parameters
    filters = {}
    filters[:brand_name] = params[:brand] if params[:brand].present?
    filters[:category_name] = params[:category] if params[:category].present?
    # Add price range filter
    filters["variants.price"] = range_filter(params[:min_price], params[:max_price]) if params[:min_price] || params[:max_price]

    # Execute the search query
    @products = Product.search(
      params[:query].presence || "*",
      where: filters,
      aggs: { # aggs (aggregations) are used to create the filter facets
        brand_name: { limit: 10 },
        category_name: { limit: 10 }
      },
      page: params[:page] || 1,
      per_page: params[:per_page] || 20
    )

    render json: {
      products: @products.results,
      facets: @products.aggs,
      pagination: {
        current_page: @products.page,
        total_pages: @products.total_pages,
        total_count: @products.total_count
      }
    }
  end

  private

  def range_filter(min, max)
    range = {}
    range[:gte] = min.to_f if min.present?
    range[:lte] = max.to_f if max.present?
    range
  end
end
```

---

## Part 2: User Frontend

### Step 1: Create the Product Listing Page (PLP)
This will be the main page where users browse and filter products.

**Example File Structure:**
- `pages/products.js`
- `components/ProductGrid.js`
- `components/FilterSidebar.js`

### Step 2: Build the Filter Sidebar Component
This component will display the available filters (facets) returned from the search API and allow users to make selections.

**Example Code: `components/FilterSidebar.js`**
```javascript
import React from 'react';

const FilterSidebar = ({ facets, onFilterChange }) => {
  const handleCheckboxChange = (filterType, value) => {
    // This function would be passed from the parent page
    // to update the search query state and re-fetch results.
    onFilterChange(filterType, value);
  };

  return (
    <aside>
      <h3>Filters</h3>
      <div>
        <h4>Brands</h4>
        {facets.brand_name?.buckets.map(bucket => (
          <div key={bucket.key}>
            <input
              type="checkbox"
              id={`brand-${bucket.key}`}
              onChange={() => handleCheckboxChange('brand', bucket.key)}
            />
            <label htmlFor={`brand-${bucket.key}`}>{bucket.key} ({bucket.doc_count})</label>
          </div>
        ))}
      </div>
      <div>
        <h4>Categories</h4>
        {facets.category_name?.buckets.map(bucket => (
          // ... similar logic for categories ...
        ))}
      </div>
    </aside>
  );
};

export default FilterSidebar;
```

### Step 3: Build the Main Product Listing Page
This page will manage the state for search queries and filters, call the search API, and pass the results to the `FilterSidebar` and `ProductGrid` components.

**Example Code: `pages/products.js`**
```javascript
import React, { useState, useEffect } from 'react';
import FilterSidebar from '../components/FilterSidebar';
import ProductGrid from '../components/ProductGrid';
import { useRouter } from 'next/router';

const ProductsPage = () => {
  const [products, setProducts] = useState([]);
  const [facets, setFacets] = useState({});
  const [pagination, setPagination] = useState({});
  const router = useRouter();

  useEffect(() => {
    const fetchProducts = async () => {
      // Build query string from router.query (e.g., /products?query=shirt&brand=Nike)
      const queryString = new URLSearchParams(router.query).toString();
      const response = await fetch(`http://localhost:3000/api/v1/search?${queryString}`);
      if (response.ok) {
        const data = await response.json();
        setProducts(data.products);
        setFacets(data.facets);
        setPagination(data.pagination);
      }
    };
    fetchProducts();
  }, [router.query]); // Re-fetch whenever the URL query changes

  const handleFilterChange = (filterType, value) => {
    // Update the URL query to trigger a re-fetch
    const newQuery = { ...router.query, [filterType]: value };
    router.push({
      pathname: '/products',
      query: newQuery,
    });
  };

  return (
    <div style={{ display: 'flex' }}>
      <FilterSidebar facets={facets} onFilterChange={handleFilterChange} />
      <main>
        <ProductGrid products={products} />
        {/* Add pagination controls here based on the 'pagination' state */}
      </main>
    </div>
  );
};

export default ProductsPage;
```
This completes Sprint 4. The user-facing application now has a powerful search and discovery feature, which is a major milestone.