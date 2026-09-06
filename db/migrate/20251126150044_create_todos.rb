class CreateTodos < ActiveRecord::Migration[8.0]
  def change
    create_table :todos do |t|
      t.string :name
      t.text :description
      t.boolean :active
      t.date :due
      t.integer :priority
      t.references :user, null: false, foreign_key: true
      t.references :project, null: false, foreign_key: true
      t.string :source
      t.string :where
      t.string :url
      t.integer :depends_on_id
      t.datetime :hide_until
      t.integer :progress_status
      t.boolean :favorite
      t.text :sys_notes
      t.string :photo_url

      t.timestamps
    end
  end
end
