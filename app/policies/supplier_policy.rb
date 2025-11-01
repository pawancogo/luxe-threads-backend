class SupplierPolicy < ApplicationPolicy
  def index?
    user.super_admin? || user.supplier_admin?
  end

  def show?
    user.super_admin? || user.supplier_admin?
  end

  def create?
    user.super_admin? || user.supplier_admin?
  end

  def update?
    user.super_admin? || user.supplier_admin?
  end

  def destroy?
    user.super_admin? || user.supplier_admin?
  end

  def verify?
    user.super_admin? || user.supplier_admin?
  end

  class Scope < Scope
    def resolve
      if user.super_admin? || user.supplier_admin?
        scope.all
      else
        scope.none
      end
    end
  end
end


