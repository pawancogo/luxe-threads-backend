class EnhanceAddressesTable < ActiveRecord::Migration[7.1]
  def change
    # Add address details
    add_column :addresses, :label, :string, limit: 100
    add_column :addresses, :alternate_phone, :string, limit: 20
    add_column :addresses, :landmark, :string
    
    # Add location data
    add_column :addresses, :latitude, :decimal, precision: 10, scale: 8
    add_column :addresses, :longitude, :decimal, precision: 11, scale: 8
    add_column :addresses, :pincode_id, :bigint
    
    # Add verification
    add_column :addresses, :is_verified, :boolean, default: false
    add_column :addresses, :verification_status, :string, limit: 50
    
    # Add delivery instructions
    add_column :addresses, :delivery_instructions, :text
    
    # Add indexes
    add_index :addresses, :postal_code, name: 'idx_addresses_pincode'
    add_index :addresses, [:latitude, :longitude], name: 'idx_addresses_location'
    add_index :addresses, :verification_status
    
    # Note: SQLite doesn't support check constraints
    # Verification status validation will be enforced at application level
  end
end


