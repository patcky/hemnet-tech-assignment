class AddMunicipalityRefToPrices < ActiveRecord::Migration[7.1]
  def change
    add_reference :prices, :municipality, null: false, foreign_key: true
  end
end
