require "test_helper"

module Workarea
  module Avatax
    class TaxRequest::OrderLinesTest < TestCase
      def test_lines_with_single_shipping
        order = create_checkout_order(email: "epigeon@weblinc.com")
        shippings = Shipping.where(order_id: order.id)
        order_line_items = TaxRequest::OrderLines.new(order, shippings)

        assert_equal 2, order_line_items.lines.size
      end

      def test_lines_with_split_shippings
        order = create_split_shipping_checkout_order
        shippings = Shipping.where(order_id: order.id)
        order_line_items = TaxRequest::OrderLines.new(order, shippings)

        assert_equal 6, order_line_items.lines.size
        expected_lines = [
          {
            quantity: 2,
            amount: "10.00",
            itemCode: "SKU1",
            taxCode: "001",
            description: "Split Shipping Product One",
            number: 1,
            addresses: {
              shipTo: {
                line1: "22 S 3rd St",
                line2: nil,
                city: "Philadelphia",
                region: "PA",
                country: "US",
                postalCode: "19106"
              }
            }
          },
          {
            quantity: 1,
            amount: "7.00",
            itemCode: "SKU2",
            taxCode: "001",
            description: "Split Shipping Product Two",
            number: 2,
            addresses: {
              shipTo: {
                line1: "22 S 3rd St",
                line2: nil,
                city: "Philadelphia",
                region: "PA",
                country: "US",
                postalCode: "19106"
              }
            }
          },
          {
            quantity: 1,
            amount: "7.00",
            itemCode: "SKU2",
            taxCode: "001",
            description: "Split Shipping Product Two",
            number: 3,
            addresses: {
              shipTo: {
                line1: "12 N 3rd St",
                line2: nil,
                city: "Philadelphia",
                region: "PA",
                country: "US",
                postalCode: "19106"
              }
            }
          },
          {
            quantity: 4,
            amount: "36.00",
            itemCode: "SKU3",
            taxCode: "001",
            description: "Split Shipping Product Three",
            number: 4,
            addresses: {
              shipTo: {
                line1: "12 N 3rd St",
                line2: nil,
                city: "Philadelphia",
                region: "PA",
                country: "US",
                postalCode: "19106"
              }
            }
          },
          {
            quantity: 1,
            amount: "5.00",
            itemCode: "SHIPPING",
            taxCode: "001",
            description: "Ground",
            number: 5
          },
          {
            quantity: 1,
            amount: "10.00",
            itemCode: "SHIPPING",
            taxCode: "001",
            description: "Express",
            number: 6
          }
        ]
        assert_equal expected_lines, order_line_items.lines.map(&:hash)
      end
    end
  end
end
