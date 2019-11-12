module Workarea
  module Avatax
    class UsageType
      include ApplicationDocument

      field :code,          type: String
      field :name,          type: String, localize: true
      field :country_codes, type: Array

      validates_presence_of :code, :name, :country_codes

      def countries
        country_codes.map { |code| Country[code] }.compact
      end
    end
  end
end
