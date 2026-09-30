class CreateIncomes < ActiveRecord::Migration[8.0]
  def change
    create_table :incomes do |t|
      t.references :user, null: false, foreign_key: true
      t.references :household, foreign_key: true
      t.string :description, null: false
      t.decimal :amount, precision: 12, scale: 2, null: false
      t.date :received_on, null: false

      t.timestamps
    end
    add_index :incomes, [ :household_id, :received_on ]
  end
end
