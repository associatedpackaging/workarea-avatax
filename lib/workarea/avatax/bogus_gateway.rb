module Workarea
  module Avatax
    class BogusGateway
      class BogusResponse
        private

          def request_headers
            {
              "Accept"        => "application/json; charset=utf-8",
              "User-Agent"    => "AvaTax Ruby Gem 17.5.0",
              "Content-Type"  => "application/json",
              "Authorization" => "Basic ZXBpZ2VvbkB3ZWJsaW5jLmNvbTo2NDhCMEE5ODUx"
            }
          end

          def response_headers
            {
              "transfer-encoding" => "chunked",
              "content-type"      => "application/json; charset=utf-8",
              "server"            => "Kestrel",
              "serverduration"    => "00:00:00.0937524",
              "databasecalls"     => "4",
              "databaseduration"  => "00:00:00.0156261",
              "date"              => "Thu, 08 Jun 2017 19:04:38 GMT"
            }
          end
      end

      def create_transaction(body, options = {})
        BogusCreateTransaction.new(body).response
      end
    end
  end
end
