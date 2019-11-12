module Workarea
  module Avatax
    class TaxRequest::Response
      attr_reader :response, :request_order_line_items, :request_shipping_line_items
      delegate :success?, to: :response

      def initialize(response:, request_order_line_items:, request_shipping_line_items:)
        @response = response
        @request_order_line_items = request_order_line_items
        @request_shipping_line_items = request_shipping_line_items
      end

      def body
        @body ||= Hashie::Mash.new response.body
      end

      def tax_line_for_adjustment(price_adjustment, shipping: nil)
        return unless success?

        line_number =
          if shipping&.partial?
            request_order_line_items
              .detect { |line_item| line_item.adjustment == price_adjustment && line_item.shipping == shipping }
              .try(:line_number)
          else
            request_order_line_items
              .detect { |line_item| line_item.adjustment == price_adjustment }
              .try(:line_number)
          end

        return unless line_number

        body.lines.detect { |line| line.lineNumber.to_i == line_number }
      end

      def tax_line_for_shipping(shipping)
        return unless success?

        line_number = request_shipping_line_items
          .detect { |line_item| line_item.shipping.id == shipping.id }
          .try(:line_number)

        return unless line_number

        body.lines.detect { |line| line.lineNumber.to_i == line_number }
      end
    end
  end
end
