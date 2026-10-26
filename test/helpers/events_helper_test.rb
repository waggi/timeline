require "test_helper"

class EventsHelperTest < ActionView::TestCase
  test "source_icon renders a labelled icon for every source" do
    Event::SOURCES.each do |source|
      render inline: "<%= source_icon(source) %>", locals: { source: source }

      assert_select "span.source-icon[data-testid=source-icon][data-source=?] svg[role=img][aria-label=?]", source, source_label(source)
    end
  end

  test "timeline_items lists events with their dates, sources and urls" do
    event = events(:later)

    assert_equal [ { id: event.id, title: "Later event", date: "2024-06-15", source: "blog", url: event_path(event) } ], timeline_items([ event ])
  end
end
