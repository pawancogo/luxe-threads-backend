# frozen_string_literal: true

class RenameChangesToActivityChangesInAdminActivities < ActiveRecord::Migration[7.1]
  def change
    rename_column :admin_activities, :changes, :activity_changes if column_exists?(:admin_activities, :changes)
  end
end

