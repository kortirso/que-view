# frozen_string_literal: true

class SimpleJob < ApplicationJob
  queue_as :default

  def perform; end
end
