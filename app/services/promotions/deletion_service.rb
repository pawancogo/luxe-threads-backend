# frozen_string_literal: true

# Service for deleting promotions
module Promotions
  class DeletionService < BaseService
    attr_reader :promotion

    def initialize(promotion)
      super()
      @promotion = promotion
    end

    def call
      with_transaction do
        delete_promotion
      end
      set_result(@promotion)
      self
    rescue StandardError => e
      handle_error(e)
      self
    end

    private

    def delete_promotion
      @promotion.destroy
    end
  end
end

