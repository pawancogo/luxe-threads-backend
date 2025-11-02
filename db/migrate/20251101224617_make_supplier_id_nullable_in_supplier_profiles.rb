class MakeSupplierIdNullableInSupplierProfiles < ActiveRecord::Migration[7.1]
  def change
    change_column_null :supplier_profiles, :supplier_id, true
  end
end
