require "test_helper"

class ApiTokenTest < ActiveSupport::TestCase
  test "issue_for genera un token y solo guarda su digest" do
    api_token, raw_token = ApiToken.issue_for(users(:diego))

    assert raw_token.present?
    assert_not_equal raw_token, api_token.token_digest
    assert_equal ApiToken.digest(raw_token), api_token.token_digest
    assert_in_delta ApiToken::TTL.from_now, api_token.expires_at, 5
  end

  test "authenticate encuentra tokens vigentes y registra el uso" do
    api_token = ApiToken.authenticate("lucia-token")

    assert_equal users(:lucia), api_token.user
    assert api_token.last_used_at.present?
  end

  test "authenticate rechaza tokens vencidos, inexistentes o vacíos" do
    assert_nil ApiToken.authenticate("expired-token")
    assert_nil ApiToken.authenticate("no-existe")
    assert_nil ApiToken.authenticate(nil)
  end
end
