# frozen_string_literal: true

# Service for updating category path and level
# Extracted from Category model callbacks to follow SOLID principles
module Categories
  class PathService < BaseService
    def initialize(category)
      super()
      @category = category
    end

    def call
      update_path_and_level
      set_result(@category)
      self
    rescue StandardError => e
      handle_error(e)
      self
    end

    private

    def update_path_and_level
      if @category.parent_id.present? && @category.parent
        @category.level = @category.parent.level + 1
        @category.path = "#{@category.parent.path} > #{@category.name}"
      else
        @category.level = 0
        @category.path = @category.name
      end
    end
  end
end

