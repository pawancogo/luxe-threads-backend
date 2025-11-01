module Admin
  class AdminsController < BaseController
    before_action :require_super_admin!
    before_action :set_admin, only: [:show, :edit, :update, :destroy]

    def index
      @admins = Admin.all.order(:role, :first_name)
    end

    def show
    end

    def new
      @admin = Admin.new
    end

    def create
      @admin = Admin.new(admin_params)
      
      if @admin.save
        redirect_to admin_admins_path, notice: 'Admin created successfully.'
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
    end

    def update
      if @admin.update(admin_params)
        redirect_to admin_admins_path, notice: 'Admin updated successfully.'
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      # Prevent super admin from deleting themselves
      if @admin == current_admin
        redirect_to admin_admins_path, alert: 'You cannot delete your own account.'
        return
      end
      
      @admin.destroy
      redirect_to admin_admins_path, notice: 'Admin deleted successfully.'
    end

    private

    def set_admin
      @admin = Admin.find(params[:id])
    end

    def admin_params
      params.require(:admin).permit(:first_name, :last_name, :email, :phone_number, :password, :password_confirmation, :role)
    end
  end
end


