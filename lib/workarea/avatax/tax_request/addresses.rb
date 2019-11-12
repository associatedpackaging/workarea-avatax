module Workarea
  module Avatax
    class TaxRequest::Addresses
      attr_reader :tax_request

      def initialize(tax_request:)
        @tax_request = tax_request
      end

      def hash
        return { singleLocation: ship_from } unless ship_to.present?

        { shipFrom: ship_from, shipTo: ship_to }
      end

      private

        def ship_from
          Avatax.config.distribution_center
        end

        def ship_to
          return unless address = tax_request.shippings.first.try(:address)
          {
            line1:      address.street,
            line2:      address.street_2,
            city:       address.city,
            region:     address.region,
            country:    address.country.alpha2,
            postalCode: address.postal_code
          }
        end
    end
  end
end
