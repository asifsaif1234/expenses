# frozen_string_literal: true

class CreateExpenses < ActiveRecord::Migration[8.0]
  def change
    create_table :expenses do |t|
      t.decimal :amount, precision: 10, scale: 2, null: false
      t.date :expense_date, null: false
      t.text :description
      t.references :category, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end

    add_index :expenses, :expense_date
    add_index :expenses, [ :user_id, :expense_date ]
    add_index :expenses, [ :category_id, :expense_date ]
    add_index :expenses, [ :user_id, :category_id, :expense_date ],
              name: 'index_expenses_on_user_category_date'
  end
end
