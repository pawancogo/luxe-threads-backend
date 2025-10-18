class CreateReturnMedia < ActiveRecord::Migration[7.1]
  def change
    create_table :return_media do |t|
      t.references :return_item, null: false, foreign_key: true
      t.string :media_url
      t.string :media_type

      t.timestamps
    end
  end
end
