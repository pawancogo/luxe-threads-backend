class AdminPolicy < ApplicationPolicy
  def index?
    user.super_admin? || user.user_admin?
  end

  def show?
    user.super_admin? || user.user_admin?
  end

  def create?
    user.super_admin?
  end

  def update?
    user.super_admin? || (user.user_admin? && record != user)
  end

  def destroy?
    user.super_admin? && record != user
  end

  def dashboard?
    user.super_admin? || user.user_admin? || user.product_admin? || user.order_admin? || user.supplier_admin?
  end

  class Scope < Scope
    def resolve
      if user.super_admin?
        scope.all
      elsif user.user_admin?
        scope.where.not(id: user.id)
      else
        scope.none
      end
    end
  end
end
