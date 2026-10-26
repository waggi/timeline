require "application_system_test_case"

class EventsTest < ApplicationSystemTestCase
  test "the home page timeline shows a newly stored event" do
    event = Event.create!(title: "New timeline entry", happened_on: Date.new(2023, 3, 14), description: "A new chapter")

    visit root_url

    assert_selector "[data-timeline-ready] [data-testid=timeline]"
    assert_selector "[data-testid=timeline-item][data-event-id='#{event.id}']", text: event.title
    assert_selector "[data-testid=event-list-item][data-event-id='#{event.id}']", text: event.title
  end

  test "clicking a timeline event shows its title, date and description" do
    event = events(:earlier)
    visit root_url

    assert_selector "[data-timeline-ready] [data-testid=timeline-item][data-event-id='#{event.id}']"
    find("[data-testid=timeline-item][data-event-id='#{event.id}']").click

    within "[data-testid=event-details]" do
      assert_selector "h1", text: event.title
      assert_selector "time[datetime='#{event.happened_on.iso8601}']", text: "January 1, 2020"
      assert_text event.description
    end
  end

  test "adding an event through the home page form puts it on the timeline" do
    visit root_url
    find("[data-testid=add-event-button]").click

    within "[data-testid=new-event-dialog]" do
      fill_in "Title", with: "Added on the page"
      fill_in "Happened on", with: Date.new(2026, 10, 23)
      fill_in "Description", with: "Created through the dialog"
      click_on "Create Event"
    end

    assert_selector "[data-testid=timeline-item]", text: "Added on the page"
    event = Event.find_by!(title: "Added on the page")
    assert_equal "manual", event.source
    assert_current_path root_path
    assert_selector "[data-timeline-ready] [data-testid=timeline-item][data-event-id='#{event.id}']", text: event.title
    assert_selector "[data-testid=event-list-item][data-event-id='#{event.id}']", text: event.title
  end

  test "timeline distinguishes manual, file and blog events visually" do
    skip "Bug: timeline items do not expose or visually distinguish event sources"

    manual = events(:earlier)
    blog = events(:later)
    file = Event.create!(title: "Imported entry", happened_on: Date.new(2022, 5, 10), source: "file")
    visit root_url

    assert_selector "[data-timeline-ready] [data-testid=timeline-item]", count: 3
    { manual => "manual", file => "file", blog => "blog" }.each do |event, source|
      within "[data-testid=timeline-item][data-event-id='#{event.id}'][data-source='#{source}']" do
        assert_selector "[data-testid=source-icon][data-source='#{source}']"
      end
    end
  end

  test "browsing the timeline and showing event details" do
    visit root_url

    assert_selector "[data-timeline-ready] [data-testid=timeline] [data-testid=timeline-item]", count: Event.count
    assert_selector "[data-testid=timeline-item]", text: "MILESTONES"
    assert_no_selector "[data-testid=timeline] [data-testid=source-icon]"

    find("[data-testid=timeline-item]", text: "Later event").click
    within "[data-testid=event-details]" do
      assert_selector "h1", text: "Later event"
      assert_text "Collected from the blog"
    end

    within("[data-testid=event-list]") { click_on "First event" }
    within "[data-testid=event-details]" do
      assert_selector "h1", text: "First event"
      assert_selector "a[target=_blank]", text: "Open source"
      assert_link "Open source", href: "https://example.com/first"
    end

    find("[data-testid=zoom-in]").click
    find("[data-testid=zoom-out]").click
    find("[data-testid=zoom-fit]").click
    assert_selector "[data-testid=timeline-item]", count: Event.count
  end

  test "adding, editing and deleting an event from the timeline page" do
    visit root_url
    find("[data-testid=add-event-button]").click

    within "[data-testid=new-event-dialog]" do
      fill_in "Title", with: "A milestone"
      fill_in "Happened on", with: Date.new(2026, 10, 23)
      fill_in "Category", with: "Launches"
      fill_in "Description", with: "First line\nSecond line"
      fill_in "Source URL", with: "https://example.com/milestone"
      click_on "Create Event"
    end

    assert_text "Event was successfully created."
    assert_no_selector "[data-testid=new-event-dialog]", visible: true
    assert_current_path root_path
    assert_selector "[data-testid=timeline-item]", text: "A milestone"
    within "[data-testid=event-details]" do
      assert_selector "h1", text: "A milestone"
      assert_text "First line"
      assert_text "Added manually"
      assert_selector "[data-testid=category-chip]", text: "Launches"
      find("[data-testid=event-edit-link]").click
    end

    fill_in "Title", with: "Updated milestone"
    click_on "Update Event"
    assert_text "Event was successfully updated."
    assert_selector "h1", text: "Updated milestone"

    click_on "Back to events"
    within("[data-testid=event-list]") { click_on "Updated milestone" }
    within("[data-testid=event-details]") { accept_confirm { click_on "Delete" } }

    assert_text "Event was successfully deleted."
    assert_no_text "Updated milestone"
  end

  test "the event details card does not cover the event list when scrolling" do
    30.times { |i| Event.create!(title: "Extra event #{i}", happened_on: Date.new(2022, 1, 1) + i, source: "manual") }
    page.current_window.resize_to(1400, 700)
    visit root_url
    assert_selector "[data-timeline-ready]"

    within("[data-testid=event-list]") { click_on "First event" }
    within("[data-testid=event-details]") { assert_selector "h1", text: "First event" }

    page.execute_script("window.scrollTo(0, document.body.scrollHeight)")
    overlap = page.evaluate_script(<<~JS)
      (() => {
        const card = document.querySelector("[data-testid=event-details]").getBoundingClientRect()
        const list = document.querySelector("[data-testid=event-list]").getBoundingClientRect()
        return card.left < list.right && list.left < card.right && card.top < list.bottom && list.top < card.bottom
      })()
    JS
    assert_not overlap, "the event details card overlaps the event list"
  end

  test "filtering the timeline by category" do
    visit root_url
    assert_selector "[data-testid=timeline-item]", count: 2

    click_on "Milestones"
    assert_selector "[data-testid=timeline-item]", count: 1, text: "First event"
    assert_selector "[data-testid=event-list-item]", count: 1
    assert_selector "[data-testid=category-filter-chip][aria-pressed=true]", text: "Milestones"

    click_on "No category"
    assert_selector "[data-testid=timeline-item]", count: 1, text: "Later event"

    find("[data-testid=category-filter-chip]", text: "All").click
    assert_selector "[data-testid=timeline-item]", count: 2
    assert_selector "[data-testid=event-list-item]", count: 2
  end

  test "shows validation errors in the dialog and lets the user correct them" do
    visit root_url
    find("[data-testid=add-event-button]").click

    within "[data-testid=new-event-dialog]" do
      fill_in "Title", with: "Invalid source URL"
      fill_in "Happened on", with: Date.new(2026, 10, 23)
      fill_in "Source URL", with: "ftp://example.com"
      click_on "Create Event"

      assert_selector "[role=alert]", text: "Url must be an HTTP or HTTPS URL"
      assert_field "Title", with: "Invalid source URL"
      fill_in "Source URL", with: "https://example.com"
      click_on "Create Event"
    end

    assert_text "Event was successfully created."
    assert_selector "[data-testid=timeline-item]", text: "Invalid source URL"
  end

  test "the standalone new event page still works" do
    visit new_event_url
    fill_in "Title", with: "From the new page"
    fill_in "Happened on", with: Date.new(2026, 10, 23)
    click_on "Create Event"

    assert_text "Event was successfully created."
    assert_selector "h1", text: "From the new page"
  end
end
