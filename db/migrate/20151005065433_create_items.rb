class CreateItems < ActiveRecord::Migration
  def change
    create_table :items do |t|
      t.references :place, index: true, foreign_key: true
      t.string :name
      t.text :description
      t.integer :cost

      t.timestamps null: false
    end
  end
end
