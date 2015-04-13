require 'rails/application'
require 'rails-api/public_exceptions'
require 'rails-api/application/default_middleware_stack'

module Rails
  class Application < Engine
    def default_middleware_stack
      DefaultMiddlewareStack.new(self, config, paths).build_stack
    end

    private

    def setup_generators!
      generators = config.generators

      generators.templates.unshift File::expand_path('../templates', __FILE__)
      generators.resource_route = :api_resource_route

      generators.hide_namespace "css"

      generators.rails({
        :helper => false,
        :assets => false,
        :stylesheets => false,
        :stylesheet_engine => nil,
        :template_engine => nil
      })
    end

    ActiveSupport.on_load(:before_configuration) do
      config.api_only = true
      setup_generators!
    end
  end
end
