# frozen_string_literal: true

class UpdatePackagePrice
  def self.call(**options)
    validate_options(options)
    package = options[:package]
    new_price_cents = options[:amount]
    municipality = options[:municipality]
    ActiveRecord::Base.transaction do
      year = options[:year].nil? ? Date.today.year : options[:year]
      # Add a pricing history record for previous price, if package has a price and no history exists for that package
      if package.amount_cents > 0 and package.prices.empty?
        # Although this is meant to save the historical price, the price is being created with the current price's
        # municipality, which is incorrect, but we don't have the historical data's municipality. Another approach would be
        # to set a default municipality specifically for the historical price.
        Price.create!(package: package, amount_cents: package.amount_cents, municipality: municipality, year: package.created_at.year)
      end
      # Update the current package price to match the new price
      package.update!(amount_cents: new_price_cents)
      # Save the new price to history
      Price.create!(package: package, amount_cents: new_price_cents, municipality: municipality, year: year)
    end
  end

  private

    def self.validate_options(options)
      raise ArgumentError, "package is a required argument" if options[:package].nil?
      raise ArgumentError, "new_price_cents is a required argument" if options[:amount].nil?
      raise ArgumentError, "new_price_cents must be greater than 0" if options[:amount].nil? or options[:amount] <= 0
      raise ArgumentError, "municipality is a required argument" if options[:municipality].nil?
      if options[:year].present? and (options[:year].to_i < 1900 or options[:year].to_i > Date.today.year)
        raise ArgumentError, "year must be between 1900 and the current year"
      end
    end
end
