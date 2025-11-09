# PaperTrail configuration for production-ready audit logging
PaperTrail.configure do |config|
  # Enable PaperTrail
  config.enabled = true
  
  # Store metadata in meta column (JSON)
  # This prevents PaperTrail from trying to save controller_info as direct attributes
  config.has_paper_trail_defaults = {
    meta: {}
  }
end
