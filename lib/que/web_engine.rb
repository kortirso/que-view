# frozen_string_literal: true

require 'forwardable'

require 'que/web_engine/version'
require 'que/web_engine/engine'
require 'que/web_engine/configuration'
require 'que/web_engine/dsl'

module Que
  module WebEngine
    extend self
    extend Forwardable

    # Public: Configure emailbutler.
    #
    #   Que::WebEngine.configure do |config|
    #   end
    #
    def configure
      yield configuration
    end

    # Public: Returns Que::WebEngine::Configuration instance.
    def configuration
      @configuration ||= Configuration.new
    end

    # Public: Default per thread emailbutler instance if configured.
    # Returns Que::WebEngine::DSL instance.
    def instance
      Thread.current[:que_web_engine_instance] ||= DSL.new
    end

    # Public: All the methods delegated to instance. These should match the interface of Que::WebEngine::DSL.
    def_delegators :instance,
                   :dashboard_stats
  end
end
