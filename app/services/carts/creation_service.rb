# frozen_string_literal: true

# Service for creating carts
# Follows Single Responsibility Principle
module Carts
  class CreationService < BaseService
    attr_reader :cart

    def initialize(user)
      super()
      @user = user
    end

    def call
      return existing_cart if existing_cart.present?

      @cart = @user.create_cart!
      set_result(@cart)
      self
    rescue StandardError => e
      handle_error(e)
      self
    end

    private

    def existing_cart
      @existing_cart ||= @user.cart
    end
  end
end

