# frozen_string_literal: true

module Que
  module View
    class QueueMetricsController < Que::View::ApplicationController
      before_action :find_queue_metrics, only: %i[index]

      def index; end

      private

      def find_queue_metrics
        @queue_metrics = ::Que::View.fetch_queue_metrics
      end
    end
  end
end
