module WebmasterTools #:nodoc:
  module Sitemaps

    @@model_sitemaps     = []
    @@custom_sitemaps   = []

    [:model_sitemaps].each do |sym|
      class_eval <<-EOS, __FILE__, __LINE__
      def self.#{sym}
        if defined?(#{sym.to_s.upcase})
          #{sym.to_s.upcase}
        else
          @@#{sym}
        end
      end

      def self.#{sym}=(value)
        @@#{sym} = value
      end
      EOS
    end

    # Returns a list of all models that have declared sitemappable
    def self.all_sitemaps
      @@model_sitemaps.map{|model| model.to_s.classify.constantize}.concat(@@custom_sitemaps)
    end

    # Adds a custom sitemap to the list that will be included in the index file
    def self.add(options)
      sitemap = CustomSitemap.new(options)
      @@custom_sitemaps << sitemap unless @@custom_sitemaps.map(&:to_s).include?(sitemap.to_s)
    end

    # Node is the generic class that represents a sitemap node.
    # You can create non-ActiveRecord models and as long as they define a to_sitemap_node
    # you can use this node to add sitemappable ability to your site.
    #
    # This is particularly useful if you have a flat file that lists urls
    class Node

      attr_accessor :protocol, :host, :path, :lastmod, :priority, :changefreq

      def initialize(options)
        [:protocol, :host, :path, :lastmod, :priority, :changefreq].each do |field|
          self.send("#{field}=",options[field])
        end
      end

      # Outputs the contents of the current node to a valid sitemap element
      def to_xml(options = {})
        options[:indent] ||= 2
        xml = options[:builder] ||= Builder::XmlMarkup.new(:indent => options[:indent])
        xml.instruct! unless options[:skip_instruct]
        xml.url do
          xml.tag!(:loc, "#{protocol || options[:protocol]}#{host || options[:host]}#{path}")
          xml.tag!(:lastmod, lastmod.xmlschema) if lastmod.respond_to?(:xmlschema)
          xml.tag!(:priority, priority)
          xml.tag!(:changefreq, changefreq)
        end
      end
    end

    # This IndexNode is the object that represents a single row in the 
    # sitemap index file.
    # You can create your own classes, and as long as they have a to_sitemap_index_node
    # method they can be used as part of the sitemap index file
    class IndexNode      
      attr_accessor :protocol, :host, :path, :lastmod

      def initialize(options)
        [:protocol, :host, :path, :lastmod].each do |field|
          self.send("#{field}=",options[field])
        end
      end

      # Returns an xml representation of the IndexNode that conforms to 
      # xml sitemap index elements
      def to_xml(options = {})
        options[:indent] ||= 2
        xml = options[:builder] ||= Builder::XmlMarkup.new(:indent => options[:indent])
        xml.instruct! unless options[:skip_instruct]
        xml.sitemap do
          xml.tag!(:loc, "#{protocol || options[:protocol]}#{host || options[:host]}#{path}")
          xml.tag!(:lastmod, lastmod.xmlschema) if lastmod.respond_to?(:xmlschema)
        end
      end
    end

    # Gives you the ability to define a url that contains a sitemap
    # Contains a to_sitemap_index_node method so it can be used in arrays that 
    # will be the base of the sitemap index
    class CustomSitemap
      attr_accessor :protocol, :host, :path, :lastmod

      def initialize(options)
        @protocol = options[:protocol]      || WebmasterTools::Sitemaps::Defaults.protocol      || "http://"
        @host     = options[:host]          || WebmasterTools::Sitemaps::Defaults.host          || "localhost:3000"
        @path     = options[:path]
        @lastmod  = options[:lastmod]
      end
      
      def to_sitemap_index_node
        IndexNode.new(:protocol => protocol, :host => host, :path => path, :lastmod => lastmod)
      end
      
      def to_s
        "#{protocol}#{host}#{path}"
      end
    end

  end

  # A custom controller that we'll use for setting up the sitemap
  class SitemapsController < ActionController::Base

    # An index file that links to all of the other sitemaps
    def index
      render :xml => WebmasterTools::Sitemaps.all_sitemaps.to_sitemap_index(options)
    end

    # This method handles all calls to the active record sitemaps
    def model
      render :xml => params[:model].classify.constantize.sitemap.to_sitemap(options)
    end

    private

    def options
      returning options = {} do
        options[:host]      = request.host_with_port if WebmasterTools::Sitemaps::Defaults.host == :current
        options[:protocol]  = request.protocol if WebmasterTools::Sitemaps::Defaults.protocol == :current
      end
    end

  end


end