require "test_helper"

class Event::CsvImportTest < ActiveSupport::TestCase
  setup do
    @path = file_fixture("events.csv")
  end

  test "creates file events from every row" do
    assert_difference -> { Event.where(source: "file").count }, 2 do
      assert_equal 2, Event::CsvImport.new(@path).call
    end

    event = Event.find_by!(title: "First release")
    assert_equal Date.new(2014, 10, 30), event.happened_on
    assert_equal "The first release.", event.description
    assert_equal "https://example.com/release", event.url
    assert_equal "Product", event.category
    assert_equal "file", event.source
  end

  test "reads quoted titles and stores a blank url as nil" do
    Event::CsvImport.new(@path).call

    event = Event.find_by!(title: "Rename, part one")
    assert_equal Date.new(2023, 2, 9), event.happened_on
    assert_nil event.url
  end

  test "updates existing events instead of duplicating them on rerun" do
    Event::CsvImport.new(@path).call
    Event.find_by!(title: "First release").update!(description: "Old text")

    assert_no_difference -> { Event.count } do
      Event::CsvImport.new(@path).call
    end
    assert_equal "The first release.", Event.find_by!(title: "First release").description
  end

  test "does not touch manual events with the same title and date" do
    manual = Event.create!(title: "First release", happened_on: "2014-10-30", description: "Mine")

    Event::CsvImport.new(@path).call

    assert_equal "Mine", manual.reload.description
    assert_equal "manual", manual.source
  end

  test "rejects an invalid date and imports nothing" do
    path = write_csv(<<~CSV)
      Name,Category,Date,Milestone,URL
      Good,Brand,"May 5, 2023",Fine,
      Bad,Brand,"someday",Broken,
    CSV

    error = assert_raises(ArgumentError) { Event::CsvImport.new(path).call }
    assert_match ":3: invalid date", error.message
    assert_not Event.exists?(title: "Good")
  end

  test "rejects a row without a title and imports nothing" do
    path = write_csv(<<~CSV)
      Name,Category,Date,Milestone,URL
      Good,Brand,"May 5, 2023",Fine,
      ,Brand,"May 6, 2023",No title,
    CSV

    assert_raises(ActiveRecord::RecordInvalid) { Event::CsvImport.new(path).call }
    assert_not Event.exists?(title: "Good")
  end

  test "imports the JetBrains Academy milestones seed file without internal links" do
    path = Rails.root.join("db/seeds/jetbrains_academy_milestones.csv")

    assert_equal 17, Event::CsvImport.new(path).call

    events = Event.where(source: "file")
    assert_equal 17, events.count
    assert_equal Date.new(2014, 10, 30), events.minimum(:happened_on)
    assert_equal Date.new(2023, 12, 19), events.maximum(:happened_on)
    assert_equal [ "Educational brand", "In-IDE learning", "JetBrains Academy / Hyperskill" ], events.distinct.order(:category).pluck(:category)
    events.where.not(url: nil).pluck(:url).each do |url|
      assert_no_match(/jetbrains\.team|youtrack|docs\.google/, url)
    end
  end

  private
    def write_csv(content)
      file = Tempfile.new([ "events", ".csv" ])
      file.write(content)
      file.close
      file.path
    end
end
