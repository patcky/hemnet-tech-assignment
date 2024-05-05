# frozen_string_literal: true

class UpdatePackagePrice
  def self.call(package, new_price_cents, municipality, **options)
    Package.transaction do
      year = options[:year].nil? ? Date.today.year : options[:year]
      # Add a pricing history record for previous price, if package has a price and no history exists for that package,
      # amount and municipality combination
      if package.amount_cents > 0 and Price.where(
          package: package,
          amount_cents: package.amount_cents,
          municipality: municipality,
        ).empty?
        Price.create!(package: package, amount_cents: package.amount_cents, municipality: municipality, year: year)
      end
      # Update the current package price to match the new price
      package.update!(amount_cents: new_price_cents)
      # Save the new price to history
      Price.create!(package: package, amount_cents: new_price_cents, municipality: municipality, year: year)
    end
  end
end
