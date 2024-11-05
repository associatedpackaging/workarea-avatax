require "test_helper"

module Workarea
  class AvataxTest < Workarea::TestCase
    def test_auto_configure_gateway_creates_bogus_gateway_without_secrets
      assert_instance_of(AvaTax::BogusGateway, AvaTax.gateway)
    end

    def test_auto_configure_gateway_creates_real_gateway_with_secrets
      Rails.application.secrets.merge!(
        avatax: {
          username: "epigeon@weblinc.com",
          password: "648B0A9851",
          endpoint: "https://sandbox-rest.avatax.com/"
        }
      )

      AvaTax.auto_configure_gateway
      assert_instance_of(::AvaTax::Client, AvaTax.gateway)

    ensure
      Rails.application.secrets.delete(:avatax)
      AvaTax.gateway = AvaTax::BogusGateway.new
    end
  end
end
