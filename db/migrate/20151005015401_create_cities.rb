class CreateCities < ActiveRecord::Migration
  def change
    create_table :cities do |t|
      t.string  :name,    null: false
      t.string  :state,   null: false
      t.string  :country, null: false

      t.decimal :lat_pos, precision: 13, scale: 10
      t.decimal :lng_pos, precision: 13, scale: 10
      t.decimal :lat_min, precision: 13, scale: 10
      t.decimal :lat_max, precision: 13, scale: 10
      t.decimal :lng_min, precision: 13, scale: 10
      t.decimal :lng_max, precision: 13, scale: 10

      t.integer :population
      t.integer :census_year

      t.integer :priority, default: 0

      t.integer :places_count, default: 0
      t.integer :completed_places_count, default: 0

      t.datetime :geocoded_at
      t.datetime :completed_at
      t.timestamps null: false
    end

    add_index :cities, [:name, :state, :country], unique: true
  end
end
