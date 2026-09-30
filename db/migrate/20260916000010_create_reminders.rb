class CreateReminders < ActiveRecord::Migration[8.0]
  def change
    create_table :reminders do |t|
      t.references :household, null: false, foreign_key: true
      t.references :user, foreign_key: true
      t.string :title, null: false
      t.decimal :amount, precision: 12, scale: 2
      t.date :due_on, null: false
      t.datetime :paid_at
      t.datetime :notified_at

      t.timestamps
    end
    add_index :reminders, [ :household_id, :due_on ]
  end
end
