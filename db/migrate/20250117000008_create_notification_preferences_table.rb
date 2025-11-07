# frozen_string_literal: true

class CreateNotificationPreferencesTable < ActiveRecord::Migration[7.1]
  def change
    unless table_exists?(:notification_preferences)
      create_table :notification_preferences do |t|
        t.references :user, null: false, foreign_key: true
        
        # Preferences (JSON for flexibility)
        t.text :preferences, default: '{
          "email": {
            "order_updates": true,
            "promotions": true,
            "reviews": true,
            "system": true
          },
          "sms": {
            "order_updates": true,
            "promotions": false,
            "reviews": false,
            "system": false
          },
          "push": {
            "order_updates": true,
            "promotions": true,
            "reviews": true,
            "system": true
          }
        }'
        
        t.timestamps
      end
      
      # Add unique constraint on user_id
      add_index :notification_preferences, :user_id, unique: true unless index_exists?(:notification_preferences, :user_id)
    end
  end
end

