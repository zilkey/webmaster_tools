# Creates a file named config/webmaster_verification.yml
# Adds a "map.webmaster_verification" to config/routes.rb
class WebmasterVerificationGenerator < Rails::Generator::Base
  def manifest
    record do |m|
      m.file "webmaster_verification.yml", "config/webmaster_verification.yml"
      m.route_webmaster_verification
    end
  end
end