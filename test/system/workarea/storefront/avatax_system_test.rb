require 'test_helper'

module Workarea
  module Storefront
    class AvataxSystemTest < Workarea::SystemTest
      include Storefront::SystemTest

      setup :setup_checkout_specs
      setup :start_guest_checkout

      def test_showing_taxes
        assert_current_path(storefront.checkout_addresses_path)
        fill_in_email
        fill_in_shipping_address
        click_button t('workarea.storefront.checkouts.continue_to_shipping')

        visit storefront.cart_path
        assert page.has_content? "0.84"
      end
    end
  end
end
