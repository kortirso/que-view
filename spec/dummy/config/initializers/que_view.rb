# frozen_string_literal: true

Que::View.configure do |config|
  config.ui_username = 'username'
  config.ui_password = 'password'
  config.ui_secured_environments = %w[production]
end
