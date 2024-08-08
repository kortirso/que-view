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

      def humanized_job_args(job)
        case job[:job_class]
        when 'ActiveJob::QueueAdapters::QueAdapter::JobWrapper' then active_job_args(job)
        else que_args(job)
        end.join('<br />').html_safe
      end

      def humanized_enqueued_at(job)
        case job[:job_class]
        when 'ActiveJob::QueueAdapters::QueAdapter::JobWrapper'
          job.dig(:args, 0, :enqueued_at).to_time.strftime('%Y-%m-%d %H:%M:%S')
        end
      end

      private

      def active_job_args(job)
        job.dig(:args, 0, :arguments)&.map do |arg|
          next arg.except(:_aj_ruby2_keywords, :_aj_symbol_keys) if arg.is_a?(Hash)

          arg
        end || []
      end

      def que_args(job)
        job[:args].push(job[:kwargs])
      end
    end
  end
end
