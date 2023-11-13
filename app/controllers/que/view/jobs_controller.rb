# frozen_string_literal: true

module Que
  module View
    class JobsController < Que::View::ApplicationController
      PER_PAGE = 20

      def index
        @jobs = find_jobs(params[:status])
        @jobs_amount = find_jobs_amount(params[:status])
      end

      def destroy
        redirect_to(
          jobs_path(status: params[:status]),
          notice: 'Removing single job is not ready yet'
        )
      end

      def destroy_all
        updated_rows = destroy_all_jobs(params[:status])
        redirect_to(
          jobs_path(status: params[:status]),
          notice: updated_rows.empty? ? 'No jobs deleted' : "#{updated_rows.count} jobs deleted"
        )
      end

      private

      def find_jobs(status)
        case status&.to_sym
        when :failing then ::Que::View.failing_jobs(PER_PAGE, offset, '%')
        else []
        end
      end

      def find_jobs_amount(status)
        ::Que::View.dashboard_stats('%')[0][status&.to_sym]
      end

      def destroy_all_jobs(status)
        case status&.to_sym
        when :failing then ::Que::View.delete_all_failing_jobs
        else 0
        end
      end

      def page
        (params[:page] || 1).to_i
      end

      def offset
        (page - 1) * PER_PAGE
      end
    end
  end
end
