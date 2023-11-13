# frozen_string_literal: true

require 'forwardable'

require 'que/view/version'
require 'que/view/engine'
require 'que/view/configuration'
require 'que/view/dsl'

module Que
  module View
    extend self
    extend Forwardable

    # Public: Configure emailbutler.
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

    # Public: Default per thread emailbutler instance if configured.
    # Returns Que::View::DSL instance.
    def instance
      Thread.current[:que_view_instance] ||= DSL.new
    end

    # Public: All the methods delegated to instance. These should match the interface of Que::View::DSL.
    def_delegators :instance,
                   :dashboard_stats, :failing_jobs, :delete_all_failing_jobs
  end
end
