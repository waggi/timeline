require "test_helper"

class EventTest < ActiveSupport::TestCase
  def build_event(**attributes)
    Event.new(title: "Something happened", happened_on: Date.new(2026, 5, 1), **attributes)
  end

  test "is valid with title and date only" do
    assert build_event.valid?
  end

  test "defaults source to manual" do
    assert_equal "manual", Event.new.source
  end

  test "requires title" do
    event = build_event(title: " ")
    assert_not event.valid?
    assert_includes event.errors[:title], "can't be blank"
  end

  test "requires happened_on" do
    event = build_event(happened_on: nil)
    assert_not event.valid?
    assert_includes event.errors[:happened_on], "can't be blank"
  end

  test "accepts each known source" do
    Event::SOURCES.each do |source|
      assert build_event(source: source).valid?, "expected #{source} to be valid"
    end
  end

  test "rejects unknown source" do
    event = build_event(source: "twitter")
    assert_not event.valid?
    assert event.errors[:source].any?
  end

  test "accepts http and https urls" do
    assert build_event(url: "http://example.com/post").valid?
    assert build_event(url: "https://example.com/post?id=1").valid?
  end

  test "allows blank url" do
    assert build_event(url: "").valid?
  end

  test "rejects non-http urls" do
    [ "example.com", "javascript:alert(1)", "ftp://example.com" ].each do |url|
      assert_not build_event(url: url).valid?, "expected #{url} to be invalid"
    end
  end

  test "chronological orders by date, oldest first" do
    later = Event.create!(title: "Later", happened_on: Date.new(2027, 1, 1))
    assert_equal [ events(:kickoff), events(:launch), later ], Event.chronological.to_a
  end
end
