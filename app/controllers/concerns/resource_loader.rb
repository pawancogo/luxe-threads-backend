# frozen_string_literal: true

# Concern for loading and authorizing resources
# Follows DRY principle - eliminates duplicate find/authorize logic
module ResourceLoader
  extend ActiveSupport::Concern

  private

  # Load a resource by ID with automatic error handling
  # Usage: before_action :load_resource, only: [:show, :update, :destroy]
  def load_resource
    resource_class = self.class.resource_class
    @resource = resource_class.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render_not_found("#{resource_class.model_name.human} not found")
  end

  # Load resource with custom scope
  # Usage: load_scoped_resource(Product.where(supplier_profile_id: current_supplier.id))
  def load_scoped_resource(scope)
    @resource = scope.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render_not_found('Resource not found')
  end

  # Load resource and authorize access
  # Usage: load_and_authorize_resource
  def load_and_authorize_resource
    load_resource
    authorize_resource_access if respond_to?(:authorize_resource_access, true)
  end

  class_methods do
    # Set the resource class for this controller
    # Usage: resource_class Product
    def resource_class(klass = nil)
      if klass
        @resource_class = klass
      else
        @resource_class ||= model_name.classify.constantize
      end
    end
  end
end

