# frozen_string_literal: true

# Service for updating categories
module Categories
  class UpdateService < BaseService
    attr_reader :category

    def initialize(category, category_params)
      super()
      @category = category
      @category_params = category_params
    end

    def call
      with_transaction do
        update_category
      end
      set_result(@category)
      self
    rescue StandardError => e
      handle_error(e)
      self
    end

    private

    def update_category
      unless @category.update(@category_params)
        add_errors(@category.errors.full_messages)
        raise ActiveRecord::RecordInvalid, @category
      end
    end
  end
end

