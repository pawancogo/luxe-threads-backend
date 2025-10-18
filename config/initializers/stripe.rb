if Rails.application.credentials.stripe&.dig(:secret_key)
  Stripe.api_key = Rails.application.credentials.stripe[:secret_key]
end