# frozen_string_literal: true

module Que
  module View
    class QueueMetricsController < Que::View::ApplicationController
      before_action :find_queue_metrics, only: %i[index]
      before_action :find_queue_latencies, only: %i[index]

      def index; end

      private

      def find_queue_metrics
        @queue_metrics = ::Que::View.fetch_queue_metrics
      end

      def find_queue_latencies
        current_time = DateTime.now.to_i
        @queue_latencies =
          ::Que::View
            .fetch_queue_latencies(@queue_metrics.keys)
            .transform_values { |value| current_time - value.to_time.to_i }
      end
    end
  end
end
