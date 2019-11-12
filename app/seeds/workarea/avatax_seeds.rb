module Workarea
  class AvataxSeeds
    def perform
      return unless AvaTax.config[:username].present? && AvaTax.config[:password].present?
      puts "Adding Avalara Usage Types..."

      result = ::AvaTax.list_entity_use_codes
      raise "Failed to get avatax usage codes from api" unless result.success?

      result.body["value"].each do |entity_use_code|
        Workarea::Avatax::UsageType.find_or_create_by(
          code: entity_use_code["code"],
          name: formatted_names.fetch(entity_use_code["name"], entity_use_code["name"]),
          country_codes: entity_use_code["validCountries"]
        )
      end
    end

    private

      def formatted_names
        {
          "FEDERAL GOV"                   => "Federal Government",
          "STATE GOV"                     => "State Government",
          "TRIBAL GOVERNMENT"             => "Tribal Government",
          "FOREIGN DIPLOMAT"              => "Foreign diplomat",
          "CHARITABLE/EXEMPT ORG"         => "Charitable or excempt org",
          "RELIGIOUS ORG"                 => "Religious or educational org",
          "EDUCATIONAL ORG"               => "Educational org",
          "RESALE"                        => "Resale",
          "AGRICULTURE"                   => "Commercial agricultural production",
          "INDUSTRIAL PROD/MANUFACTURERS" => "Industrial production / manufacturer",
          "DIRECT PAY"                    => "Direct pay permit",
          "DIRECT MAIL"                   => "Direct mail",
          "OTHER/CUSTOM"                  => "Other or custom",
          "LOCAL GOVERNMENT"              => "Local Government",
          "COMMERCIAL AQUACULTURE"        => "Commercial aquaculture",
          "COMMERCIAL FISHERY"            => "Commercial fishery",
          "NON-RESIDENT"                  => "Non-resident",
          "NON-EXEMPT TAXABLE CUSTOMER"   => "Non-excempt taxable customer"
        }
      end
  end
end
