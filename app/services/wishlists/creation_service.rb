# frozen_string_literal: true

# Service for creating wishlists
# Follows Single Responsibility Principle
module Wishlists
  class CreationService < BaseService
    attr_reader :wishlist

    def initialize(user)
      super()
      @user = user
    end

    def call
      return existing_wishlist if existing_wishlist.present?

      @wishlist = @user.create_wishlist!
      set_result(@wishlist)
      self
    rescue StandardError => e
      handle_error(e)
      self
    end

    private

    def existing_wishlist
      @existing_wishlist ||= @user.wishlist
    end
  end
end

