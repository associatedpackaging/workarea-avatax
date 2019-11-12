module Workarea
  module Avatax
    class BogusGateway::BogusCreateTransaction < BogusGateway::BogusResponse
      attr_reader :request_body

      def initialize(request_body)
        @request_body = request_body
      end

      def response
        env = Faraday::Env.new(
          :post,
          response_body,
          URI("https://sandbox-rest.avatax.com/api/v2/transactions/create"),
          Faraday::RequestOptions.new,
          request_headers,
          Faraday::SSLOptions.new(true),
          nil,
          nil,
          nil,
          response_headers,
          201,
          "Created"
        )
        Faraday::Response.new(env)
      end

      private

        def response_body
          {
            "id"        => 0,
            "code"      => "0B41518F49",
            "companyId" => 0,
            "status"    => "Temporary",
            "type"      => "SalesOrder",
            "totalTax"  => lines.sum { |line| line["tax"] },
            "lines"     => lines
          }
        end

        def lines
          @lines ||= request_body[:lines].map.with_index(1) do |line, number|
            if Rails.env.test?
              test_like_line(line, number)
            else
              api_like_line(line, number)
            end
          end.compact
        end

        def api_like_line(line, number)
          {
            "id"             => 0,
            "transactionId"  => 0,
            "lineNumber"     => number.to_s,
            "description"    => "",
            "discountAmount" => 0.0,
            "exemptAmount"   => 0.0,
            "exemptCertId"   => 0,
            "isItemTaxable"  => true,
            "itemCode"       => "",
            "lineAmount"     => line[:amount],
            "quantity"       => 0.0,
            "reportingDate"  => "2017-06-08",
            "tax"            => (line[:amount].to_m * 0.08).to_s,
            "taxableAmount"  => line[:amount],
            "taxCalculated"  => (line[:amount].to_m * 0.08).to_s,
            "taxCode"        => "P0000000",
            "taxDate"        => "2017-06-08",
            "taxIncluded"    => false,
            "details"        => [
              {
                "id"                 => 0,
                "transactionLineId"  => 0,
                "transactionId"      => 0,
                "country"            => "US",
                "region"             => "PA",
                "exemptAmount"       => 0.0,
                "jurisCode"          => "42",
                "jurisName"          => "PENNSYLVANIA",
                "stateAssignedNo"    => "",
                "jurisType"          => "STA",
                "nonTaxableAmount"   => 0.0,
                "rate"               => 0.06,
                "tax"                => (line[:amount].to_m * 0.06).to_s,
                "taxableAmount"      => line[:amount],
                "taxType"            => "Sales",
                "taxName"            => "PA STATE TAX",
                "taxAuthorityTypeId" => 45,
                "taxCalculated"      => (line[:amount].to_m * 0.06).to_s,
                "rateType"           => "General",
                "rateTypeCode"       => "G"
              },
              {
                "id"                 => 0,
                "transactionLineId"  => 0,
                "transactionId"      => 0,
                "country"            => "US",
                "region"             => "PA",
                "exemptAmount"       => 0.0,
                "jurisCode"          => "101",
                "jurisName"          => "PHILADELPHIA",
                "stateAssignedNo"    => "51",
                "jurisType"          => "CTY",
                "nonTaxableAmount"   => 0.0,
                "rate"               => 0.02,
                "tax"                => (line[:amount].to_m * 0.02).to_s,
                "taxableAmount"      => line[:amount],
                "taxType"            => "Sales",
                "taxName"            => "PA COUNTY TAX",
                "taxAuthorityTypeId" => 45,
                "taxCalculated"      => (line[:amount].to_m * 0.02).to_s,
                "rateType"           => "General",
                "rateTypeCode"       => "G"
              }
            ]
          }
        end

        def test_like_line(line, number)
          request_address = request_body[:addresses][:shipTo] ||
            request_body[:addresses][:singleLocation]

          address =
            if request_address.blank?
              Workarea::Address.new
            else
              # need to underscore keys and duck a workarea::address
              Hashie::Mash.new(Hash[request_address.map { |k, v| [k.to_s.underscore, v] }])
            end

          tax_rate = Workarea::Tax.find_rate(
            line[:taxCode],
            line[:amount].to_m,
            address
          )

          return unless tax_rate.present?
          {
            "id"             => 0,
            "transactionId"  => 0,
            "lineNumber"     => number.to_s,
            "description"    => "",
            "discountAmount" => 0.0,
            "exemptAmount"   => 0.0,
            "exemptCertId"   => 0,
            "isItemTaxable"  => true,
            "itemCode"       => "",
            "lineAmount"     => line[:amount],
            "quantity"       => 0.0,
            "reportingDate"  => "2017-06-08",
            "tax"            => (line[:amount].to_m * tax_rate.percentage).to_s,
            "taxableAmount"  => line[:amount],
            "taxCalculated"  => (line[:amount].to_m * tax_rate.percentage).to_s,
            "taxCode"        => "P0000000",
            "taxDate"        => "2017-06-08",
            "taxIncluded"    => false,
            "details"        => [
              {
                "id"                 => 0,
                "transactionLineId"  => 0,
                "transactionId"      => 0,
                "country"            => "US",
                "region"             => "PA",
                "exemptAmount"       => 0.0,
                "jurisCode"          => "42",
                "jurisName"          => "PENNSYLVANIA",
                "stateAssignedNo"    => "",
                "jurisType"          => "STA",
                "nonTaxableAmount"   => 0.0,
                "rate"               => tax_rate.percentage,
                "tax"                => (line[:amount].to_m * tax_rate.percentage).to_s,
                "taxableAmount"      => line[:amount],
                "taxType"            => "Sales",
                "taxName"            => "PA STATE TAX",
                "taxAuthorityTypeId" => 45,
                "taxCalculated"      => (line[:amount].to_m * tax_rate.percentage).to_s,
                "rateType"           => "General",
                "rateTypeCode"       => "G"
              }
            ]
          }
        end
    end
  end
end
