class CreateProjects < ActiveRecord::Migration[8.0]
  def change
    create_table :projects do |t|
      t.string :name
      t.text :description
      t.string :color
      t.boolean :active
      t.references :user, null: false, foreign_key: true
      t.boolean :home_visible
      t.boolean :public
      t.boolean :system
      t.string :photo_url

      t.timestamps
    end
  end
end
