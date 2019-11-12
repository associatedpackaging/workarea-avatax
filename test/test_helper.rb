require "simplecov"

SimpleCov.start "rails" do
  add_filter "/workarea/avatax/version.rb"
  add_filter "/lib/avatax*"
  add_filter "app/seeds/*"
  add_filter "lib/workarea/avatax/bogus_gateway*"
  add_group "View Models", "app/view_models"
  add_group "Queries", "app/queries"
end

ENV["RAILS_ENV"] = "test"

require File.expand_path("../../test/dummy/config/environment.rb", __FILE__)
require "rails/test_help"
require "workarea/test_help"

# Filter out Minitest backtrace while allowing backtrace from other libraries
# to be shown.
Minitest.backtrace_filter = Minitest::BacktraceFilter.new
