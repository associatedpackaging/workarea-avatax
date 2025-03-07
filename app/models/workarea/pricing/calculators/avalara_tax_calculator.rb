module Workarea
  module Pricing
    module Calculators
      # Calculates order/shipping sales tax via the Avalara AvaTax API
      #
      class AvalaraTaxCalculator
        include Calculator

        def adjust
          if organization_tax_exempt?
             shippings.each do |tmp_shipping|
              next unless tmp_shipping.address.present?

              price_adjustments_for(tmp_shipping).each do |adjustment|
                tmp_shipping.adjust_pricing(
                  price: 'tax',
                  calculator: self.class.name,
                  description: 'Item Tax',
                  amount: 0.to_m,
                  data: {
                    'adjustment' => adjustment.id,
                    'order_item_id' => adjustment._parent.id,
                    'tax_code' => adjustment.data['tax_code'],
                    'tax_exempt' => true
                  }
                )
              end
            end

            return
          end

          response = AvaTax::TaxRequest.new(
            order: order,
            shippings: shippings,
            **request_options
          ).response

          return unless response.success?

          shippings.each do |shipping|
            next unless shipping.address.present?

            price_adjustments_for(shipping).each do |adjustment|
              tax_line = response.tax_line_for_adjustment adjustment, shipping: shipping
              next unless tax_line.present?

              adjust_pricing(
                shipping,
                tax_line,
                "order_item_id" => adjustment._parent.id,
                "adjustment" => adjustment.id
               )
            end

            shipping_tax_line = response.tax_line_for_shipping(shipping)
            adjust_pricing(shipping, shipping_tax_line, "shipping_service_tax" => true)
          end

          order.items.reject(&:shipping?).each do |non_shipped_item|
            non_shipped_item.price_adjustments.each do |adjustment|
              tax_line = response.tax_line_for_adjustment(adjustment)
              next unless tax_line.present? && tax_line.tax.to_m > 0

              data = {
                'adjustment' => adjustment.id,
                'order_item_id' => adjustment._parent.id,
                'tax_code' => adjustment.data['tax_code']
              }

              non_shipped_item.adjust_pricing(
                price: 'tax',
                calculator: self.class.name,
                description: 'Item Tax',
                amount: tax_line.tax.to_m,
                data: data.merge(find_line_details(tax_line))
              )
            end
          end

        rescue Faraday::Error => error
          Raven.capture_exception(error) if defined?(Raven)
          avatax_fallback(error)
        end

        private

          def organization_tax_exempt?
            return false unless Workarea::Plugin.installed?(:b2b)

            account = Organization::Account.find(order.account_id) rescue nil

            return unless account.present?

            account.entity_use_code != 'TAXABLE'
          end

          def request_options
            { timeout: 2 }
          end

          def avatax_fallback(_error)
            Pricing::Calculators::TaxCalculator.new(request).adjust
          end
          alias_method :handle_timeout_error, :avatax_fallback

          # If doing split shipping (different items go to different shipping
          # addresses), decorate this method to return the proper price
          # adjustments that match the shipping. (This will have to be added to
          # the UI and saved, probably on the Shipping object)
          #
          # @return [PriceAdjustmentSet]
          #
          def price_adjustments_for(shipping)
            order.price_adjustments
          end

          def adjust_pricing(shipping, tax_line, data = {})
            return if tax_line.tax.to_m.zero?

            shipping.adjust_pricing(
              price: "tax",
              calculator: self.class.name,
              description: "Sales Tax",
              amount: tax_line.tax.to_m,
              data: data.merge(find_line_details(tax_line))
            )
          end

          def find_line_details(tax_line)
            tax_line.details.each_with_object({}) do |detail, memo|
              memo[detail.taxName] = detail.rate
            end
          end
      end
    end
  end
end
