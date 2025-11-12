# frozen_string_literal: true

# Data Integrity Guide for Models
# 
# This file documents the safe patterns for data updates to ensure validations
# and callbacks always run, regardless of entry point (Controller, Rails Admin, Console).
#
# ============================================================================
# SAFE UPDATE METHODS (Always Use These)
# ============================================================================
#
# ✅ save / save!
#   - Triggers validations and callbacks
#   - Use in: Models, Services, Controllers, Rails Admin, Console
#   - Example: @order.save!
#
# ✅ update / update!
#   - Triggers validations and callbacks
#   - Use in: Models, Services, Controllers, Rails Admin, Console
#   - Example: @order.update!(status: 'shipped')
#
# ✅ create / create!
#   - Triggers validations and callbacks
#   - Use in: Models, Services, Controllers, Rails Admin, Console
#   - Example: Order.create!(order_params)
#
# ============================================================================
# DANGEROUS METHODS (Avoid Unless Absolutely Necessary)
# ============================================================================
#
# ❌ update_column / update_columns
#   - BYPASSES validations and callbacks
#   - Only use for:
#     1. Avoiding infinite callback loops (e.g., status_history in status change callbacks)
#     2. Performance-critical bulk updates where validations are guaranteed elsewhere
#     3. Timestamp updates that don't need callbacks (e.g., last_login_at)
#   - MUST be documented with a comment explaining why it's safe
#   - Example: update_column(:status_history, history) # Avoids callback loop
#
# ❌ update_all
#   - BYPASSES validations and callbacks
#   - Only use for bulk updates where validations are guaranteed
#   - Example: Order.where(status: 'pending').update_all(status: 'cancelled')
#
# ============================================================================
# RAILS ADMIN INTEGRATION
# ============================================================================
#
# Rails Admin by default uses save/update which triggers validations and callbacks.
# No special configuration needed - model validations and callbacks will run.
#
# For complex workflows, you can override Rails Admin actions to call services:
# See: config/initializers/rails_admin.rb (if needed)
#
# ============================================================================
# CONSOLE OPERATIONS
# ============================================================================
#
# Always use save/update/create in console:
#   ✅ Order.find(1).update!(status: 'shipped')
#   ❌ Order.find(1).update_column(:status, 'shipped')
#
# ============================================================================
# SERVICE OBJECTS
# ============================================================================
#
# Services should always use save/update/create:
#   ✅ @order.update!(params)
#   ❌ @order.update_columns(params)
#
# ============================================================================
# MODEL CALLBACKS
# ============================================================================
#
# Model callbacks (before_save, after_save, etc.) run automatically when using:
# - save / save!
# - update / update!
# - create / create!
#
# They DO NOT run when using:
# - update_column / update_columns
# - update_all
#
# ============================================================================
# VALIDATIONS
# ============================================================================
#
# Model validations run automatically when using:
# - save / save!
# - update / update!
# - create / create!
#
# They DO NOT run when using:
# - update_column / update_columns
# - update_all
#
# ============================================================================
# EXAMPLES
# ============================================================================
#
# ✅ GOOD: Controller update
#   def update
#     @order.update!(order_params)  # Triggers validations and callbacks
#   end
#
# ✅ GOOD: Rails Admin (automatic)
#   Rails Admin uses @order.save which triggers validations and callbacks
#
# ✅ GOOD: Console
#   Order.find(1).update!(status: 'shipped')  # Triggers validations and callbacks
#
# ✅ GOOD: Service
#   def call
#     @order.update!(status: 'shipped')  # Triggers validations and callbacks
#   end
#
# ❌ BAD: Bypassing validations
#   @order.update_column(:status, 'shipped')  # No validations, no callbacks!
#
# ✅ ACCEPTABLE: Avoiding callback loop (with documentation)
#   # In after_update callback, updating status_history
#   # Using update_column to avoid infinite loop
#   update_column(:status_history, history.to_json)
#
# ============================================================================

module DataIntegrityGuide
  # This is a documentation-only module
  # Include it in models if you want to reference the guide
  # It doesn't add any functionality
end

