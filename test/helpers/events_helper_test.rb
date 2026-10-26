require "test_helper"

class EventsHelperTest < ActionView::TestCase
  test "source_icon renders a labelled icon for every source" do
    Event::SOURCES.each do |source|
      render inline: "<%= source_icon(source) %>", locals: { source: source }

      assert_select "span.source-icon[data-testid=source-icon][data-source=?] svg[role=img][aria-label=?]", source, source_label(source)
    end
  end

  test "timeline_items lists events with their dates, categories and urls" do
    event = events(:earlier)

    assert_equal [ { id: event.id, title: "First event", date: "2020-01-01", category: "Milestones",
      color: category_class("Milestones"), url: event_path(event) } ], timeline_items([ event ])
  end

  test "category_class hands out colors in the order categories were first used" do
    assert_equal "category-1", category_class("Milestones")
    assert_equal "category-none", category_class(nil)

    %w[Work Travel Family Health Music Sport Books].each do |category|
      Event.create!(title: category, happened_on: "2026-10-23", category: category)
    end
    @categories_by_first_use = nil

    assert_equal "category-1", category_class("Milestones")
    assert_equal "category-2", category_class("Work")
    assert_equal "category-7", category_class("Sport")
    assert_equal "category-1", category_class("Books")
  end

  test "category_chip shows the name and nothing for a blank category" do
    render inline: "<%= category_chip('Travel') %>"
    assert_select "span.category-chip[data-testid=category-chip]", "Travel"
    assert_nil category_chip(nil)
  end

  test "event_date shows a readable date" do
    assert_equal "September 1, 2023", event_date(Date.new(2023, 9, 1))
  end
end
