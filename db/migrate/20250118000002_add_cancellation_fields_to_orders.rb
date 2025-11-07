class AddCancellationFieldsToOrders < ActiveRecord::Migration[7.1]
  def change
    add_column :orders, :cancellation_reason, :text
    add_column :orders, :cancelled_at, :datetime
    add_column :orders, :cancelled_by, :string # 'customer' or 'admin'
    
    add_index :orders, :cancelled_at
  end
end

