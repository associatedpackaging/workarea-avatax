require "test_helper"

module Workarea
  module Pricing
    module Calculators
      class ExemptTaxCalculatorTest < Workarea::TestCase
        if Workarea::Plugin.installed?(:b2b)
          def test_adjust
            account = create_account(tax_exempt: true)

            create_pricing_sku(
              id: 'SKU',
              tax_code: '001',
              prices: [{ regular: 5.to_m }]
            )

            create_tax_category(
              code:  '001',
              rates: [{ percentage: 0.06, region: 'PA', country: 'US' }]
            )

            order = Order.new(
              account_id: account.id,
              items: [
                {
                  price_adjustments: [
                    {
                      price: 'item',
                      amount: 5.to_m,
                      data: { 'tax_code' => '001' }
                    }
                  ]
                }
              ]
            )

            shipping = Shipping.new

            shipping.set_address(
              postal_code: '19106',
              region: 'PA',
              country: 'US'
            )

            AvalaraTaxCalculator.test_adjust(order, shipping)

            assert_equal(1, shipping.price_adjustments.length)
            assert_equal('tax', shipping.price_adjustments.last.price)
            assert_equal(0.to_m, shipping.price_adjustments.first.amount)
            assert(shipping.price_adjustments.first.data["tax_exempt"])
          end
        end
      end
    end
  end
end
