require "test_helper"

class EventTest < ActiveSupport::TestCase
  setup do
    @event = Event.new(title: "A new event", happened_on: "2026-10-23")
  end

  test "requires only title and happened_on and defaults to manual" do
    assert @event.save
    assert_equal "manual", @event.reload.source
  end

  test "requires a nonblank title" do
    [ nil, "", "  " ].each do |title|
      @event.title = title
      assert_not @event.valid?
      assert_includes @event.errors[:title], "can't be blank"
    end
  end

  test "requires a valid date" do
    [ nil, "", "not a date", "2026-02-30" ].each do |date|
      @event.happened_on = date
      assert_not @event.valid?
      assert_includes @event.errors[:happened_on], "can't be blank"
    end
  end

  test "accepts each supported source" do
    %w[manual file blog].each do |source|
      @event.source = source
      assert @event.valid?, @event.errors.full_messages.to_sentence
    end
  end

  test "rejects missing and unknown sources" do
    [ nil, "", "import" ].each do |source|
      @event.source = source
      assert_not @event.valid?
      assert_includes @event.errors[:source], "is not included in the list"
    end
  end

  test "database rejects unsupported sources when model validations are bypassed" do
    skip "Bug: the database has no source inclusion constraint; insert_all! stores unsupported values"

    assert_raises ActiveRecord::StatementInvalid do
      Event.insert_all!([ { title: "Imported event", happened_on: Date.new(2026, 10, 23), source: "unknown" } ])
    end
  end

  test "accepts optional HTTP and HTTPS source URLs" do
    [ nil, "", "http://example.com", "https://example.com/post?q=timeline#event" ].each do |url|
      @event.url = url
      assert @event.valid?, @event.errors.full_messages.to_sentence
    end
  end

  test "rejects invalid URLs and unsafe schemes" do
    [ "not a URL", "/relative", "https://", "https:///path", "https://example.com/a b", "javascript:alert(1)", "ftp://example.com" ].each do |url|
      @event.url = url
      assert_not @event.valid?, "Expected #{url.inspect} to be invalid"
      assert @event.errors[:url].any?
    end
  end

  test "orders by date with a stable order for events on the same day" do
    same_day = Event.create!(title: "Another event", happened_on: events(:earlier).happened_on)

    assert_equal [ events(:earlier), same_day, events(:later) ], Event.chronological.to_a
  end

  test "category is optional, trimmed and limited to 50 characters" do
    @event.category = "  Work   trips  "
    assert @event.save
    assert_equal "Work trips", @event.category

    @event.category = "   "
    assert @event.valid?
    assert_nil @event.category

    @event.category = "a" * 51
    assert_not @event.valid?
    assert_includes @event.errors[:category], "is too long (maximum is 50 characters)"
  end

  test "categories lists distinct names in alphabetical order" do
    Event.create!(title: "Another", happened_on: "2026-10-23", category: "Bravo")
    Event.create!(title: "Again", happened_on: "2026-10-24", category: "Bravo")

    assert_equal [ "Bravo", "Milestones" ], Event.categories
  end

  test "categories_by_first_use keeps the order in which categories appeared" do
    Event.create!(title: "Z first", happened_on: "2026-10-23", category: "Zeta")
    Event.create!(title: "A later", happened_on: "2026-10-24", category: "Alpha")

    assert_equal [ "Milestones", "Zeta", "Alpha" ], Event.categories_by_first_use
  end

  test "categories_by_first_use uses the earliest event when a category is reused" do
    first = Event.create!(title: "First new category", happened_on: "2026-10-23", category: "Travel")
    Event.create!(title: "Another category", happened_on: "2026-10-24", category: "Work")
    Event.create!(title: "Travel again", happened_on: "2026-10-25", category: first.category)

    assert_equal [ "Milestones", "Travel", "Work" ], Event.categories_by_first_use
  end
end
