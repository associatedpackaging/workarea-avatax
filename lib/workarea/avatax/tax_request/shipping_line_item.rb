module Workarea
  module Avatax
    class TaxRequest::ShippingLineItem < TaxRequest::LineItem
      attr_reader :shipping

      def initialize(shipping:)
        super
        @shipping = shipping
      end

      private

        def quantity
          1
        end

        def amount
          shipping.price_adjustments.adjusting("shipping").sum(&:amount)
        end

        def item_code
          "SHIPPING"
        end

        def tax_code
          shipping.shipping_service.try(:tax_code)
        end

        def description
          shipping.shipping_service.try(:name)
        end
    end
  end
end
