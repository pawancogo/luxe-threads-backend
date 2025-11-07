# frozen_string_literal: true

# Concern to restrict supplier access to customer-only features
module CustomerOnly
  extend ActiveSupport::Concern

  included do
    before_action :reject_suppliers
  end

  private

  def reject_suppliers
    if current_user&.supplier?
      render_forbidden('Suppliers cannot access this feature')
    end
  end
end


