# Technical Context: luxe-threads Backend

## 1. Core Technology Stack

- **Backend Framework:** Ruby on Rails 8.0.2
- **Programming Language:** Ruby
- **Database:** SQLite3 (for development, will be replaced with PostgreSQL or MySQL for production)
- **Web Server:** Puma
- **Asset Pipeline:** Propshaft
- **JavaScript Bundling:** Importmap
- **Frontend Framework (for Hotwire):** Stimulus & Turbo

## 2. Key Libraries & Gems

- **API Development:** Jbuilder (for JSON APIs)
- **Authentication:** bcrypt (to be enabled for `has_secure_password`)
- **Background Jobs:** Solid Queue
- **Caching:** Solid Cache
- **WebSockets:** Solid Cable
- **Deployment:** Kamal (Docker-based)
- **Testing:** Capybara, Selenium Webdriver, Minitest
- **Code Quality:** RuboCop (with rails-omakase config)
- **Security Scanning:** Brakeman

## 3. Development Environment

- **Local Setup:** Standard Rails development environment.
- **Dependencies:** Managed by Bundler via the `Gemfile`.
- **Database Migrations:** Handled by Active Record Migrations.

## 4. Technical Constraints & Decisions

- **API Style:** We will start with a RESTful API, using JSON as the data format. A transition to GraphQL could be considered later if the project's needs evolve.
- **Database Choice:** While SQLite is suitable for development, the production environment will require a more robust database like PostgreSQL to handle concurrent connections and larger datasets effectively.
- **Authentication Strategy:** We will implement token-based authentication (e.g., JWT) to secure the API endpoints for mobile and web clients.
- **Modularity:** The application will be structured into logical components (e.g., users, products, orders) to ensure maintainability and scalability.