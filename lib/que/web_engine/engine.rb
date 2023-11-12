# frozen_string_literal: true

module Que
  module WebEngine
    class Engine < ::Rails::Engine
      isolate_namespace Que::WebEngine
    end
  end
end
