# frozen_string_literal: true

namespace :data do
  desc "Migrate and enhance orders data"
  task migrate_orders: :environment do
    puts "Migrating orders..."
    
    Order.find_each do |order|
      # Generate order number if missing
      if order.order_number.blank?
        date = order.created_at.strftime('%Y%m%d')
        sequence = Order.where("order_number LIKE ?", "ORD-#{date}-%").count + 1
        order_number = "ORD-#{date}-#{sequence.to_s.rjust(8, '0')}"
        order.update_column(:order_number, order_number)
      end
      
      # Initialize status history if missing
      if order.status_history.blank?
        history = [{
          'status' => order.status,
          'timestamp' => order.created_at.iso8601,
          'note' => 'Order created'
        }]
        order.update_column(:status_history, history.to_json)
      end
      
      # Recalculate total if needed (for data consistency)
      calculated_total = order.order_items.sum { |item| (item.final_price || item.price_at_purchase) * item.quantity }
      if order.total_amount != calculated_total
        puts "  Warning: Order #{order.id} total mismatch (stored: #{order.total_amount}, calculated: #{calculated_total})"
      end
    end
    
    puts "✅ Orders migration completed!"
  end
end

