# frozen_string_literal: true

require "spec_helper"

RSpec.describe Municipality do
  it "validates the presence of name" do
    municipality = Municipality.new(name: nil)
    expect(municipality.validate).to eq(false)
    expect(municipality.errors[:name]).to be_present
  end

  it "has many prices" do
    municipality = Municipality.new(name: "Göteborg")
    expect(municipality.prices).to eq([])
  end

  it "has many packages through prices" do
    municipality = Municipality.new(name: "Göteborg")
    expect(municipality.packages).to eq([])
  end

  it "destroys associated prices when destroyed" do
    municipality = Municipality.create!(name: "Göteborg")
    package = Package.create!(name: "Dunderhonung")
    Price.create!(amount_cents: 100_00, package: package, municipality: municipality, year: 1995)

    expect {
      municipality.destroy
    }.to change(Price, :count).by(-1)
  end
end
