# Because of http://dev.rubyonrails.org/ticket/9815
# when the routes get reloaded by any inflector call
# it erases these routes

require 'active_support'
require 'active_support/core_ext/array'
require 'active_support/core_ext/array/conversions'
require 'action_controller/routing'
require 'rails_generator/base'
require 'rails_generator/commands'

require 'webmaster_tools/core_ext'
require 'webmaster_tools/defaults'
require 'webmaster_tools/verification'
require 'webmaster_tools/routing'
require 'webmaster_tools/sitemaps'
require 'webmaster_tools/sitemappable'

Array.class_eval do
  include WebmasterTools::CoreExtensions::Array
end

# Important - you must require the config file _before_ sending the 
# include to ActiveRecord::Base
config_file = File.join(RAILS_ROOT,"config","initializers","webmaster_tools.rb")
require config_file if File.exists?(config_file)

ActiveRecord::Base.send :include, WebmasterTools::Sitemappable

# This is a complete hack, and may even break the behavior of other parts of the app
# For the sitemap to function correctly, we need to have a list of all models
# That are sitemappable - so all models need to be loaded
# Rails does not actually require_dependency on the models though - so at the time
# of the plugin initialization, it seems like there are no subclasses to AR Base
# As a result, we require_dependency here on all of the models
# This is a hack because it only looks in the app models directories (and all subdirectories)
# However, a model could also live in a plugin
# The way this is set up, if I have a model in my models directory, and a model in my plugin
# that is sitemappable, if the sitemap is called _before_ the other model is called, the sitemap
# will not include the plugin's sitemap - so each plugin that implements a model with sitemappable
# also has to require_dependency on that model - a total and complete hack
# We do this before the routes so the routes can read from the index
Dir.glob(File.join(RAILS_ROOT,'app','models','**','*.rb')).each do |file|
  require_dependency file
end

ActionController::Routing::RouteSet::Mapper.send :include, WebmasterTools::Routing::MapperExtensions

Rails::Generator::Commands::Create.send :include, WebmasterTools::Verification::Generator::Create
Rails::Generator::Commands::Destroy.send :include, WebmasterTools::Verification::Generator::Destroy
Rails::Generator::Commands::List.send :include, WebmasterTools::Verification::Generator::List

# see http://dev.rubyonrails.org/ticket/9815#comment:6
ActionController::Routing::Routes.reload!
