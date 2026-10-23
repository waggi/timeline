require "test_helper"

class EventsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @event = events(:launch)
  end

  test "root shows the events list" do
    get root_url
    assert_response :success
    assert_select "h1", "Events"
  end

  test "index lists events sorted by date" do
    get events_url
    assert_response :success
    assert_select "#events h2", count: 2
    titles = css_select("#events h2").map(&:text)
    assert_match "Kickoff meeting", titles.first
    assert_match "Project launch", titles.last
  end

  test "index shows a placeholder when there are no events" do
    Event.delete_all
    get events_url
    assert_select "#events", /No events yet/
  end

  test "should get new" do
    get new_event_url
    assert_response :success
  end

  test "should create event" do
    assert_difference("Event.count") do
      post events_url, params: { event: { title: "New one", happened_on: "2026-07-01", description: "Details", url: "https://example.com" } }
    end

    assert_redirected_to events_url
    event = Event.order(:id).last
    assert_equal "New one", event.title
    assert_equal Date.new(2026, 7, 1), event.happened_on
    assert_equal "manual", event.source
  end

  test "create ignores source param" do
    post events_url, params: { event: { title: "New one", happened_on: "2026-07-01", source: "blog" } }
    assert_equal "manual", Event.order(:id).last.source
  end

  test "should not create invalid event" do
    assert_no_difference("Event.count") do
      post events_url, params: { event: { title: "", happened_on: "" } }
    end

    assert_response :unprocessable_content
  end

  test "should get edit" do
    get edit_event_url(@event)
    assert_response :success
  end

  test "should update event" do
    patch event_url(@event), params: { event: { title: "Renamed", happened_on: "2026-04-01" } }
    assert_redirected_to events_url
    @event.reload
    assert_equal "Renamed", @event.title
    assert_equal Date.new(2026, 4, 1), @event.happened_on
  end

  test "should not update event with invalid data" do
    patch event_url(@event), params: { event: { title: "" } }
    assert_response :unprocessable_content
    assert_equal "Project launch", @event.reload.title
  end

  test "should destroy event" do
    assert_difference("Event.count", -1) do
      delete event_url(@event)
    end

    assert_redirected_to events_url
  end
end
