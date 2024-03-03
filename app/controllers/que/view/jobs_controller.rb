# frozen_string_literal: true

module Que
  module View
    class JobsController < Que::View::ApplicationController
      PER_PAGE = 20

      before_action :find_queue_names, only: %i[index]
      before_action :find_job_names, only: %i[index]
      before_action :find_job, only: %i[show]

      def index
        @jobs = find_jobs(index_params)
        paginate
      end

      def show; end

      def update
        updated_rows = ::Que::View.reschedule_job(params[:id], Time.now)
        redirect_to(
          root_path,
          notice: updated_rows.empty? ? 'Job is not rescheduled' : 'Job is rescheduled'
        )
      end

      def destroy
        updated_rows = ::Que::View.delete_job(params[:id])
        redirect_to(
          root_path,
          notice: updated_rows.empty? ? 'Job is not deleted' : 'Job is deleted'
        )
      end

      def reschedule_all
        updated_rows = reschedule_all_jobs(params[:status], Time.now)
        redirect_to(
          jobs_path(status: params[:status]),
          notice: updated_rows.empty? ? 'No jobs rescheduled' : "#{updated_rows.count} jobs rescheduled"
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

      def find_queue_names
        @queue_names = [
          ['All queues', nil]
        ] + ::Que::View.fetch_queue_names
      end

      def find_job_names
        @job_names = [
          ['All jobs', nil]
        ] + ::Que::View.fetch_job_names(params[:queue_name])
      end

      def find_job
        @job = ::Que::View.fetch_job(params[:id])[0]
        return if @job

        redirect_to root_path, notice: 'Job is not found'
      end

      def paginate
        return if %w[failing scheduled].exclude?(params[:status])
        return unless @jobs.any?

        @pagination = Que::View::Pagination.new(
          params: {
            page: page,
            per_page: params[:per_page] || PER_PAGE,
            count: find_jobs_total_amount(params[:status])
          }
        )
      end

      def find_jobs(params)
        case params[:status]&.to_sym
        when :running then ::Que::View.fetch_running_jobs(params)
        when :failing then ::Que::View.fetch_failing_jobs(PER_PAGE, offset, params)
        when :scheduled then ::Que::View.fetch_scheduled_jobs(PER_PAGE, offset, params)
        when :finished then ::Que::View.fetch_finished_jobs(PER_PAGE, offset, params)
        when :expired then ::Que::View.fetch_expired_jobs(PER_PAGE, offset, params)
        else []
        end
      end

      def find_jobs_total_amount(status)
        ::Que::View.fetch_dashboard_stats[0][status&.to_sym]
      end

      def reschedule_all_jobs(status, time)
        case status&.to_sym
        when :failing then ::Que::View.reschedule_failing_jobs(time)
        when :scheduled then ::Que::View.reschedule_scheduled_jobs(time)
        else []
        end
      end

      def destroy_all_jobs(status)
        case status&.to_sym
        when :failing then ::Que::View.delete_failing_jobs
        when :scheduled then ::Que::View.delete_scheduled_jobs
        else []
        end
      end

      def offset
        (page - 1) * PER_PAGE
      end

      def page
        (params[:page] || 1).to_i
      end

      def index_params
        params.permit(:status, :queue_name, :job_name).to_h.symbolize_keys
      end
    end
  end
end
