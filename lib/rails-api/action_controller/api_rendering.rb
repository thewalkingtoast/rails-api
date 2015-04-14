module ActionController
  module ApiRendering
    def render_to_body(options = {})
      _process_options(options)
      super
    end
  end
end
