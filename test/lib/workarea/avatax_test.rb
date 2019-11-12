require "test_helper"

module Workarea
  class AvataxTest < Workarea::TestCase
    def test_auto_configure_gateway_creates_bogus_gateway_without_secrets
      assert_instance_of(Avatax::BogusGateway, Avatax.gateway)
    end

    def test_auto_configure_gateway_creates_real_gateway_with_secrets
      Rails.application.secrets.merge!(
        avatax: {
          username: "epigeon@weblinc.com",
          password: "648B0A9851",
          endpoint: "https://sandbox-rest.avatax.com/"
        }
      )

      Avatax.auto_configure_gateway
      assert_instance_of(AvaTax::Client, Avatax.gateway)

      assert_includes(Avatax.gateway.connection_options[:request].keys, :timeout)

    ensure
      Rails.application.secrets.delete(:avatax)
      Avatax.gateway = Avatax::BogusGateway.new
    end
  end
end
