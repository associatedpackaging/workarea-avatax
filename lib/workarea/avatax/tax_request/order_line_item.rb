module Workarea
  module Avatax
    class TaxRequest::OrderLineItem < TaxRequest::LineItem
      attr_reader :order_item, :adjustment, :shipping

      def initialize(order_item:, adjustment:, adjustment_set:, quantity: nil, shipping: nil)
        @order_item = order_item
        @adjustment = adjustment
        @adjustment_set = adjustment_set
        @quantity = quantity
        @shipping = shipping
      end

      private

        def addresses
          return unless address = shipping&.address

          {
            shipTo: {
              line1:      address.street,
              line2:      address.street_2,
              city:       address.city,
              region:     address.region,
              country:    address.country.alpha2,
              postalCode: address.postal_code
            }
          }
        end

        def quantity
          @quantity || adjustment.quantity
        end

        def amount
          total = @adjustment_set.taxable_share_for adjustment
          if shipping.present? && shipping.partial?
            total *= quantity / order_item.quantity.to_f
          end
          total
        end

        def item_code
          order_item.sku
        end

        def tax_code
          adjustment.data["tax_code"]
        end

        def product
          @product ||= Mongoid::Factory.from_db(
            Catalog::Product,
            order_item.product_attributes
          )
        end

        def description
          return if order_item.product_attributes.empty?
          product.name
        end
    end
  end
end
