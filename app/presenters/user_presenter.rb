# frozen_string_literal: true

# Presenter for User admin views
class UserPresenter
  attr_reader :user

  delegate :id, :email, :first_name, :last_name, :phone_number, :status, :created_at, to: :user

  def initialize(user)
    @user = user
  end

  def full_name
    user.full_name || 'N/A'
  end

  def status_label
    case user.status.to_s
    when 'active' then 'Active'
    when 'inactive' then 'Inactive'
    when 'suspended' then 'Suspended'
    when 'deleted' then 'Deleted'
    else user.status.to_s.humanize
    end
  end

  def status_badge_class
    {
      'active' => 'badge-success',
      'inactive' => 'badge-secondary',
      'suspended' => 'badge-warning',
      'deleted' => 'badge-danger'
    }[user.status.to_s] || 'badge-secondary'
  end

  def email_verified_badge
    user.email_verified? ? 'badge-success' : 'badge-warning'
  end

  def email_verified_label
    user.email_verified? ? 'Verified' : 'Unverified'
  end

  def formatted_created_at
    user.created_at&.strftime('%B %d, %Y')
  end

  def order_count
    user.orders.count
  end

  def total_spent
    user.orders.where(payment_status: 'paid').sum(:total_amount)
  end

  def formatted_total_spent
    format_currency(total_spent)
  end

  private

  def format_currency(amount, currency = 'INR')
    return 'N/A' unless amount
    
    case currency
    when 'USD'
      "$#{amount.to_f.round(2)}"
    when 'INR'
      "₹#{amount.to_f.round(2)}"
    else
      "#{amount.to_f.round(2)} #{currency}"
    end
  end
end

