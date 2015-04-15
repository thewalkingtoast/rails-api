require 'test_helper'

class MiddlewareApiController < ActionController::API
  use ActionDispatch::ShowExceptions, Rails::API::PublicExceptions.new(Rails.public_path)

  def boom
    raise "boom"
  end
end

class RenderExceptionsTest < ActionDispatch::IntegrationTest
  def setup
    @app = RenderersApiController.action(:boom)
  end

  def test_render_json_exception
    get "/fake", headers: { 'HTTP_ACCEPT' => 'application/json' }
    assert_response :internal_server_error
    assert_equal 'application/json', response.content_type.to_s
    assert_equal({ :status => '500', :error => 'boom' }.to_json, response.body)
  end

  def test_render_xml_exception
    get "/fake", headers: { 'HTTP_ACCEPT' => 'application/xml' }
    assert_response :internal_server_error
    assert_equal 'application/xml', response.content_type.to_s
    assert_equal({ :status => '500', :error => 'boom' }.to_xml, response.body)
  end

  def test_render_fallback_exception
    get "/fake", headers: { 'HTTP_ACCEPT' => 'text/csv' }
    assert_response :internal_server_error
    assert_equal 'text/html', response.content_type.to_s
  end
end
