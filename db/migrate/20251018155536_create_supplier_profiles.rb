class CreateSupplierProfiles < ActiveRecord::Migration[7.1]
  def change
    create_table :supplier_profiles do |t|
      t.references :user, null: false, foreign_key: true
      t.string :company_name
      t.string :gst_number
      t.text :description
      t.string :website_url
      t.boolean :verified

      t.timestamps
    end
  end
end
