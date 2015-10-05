class CreateItems < ActiveRecord::Migration
  def change
    create_table :items do |t|
      t.references :place, index: true, foreign_key: true
      t.string :name
      t.text :description
      t.integer :cost
      t.string :min_time
      t.string :max_time
      t.text :extra

      t.timestamps null: false
    end
  end
end
