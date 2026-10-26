require "csv"

# Imports events from a CSV exported from Notion, with the columns
# Name, Category, Date ("October 30, 2014"), Milestone and URL.
# Rerunning the import updates existing events instead of duplicating them.
class Event::CsvImport
  DATE_FORMAT = "%B %d, %Y"

  def initialize(path)
    @path = path
  end

  def call
    Event.transaction do
      rows.each.with_index(2).count { |row, line| import(row, line) }
    end
  end

  private
    def rows
      CSV.read(@path, headers: true, encoding: "bom|utf-8")
    end

    def import(row, line)
      event = Event.find_or_initialize_by(source: "file", title: row["Name"].to_s.strip, happened_on: parse_date(row["Date"], line))
      event.update!(description: row["Milestone"].presence, url: row["URL"].presence, category: row["Category"].presence)
    end

    def parse_date(value, line)
      Date.strptime(value.to_s.strip, DATE_FORMAT)
    rescue Date::Error
      raise ArgumentError, "#{@path}:#{line}: invalid date #{value.inspect}"
    end
end
