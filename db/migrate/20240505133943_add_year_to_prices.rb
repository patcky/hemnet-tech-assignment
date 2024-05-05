class AddYearToPrices < ActiveRecord::Migration[7.1]
  def change
    add_column :prices, :year, :integer, null: false, index: true
  end
end
