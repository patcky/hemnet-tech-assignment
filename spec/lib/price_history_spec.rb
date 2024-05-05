# frozen_string_literal: true

require "spec_helper"

RSpec.describe PriceHistory do
  it "fetches price history given year and package name" do
    package = Package.create!(name: "premium")
    stockholm = Municipality.create!(name: "Stockholm")
    UpdatePackagePrice.call(package, 200_00, stockholm, year: 2024)
    uppsala = Municipality.create!(name: "Uppsala")
    UpdatePackagePrice.call(package, 300_00, uppsala, year: 2024)
    UpdatePackagePrice.call(package, 400_00, uppsala, year: 2024)

    price_history = PriceHistory.call(
      year: "2024",
      package: "premium",
    )
    expect(price_history.keys).to eq(["Stockholm", "Uppsala"])
    expect(price_history["Stockholm"]).to eq([200_00])
    expect(price_history["Uppsala"]).to eq([300_00, 400_00])
    expect(package.amount_cents).to eq(400_00)
  end

  it "fetches price history given year, package name and municipality" do
    package = Package.create!(name: "premium")
    stockholm = Municipality.create!(name: "Stockholm")
    UpdatePackagePrice.call(package, 200_00, stockholm, year: 2024)
    uppsala = Municipality.create!(name: "Uppsala")
    UpdatePackagePrice.call(package, 300_00, uppsala, year: 2024)
    UpdatePackagePrice.call(package, 400_00, uppsala, year: 2024)

    price_history = PriceHistory.call(
      year: "2024",
      package: "premium",
      municipality: "Stockholm",
    )
    expect(price_history.keys).to eq(["Stockholm"])
    expect(price_history["Stockholm"]).to eq([200_00])
    expect(package.amount_cents).to eq(400_00)
  end

  it "raises an error if the package does not exist" do
    expect {
      PriceHistory.call(
        year: "2024",
        package: "premium",
      )
    }.to raise_error(ActiveRecord::RecordNotFound)
  end

  it "raises an error if the package is not provided" do
    expect {
      PriceHistory.call(
        year: "2024",
      )
    }.to raise_error(ArgumentError)
  end

  it "raises an error if the municipality does not exist" do
    package = Package.create!(name: "premium")
    uppsala = Municipality.create!(name: "Uppsala")
    UpdatePackagePrice.call(package, 300_00, uppsala, year: 2024)
    UpdatePackagePrice.call(package, 400_00, uppsala, year: 2024)
    expect {
      PriceHistory.call(
        year: "2024",
        package: "premium",
        municipality: "FooBar",
      )
    }.to raise_error(ActiveRecord::RecordNotFound)
  end

  it "raises an error if the year is not provided" do
    expect {
      PriceHistory.call(
        package: "premium",
      )
    }.to raise_error(ArgumentError)
  end

  it "raises an error if the year is not valid" do
    package = Package.create!(name: "premium")
    uppsala = Municipality.create!(name: "Uppsala")
    UpdatePackagePrice.call(package, 300_00, uppsala, year: 2024)
    UpdatePackagePrice.call(package, 400_00, uppsala, year: 2024)
    expect {
      PriceHistory.call(
        year: "2025",
        package: "premium",
      )
    }.to raise_error(ArgumentError)
    expect {
      PriceHistory.call(
        year: "1899",
        package: "premium",
      )
    }.to raise_error(ArgumentError)
  end
end
