class CreatePlaces < ActiveRecord::Migration
  def change
    create_table :places do |t|
      t.references :city, unique: true, null: false

      t.string  :title
      t.text    :address

      t.decimal :lat, precision: 13, scale: 10
      t.decimal :lng, precision: 13, scale: 10
      t.string  :establishment_name

      t.integer :ref_id
      t.decimal :ref_rating, precision: 3, scale: 2
      t.integer :ref_votes_count, default: 0

      t.text    :raw_snippet

      t.integer :locked_by      # locked for updates
      t.integer :items_count, default: 0

      t.datetime :completed_at
      t.timestamps null: false
    end
  end
end
