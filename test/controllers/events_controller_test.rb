require "test_helper"

class EventsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @event = events(:earlier)
    @attributes = { title: "New event", happened_on: "2026-10-23", description: "Some details", url: "https://example.com/new" }
  end

  test "home page shows the timeline, the event list and the inline form" do
    get root_url

    assert_response :success
    assert_select "h1", "Events"
    assert_select "[data-controller=timeline][data-timeline-items-value]" do |sections|
      items = JSON.parse(sections.first["data-timeline-items-value"])
      assert_equal Event.chronological.map(&:id), items.map { |item| item["id"] }
      assert_equal({ "id" => @event.id, "title" => @event.title, "date" => "2020-01-01", "source" => "manual", "url" => event_path(@event) }, items.first)
    end
    assert_select "[data-testid=timeline]"
    assert_select "turbo-frame#event_details[target=_top]"
    assert_select "[data-testid=event-list] [data-testid=event-list-item] a" do |links|
      assert_equal Event.chronological.map(&:title), links.map { |link| link.text.strip }
    end
    assert_select "[data-testid=event-list-item][data-event-id=?] [data-testid=source-icon][data-source=blog]", events(:later).id.to_s
    assert_select "dialog[data-testid=new-event-dialog] form[action=?]", events_path do
      assert_select "input[name=inline]"
      assert_select "[name='event[source]']", count: 0
    end
  end

  test "index displays an empty state" do
    Event.delete_all
    get events_url

    assert_response :success
    assert_select "[data-testid=empty-state]", /No events yet/
    assert_select "[data-testid=timeline]", count: 0
  end

  test "shows event details" do
    get event_url(@event)

    assert_response :success
    assert_select "turbo-frame#event_details[target=_top] h1", @event.title
    assert_select "[data-testid=source-icon][data-source=manual]"
    assert_select "h1", @event.title
    assert_select "time[datetime=?]", @event.happened_on.iso8601
    assert_select "p", @event.description
    assert_select "a[href=?]", @event.url
    assert_select "p", "Source type: manual"
  end

  test "shows an event without optional fields" do
    @event.update!(description: nil, url: nil)
    get event_url(@event)

    assert_response :success
    assert_select "a", text: "Source", count: 0
  end

  test "does not render unsafe source links even if validations were bypassed" do
    @event.update_column(:url, "javascript:alert(1)")
    get event_url(@event)

    assert_response :success
    assert_select "a[href^='javascript:']", count: 0
    assert_select "a:not([href])", "Source"
  end

  test "renders the new event form" do
    get new_event_url

    assert_response :success
    assert_select "form[action=?]", events_path
    assert_select "input[name='event[title]'][required]"
    assert_select "input[type=date][name='event[happened_on]'][required]"
    assert_select "textarea[name='event[description]']"
    assert_select "input[type=url][name='event[url]']"
    assert_select "[name='event[source]']", count: 0
  end

  test "creates an event with manual source even when another source is submitted" do
    assert_difference "Event.count", 1 do
      post events_url, params: { event: @attributes.merge(source: "blog") }
    end

    created = Event.order(:id).last
    assert_redirected_to event_url(created)
    assert_equal "manual", created.source
    assert_equal @attributes[:title], created.title
    assert_equal Date.new(2026, 10, 23), created.happened_on
    assert_equal @attributes[:description], created.description
    assert_equal @attributes[:url], created.url
    follow_redirect!
    assert_select "[role=status]", "Event was successfully created."
  end

  test "creating from the timeline dialog updates the page in place" do
    assert_difference "Event.count", 1 do
      post events_url(format: :turbo_stream), params: { inline: 1, event: @attributes }
    end

    created = Event.order(:id).last
    assert_response :success
    assert_equal "text/vnd.turbo-stream.html", response.media_type
    assert_select "turbo-stream[action=replace][target=timeline_section]" do
      assert_select "template turbo-frame#event_details[src=?]", event_path(created)
      assert_select "template [data-testid=event-list-item][data-event-id=?]", created.id.to_s
    end
    assert_select "turbo-stream[action=update][target=flash]", /Event was successfully created./
  end

  test "invalid creation from the timeline dialog re-renders the form with errors" do
    assert_no_difference "Event.count" do
      post events_url(format: :turbo_stream), params: { inline: 1, event: @attributes.merge(title: "") }
    end

    assert_response :unprocessable_entity
    assert_select "turbo-stream[action=replace][target=event_form]" do
      assert_select "template [role=alert]", /Title can't be blank/
      assert_select "template input[name=inline]"
    end
  end

  test "the standalone new page keeps redirecting even when Turbo asks for a stream" do
    post events_url, params: { event: @attributes }, as: :turbo_stream

    assert_redirected_to event_url(Event.order(:id).last)
  end

  test "invalid creation renders errors and preserves entered values" do
    assert_no_difference "Event.count" do
      post events_url, params: { event: @attributes.merge(title: "", happened_on: "invalid") }
    end

    assert_response :unprocessable_entity
    assert_select "[role=alert]", /Title can't be blank/
    assert_select "[role=alert]", /Happened on can't be blank/
    assert_select "textarea", @attributes[:description]
  end

  test "renders the edit form with current values" do
    get edit_event_url(@event)

    assert_response :success
    assert_select "input[name='event[title]'][value=?]", @event.title
    assert_select "input[name='event[happened_on]'][value=?]", @event.happened_on.iso8601
  end

  test "updates event details without changing its source" do
    @event = events(:later)
    patch event_url(@event), params: { event: @attributes.merge(source: "manual") }

    assert_response :see_other
    assert_redirected_to event_url(@event)
    @event.reload
    assert_equal @attributes[:title], @event.title
    assert_equal Date.new(2026, 10, 23), @event.happened_on
    assert_equal @attributes[:description], @event.description
    assert_equal @attributes[:url], @event.url
    assert_equal "blog", @event.source
  end

  test "invalid update displays errors without changing stored values" do
    patch event_url(@event), params: { event: { title: "", url: "javascript:alert(1)" } }

    assert_response :unprocessable_entity
    assert_select "[role=alert]", /Title can't be blank/
    assert_select "[role=alert]", /Url must be an HTTP or HTTPS URL/
    assert_equal "First event", @event.reload.title
    assert_equal "https://example.com/first", @event.url
  end

  test "deletes an event and returns to the list" do
    assert_difference "Event.count", -1 do
      delete event_url(@event)
    end

    assert_response :see_other
    assert_redirected_to events_url
    follow_redirect!
    assert_select "[role=status]", "Event was successfully deleted."
    assert_select "#event_#{@event.id}", count: 0
  end

  test "returns not found for missing events" do
    missing_id = Event.maximum(:id) + 1

    get event_url(missing_id)
    assert_response :not_found
    get edit_event_url(missing_id)
    assert_response :not_found
    patch event_url(missing_id), params: { event: @attributes }
    assert_response :not_found
    delete event_url(missing_id)
    assert_response :not_found
  end
end
