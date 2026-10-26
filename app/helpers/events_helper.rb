module EventsHelper
  SOURCE_LABELS = { "manual" => "Added manually", "file" => "Imported from a file", "blog" => "Collected from the blog" }.freeze

  SOURCE_ICON_PATHS = {
    "manual" => "M4 20h4L18.5 9.5a2.83 2.83 0 0 0-4-4L4 16v4Z M13.5 6.5l4 4",
    "file" => "M14 3H7a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h10a2 2 0 0 0 2-2V8l-5-5Z M14 3v5h5 M9 13h6 M9 17h6",
    "blog" => "M5 11a8 8 0 0 1 8 8 M5 5a14 14 0 0 1 14 14 M6 19h.01"
  }.freeze

  def source_label(source)
    SOURCE_LABELS.fetch(source, source.to_s.humanize)
  end

  def source_icon(source)
    label = source_label(source)

    tag.span class: "source-icon source-icon--#{source}", title: label, data: { testid: "source-icon", source: source } do
      tag.svg(viewBox: "0 0 24 24", width: 16, height: 16, fill: "none", stroke: "currentColor",
        "stroke-width": 2, "stroke-linecap": "round", "stroke-linejoin": "round", role: "img", "aria-label": label) do
        tag.path(d: SOURCE_ICON_PATHS.fetch(source, SOURCE_ICON_PATHS["manual"]))
      end
    end
  end

  def timeline_items(events)
    events.map do |event|
      { id: event.id, title: event.title, date: event.happened_on.iso8601, source: event.source, url: event_path(event) }
    end
  end
end
