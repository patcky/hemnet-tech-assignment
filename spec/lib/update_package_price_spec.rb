# frozen_string_literal: true

require "spec_helper"

RSpec.describe UpdatePackagePrice do
  it "updates the current price of the provided package" do
    package = Package.create!(name: "Dunderhonung")
    municipality = Municipality.create!(name: "Göteborg")

    UpdatePackagePrice.call(package: package, amount: 200_00, municipality: municipality)
    expect(package.reload.amount_cents).to eq(200_00)
  end

  it "only updates the passed package price" do
    package = Package.create!(name: "Dunderhonung")
    other_package = Package.create!(name: "Farmors köttbullar", amount_cents: 100_00)
    municipality = Municipality.create!(name: "Lidköping")

    expect {
      UpdatePackagePrice.call(package: package, amount: 200_00, municipality: municipality)
    }.not_to change {
      other_package.reload.amount_cents
    }
  end

  it "stores the old price of the provided package in its price history" do
    package = Package.create!(name: "Dunderhonung", amount_cents: 100_00)
    municipality = Municipality.create!(name: "Luleå")

    UpdatePackagePrice.call(package: package, amount: 200_00, municipality: municipality)
    expect(package.prices.size).to eq(2)
    price = package.prices.first
    expect(price.amount_cents).to eq(100_00)
  end

  it "creates a new price history record for a package without previous prices" do
    package = Package.create!(name: "Sommarhonung")
    municipality = Municipality.create!(name: "Luleå")

    UpdatePackagePrice.call(package: package, amount: 200_00, municipality: municipality)
    expect(package.prices.size).to eq(1)
    expect(package.prices.first.amount_cents).to eq(200_00)
  end

  it "associates the price history record with the provided municipality" do
    package = Package.create!(name: "Dunderhonung")
    municipality = Municipality.create!(name: "Luleå")

    UpdatePackagePrice.call(package: package, amount: 200_00, municipality: municipality)
    expect(package.prices.first.municipality).to eq(municipality)
  end

  it "associates the price history record with the provided year" do
    package = Package.create!(name: "Dunderhonung")
    municipality = Municipality.create!(name: "Luleå")

    UpdatePackagePrice.call(package: package, amount: 200_00, municipality: municipality, year: 1999)
    expect(package.prices.first.year).to eq(1999)
  end

  it "defaults price year to the current year if no year is provided" do
    package = Package.create!(name: "Dunderhonung")
    municipality = Municipality.create!(name: "Luleå")

    UpdatePackagePrice.call(package: package, amount: 200_00, municipality: municipality)
    expect(package.prices.first.year).to eq(Date.today.year)
  end

  it "raises an error if the package is not provided or doesn't exist" do
    municipality = Municipality.create!(name: "Luleå")
    expect {
      UpdatePackagePrice.call(package: nil, amount: 200_00, municipality: municipality)
    }.to raise_error(ArgumentError)
    expect {
      UpdatePackagePrice.call(package: Package.new, amount: 200_00, municipality: municipality)
    }.to raise_error(ActiveRecord::RecordInvalid)
  end

  it "raises an error if amount is not provided or is incorrect" do
    package = Package.create!(name: "Dunderhonung")
    municipality = Municipality.create!(name: "Luleå")

    expect {
      UpdatePackagePrice.call(package: package, amount: nil, municipality: municipality)
    }.to raise_error(ArgumentError)
    expect {
      UpdatePackagePrice.call(package: package, amount: 0, municipality: municipality)
    }.to raise_error(ArgumentError)

    expect(package.reload.amount_cents).to be_zero
    expect(package.prices).to be_empty
  end
end
