# frozen_string_literal: true

module Que
  module WebEngine
    class WelcomeController < Que::WebEngine::ApplicationController
      def index
        @dashboard_stats = ::Que::WebEngine.dashboard_stats('%')[0]
      end
    end
  end
end
