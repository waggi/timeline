require "application_system_test_case"

class EventsTest < ApplicationSystemTestCase
  test "creating, editing and deleting an event" do
    visit root_url
    click_on "New event"

    fill_in "Title", with: "First commit"
    fill_in "Happened on", with: Date.new(2026, 2, 1)
    fill_in "Description", with: "Where it all started"
    click_on "Create Event"

    assert_text "Event was successfully created."
    assert_text "First commit"

    within "##{ActionView::RecordIdentifier.dom_id(Event.find_by!(title: "First commit"))}" do
      click_on "Edit"
    end
    fill_in "Title", with: "Initial commit"
    click_on "Update Event"

    assert_text "Event was successfully updated."
    assert_text "Initial commit"

    within "##{ActionView::RecordIdentifier.dom_id(Event.find_by!(title: "Initial commit"))}" do
      accept_confirm { click_on "Delete" }
    end

    assert_text "Event was successfully deleted."
    assert_no_text "Initial commit"
  end
end
