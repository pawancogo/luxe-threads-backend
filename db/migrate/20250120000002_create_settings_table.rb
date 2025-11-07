class CreateSettingsTable < ActiveRecord::Migration[7.1]
  def change
    create_table :settings do |t|
      t.string :key, null: false, index: { unique: true }
      t.text :value
      t.string :value_type, default: 'string' # string, integer, float, boolean, json
      t.string :category, default: 'general' # general, payment, shipping, email, feature_flags
      t.text :description
      t.boolean :is_public, default: false # Whether this setting can be exposed to frontend
      
      t.timestamps
    end
  end
end

