# frozen_string_literal: true

require "test_helper"

class HomeControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get home_index_url
    assert_response :success
  end

  # Optional: Test authenticated flow
  test "should redirect to expenses for signed-in user" do
    user = users(:one)
    sign_in user
    get root_url
    assert_redirected_to expenses_url
  end
end
