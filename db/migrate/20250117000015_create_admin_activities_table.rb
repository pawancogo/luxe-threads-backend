# frozen_string_literal: true

class CreateAdminActivitiesTable < ActiveRecord::Migration[7.1]
  def change
    unless table_exists?(:admin_activities)
      create_table :admin_activities do |t|
        t.references :admin, null: false, foreign_key: true
        
        # Activity Details
        t.string :action, limit: 100, null: false # create_product, approve_order, etc.
        t.string :resource_type, limit: 50 # product, order, supplier, etc.
        t.integer :resource_id
        
        # Details
        t.text :description
        t.text :changes, default: '{}' # Before/after changes (JSON)
        t.string :ip_address, limit: 50
        t.text :user_agent
        
        t.timestamps
      end
      
      add_index :admin_activities, [:resource_type, :resource_id] unless index_exists?(:admin_activities, [:resource_type, :resource_id])
      add_index :admin_activities, :action unless index_exists?(:admin_activities, :action)
      add_index :admin_activities, :created_at unless index_exists?(:admin_activities, :created_at)
    end
  end
end

