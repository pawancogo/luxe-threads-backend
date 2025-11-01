# Database Design & Optimization Guide

## Table of Contents
1. [Database Fundamentals](#database-fundamentals)
2. [Database Design Principles](#database-design-principles)
3. [Normalization](#normalization)
4. [Indexing Strategies](#indexing-strategies)
5. [Query Optimization](#query-optimization)
6. [Database Scaling](#database-scaling)
7. [Common Interview Questions](#common-interview-questions)
8. [Performance Monitoring](#performance-monitoring)

## Database Fundamentals

### Types of Databases

#### Relational Databases (RDBMS)
- **ACID Properties**: Atomicity, Consistency, Isolation, Durability
- **Examples**: PostgreSQL, MySQL, Oracle, SQL Server
- **Use Cases**: Financial systems, e-commerce, user management

#### NoSQL Databases
- **Document Stores**: MongoDB, CouchDB
- **Key-Value Stores**: Redis, DynamoDB
- **Column Family**: Cassandra, HBase
- **Graph Databases**: Neo4j, Amazon Neptune

### Database Components
- **Tables**: Store data in rows and columns
- **Indexes**: Improve query performance
- **Views**: Virtual tables based on queries
- **Stored Procedures**: Pre-compiled SQL code
- **Triggers**: Automatic actions on data changes

## Database Design Principles

### 1. Entity-Relationship Modeling
```
User (1) ←→ (M) Order (M) ←→ (1) Product
```

**Entity Types:**
- **Strong Entity**: Can exist independently (User, Product)
- **Weak Entity**: Depends on another entity (OrderItem)

**Relationship Types:**
- **One-to-One (1:1)**: User ↔ Profile
- **One-to-Many (1:M)**: User → Orders
- **Many-to-Many (M:M)**: Users ↔ Products (through Orders)

### 2. Database Schema Design

#### Good Schema Design Principles
- **Atomicity**: Each column contains single values
- **Consistency**: Data follows business rules
- **Redundancy**: Minimize duplicate data
- **Flexibility**: Easy to modify and extend

#### Example Schema Design
```sql
-- Users table
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Products table
CREATE TABLE products (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    price DECIMAL(10,2) NOT NULL,
    category_id INTEGER REFERENCES categories(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Orders table
CREATE TABLE orders (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id),
    total_amount DECIMAL(10,2) NOT NULL,
    status VARCHAR(50) DEFAULT 'pending',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Order Items table (Junction table)
CREATE TABLE order_items (
    id SERIAL PRIMARY KEY,
    order_id INTEGER REFERENCES orders(id),
    product_id INTEGER REFERENCES products(id),
    quantity INTEGER NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL
);
```

## Normalization

### First Normal Form (1NF)
- Each column contains atomic values
- No repeating groups
- Each row is unique

**Example - Before 1NF:**
```
OrderID | Customer | Products
1       | John     | Laptop, Mouse, Keyboard
```

**Example - After 1NF:**
```
OrderID | Customer | Product
1       | John     | Laptop
1       | John     | Mouse
1       | John     | Keyboard
```

### Second Normal Form (2NF)
- Must be in 1NF
- All non-key attributes fully depend on primary key

**Example - Before 2NF:**
```
OrderID | ProductID | ProductName | Quantity | Price
1       | 101       | Laptop      | 1        | 1000
1       | 102       | Mouse       | 2        | 25
```

**Example - After 2NF:**
```
Orders Table:
OrderID | ProductID | Quantity
1       | 101       | 1
1       | 102       | 2

Products Table:
ProductID | ProductName | Price
101       | Laptop      | 1000
102       | Mouse       | 25
```

### Third Normal Form (3NF)
- Must be in 2NF
- No transitive dependencies

**Example - Before 3NF:**
```
OrderID | CustomerID | CustomerName | CustomerCity
1       | 1001       | John Smith   | New York
```

**Example - After 3NF:**
```
Orders Table:
OrderID | CustomerID
1       | 1001

Customers Table:
CustomerID | CustomerName | CustomerCity
1001       | John Smith   | New York
```

### Denormalization
Sometimes denormalization is acceptable for performance:
- **Read-heavy workloads**: Reduce JOIN operations
- **Reporting systems**: Pre-computed aggregations
- **Caching**: Store frequently accessed data together

## Indexing Strategies

### Types of Indexes

#### 1. Primary Index
- Automatically created on PRIMARY KEY
- Unique and not null
- Clustered index (data physically ordered)

#### 2. Secondary Index
- Created on non-primary key columns
- Non-clustered index
- Separate data structure

#### 3. Composite Index
```sql
CREATE INDEX idx_user_email_name ON users(email, first_name);
```
- Multiple columns in single index
- Order matters (leftmost prefix rule)

#### 4. Partial Index
```sql
CREATE INDEX idx_active_users ON users(email) WHERE status = 'active';
```
- Index only subset of rows
- Reduces index size

#### 5. Covering Index
```sql
CREATE INDEX idx_user_covering ON users(email) INCLUDE (first_name, last_name);
```
- Contains all columns needed for query
- Avoids table lookups

### Index Design Best Practices

#### When to Create Indexes
- **Frequently queried columns**
- **Foreign key columns**
- **Columns in WHERE clauses**
- **Columns in ORDER BY clauses**
- **Columns in JOIN conditions**

#### When NOT to Create Indexes
- **Small tables** (< 1000 rows)
- **Frequently updated columns**
- **Columns with low cardinality**
- **Too many indexes** (slows down writes)

#### Index Maintenance
```sql
-- Analyze index usage
SELECT 
    schemaname,
    tablename,
    indexname,
    idx_scan,
    idx_tup_read,
    idx_tup_fetch
FROM pg_stat_user_indexes
ORDER BY idx_scan DESC;

-- Rebuild fragmented indexes
REINDEX INDEX idx_user_email;
```

## Query Optimization

### 1. Query Analysis

#### EXPLAIN and EXPLAIN ANALYZE
```sql
EXPLAIN ANALYZE 
SELECT u.first_name, u.last_name, o.total_amount
FROM users u
JOIN orders o ON u.id = o.user_id
WHERE u.email = 'john@example.com';
```

#### Understanding Query Plans
- **Seq Scan**: Full table scan (expensive)
- **Index Scan**: Using index (efficient)
- **Hash Join**: Hash-based join
- **Nested Loop**: Nested loop join
- **Sort**: Sorting operation

### 2. Common Performance Issues

#### N+1 Query Problem
**Bad:**
```ruby
users = User.all
users.each do |user|
  puts user.orders.count  # N+1 queries
end
```

**Good:**
```ruby
users = User.includes(:orders)
users.each do |user|
  puts user.orders.count  # Single query with JOIN
end
```

#### Missing Indexes
```sql
-- Slow query
SELECT * FROM orders WHERE user_id = 123;

-- Add index
CREATE INDEX idx_orders_user_id ON orders(user_id);
```

#### Inefficient JOINs
```sql
-- Bad: Cartesian product
SELECT * FROM users, orders WHERE users.id = orders.user_id;

-- Good: Explicit JOIN
SELECT * FROM users 
JOIN orders ON users.id = orders.user_id;
```

### 3. Query Optimization Techniques

#### Use Appropriate Data Types
```sql
-- Bad: VARCHAR for numbers
user_id VARCHAR(10)

-- Good: INTEGER
user_id INTEGER
```

#### Limit Result Sets
```sql
-- Bad: No limit
SELECT * FROM orders;

-- Good: Use LIMIT
SELECT * FROM orders LIMIT 100;
```

#### Use EXISTS instead of IN for subqueries
```sql
-- Bad: IN with subquery
SELECT * FROM users 
WHERE id IN (SELECT user_id FROM orders);

-- Good: EXISTS
SELECT * FROM users u
WHERE EXISTS (SELECT 1 FROM orders o WHERE o.user_id = u.id);
```

#### Avoid SELECT *
```sql
-- Bad: Select all columns
SELECT * FROM users;

-- Good: Select only needed columns
SELECT id, email, first_name FROM users;
```

## Database Scaling

### 1. Vertical Scaling (Scale Up)
- **Add more CPU/RAM** to existing server
- **Upgrade storage** to faster SSDs
- **Increase memory** for better caching

### 2. Horizontal Scaling (Scale Out)

#### Read Replicas
```
Master DB (Write) → Read Replica 1
                → Read Replica 2
                → Read Replica 3
```

**Implementation:**
```ruby
# Rails configuration
config.database_configuration = {
  'development' => {
    'primary' => { 'adapter' => 'postgresql', 'database' => 'app_primary' },
    'primary_replica' => { 'adapter' => 'postgresql', 'database' => 'app_primary', 'replica' => true }
  }
}
```

#### Database Sharding
```
Shard 1: User ID 1-1000
Shard 2: User ID 1001-2000
Shard 3: User ID 2001-3000
```

**Sharding Strategies:**
- **Range-based**: Split by ID ranges
- **Hash-based**: Use hash function on key
- **Directory-based**: Lookup table for shard mapping

#### Partitioning
```sql
-- Range partitioning
CREATE TABLE orders (
    id SERIAL,
    user_id INTEGER,
    order_date DATE,
    total_amount DECIMAL(10,2)
) PARTITION BY RANGE (order_date);

-- Create partitions
CREATE TABLE orders_2023 PARTITION OF orders
FOR VALUES FROM ('2023-01-01') TO ('2024-01-01');

CREATE TABLE orders_2024 PARTITION OF orders
FOR VALUES FROM ('2024-01-01') TO ('2025-01-01');
```

### 3. Caching Strategies

#### Application-Level Caching
```ruby
# Rails caching
Rails.cache.fetch("user_#{user_id}", expires_in: 1.hour) do
  User.find(user_id)
end
```

#### Database Query Caching
```sql
-- PostgreSQL query cache
SET shared_preload_libraries = 'pg_stat_statements';
```

#### Redis Caching
```ruby
# Redis for session storage
redis = Redis.new
redis.set("user_session:#{session_id}", user_data, ex: 3600)
```

## Common Interview Questions

### 1. Design a Database for E-commerce
**Requirements:**
- Users, Products, Orders, Categories
- Support for product variants
- Order history and tracking
- Inventory management

**Schema Design:**
```sql
-- Users
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    password_digest VARCHAR(255) NOT NULL,
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    phone VARCHAR(20),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Categories
CREATE TABLE categories (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    parent_id INTEGER REFERENCES categories(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Products
CREATE TABLE products (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    base_price DECIMAL(10,2) NOT NULL,
    category_id INTEGER REFERENCES categories(id),
    sku VARCHAR(100) UNIQUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Product Variants
CREATE TABLE product_variants (
    id SERIAL PRIMARY KEY,
    product_id INTEGER REFERENCES products(id),
    size VARCHAR(20),
    color VARCHAR(50),
    price DECIMAL(10,2),
    stock_quantity INTEGER DEFAULT 0,
    sku VARCHAR(100) UNIQUE
);

-- Orders
CREATE TABLE orders (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id),
    order_number VARCHAR(50) UNIQUE NOT NULL,
    total_amount DECIMAL(10,2) NOT NULL,
    status VARCHAR(50) DEFAULT 'pending',
    shipping_address TEXT,
    billing_address TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Order Items
CREATE TABLE order_items (
    id SERIAL PRIMARY KEY,
    order_id INTEGER REFERENCES orders(id),
    product_variant_id INTEGER REFERENCES product_variants(id),
    quantity INTEGER NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    total_price DECIMAL(10,2) NOT NULL
);
```

### 2. Optimize a Slow Query
**Problem Query:**
```sql
SELECT u.first_name, u.last_name, COUNT(o.id) as order_count
FROM users u
LEFT JOIN orders o ON u.id = o.user_id
WHERE u.created_at > '2023-01-01'
GROUP BY u.id, u.first_name, u.last_name
HAVING COUNT(o.id) > 5
ORDER BY order_count DESC
LIMIT 100;
```

**Optimization Steps:**
1. **Add indexes:**
```sql
CREATE INDEX idx_users_created_at ON users(created_at);
CREATE INDEX idx_orders_user_id ON orders(user_id);
```

2. **Rewrite query:**
```sql
SELECT u.first_name, u.last_name, o.order_count
FROM users u
JOIN (
    SELECT user_id, COUNT(*) as order_count
    FROM orders
    GROUP BY user_id
    HAVING COUNT(*) > 5
) o ON u.id = o.user_id
WHERE u.created_at > '2023-01-01'
ORDER BY o.order_count DESC
LIMIT 100;
```

### 3. Design a Database for Social Media
**Requirements:**
- Users, Posts, Comments, Likes, Follows
- Timeline generation
- Real-time updates

**Schema Design:**
```sql
-- Users
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    full_name VARCHAR(100),
    bio TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Posts
CREATE TABLE posts (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id),
    content TEXT NOT NULL,
    image_url VARCHAR(500),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Comments
CREATE TABLE comments (
    id SERIAL PRIMARY KEY,
    post_id INTEGER REFERENCES posts(id),
    user_id INTEGER REFERENCES users(id),
    content TEXT NOT NULL,
    parent_id INTEGER REFERENCES comments(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Likes
CREATE TABLE likes (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id),
    likeable_type VARCHAR(50) NOT NULL, -- 'Post' or 'Comment'
    likeable_id INTEGER NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(user_id, likeable_type, likeable_id)
);

-- Follows
CREATE TABLE follows (
    id SERIAL PRIMARY KEY,
    follower_id INTEGER REFERENCES users(id),
    following_id INTEGER REFERENCES users(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(follower_id, following_id)
);
```

## Performance Monitoring

### Key Metrics to Monitor

#### Database Metrics
- **Connection Count**: Active database connections
- **Query Performance**: Slow query log
- **Lock Waits**: Deadlock detection
- **Cache Hit Ratio**: Buffer pool efficiency
- **Disk I/O**: Read/write operations

#### Application Metrics
- **Response Time**: API response times
- **Throughput**: Requests per second
- **Error Rate**: Failed requests percentage
- **Resource Usage**: CPU, memory, disk

### Monitoring Tools

#### Database Monitoring
```sql
-- PostgreSQL monitoring queries
SELECT 
    query,
    calls,
    total_time,
    mean_time,
    rows
FROM pg_stat_statements
ORDER BY total_time DESC
LIMIT 10;

-- Check index usage
SELECT 
    schemaname,
    tablename,
    indexname,
    idx_scan,
    idx_tup_read
FROM pg_stat_user_indexes
WHERE idx_scan = 0;
```

#### Application Monitoring
```ruby
# Rails performance monitoring
# Gemfile
gem 'newrelic_rpm'
gem 'rack-mini-profiler'

# Application monitoring
class ApplicationController < ActionController::Base
  before_action :log_performance
  
  private
  
  def log_performance
    start_time = Time.current
    yield
    duration = Time.current - start_time
    Rails.logger.info "Request completed in #{duration}ms"
  end
end
```

### Performance Tuning Checklist

#### Database Level
- [ ] Analyze slow query log
- [ ] Add missing indexes
- [ ] Remove unused indexes
- [ ] Optimize table statistics
- [ ] Configure connection pooling
- [ ] Set appropriate buffer sizes

#### Application Level
- [ ] Implement query optimization
- [ ] Add application-level caching
- [ ] Use database connection pooling
- [ ] Implement lazy loading
- [ ] Optimize N+1 queries
- [ ] Use background jobs for heavy operations

#### Infrastructure Level
- [ ] Monitor resource usage
- [ ] Scale database resources
- [ ] Implement read replicas
- [ ] Use CDN for static content
- [ ] Configure load balancing
- [ ] Set up monitoring alerts

## Best Practices Summary

### Design Phase
1. **Start with requirements** and use cases
2. **Design for scalability** from the beginning
3. **Choose appropriate data types**
4. **Plan for indexing** strategy
5. **Consider data relationships** carefully

### Development Phase
1. **Write efficient queries** from the start
2. **Use prepared statements** for security
3. **Implement proper error handling**
4. **Add logging and monitoring**
5. **Test with realistic data volumes**

### Production Phase
1. **Monitor performance** continuously
2. **Regular maintenance** and optimization
3. **Backup and recovery** procedures
4. **Security updates** and patches
5. **Capacity planning** for growth

Remember: Database optimization is an iterative process. Start with the most impactful changes and measure the results before making additional optimizations.



