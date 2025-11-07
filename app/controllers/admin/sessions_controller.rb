class Admin::SessionsController < BaseController
    skip_before_action :authenticate_request, only: [:new, :create, :destroy]
    
    def new
      # Simple login form for Rails Admin
      render html: <<~HTML.html_safe
        <!DOCTYPE html>
        <html>
        <head>
          <title>Admin Login - LuxeThreads</title>
          <style>
            body { font-family: Arial, sans-serif; max-width: 400px; margin: 100px auto; padding: 20px; }
            .form-group { margin-bottom: 15px; }
            label { display: block; margin-bottom: 5px; }
            input[type="email"], input[type="password"] { width: 100%; padding: 8px; border: 1px solid #ddd; border-radius: 4px; }
            button { background: #007bff; color: white; padding: 10px 20px; border: none; border-radius: 4px; cursor: pointer; }
            button:hover { background: #0056b3; }
            .error { color: red; margin-top: 10px; }
          </style>
        </head>
        <body>
          <h2>Admin Login</h2>
          <form action="/admin/sessions" method="post">
            <div class="form-group">
              <label for="email">Email:</label>
              <input type="email" id="email" name="email" required>
            </div>
            <div class="form-group">
              <label for="password">Password:</label>
              <input type="password" id="password" name="password" required>
            </div>
            <button type="submit">Login</button>
            #{params[:error] ? "<div class='error'>#{params[:error]}</div>" : ""}
          </form>
        </body>
        </html>
      HTML
    end

    def create
      admin = Admin.find_by(email: params[:email])
      
      if admin&.authenticate(params[:password])
        session[:admin_id] = admin.id
        redirect_to '/admin'
      else
        redirect_to '/admin/login?error=Invalid credentials or insufficient permissions'
      end
    end

    def destroy
      session[:admin_id] = nil
      redirect_to '/admin/login'
    end
  end


