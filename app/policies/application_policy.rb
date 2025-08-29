class ApplicationPolicy
  attr_reader :user, :record

  def initialize(user, record)
    @user = user
    @record = record
  end

  # This is the key method for RailsAdmin access.
  # Allow access only to admin roles.
  def access?
    user.present? && (user.super_admin? || user.product_admin? || user.order_admin?)
  end
end