# frozen_string_literal: true

class ArgsJob < ApplicationJob
  queue_as :default

  def perform(*options); end
end
