module WebmasterTools #:nodoc:
  module Routing #:nodoc:
    module MapperExtensions

      # Usage:
      #
      #   ActionController::Routing::Routes.draw do |map|
      #     map.xml_sitemap
      #   end
      #
      # Adds a route for /sitemap.xml
      def xml_sitemap
        @set.add_route("/sitemap.xml", {:controller => "webmaster_tools/sitemaps", :action => "index", :format => "xml"})
        WebmasterTools::Sitemaps.model_sitemaps.each do |model|
          @set.add_route("/#{model.to_s.pluralize}_sitemap.xml", {:controller => "webmaster_tools/sitemaps", :action => "model", :format => "xml", :model => model.to_s})
        end
      end

      # Usage:
      #
      #   ActionController::Routing::Routes.draw do |map|
      #     map.webmaster_verification
      #   end
      #
      def webmaster_verification
        add_google_routes
        add_yahoo_routes
        add_live_route
      end

      private

      def add_google_routes
        WebmasterTools::Verification::Config.authorized_accounts(:google).each do |entry|
          options = {:controller => "webmaster_tools/verification", :action => "google"}
          @set.add_route(entry.last, options)
        end
      end

      def add_yahoo_routes
        WebmasterTools::Verification::Config.authorized_accounts(:yahoo).each do |entry|
          options = {:controller => "webmaster_tools/verification", :action => "yahoo", :content => entry.last["content"]}
          @set.add_route(entry.last["filename"], options)
        end
      end

      def add_live_route
        options = {:controller => "webmaster_tools/verification", :action => "live", :format => "xml"}
        @set.add_route("LiveSearchSiteAuth.xml", options)
      end
    end
  end
end