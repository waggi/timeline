class AddCategoryToEvents < ActiveRecord::Migration[8.1]
  def change
    add_column :events, :category, :string
    add_index :events, :category
  end
end
