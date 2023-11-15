# frozen_string_literal: true

module Que
  module View
    class ApplicationController < ActionController::Base
      http_basic_authenticate_with name: ::Que::Web.configuration.ui_username,
                                   password: ::Que::Web.configuration.ui_password,
                                   if: -> { basic_auth_enabled? }

      private

      def basic_auth_enabled?
        configuration = ::Que::Web.configuration

        return false if configuration.ui_username.blank?
        return false if configuration.ui_password.blank?

        configuration.ui_secured_environments.include?(Rails.env)
      end
    end
  end
end
