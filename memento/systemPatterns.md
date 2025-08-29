# System Patterns: luxe-threads Backend

## 1. Architectural Style

We will adopt a **Modular Monolith** architecture. This approach allows us to maintain the simplicity of a single codebase and deployment pipeline while enforcing logical boundaries between different domains of the application (e.g., User Management, Product Catalog, Order Processing). This will be achieved through the use of Rails engines or namespaces.

## 2. Design Patterns

- **Model-View-Controller (MVC):** We will adhere to the standard Rails MVC pattern to separate concerns and organize our code.
- **Service Objects:** For complex business logic that doesn't fit neatly into a model or controller, we will use Service Objects. This keeps our models and controllers lean and focused on their primary responsibilities.
- **Repository Pattern:** To decouple our application from the database and improve testability, we will consider using the Repository Pattern. This will involve creating a layer of objects responsible for querying and persisting data.
- **Presenter Pattern (or Decorators):** To handle view-specific logic and formatting without cluttering our models, we will use Presenters or Decorators.
- **Observer Pattern:** For handling cross-cutting concerns like sending notifications after an order is placed, we will use the Observer Pattern, likely leveraging Active Job and callbacks.
- **Role-Based Access Control (RBAC):** We will implement a role-based authorization system to manage permissions for different user types (Customer, Supplier, Admin). A `role` attribute will be added to the User model.
- **Admin Interface:** We will use a hybrid approach for the admin dashboard. The `rails_admin` gem will be used for standard CRUD operations, and we will build custom pages and dashboards for more complex and specific administrative tasks.

## 3. API Design

- **RESTful Principles:** Our API will follow RESTful principles, using standard HTTP verbs (GET, POST, PUT, DELETE) and status codes.
- **Versioning:** The API will be versioned (e.g., `/api/v1/...`) to allow for future changes without breaking existing clients.
- **JSON API Specification:** We will follow the JSON API specification (jsonapi.org) for consistent request and response formats. This will make our API easier to consume and understand.
- **Authentication:** API endpoints will be secured using JSON Web Tokens (JWT). A token will be issued upon successful login and required for all subsequent authenticated requests.

## 4. Component Relationships

```mermaid
graph TD
    subgraph "User Roles"
        Customer(Customer)
        Supplier(Supplier)
        Admin(Admin)
    end

    subgraph "User Domain"
        A[Users] -- has a --> R{Role}
        A --> B(Profiles)
        A --> C{Authentication}
        A --> D[Addresses]
    end

    subgraph "Product Domain"
        E[Products] --> F(Categories)
        E --> G[Brands]
        E --> H[Reviews]
        E --> I[Inventory]
    end

    subgraph "Order Domain"
        J[Orders] --> K(Order Items)
        J --> L{Payments}
        J --> M[Shipments]
    end

    subgraph "Interactions & Permissions"
        Customer -- "Manages" --> B
        Customer -- "Places" --> J
        Customer -- "Writes" --> H
        
        Supplier -- "Manages" --> E
        Supplier -- "Manages" --> I
        Supplier -- "Views" --> J
        
        Admin -- "Manages" --> A
        Admin -- "Manages" --> E
        Admin -- "Manages" --> J

        E -- "Belongs to" --> K
        N[Shopping Cart] --> Customer
        O[Wishlist] --> Customer
        N -- "Contains" --> E
        O -- "Contains" --> E
    end
    
    R --> Customer
    R --> Supplier
    R --> Admin