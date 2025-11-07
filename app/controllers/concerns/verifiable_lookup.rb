# frozen_string_literal: true

# Concern for looking up verifiable objects (Admin, User, Supplier)
# Reduces code duplication in controllers that work with polymorphic verifiable associations
module VerifiableLookup
  extend ActiveSupport::Concern

  VERIFIABLE_TYPES = {
    'admin' => Admin,
    'user' => User,
    'supplier' => User  # Suppliers are now Users with role='supplier'
  }.freeze

  included do
    private

    # Find verifiable object based on type and id
    # @param type [String] The verifiable type ('admin', 'user', 'supplier')
    # @param id [String, Integer] The verifiable id
    # @return [Admin, User] The verifiable object (suppliers are Users)
    # @raise [ArgumentError] If type is invalid
    # @raise [ActiveRecord::RecordNotFound] If record not found
    def find_verifiable(type, id)
      klass = verifiable_class(type)
      if type.to_s.downcase == 'supplier'
        # Suppliers are Users with role='supplier'
        User.where(role: 'supplier').find(id)
      else
        klass.find(id)
      end
    end

    # Get the model class for a verifiable type
    # @param type [String] The verifiable type
    # @return [Class] The model class
    # @raise [ArgumentError] If type is invalid
    def verifiable_class(type)
      VERIFIABLE_TYPES[type.to_s.downcase] || raise(ArgumentError, "Invalid verifiable type: #{type}")
    end

    # Check if a verifiable type is valid
    # @param type [String] The verifiable type to check
    # @return [Boolean] True if valid, false otherwise
    def valid_verifiable_type?(type)
      VERIFIABLE_TYPES.key?(type.to_s.downcase)
    end

    # Set instance variables for verifiable in controller
    # @param type [String] The verifiable type
    # @param id [String, Integer] The verifiable id
    # @param email [String, nil] Optional email parameter
    def load_verifiable_for_view(type, id, email = nil)
      @verifiable_type = type
      @verifiable_id = id
      @email = email
      @verifiable = find_verifiable(type, id)
      @email ||= @verifiable.email if @verifiable.respond_to?(:email)
    end
  end
end


