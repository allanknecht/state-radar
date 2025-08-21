require "test_helper"

class ScrapperRecordsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get scrapper_records_index_url
    assert_response :success
  end

  test "should get show" do
    get scrapper_records_show_url
    assert_response :success
  end
end
