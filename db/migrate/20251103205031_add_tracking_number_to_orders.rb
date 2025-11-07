class AddTrackingNumberToOrders < ActiveRecord::Migration[7.1]
  def up
    unless column_exists?(:orders, :tracking_number)
      add_column :orders, :tracking_number, :string
      add_index :orders, :tracking_number unless index_exists?(:orders, :tracking_number)
    end
  end

  def down
    if column_exists?(:orders, :tracking_number)
      remove_index :orders, :tracking_number if index_exists?(:orders, :tracking_number)
      remove_column :orders, :tracking_number
    end
  end
end
