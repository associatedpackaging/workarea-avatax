module Workarea
  module Avatax
    class Engine < ::Rails::Engine
      include Workarea::Plugin

      isolate_namespace Workarea::Avatax

      #Workarea::Avatax.configure do |config|
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
      #  Workarea::Publisher.add_listener(Workarea::Avatax::InvoiceListener)
      #end
    end
  end
end
