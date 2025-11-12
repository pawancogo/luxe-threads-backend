# frozen_string_literal: true

# Service for deleting categories
module Categories
  class DeletionService < BaseService
    attr_reader :category

    def initialize(category)
      super()
      @category = category
    end

    def call
      with_transaction do
        delete_category
      end
      set_result(@category)
      self
    rescue StandardError => e
      handle_error(e)
      self
    end

    private

    def delete_category
      @category.destroy
    end
  end
end

