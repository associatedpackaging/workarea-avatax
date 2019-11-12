require "test_helper"

module Workarea
  module Avatax
    class TaxRequest::ResponseTest < Workarea::TestCase
      setup :create_tax_rate

      def test_tax_line_for_adjustment
        response = TaxRequest.new(order: order, shippings: shippings).response

        adjustment = order.price_adjustments.detect { |a| a.data["tax_code"].present? }
        adjustment_tax_line = response.tax_line_for_adjustment(adjustment)
        assert_equal "0.80", adjustment_tax_line.tax
      end

      def test_tax_line_for_shipping
        response = TaxRequest.new(order: order, shippings: shippings).response

        shipping = shippings.first
        shipping_tax_line = response.tax_line_for_shipping(shipping)
        assert_equal "0.08", shipping_tax_line.tax
      end

      private

        def order
          @order ||= create_checkout_order(email: "epigeon@weblinc.com")
        end

        def shippings
          @shippings ||= Shipping.where(order_id: order.id)
        end

        def create_tax_rate
          create_tax_category(
            code: "P0000000",
            rates: [{ percentage: 0.08, country: "US", region: "PA" }]
          )
        end
    end
  end
end
