module Workarea
  module AvaTax
    class TaxInvoiceWorker
      include Sidekiq::Worker
      include Sidekiq::CallbacksWorker

      sidekiq_options(
        enqueue_on: {
          Workarea::Order => :place,
          ignore_if: -> { AvaTax.config.order_handling == :none }
        }
      )

      def perform(order_id)
        order = Workarea::Order.find(order_id)
        shippings = Workarea::Shipping.where(order_id: order.id).to_a

        response = AvaTax::TaxRequest.new(
          order: order,
          shippings: shippings,
          type: "SalesInvoice",
          commit: AvaTax.commit?
        ).response

        raise "Failed to invoice tax for order: #{order.id}" unless response.success?
      end
    end
  end
end
