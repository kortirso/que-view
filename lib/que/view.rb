# frozen_string_literal: true

require 'forwardable'

require 'que/view/version'
require 'que/view/engine'
require 'que/view/configuration'
require 'que/view/dsl'
require 'que/view/pagination'

module Que
  module View
    extend self
    extend Forwardable

    # Public: Configure que view.
    #
    #   Que::View.configure do |config|
    #   end
    #
    def configure
      yield configuration
    end

    # Public: Returns Que::View::Configuration instance.
    def configuration
      @configuration ||= Configuration.new
    end

    # Public: Default per thread que view instance if configured.
    # Returns Que::View::DSL instance.
    def instance
      Thread.current[:que_view_instance] ||= DSL.new
    end

    # Public: All the methods delegated to instance. These should match the interface of Que::View::DSL.
    def_delegators :instance, :fetch_dashboard_stats, :fetch_que_lockers,
                   :fetch_queue_names, :fetch_job_names,
                   :fetch_running_jobs, :fetch_failing_jobs, :fetch_scheduled_jobs, :fetch_finished_jobs,
                   :fetch_expired_jobs, :fetch_job,
                   :delete_failing_jobs, :delete_scheduled_jobs, :delete_job,
                   :reschedule_scheduled_jobs, :reschedule_failing_jobs, :reschedule_job
  end
end
