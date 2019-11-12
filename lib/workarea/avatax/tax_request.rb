module Workarea
  module Avatax
    class TaxRequest
      attr_reader :order, :shippings, :options

      def initialize(order:, shippings: [], **options)
        @order = order
        @shippings = shippings
        @options = options.deep_symbolize_keys
      end

      def response
        @response ||= Response.new(
          response: Avatax.gateway.create_transaction(request_body, request_options),
          request_order_line_items: order_lines.order_line_items,
          request_shipping_line_items: order_lines.shipping_line_items
        )
      end

      private

        def request_body
          {
            type:              type,
            date:              date,
            code:              order.id.to_s,
            companyCode:       company_code,
            customerCode:      customer_code,
            customerUsageType: customer_usage_type,
            addresses:         addresses.hash,
            commit:            commit,
            lines:             order_lines.lines.map(&:hash)
          }
        end

        def request_options
          options.slice(:timeout)
        end

        def addresses
          Addresses.new(tax_request: self)
        end

        def date
          DateTime.now.iso8601
        end

        def type
          options[:type] || "SalesOrder"
        end

        def commit
          options[:commit] || false
        end

        def customer_code
          return "" unless order.email.present?

          order.email.truncate(50, omission: "")
        end

        def customer_usage_type
          return "" unless order.email.present?

          User.find_by_email(order.email).try(:customer_usage_type)
        end

        def company_code
          Workarea::Avatax.config.company_code
        end

        def order_lines
          @order_lines ||= OrderLines.new(order, shippings)
        end
    end
  end
end
