class CreateCategories < ActiveRecord::Migration[8.0]
  def change
    # household_id NULL = categoría global, disponible para todos los hogares.
    create_table :categories do |t|
      t.references :household, foreign_key: true
      t.string :name, null: false
      t.string :color, null: false, default: "#2F4F4A"

      t.timestamps
    end
    add_index :categories, [ :household_id, :name ], unique: true
  end
end
