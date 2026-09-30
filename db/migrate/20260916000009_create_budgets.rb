class CreateBudgets < ActiveRecord::Migration[8.0]
  def change
    # category_id NULL = presupuesto general del mes. period = primer día del mes.
    create_table :budgets do |t|
      t.references :household, null: false, foreign_key: true
      t.references :category, foreign_key: true
      t.date :period, null: false
      t.decimal :amount, precision: 12, scale: 2, null: false

      t.timestamps
    end
    add_index :budgets, [ :household_id, :category_id, :period ], unique: true
  end
end
