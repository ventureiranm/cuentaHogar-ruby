ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

module ActiveSupport
  class TestCase
    parallelize(workers: :number_of_processors)
    fixtures :all

    TEST_PASSWORD = "password123".freeze
  end
end

module AuthTestHelpers
  # Login en el back-office (cookie de sesión).
  def sign_in_as(user, password: ActiveSupport::TestCase::TEST_PASSWORD)
    post session_path, params: { email_address: user.email_address, password: password }
  end

  # Header para la API. Los tokens en claro de los fixtures están en test/fixtures/api_tokens.yml.
  def auth_headers(raw_token)
    { "Authorization" => "Bearer #{raw_token}" }
  end
end

module ActionDispatch
  class IntegrationTest
    include AuthTestHelpers
  end
end
