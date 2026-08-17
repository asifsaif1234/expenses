class CreateCategories < ActiveRecord::Migration[8.0]
  def change
    create_table :categories do |t|

      t.string :name, null: false
      t.string :icon, default: "📌"
      t.string :color, default: "#6c757d"
      t.text :description
      t.references :user, foreign_key: true, null: true
      t.references :category_group, foreign_key: true, null: true
      t.boolean :is_system, default: false
      t.boolean :is_active, default: true
      
      t.timestamps
    end
    
    # Add indexes separately
    add_index :categories, [:user_id, :name], unique: true
    add_index :categories, :is_system
    add_index :categories, :is_active
  end
end
