require 'test_helper'

class MonitorControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get monitor_index_url
    assert_response :success
  end

end
