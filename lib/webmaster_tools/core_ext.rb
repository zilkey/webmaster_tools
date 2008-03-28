module WebmasterTools #:nodoc:
  module CoreExtensions #:nodoc:
    module Array

      # Loops through every element in an array and calls "to_sitemap_node.to_xml"
      def to_sitemap(options = {})
        
        options[:host]
        options[:protocol]
        
        raise "Not all elements respond to to_sitemap_node" unless all? { |e| e.respond_to? :to_sitemap_node }

        options[:indent]   ||= 2
        options[:builder]  ||= Builder::XmlMarkup.new(:indent => options[:indent])

        root     = "urlset"
        children = "url"

        options[:builder].instruct! unless options.delete(:skip_instruct)

        opts = options.merge({ :root => children })

        xml = options[:builder]
        if empty?
          xml.tag!(root, {:xmlns => "http://www.sitemaps.org/schemas/sitemap/0.9"})
        else
          xml.tag!(root, {:xmlns => "http://www.sitemaps.org/schemas/sitemap/0.9"}) {
            yield xml if block_given?
            each { |e| e.to_sitemap_node.to_xml(opts.merge!({ :skip_instruct => true })) }
          }
        end
      end

      # Loops through every element in an array and calls "to_sitemap_index"
      def to_sitemap_index(options = {})
        
        options[:host]
        options[:protocol]
        
        raise "Not all elements respond to to_sitemap_index_node" unless all? { |e| e.respond_to? :to_sitemap_index_node }

        options[:indent]   ||= 2
        options[:builder]  ||= Builder::XmlMarkup.new(:indent => options[:indent])

        root     = "sitemapindex"
        children = "sitemap"

        options[:builder].instruct! unless options.delete(:skip_instruct)

        opts = options.merge({ :root => children })

        xml = options[:builder]
        if empty?
          xml.tag!(root, {:xmlns => "http://www.sitemaps.org/schemas/sitemap/0.9"})
        else
          xml.tag!(root, {:xmlns => "http://www.sitemaps.org/schemas/sitemap/0.9"}) {
            yield xml if block_given?
            each { |e| e.to_sitemap_index_node.to_xml(opts.merge!({ :skip_instruct => true })) }
          }
        end
      end
    end
  end
end