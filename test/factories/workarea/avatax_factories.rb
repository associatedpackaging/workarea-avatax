module Workarea
  module Factories
    module AvataxFactories
      Factories.add self

      def create_checkout_order(overrides = {})
        attributes = overrides

        shipping_service = create_shipping_service(tax_code: "P0000000")
        sku = "SKU1"
        product = create_product(variants: [{ sku: sku, regular: 5.to_m, tax_code: "P0000000" }])

        Workarea::Order.new(attributes).tap do |order|
          shipping = Workarea::Shipping.create!(order_id: order.id)

          shipping.set_shipping_service(
            id: shipping_service.id,
            name: shipping_service.name,
            base_price: shipping_service.rates.first.price,
            tax_code: shipping_service.tax_code
          )

          order.items.build(
            product_id: product.id,
            sku: sku,
            quantity: 2,
            product_attributes: product.as_document
          )

          shipping.set_address(
            first_name:  "Eric",
            last_name:   "Pigeon",
            street:      "22 S 3rd St",
            city:        "Philadelphia",
            region:      "PA",
            postal_code: 19106,
            country:     "US"
          )

          Workarea::Pricing.perform(order)

          order.save!
        end
      end

      def create_split_shipping_checkout_order(overrides = {})
        attributes = { email: "epigeon@workarea.com" }.merge overrides
        product_1 = create_product(
          id: "PROD1",
          name: "Split Shipping Product One",
          variants: [{ sku: "SKU1", regular: 5.to_m, tax_code: "001" }]
        )
        product_2 = create_product(
          id: "PROD2",
          name: "Split Shipping Product Two",
          variants: [{ sku: "SKU2", regular: 7.to_m, tax_code: "001" }]
        )
        product_3 = create_product(
          id: "PROD3",
          name: "Split Shipping Product Three",
          variants: [{ sku: "SKU3", regular: 9.to_m, tax_code: "001" }]
        )
        ground = create_shipping_service(name: "Ground", tax_code: "001", rates: [{ price: 5.to_m }])
        express = create_shipping_service(name: "Express", tax_code: "001", rates: [{ price: 10.to_m }])

        Workarea::Order.new(attributes).tap do |order|
          order.items.build(
            product_id: "PROD1",
            sku: "SKU1",
            quantity: 2,
            product_attributes: product_1.as_document
          )

          order.items.build(
            product_id: "PROD2",
            sku: "SKU2",
            quantity: 2,
            product_attributes: product_2.as_document
          )

          order.items.build(
            product_id: "PROD3",
            sku: "SKU3",
            quantity: 4,
            product_attributes: product_3.as_document
          )

          shipping_1 = Workarea::Shipping.create!(
            order_id: order.id,
            quantities: {
              order.items.first.id.to_s => 2,
              order.items.second.id.to_s => 1
            },
            address: {
              first_name:  "Eric",
              last_name:   "Pigeon",
              street:      "22 S 3rd St",
              city:        "Philadelphia",
              region:      "PA",
              postal_code: 19106,
              country:     "US"
            }
          )

          shipping_1.set_shipping_service(
            id: ground.id,
            name: ground.name,
            base_price: ground.rates.first.price,
            tax_code: ground.tax_code
          )

          shipping_2 = Workarea::Shipping.create!(
            order_id: order.id,
            quantities: {
              order.items.second.id.to_s => 1,
              order.items.third.id.to_s => 4
            },
            address: {
              first_name:  "Eric",
              last_name:   "Pigeon",
              street:      "12 N 3rd St",
              city:        "Philadelphia",
              region:      "PA",
              postal_code: 19106,
              country:     "US"
            }
          )

          shipping_2.set_shipping_service(
            id: express.id,
            name: express.name,
            base_price: express.rates.first.price,
            tax_code: express.tax_code
          )

          Workarea::Pricing.perform(order)
          order.save!
        end
      end
    end
  end
end
