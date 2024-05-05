# frozen_string_literal: true

require "spec_helper"

RSpec.describe UpdatePackagePrice do
  it "updates the current price of the provided package" do
    package = Package.create!(name: "Dunderhonung")
    municipality = Municipality.create!(name: "Göteborg")

    UpdatePackagePrice.call(package, 200_00, municipality)
    expect(package.reload.amount_cents).to eq(200_00)
  end

  it "only updates the passed package price" do
    package = Package.create!(name: "Dunderhonung")
    other_package = Package.create!(name: "Farmors köttbullar", amount_cents: 100_00)
    municipality = Municipality.create!(name: "Lidköping")

    expect {
      UpdatePackagePrice.call(package, 200_00, municipality)
    }.not_to change {
      other_package.reload.amount_cents
    }
  end

  it "stores the old price of the provided package in its price history" do
    package = Package.create!(name: "Dunderhonung", amount_cents: 100_00)
    municipality = Municipality.create!(name: "Luleå")

    UpdatePackagePrice.call(package, 200_00, municipality)
    expect(package.prices).to be_one
    price = package.prices.first
    expect(price.amount_cents).to eq(100_00)
  end

  it "associates the price history record with the provided municipality" do
    package = Package.create!(name: "Dunderhonung")
    municipality = Municipality.create!(name: "Luleå")

    UpdatePackagePrice.call(package, 200_00, municipality)
    expect(package.prices.first.municipality).to eq(municipality)
  end

  it "rolls back the transaction if the price update fails" do
    package = Package.create!(name: "Dunderhonung")
    municipality = Municipality.create!(name: "Luleå")

    expect {
      UpdatePackagePrice.call(package, nil, municipality)
    }.to raise_error(ActiveRecord::RecordInvalid)

    expect(package.reload.amount_cents).to be_zero
    expect(package.prices).to be_empty
  end
end
