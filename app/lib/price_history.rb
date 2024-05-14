# frozen_string_literal: true

class PriceHistory
  def self.call(**options)
    # Feature request 2: Pricing History
    self.validate_options(options)
    package = Package.find_by!(name: options[:package].downcase)
    prices = package.prices.where(year: options[:year].to_i)
    prices = self.filter_by_municipality(prices, options[:municipality].downcase) if options[:municipality].present?
    return self.build_result(prices)
  end

  private

    def self.validate_options(options)
      if options[:year].nil?
        # To improve: instead of raising errors for each missing arg, we could save or log the errors somewhere
        # that can be accessed later, so that we can fix the issues
        raise ArgumentError, "year is a required argument"
      end
      if options[:year].to_i < 1900 or options[:year].to_i > Date.today.year
        raise ArgumentError, "year must be between 1900 and the current year"
      end
      if options[:package].nil?
        raise ArgumentError, "package is a required argument"
      end
    end

    def self.filter_by_municipality(prices, municipality)
      return prices.join(:municipality).where(municipalities: { name: municipality })
    end

    def self.build_result(prices)
      result = {}
      return result if prices.empty?
      prices.each do |price|
        municipality = price.municipality.name.capitalize
        if result[municipality].nil?
          result[municipality] = [price.amount_cents]
        else
          result[municipality] << price.amount_cents
        end
      end
      return result
    end

end
