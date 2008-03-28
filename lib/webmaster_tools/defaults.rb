module WebmasterTools
  module Sitemaps
    
    # Protocol can be any string, or :current
    # Host can be any string or :current
    class Defaults
      class << self
        attr_accessor :host, :protocol, :changefreq, :lastmod_field, :priority
      end
    end
  end
end