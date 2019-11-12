module Workarea
  module Avatax
    class TaxRequest::LineItem
      attr_accessor :line_number

      def initialize(**)
        @line_number = 0
      end

      def hash
        {
          quantity:    quantity,
          amount:      amount.to_s,
          itemCode:    item_code,
          taxCode:     tax_code,
          description: description,
          number:      line_number,
          addresses:   addresses
        }.compact
      end

      private

        def quantity
          raise NotImplementedError, "#{self.class.name} must implement #quantity"
        end

        def amount
          raise NotImplementedError, "#{self.class.name} must implement #amount"
        end

        def item_code
          raise NotImplementedError, "#{self.class.name} must implement #item_code"
        end

        def tax_code
          raise NotImplementedError, "#{self.class.name} must implement #tax_code"
        end

        def description
          raise NotImplementedError, "#{self.class.name} must implement #description_code"
        end

        def addresses; end
    end
  end
end
