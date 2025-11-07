class CreateEmailTemplatesTable < ActiveRecord::Migration[7.1]
  def change
    create_table :email_templates do |t|
      t.string :template_type, null: false # order_confirmation, welcome, password_reset, etc.
      t.string :subject, null: false
      t.text :body_html
      t.text :body_text
      t.string :from_email
      t.string :from_name
      t.boolean :is_active, default: true
      t.json :variables, default: {} # Available variables for this template
      t.text :description
      
      t.timestamps
    end
    
    add_index :email_templates, :template_type, unique: true unless index_exists?(:email_templates, :template_type)
  end
end

