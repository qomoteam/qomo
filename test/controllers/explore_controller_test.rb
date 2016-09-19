require 'test_helper'

class ExploreControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get explore_index_url
    assert_response :success
  end

end
