module Workarea
  module Avatax
    class TaxInvoiceWorker
      include Sidekiq::Worker
      include Sidekiq::CallbacksWorker

      sidekiq_options(
        enqueue_on: {
          Workarea::Order => :place,
          ignore_if: -> { Avatax.config.order_handling == :none }
        }
      )

      def perform(order_id)
        order = Workarea::Order.find(order_id)
        shippings = Workarea::Shipping.where(order_id: order.id).to_a

        response = Avatax::TaxRequest.new(
          order: order,
          shippings: shippings,
          type: "SalesInvoice",
          commit: Avatax.commit?
        ).response

        raise "Failed to invoice tax for order: #{order.id}" unless response.success?
      end
    end
  end
end
