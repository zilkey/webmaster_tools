require File.dirname(__FILE__) + '/spec_helper'

class Wynken < ActiveRecord::Base;end

class Blinken < ActiveRecord::Base
  sitemappable :default_host => "test"
end

class Nod < ActiveRecord::Base
end

describe Blinken do
  it "should have sitemap" do
    p Blinken.new.sitemap_lastmod
    p Blinken.new.sitemap_changefreq
    p Blinken.new.sitemap_priority
  end
end

describe Wynken do
  it "should not raise an error when a default lastmod is specified" do
    lambda{eval "class Wynken < ActiveRecord::Base;sitemappable(:default_lastmod => 2.days.ago);end"}.should_not raise_error
  end
end

describe Nod do
  it "should have sitemap" do
    #    @wynkens.to_sitemap
  end
end