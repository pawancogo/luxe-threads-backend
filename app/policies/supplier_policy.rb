# frozen_string_literal: true

class SupplierPolicy < ApplicationPolicy
  # Suppliers are User records with role: 'supplier'
  # This policy controls access to supplier management functionality

  def index?
    user.super_admin? || user.supplier_admin?
  end

  def show?
    user.super_admin? || user.supplier_admin? || record == user
  end

  def create?
    user.super_admin? || user.supplier_admin?
  end

  def new?
    create?
  end

  def update?
    user.super_admin? || user.supplier_admin? || record == user
  end

  def edit?
    update?
  end

  def destroy?
    user.super_admin? || user.supplier_admin?
  end

  def approve?
    user.super_admin? || user.supplier_admin?
  end

  def reject?
    user.super_admin? || user.supplier_admin?
  end

  def suspend?
    user.super_admin? || user.supplier_admin?
  end

  def activate?
    user.super_admin? || user.supplier_admin?
  end

  def deactivate?
    user.super_admin? || user.supplier_admin?
  end

  def update_role?
    user.super_admin? || user.supplier_admin?
  end

  def invite?
    user.super_admin? || user.supplier_admin?
  end

  def resend_invitation?
    user.super_admin? || user.supplier_admin?
  end

  def stats?
    user.super_admin? || user.supplier_admin? || record == user
  end

  def bulk_action?
    user.super_admin? || user.supplier_admin?
  end

  class Scope < Scope
    def resolve
      if user.super_admin? || user.supplier_admin?
        scope.where(role: 'supplier')
      else
        scope.where(id: user.id, role: 'supplier')
      end
    end
  end
end

