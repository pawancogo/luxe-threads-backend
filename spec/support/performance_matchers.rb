# frozen_string_literal: true

# Simple performance matcher for RSpec
# Usage: expect { code }.to perform_under(100).ms

RSpec::Matchers.define :perform_under do |expected_time|
  chain :ms do
    @unit = :milliseconds
    @expected_time = expected_time
  end

  chain :seconds do
    @unit = :seconds
    @expected_time = expected_time
  end

  match do |block|
    @unit ||= :milliseconds
    @expected_time ||= expected_time
    
    start_time = Time.current
    block.call
    end_time = Time.current
    
    @actual_time = if @unit == :milliseconds
      ((end_time - start_time) * 1000).round(2)
    else
      (end_time - start_time).round(2)
    end
    
    @actual_time <= @expected_time
  end

  failure_message do |_block|
    "Expected to perform under #{@expected_time} #{@unit}, but took #{@actual_time} #{@unit}"
  end

  description do
    "perform under #{@expected_time} #{@unit}"
  end
end

