require "test_helper"

module Workarea
  module AvaTax
    class TaxRequestTest < Workarea::TestCase
      setup :configure_sandbox
      teardown :reset_avatax_config

      def test_successful_response
        cassette = VCR.insert_cassette(:succesful_avatax_create_transaction, record: :none)
        order = create_checkout_order(email: "epigeon@weblinc.com")
        shippings = Shipping.where(order_id: order.id)
        request = TaxRequest.new(order: order, shippings: shippings)

        response = VCR.use_cassette cassette do
          request.response
        end

        assert response.success?
      end

      def test_body_lines_split_shippings
        cassette = VCR.insert_cassette(:succesful_avatax_create_transaction_multiple_shippings, record: :none)
        order = create_split_shipping_checkout_order
        shippings = Shipping.where(order_id: order.id)
        request = TaxRequest.new(order: order, shippings: shippings)

        response = VCR.use_cassette cassette do
          request.response
        end

        assert response.success?
      end

      private

        def configure_sandbox
          ::AvaTax.configure do |config|
            config.faraday_response = true
            config.endpoint = "https://sandbox-rest.avatax.com/"
            config.username = "jyucis-lp-avatax@weblinc.com"
            config.password = "Jm{m3NX.Q"
          end

          AvaTax.gateway = ::AvaTax.client
        end

        def reset_avatax_config
          ::AvaTax.reset
          AvaTax.gateway = AvaTax::BogusGateway.new
          VCR.eject_cassette
        end
    end
  end
end
