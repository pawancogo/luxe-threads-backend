class AddUserIdToSupplierProfiles < ActiveRecord::Migration[7.1]
  def change
    add_reference :supplier_profiles, :user, null: true, foreign_key: true
  end
end
