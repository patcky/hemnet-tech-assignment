# frozen_string_literal: true

require "spec_helper"

RSpec.describe Price do
  it "validates the presence of price_cents" do
    price = Price.new
    expect(price.validate).to eq(false)
    expect(price.errors[:amount_cents]).to be_present
  end

  it "validates the presence of package" do
    price = Price.new
    expect(price.validate).to eq(false)
    expect(price.errors[:package]).to be_present
  end

  it "validates the presence of municipality" do
    price = Price.new
    expect(price.validate).to eq(false)
    expect(price.errors[:municipality]).to be_present
  end

  it "validates the presence of year" do
    price = Price.new
    expect(price.validate).to eq(false)
    expect(price.errors[:year]).to be_present
  end
end
