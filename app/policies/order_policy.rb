class OrderPolicy < ApplicationPolicy
  def index?
    user.super_admin? || user.order_admin?
  end

  def show?
    user.super_admin? || user.order_admin? || record.user == user
  end

  def create?
    user.super_admin? || user.order_admin?
  end

  def update?
    user.super_admin? || user.order_admin?
  end

  def destroy?
    user.super_admin? || user.order_admin?
  end

  class Scope < Scope
    def resolve
      if user.super_admin? || user.order_admin?
        scope.all
      else
        scope.where(user: user)
      end
    end
  end
end


