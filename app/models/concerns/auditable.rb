# frozen_string_literal: true

# Concern for models that need audit logging
# Extracts audit-related functionality
module Auditable
  extend ActiveSupport::Concern

  included do
    # PaperTrail for audit logging
    has_paper_trail
    
    # Soft delete functionality
    acts_as_paranoid
  end

  # Get audit summary
  def audit_summary
    AuditService.audit_summary(self)
  end

  # Get audit trail
  def audit_trail
    AuditService.audit_trail_for(self)
  end
end

