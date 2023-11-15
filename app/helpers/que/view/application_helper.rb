# frozen_string_literal: true

module Que
  module View
    module ApplicationHelper
      def humanized_job_class(job)
        case job[:job_class]
        when 'ActiveJob::QueueAdapters::QueAdapter::JobWrapper' then job.dig(:args, 0, :job_class)
        else job[:job_class]
        end
      end

      def format_error(job)
        return unless job[:last_error_message]

        job[:last_error_message].lines.first || ''
      end
    end
  end
end
