require "test_helper"

module Workarea
  module Pricing
    module Calculators
      class AvalaraTaxCalculatorTest < Workarea::TestCase
        def test_adjust
          create_pricing_sku(
            id: "SKU",
            tax_code: "001",
            prices: [{ regular: 5.to_m }]
          )

          create_tax_category(
            code:  "001",
            rates: [{ percentage: 0.06, region: "PA", country: "US" }]
          )

          order = Order.new(
            items: [
              {
                price_adjustments: [
                  {
                    price: "item",
                    amount: 5.to_m,
                    data: { "tax_code" => "001" }
                  }
                ],
                total_price: 5.to_m,
              }
            ]
          )

          shipping = Shipping.new(
            shipping_service: { name: "UPS Ground", tax_code: "001" },
            price_adjustments: [
              {
                price: "shipping",
                amount: "4.to_m"
              }
            ]
          )

          shipping.set_address(
            postal_code: "19106",
            region: "PA",
            country: "US"
          )

          AvalaraTaxCalculator.test_adjust(order, shipping)

          assert_equal(3, shipping.price_adjustments.length)

          item_tax = shipping.price_adjustments.detect do |adjustment|
            adjustment.data.keys.include? "order_item_id"
          end
          assert_equal("tax", item_tax.price)
          assert_equal(0.30.to_m, item_tax.amount)

          shipping_tax = shipping.price_adjustments.detect do |adjustment|
            adjustment.data.keys.include? "shipping_service_tax"
          end

          assert_equal("tax", shipping_tax.price)
          assert_equal(0.24.to_m, shipping_tax.amount)
        end
      end
    end
  end
end
