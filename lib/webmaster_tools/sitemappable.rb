# TODO: figure out how to represent nested resources easily
# TODO: guess the changefreq
# Add multiple site-map attributes?
module WebmasterTools #:nodoc:
  module Sitemappable #:nodoc:

    class << self
      def included(target)
        target.extend(ClassMethods)
      end
    end

    module ClassMethods

      # Options
      # * <tt>path</tt>: Defaults to the underscore, pluralized name - Author => /authors
      # * <tt>index_path</tt>: Defaults to the underscore and _sitemap.xml, pluralized name - Author => /authors_sitemap.xml - this way it's at the root level
      # * <tt>host</tt>: Defaults to localhost:3000
      # * <tt>protocol</tt>: Defaults to http://
      # * <tt>priority</tt>: A value from 0.0 - 1.0. Defaults to 0.5
      # * <tt>changefreq</tt>: Defualts to "daily".  Must be one of
      #     always
      #     hourly
      #     daily
      #     weekly
      #     monthly
      #     yearly
      #     never
      # * <tt>lastmod_field</tt>: The field in the database, or method on the model, that holds the last modified date. Defaults to "updated_at"
      def sitemappable(options = {})
        WebmasterTools::Sitemaps.model_sitemaps << name.downcase.to_sym unless WebmasterTools::Sitemaps.model_sitemaps.include?(name.downcase.to_sym)

        class << self
          attr_accessor :sitemap_changefreq, :sitemap_priority, :sitemap_path, :sitemap_lastmod_field, :sitemap_host, :sitemap_protocol, :sitemap_index_path
        end

        @sitemap_path           = options[:path]          || "/#{name.underscore.pluralize}"
        @sitemap_index_path     = options[:index_path]    || "/#{name.underscore.pluralize}_sitemap.xml"
        @sitemap_changefreq     = options[:changefreq]    || WebmasterTools::Sitemaps::Defaults.changefreq    || "weekly"
        @sitemap_priority       = options[:priority]      || WebmasterTools::Sitemaps::Defaults.priority      || "0.5"
        @sitemap_lastmod_field  = options[:lastmod_field] || WebmasterTools::Sitemaps::Defaults.lastmod_field || :updated_at
        @sitemap_host           = options[:host]          || WebmasterTools::Sitemaps::Defaults.host          || "localhost:3000"
        @sitemap_protocol       = options[:protocol]      || WebmasterTools::Sitemaps::Defaults.protocol      || "http://"

        include Sitemappable::InstanceMethods
        extend  Sitemappable::SingletonMethods
      end   

      # This makes it easy to check if the class has the sitemappable mixin
      def sitemappable?
        true
      end 
    end

    module SingletonMethods
      
      # Override this method to determine the last modifed date of all of the models
      # This will be displayed on the sitemap index page
      def sitemap_lastmod
        find(:first, :order => "#{sitemap_lastmod_field.to_s} desc").send(sitemap_lastmod_field)
      end

      # Override this method in your models to determine which
      # records are included in the sitemap
      def sitemap
        [self].concat(find(:all))
      end

      # Turns this record into a WebmasterTools::Sitemaps::Node
      def to_sitemap_node
        WebmasterTools::Sitemaps::Node.new(:protocol => sitemap_protocol,
        :host => sitemap_host,
        :path => sitemap_path, 
        :lastmod => sitemap_lastmod, 
        :priority => sitemap_priority,
        :changefreq => sitemap_changefreq)
      end

      # Turns this record into a WebmasterTools::Sitemaps::IndexNode
      def to_sitemap_index_node
        WebmasterTools::Sitemaps::IndexNode.new(:protocol => sitemap_protocol,
        :host => sitemap_host,
        :path => sitemap_index_path,
        :lastmod => sitemap_lastmod)
      end

    end

    module InstanceMethods

      # Determines what the lastmod element will be in the xml sitemap
      def sitemap_lastmod
        send(self.class.sitemap_lastmod_field)
      end

      # Determines what the changefreq element will be in the xml sitemap
      def sitemap_changefreq
        self.class.sitemap_changefreq
      end

      # Determines what the priority element be in the xml sitemap
      def sitemap_priority
        self.class.sitemap_priority
      end

      # Determines what the url element be in the xml sitemap
      def sitemap_path
        "#{self.class.sitemap_path}/#{to_param}"
      end

      # Determines what host the url element use in the xml sitemap
      # Useful to dynamically generate the correct subdomain for a record, for example
      def sitemap_host
        self.class.sitemap_host
      end

      # Determines what protocol the url element use in the xml sitemap
      # Useful if only certain records are https-protected
      def sitemap_protocol
        self.class.sitemap_protocol
      end
      
      # Turns this record into a sitemap node
      def to_sitemap_node
        WebmasterTools::Sitemaps::Node.new(:protocol => sitemap_protocol,
        :host => sitemap_host,
        :path => sitemap_path, 
        :lastmod => sitemap_lastmod, 
        :priority => sitemap_priority,
        :changefreq => sitemap_changefreq)
      end
    end
  end
end