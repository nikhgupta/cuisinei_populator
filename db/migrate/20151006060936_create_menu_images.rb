class CreateMenuImages < ActiveRecord::Migration
  def change
    create_table :menu_images do |t|
      t.references :place, index: true, foreign_key: true
      t.text :url
      t.string :type
      t.boolean :consumer_upload

      t.timestamps null: false
    end
  end
end
