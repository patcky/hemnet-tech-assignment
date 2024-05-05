# frozen_string_literal: true

puts "Removing old packages and their price histories"
Package.destroy_all
Municipality.destroy_all
Price.destroy_all

puts "Creating new packages"

Package.create!(
  YAML.load_file(Rails.root.join("import/packages.yaml"))
)

puts "Creating new municipalities"

Municipality.create!(
  YAML.load_file(Rails.root.join("import/municipalities.yaml"))
)

puts "Creating a price history for the packages"
packages = YAML.load_file(Rails.root.join("import/initial_price_history.yaml"))

packages.each do |package, prices|
  package = Package.find_by!(name: package)
  prices.each do |price|
    municipality = Municipality.find_by!(name: price["municipality"].downcase)
    UpdatePackagePrice.call(package, price["amount_cents"], municipality)
  end
end
