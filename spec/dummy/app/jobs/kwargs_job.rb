# frozen_string_literal: true

class KwargsJob < ApplicationJob
  queue_as :default

  def perform(*args, **kwargs); end
end
