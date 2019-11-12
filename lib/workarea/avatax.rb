require "avatax"
require "avatax/api.decorator"
require "hashie"
require "workarea/core"
require "workarea/storefront"
require "workarea/admin"

module Workarea
  module Avatax
    include ActiveSupport::Configurable

    # Config for how orders should post to avatax
    # :none - no action happens
    # :post - a salesInvoice transaction is created
    # :commit - a commited salesInvoice is created
    config.order_handling = :none

    config.company_code = nil

    def self.commit?
      config.order_handling == :commit
    end

    def self.gateway=(gateway)
      Workarea.config.gateways.avatax = gateway
    end

    def self.gateway
      Workarea.config.gateways.avatax
    end

    def self.auto_configure_gateway
      if Rails.application.secrets.avatax.present?
        avatax_secrets = Rails.application.secrets.avatax.deep_symbolize_keys

        connection_options = {
          request: { timeout: avatax_secrets[:timeout] || 2 }
        }

        if ENV["HTTP_PROXY"].present?
          connection_options.merge!(proxy: ENV["HTTP_PROXY"])
        end

        ::AvaTax.configure do |config|
          if avatax_secrets[:endpoint].present?
            config.endpoint = avatax_secrets[:endpoint]
          end

          config.username = avatax_secrets[:username]
          config.password = avatax_secrets[:password]
          config.connection_options = connection_options
        end
        self.gateway = ::AvaTax.client
      elsif gateway.blank?
        self.gateway = Avatax::BogusGateway.new
      end
    end
  end
end

require "workarea/avatax/engine"
require "workarea/avatax/version"
require "workarea/avatax/tax_request"
require "workarea/avatax/tax_request/order_lines"
require "workarea/avatax/tax_request/line_item"
require "workarea/avatax/tax_request/order_line_item"
require "workarea/avatax/tax_request/shipping_line_item"
require "workarea/avatax/tax_request/addresses"
require "workarea/avatax/tax_request/response"
require "workarea/avatax/bogus_gateway"
require "workarea/avatax/bogus_gateway/bogus_create_transaction"
