# frozen_string_literal: true

class AddRejectionReasonToProducts < ActiveRecord::Migration[7.1]
  def change
    add_column :products, :rejection_reason, :text unless column_exists?(:products, :rejection_reason)
    add_index :products, :rejection_reason, where: "rejection_reason IS NOT NULL" unless index_exists?(:products, :rejection_reason)
  end
end

