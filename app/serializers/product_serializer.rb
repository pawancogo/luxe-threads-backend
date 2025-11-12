# frozen_string_literal: true

# Serializer for Product API responses
# Uses ProductPresenter for consistency
class ProductSerializer < BaseSerializer
  def serialize
    presenter = ProductPresenter.new(object)
    presenter.to_api_hash
  end
end

