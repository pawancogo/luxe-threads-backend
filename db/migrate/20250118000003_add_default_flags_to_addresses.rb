class AddDefaultFlagsToAddresses < ActiveRecord::Migration[7.1]
  def change
    add_column :addresses, :is_default_shipping, :boolean, default: false
    add_column :addresses, :is_default_billing, :boolean, default: false
    
    add_index :addresses, :is_default_shipping
    add_index :addresses, :is_default_billing
  end
end

