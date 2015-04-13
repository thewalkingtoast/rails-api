module Rails
  class Application
    class DefaultMiddlewareStack
      def build_stack
        ActionDispatch::MiddlewareStack.new.tap do |middleware|
          if config.force_ssl
            middleware.use ::ActionDispatch::SSL, config.ssl_options
          end

          middleware.use ::Rack::Sendfile, config.action_dispatch.x_sendfile_header

          if config.serve_static_files
            middleware.use ::ActionDispatch::Static, paths["public"].first, config.static_cache_control
          end

          if rack_cache = load_rack_cache
            require "action_dispatch/http/rack_cache"
            middleware.use ::Rack::Cache, rack_cache
          end

          middleware.use ::Rack::Lock unless allow_concurrency?
          middleware.use ::Rack::Runtime
          middleware.use ::Rack::MethodOverride unless config.api_only
          middleware.use ::ActionDispatch::RequestId

          # Must come after Rack::MethodOverride to properly log overridden methods
          middleware.use ::Rails::Rack::Logger, config.log_tags
          middleware.use ::ActionDispatch::ShowExceptions, show_exceptions_app
          middleware.use ::ActionDispatch::DebugExceptions, app
          middleware.use ::ActionDispatch::RemoteIp, config.action_dispatch.ip_spoofing_check, config.action_dispatch.trusted_proxies

          unless config.cache_classes
            middleware.use ::ActionDispatch::Reloader, lambda { reload_dependencies? }
          end

          middleware.use ::ActionDispatch::Callbacks
          middleware.use ::ActionDispatch::Cookies unless config.api_only

          if !config.api_only && config.session_store
            if config.force_ssl && !config.session_options.key?(:secure)
              config.session_options[:secure] = true
            end
            middleware.use config.session_store, config.session_options
            middleware.use ::ActionDispatch::Flash
          end

          middleware.use ::ActionDispatch::ParamsParser
          middleware.use ::Rack::Head
          middleware.use ::Rack::ConditionalGet
          middleware.use ::Rack::ETag, "no-cache"
        end
      end

      private

        def show_exceptions_app
          config.exceptions_app || Rails::API::PublicExceptions.new(Rails.public_path)
        end
    end
  end
end
