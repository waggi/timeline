require "application_system_test_case"

class EventsTest < ApplicationSystemTestCase
  test "manually creating editing and deleting an event" do
    visit root_url
    assert_selector "h1", text: "Events"
    click_on "New event"

    fill_in "Title", with: "A milestone"
    fill_in "Happened on", with: Date.new(2026, 10, 23)
    fill_in "Description", with: "First line\nSecond line"
    fill_in "Source URL", with: "https://example.com/milestone"
    click_on "Create Event"

    assert_text "Event was successfully created."
    assert_selector "h1", text: "A milestone"
    assert_text "2026-10-23"
    assert_text "First line"
    assert_link "Source", href: "https://example.com/milestone"
    assert_text "Source type: manual"

    click_on "Edit"
    fill_in "Title", with: "Updated milestone"
    click_on "Update Event"

    assert_text "Event was successfully updated."
    assert_selector "h1", text: "Updated milestone"

    click_on "Back to events"
    within "article", text: "Updated milestone" do
      accept_confirm { click_on "Delete" }
    end

    assert_text "Event was successfully deleted."
    assert_no_text "Updated milestone"
  end

  test "shows server validation errors and lets the user correct them" do
    visit new_event_url
    fill_in "Title", with: "Invalid source URL"
    fill_in "Happened on", with: Date.new(2026, 10, 23)
    fill_in "Source URL", with: "ftp://example.com"
    click_on "Create Event"

    assert_selector "[role=alert]", text: "Url must be an HTTP or HTTPS URL"
    assert_field "Title", with: "Invalid source URL"
    fill_in "Source URL", with: "https://example.com"
    click_on "Create Event"

    assert_text "Event was successfully created."
  end
end
