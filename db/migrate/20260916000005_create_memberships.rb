class CreateMemberships < ActiveRecord::Migration[8.0]
  def change
    create_table :memberships do |t|
      t.references :user, null: false, foreign_key: true
      t.references :household, null: false, foreign_key: true
      t.integer :role, null: false, default: 0

      t.timestamps
    end
    add_index :memberships, [ :household_id, :user_id ], unique: true
  end
end
