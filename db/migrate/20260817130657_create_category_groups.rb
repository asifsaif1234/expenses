# frozen_string_literal: true

class CreateCategoryGroups < ActiveRecord::Migration[8.0]
  def change
    create_table :category_groups do |t|
      t.string :name, null: false
      t.string :icon, default: "📁"
      t.integer :position, default: 0
      t.references :user, foreign_key: true, null: true
      t.boolean :is_system, default: false
      t.boolean :is_active, default: true

      t.timestamps
    end

    add_index :category_groups, [ :user_id, :name ], unique: true
    add_index :category_groups, :position
    add_index :category_groups, :is_system
  end
end
