Workarea.config.pricing_calculators.swap(
  "Workarea::Pricing::Calculators::TaxCalculator",
  "Workarea::Pricing::Calculators::AvalaraTaxCalculator"
)

if Rails.application.secrets.avatax.present?
  avatax_sercrets = Rails.application.secrets.avatax.deep_symbolize_keys
  AvaTax.configure do |config|
    config.username = avatax_sercrets[:username]
    config.password = avatax_sercrets[:password]
  end
end

Workarea::Avatax.auto_configure_gateway
