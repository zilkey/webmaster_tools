require File.dirname(__FILE__) + '/spec_helper'

class Wynken;end

class Blinken
  def to_sitemap(options)
    "blink!"
  end
end

describe Array, "none respond to sitemap" do
  before(:each) do
    @none = [Wynken.new, Wynken.new]
  end
  it "should throw an error" do
    lambda{@mixed.to_sitemap}.should raise_error
  end
end

describe Array, "all respond to sitemap" do
  before(:each) do
    @all = [Blinken.new, Blinken.new]
  end
  it "should have sitemap" do
    @all.to_sitemap.should == "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<urlset xmlns=\"http://www.sitemaps.org/schemas/sitemap/0.9\">\n</urlset>\n"
  end
end

describe Array, "some respond to sitemap" do
  before(:each) do
    @mixed = [Wynken.new, Blinken.new]
  end
  it "should throw an error" do
    lambda{@mixed.to_sitemap}.should raise_error
  end
end