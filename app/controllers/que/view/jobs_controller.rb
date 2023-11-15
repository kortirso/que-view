# frozen_string_literal: true

module Que
  module View
    class JobsController < Que::View::ApplicationController
      PER_PAGE = 20

      before_action :find_job, only: %i[show]

      def index
        @jobs = find_jobs(params[:status])
        @jobs_amount = find_jobs_amount(params[:status])
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

      def find_job
        @job = ::Que::View.fetch_job(params[:id])[0]
        return if @job

        redirect_to root_path, notice: 'Job is not found'
      end

      def find_jobs(status)
        case status&.to_sym
        when :failed then ::Que::View.fetch_failed_jobs(PER_PAGE, offset, search)
        when :scheduled then ::Que::View.fetch_scheduled_jobs(PER_PAGE, offset, search)
        else []
        end
      end

      def find_jobs_amount(status)
        ::Que::View.fetch_dashboard_stats(search)[0][status&.to_sym]
      end

      def reschedule_all_jobs(status, time)
        case status&.to_sym
        when :failed then ::Que::View.reschedule_failed_jobs(time)
        when :scheduled then ::Que::View.reschedule_scheduled_jobs(time)
        else 0
        end
      end

      def destroy_all_jobs(status)
        case status&.to_sym
        when :failed then ::Que::View.delete_failed_jobs
        when :scheduled then ::Que::View.delete_scheduled_jobs
        else 0
        end
      end

      def search
        return '%' unless search_param

        "%#{search_param}%"
      end

      def search_param
        sanitised = (params[:search] || '').gsub(/[^0-9a-z:]/i, '')
        return if sanitised.empty?

        sanitised
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
