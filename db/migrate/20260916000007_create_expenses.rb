class CreateExpenses < ActiveRecord::Migration[8.0]
  def change
    # household_id NULL = gasto personal. category_id NULL = pendiente de revisión.
    create_table :expenses do |t|
      t.references :user, null: false, foreign_key: true
      t.references :household, foreign_key: true
      t.references :category, foreign_key: true
      t.string :description, null: false
      t.decimal :amount, precision: 12, scale: 2, null: false
      t.date :spent_on, null: false
      t.boolean :recurring, null: false, default: false
      t.integer :source, null: false, default: 0
      t.text :notes

      t.timestamps
    end
    add_index :expenses, [ :household_id, :spent_on ]
  end
end
