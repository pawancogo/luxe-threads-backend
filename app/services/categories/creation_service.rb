# frozen_string_literal: true

# Service for creating categories
module Categories
  class CreationService < BaseService
    attr_reader :category

    def initialize(category_params)
      super()
      @category_params = category_params
    end

    def call
      with_transaction do
        create_category
      end
      set_result(@category)
      self
    rescue StandardError => e
      handle_error(e)
      self
    end

    private

    def create_category
      @category = Category.new(@category_params)
      
      unless @category.save
        add_errors(@category.errors.full_messages)
        raise ActiveRecord::RecordInvalid, @category
      end
    end
  end
end

