module Workarea
  module AvaTax
    class Engine < ::Rails::Engine
      include Workarea::Plugin

      isolate_namespace Workarea::AvaTax

      #Workarea::AvaTax.configure do |config|
      #  config.valid_service_urls = [
      #    "https://development.avalara.net",   # development
      #    "https://avatax.avalara.net"         # production
      #  ]
      #end

      initializer "workarea.avatax.templates" do
        #Plugin.append_partials(
        #  "admin.store_menu",
        #  "workarea/admin/menus/avatax_settings"
        #)

        #Plugin.append_partials(
        #  "admin.user_permissions",
        #  "workarea/admin/users/avatax_settings"
        #)
        #Plugin.append_partials(
        #  "admin.user_properties",
        #  "workarea/admin/users/user_properties_fields"
        #)
      end

      #initializer "workarea.avatax.listeners" do
      #  Workarea::Publisher.add_listener(Workarea::AvaTax::InvoiceListener)
      #end
    end
  end
end
