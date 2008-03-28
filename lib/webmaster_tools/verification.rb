module WebmasterTools #:nodoc:
  module Verification #:nodoc:
    # A custom config class used to read the values of the config/webmaster_verification.yml file
    class Config
      class << self
        def authorized_accounts(engine)
          config = YAML.load_file("#{RAILS_ROOT}/config/webmaster_verification.yml")
          config[engine.to_s] || []
        end
      end
    end

    # Methods to mix into the generator to add the necessary routes to routes.rb
    # By mixing this in we get access to methods like gsub_file
    module Generator #:nodoc:

      # called from script/generate webmaster_verification
      # 
      # called from script/generate webmaster_verification -p
      # 
      # Adds the route to config/routes.rb
      module Create
        def route_webmaster_verification
          logger.route "map.website_verification"
          sentinel = 'ActionController::Routing::Routes.draw do |map|'
          unless options[:pretend]
            gsub_file('config/routes.rb', /(#{Regexp.escape(sentinel)})/mi){|match| "#{match}\n  map.webmaster_verification\n"}
          end          
        end
      end

      # called from script/destroy webmaster_verification
      # 
      # called from script/destroy webmaster_verification -p
      # 
      # Removes the route from config/routes.rb
      module Destroy
        def route_webmaster_verification
          logger.route "map.website_verification"
          resource_list = resources.map { |r| r.to_sym.inspect }.join(', ')
          look_for = "\n  map.webmaster_verification\n"
          gsub_file 'config/routes.rb', /(#{look_for})/mi, ''
        end      
      end

      # No idea when this is used - can't find any references to it in source
      # 
      # The rails generators just put log messages here, which is what I'll do
      module List
        def route_webmaster_verification
          logger.route "map.website_verification"
        end
      end
    end
  end

  # A custom controller that we'll use for serving the various webmaster verification files
  class VerificationController < ActionController::Base

    # GET /google<key>.html
    # Google does not require any content in the file
    def google
      render :nothing => true
    end

    # GET /y_key_<key>.html
    # Yahoo requires both a filename _and_ content
    def yahoo
      render :text => params[:content]
    end

    # GET /LiveSearchSiteAuth.xml
    # Live requires an xml file with all of the authenticated users
    def live
      users = WebmasterTools::Verification::Config.authorized_accounts(:live).map(&:last)
      xml = %Q{<?xml version="1.0"?><users><user>#{users.join("</user><user>")}</user></users>}
      render :xml => xml
    end
  end


end