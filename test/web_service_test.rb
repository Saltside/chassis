require_relative 'test_helper'

class WebServiceTest < MiniTest::Unit::TestCase
  include Rack::Test::Methods

  attr_reader :app

  def test_form_errors_return_400
    @app = Class.new Chassis::WebService do
      get '/' do
        raise Chassis::Form::UnknownFieldError, :test
      end
    end

    get '/'

    assert_equal 400, last_response.status
    assert_json last_response
    assert_error_message last_response
  end

  def test_repo_record_not_found_returns_404
    @app = Class.new Chassis::WebService do
      get '/' do
        raise Chassis::Repo::RecordNotFoundError.new(Object, 'some-id')
      end
    end

    get '/'

    assert_equal 404, last_response.status
    assert_json last_response
    assert_error_message last_response
  end

  def test_raise_an_error_when_required_param_is_not_given
    @app = Class.new Chassis::WebService do
      get '/' do
        extract! :post
      end
    end

    get '/'

    assert_equal 400, last_response.status
    assert_json last_response
    assert_error_message last_response
  end

  def test_parses_json_requests
    @app = Class.new Chassis::WebService do
      post '/' do
        params.fetch('json').fetch('key')
      end
    end

    post '/', JSON.dump(json: { key: 'value' }), 'CONTENT_TYPE' => 'application/json'

    assert_equal 'value', last_response.body
  end

  def test_blocks_robots
    @app = Class.new Chassis::WebService

    get '/robots.txt'

    assert_equal 200, last_response.status
    assert_includes last_response.body, "Disallow: /"
  end

  private
  def assert_json(response)
    assert_includes response.content_type, 'application/json'
  end

  def assert_error_message(response)
    json = JSON.load(response.body)
    assert json.fetch('error').fetch('message')
  end
end