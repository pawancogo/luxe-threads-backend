# frozen_string_literal: true

# Concern for controllers that need to find records by slug or ID
# Extracts common slug/ID lookup pattern
module SlugOrIdLookup
  extend ActiveSupport::Concern

  private

  # Find record by slug or ID
  # Usage: find_by_slug_or_id(ModelClass, params[:id])
  def find_by_slug_or_id(model_class, identifier)
    model_class.find_by(slug: identifier) || model_class.find(identifier)
  end
end

