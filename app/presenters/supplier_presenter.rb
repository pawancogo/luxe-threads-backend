# frozen_string_literal: true

# Presenter for Supplier admin views
class SupplierPresenter
  attr_reader :supplier

  delegate :id, :email, :created_at, to: :supplier

  def initialize(supplier)
    @supplier = supplier
  end

  def company_name
    supplier.supplier_profile&.company_name || 'N/A'
  end

  def status_label
    profile = supplier.supplier_profile
    return 'N/A' unless profile
    
    case profile.status.to_s
    when 'active' then 'Active'
    when 'pending' then 'Pending Approval'
    when 'suspended' then 'Suspended'
    when 'rejected' then 'Rejected'
    else profile.status.to_s.humanize
    end
  end

  def status_badge_class
    profile = supplier.supplier_profile
    return 'badge-secondary' unless profile
    
    {
      'active' => 'badge-success',
      'pending' => 'badge-warning',
      'suspended' => 'badge-danger',
      'rejected' => 'badge-danger'
    }[profile.status.to_s] || 'badge-secondary'
  end

  def formatted_created_at
    supplier.created_at&.strftime('%B %d, %Y')
  end

  def product_count
    supplier.supplier_profile&.products&.count || 0
  end

  def total_revenue
    # Calculate from order items
    0 # TODO: Implement revenue calculation
  end
end

