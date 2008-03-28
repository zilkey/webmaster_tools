# TODO: create a flag so instead of "--testing" it actually pings the server
namespace :webmaster_tools do
  namespace :google_sitemap_gen do
    desc "Generate a Google Site Map using the google_sitemap_gen tool provided by Google.  It attempts to read a config XML file in config/webmaster_tools"
    task :generate => :environment do
      exe_path = File.join(RAILS_ROOT,"vendor","plugins","webmaster_tools","google_sitemap_gen","sitemap_gen.py")
      config_path = File.join(RAILS_ROOT,"config","webmaster_tools","#{RAILS_ENV}.xml")
      system "python #{exe_path} --config=#{config_path} --testing"
    end
  end
end