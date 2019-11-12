module Workarea
  module Avatax
    class TaxRequest::OrderLines
      attr_reader :order, :shippings

      def initialize(order, shippings)
        @order = order
        @shippings = shippings
      end

      def order_line_items
        @order_line_items ||=
          if shippings.any?(&:partial?)
            split_shipping_lines
          else
            single_shipping_lines
          end.map.with_index(1) { |line, index| line.tap { |li| li.line_number = index } }
      end

      def shipping_line_items
        @shipping_line_item ||= shippings.map { |shipping| TaxRequest::ShippingLineItem.new(shipping: shipping) }
      end

      def lines
        (order_line_items + shipping_line_items).map.with_index(1) do |line_item, index|
          line_item.tap { |li| li.line_number = index }
        end
      end

      private

        def order_price_adjustments
          order.price_adjustments
        end

        def grouped_order_price_adjustments
          order_price_adjustments.grouped_by_parent
        end

        def single_shipping_lines
          grouped_order_price_adjustments.flat_map do |item, set|
            set.map do |adjustment|
              next unless adjustment.data["tax_code"].present?

              TaxRequest::OrderLineItem.new(order_item: item, adjustment: adjustment, adjustment_set: set)
            end
          end.compact
        end

        def split_shipping_lines
          shippings.flat_map do |shipping|
            shipping.quantities.flat_map do |order_item_id, quantity|
              item = order.items.detect { |oi| oi.id.to_s == order_item_id }
              adjustment_set = grouped_order_price_adjustments[item]

              adjustment_set.map do |adjustment|
                TaxRequest::OrderLineItem.new(
                  order_item: item,
                  adjustment: adjustment,
                  adjustment_set: adjustment_set,
                  quantity: quantity,
                  shipping: shipping
                )
              end
            end
          end
        end
    end
  end
end
