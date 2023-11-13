# frozen_string_literal: true

module Que
  module View
    class Engine < ::Rails::Engine
      isolate_namespace Que::View
    end
  end
end
