# frozen_string_literal: true

module Que
  module View
    class WelcomeController < Que::View::ApplicationController
      def index
        @dashboard_stats = ::Que::View.fetch_dashboard_stats[0]
      end
    end
  end
end
