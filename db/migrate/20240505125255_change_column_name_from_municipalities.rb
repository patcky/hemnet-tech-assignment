class ChangeColumnNameFromMunicipalities < ActiveRecord::Migration[7.1]
  def change
    change_column :municipalities, :name, :string, null: false
    add_index :municipalities, :name, unique: true
  end
end
