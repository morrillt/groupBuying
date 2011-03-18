if Rails.env.development?
  require 'compass'
  require 'compass/app_integration/rails'
  Compass::AppIntegration::Rails.initialize!
end
