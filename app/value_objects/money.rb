# frozen_string_literal: true

# Value object for money representation
# Ensures consistent handling of currency amounts
class Money
  include Comparable

  attr_reader :amount, :currency

  DEFAULT_CURRENCY = 'USD'.freeze

  def initialize(amount, currency = DEFAULT_CURRENCY)
    @amount = BigDecimal(amount.to_s)
    @currency = currency.to_s.upcase
  end

  def ==(other)
    return false unless other.is_a?(Money)
    amount == other.amount && currency == other.currency
  end

  def <=>(other)
    return nil unless other.is_a?(Money) && currency == other.currency
    amount <=> other.amount
  end

  def +(other)
    raise ArgumentError, 'Currency mismatch' unless currency == other.currency
    Money.new(amount + other.amount, currency)
  end

  def -(other)
    raise ArgumentError, 'Currency mismatch' unless currency == other.currency
    Money.new(amount - other.amount, currency)
  end

  def *(multiplier)
    Money.new(amount * multiplier, currency)
  end

  def /(divisor)
    Money.new(amount / divisor, currency)
  end

  def zero?
    amount.zero?
  end

  def positive?
    amount > 0
  end

  def negative?
    amount < 0
  end

  def to_s
    format('%.2f', amount)
  end

  def to_d
    amount
  end

  def formatted
    "$#{to_s}"
  end

  def self.zero(currency = DEFAULT_CURRENCY)
    new(0, currency)
  end

  def self.from_cents(cents, currency = DEFAULT_CURRENCY)
    new(cents / 100.0, currency)
  end
end

