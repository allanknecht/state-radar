require "test_helper"

class scraperRecordsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get scraper_records_index_url
    assert_response :success
  end

  test "should get show" do
    get scraper_records_show_url
    assert_response :success
  end
end
