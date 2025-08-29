# Active Context: luxe-threads Backend

## 1. Current Focus: Initial Project Setup & User Authentication

Our immediate priority is to establish a solid foundation for the application. This involves:
- Setting up the necessary gems for authentication and API development.
- Creating the database schema for the `User` model.
- Implementing the user registration and login functionality.
- Securing the API endpoints with token-based authentication (JWT).

## 2. Recent Changes

- **Project Initialization:** A new Rails 8 application has been generated.
- **Memento Creation:** The initial set of memento documents (`projectbrief.md`, `productContext.md`, `techContext.md`, `systemPatterns.md`) has been created to guide the project.

## 3. Next Steps

1.  **Install and configure necessary gems:**
    *   `bcrypt` for password hashing.
    *   `jwt` for generating and decoding JSON Web Tokens.
    *   `rack-cors` to handle Cross-Origin Resource Sharing.
    *   `rails_admin` for the admin interface.

2.  **Create the `User` model with roles:**
    *   Generate a `User` model with attributes for `name`, `email`, `password_digest`, and `role`.
    *   Add validations for the user model.
    *   Implement `has_secure_password`.
    *   Define the roles (e.g., as an enum in the model).

3.  **Implement Authentication Endpoints:**
    *   Create a `/signup` endpoint for user registration.
    *   Create a `/login` endpoint to authenticate users and issue JWTs.
    *   Create a `/logout` endpoint to handle token invalidation (optional, depending on strategy).

4.  **Set up API versioning and routing:**
    *   Create an `api/v1` namespace for all API controllers.

## 4. Active Decisions & Considerations

- **Token Expiration:** We need to decide on a reasonable expiration time for the JWTs. A short expiration time improves security, but a longer one improves user experience. We will start with a 24-hour expiration.
- **Refresh Tokens:** We will not implement refresh tokens in the initial version to keep the authentication mechanism simple. This can be added later if needed.
- **Password Complexity:** We will enforce a minimum password length but will not impose complex character requirements initially.