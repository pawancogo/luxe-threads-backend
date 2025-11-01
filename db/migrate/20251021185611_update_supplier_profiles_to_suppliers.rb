class UpdateSupplierProfilesToSuppliers < ActiveRecord::Migration[7.1]
  def change
    # Remove the old user_id column and add supplier_id
    remove_reference :supplier_profiles, :user, index: true, foreign_key: true
    add_reference :supplier_profiles, :supplier, null: false, foreign_key: true, index: true
  end
end
