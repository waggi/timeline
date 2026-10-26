class CreateEvents < ActiveRecord::Migration[8.1]
  def change
    create_table :events do |t|
      t.string :title, null: false
      t.date :happened_on, null: false
      t.text :description
      t.string :url
      t.string :source, null: false, default: "manual"

      t.timestamps
    end

    add_index :events, :happened_on
  end
end
