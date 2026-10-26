require "test_helper"

# Checks the shared memory in memory/ against the rules in
# .agents/skills/shared-memory/SKILL.md.
class MemoryTest < ActiveSupport::TestCase
  MEMORY = Rails.root.join("memory")
  TYPES = { "decisions" => "decision", "lessons" => "lesson", "environment" => "environment", "context" => "context" }.freeze
  FIELDS = %w[Type Date Source Status].freeze
  SECTIONS = [ "## What", "## Why", "## How to apply" ].freeze
  MAX_LINES = 45
  FILE_NAME = /\A(\d{4}-\d{2}-\d{2})-[a-z0-9]+(-[a-z0-9]+)*\.md\z/
  SECRETS = {
    "GitHub token" => /\b(ghp|gho|ghs)_[A-Za-z0-9]{20,}|\bgithub_pat_[A-Za-z0-9_]{20,}/,
    "Anthropic key" => /\bsk-ant-[A-Za-z0-9_-]{10,}/,
    "Rails secret_key_base" => /secret_key_base\s*[:=]\s*["']?\h{32,}|\b\h{128}\b/
  }.freeze

  test "memory/ has exactly the four folders and none is empty" do
    folders = MEMORY.children.select(&:directory?).map { |dir| dir.basename.to_s }
    assert_equal TYPES.keys.sort, folders.sort

    TYPES.each_key do |folder|
      assert Dir.glob(MEMORY.join(folder, "*.md")).any?, "memory/#{folder}/ has no entries"
    end
  end

  test "memory/ contains only README.md and entries inside the folders" do
    stray = Dir.glob(MEMORY.join("**/*"), File::FNM_DOTMATCH).reject do |path|
      path = Pathname(path)
      path.basename.to_s.in?(%w[. ..]) || path.directory? || path == MEMORY.join("README.md") ||
        (path.dirname.parent == MEMORY && path.dirname.basename.to_s.in?(TYPES.keys))
    end
    assert_empty stray.map { |path| relative(path) }, "unexpected files in memory/"
  end

  test "every file name is YYYY-MM-DD-slug.md with a real date" do
    entries.each do |path|
      match = FILE_NAME.match(path.basename.to_s)
      assert match, "#{relative(path)}: name must be YYYY-MM-DD-slug.md (lowercase, digits, hyphens)"
      assert Date.valid_date?(*match[1].split("-").map(&:to_i)), "#{relative(path)}: invalid date in file name" if match
    end
  end

  test "every entry starts with a title longer than 10 characters" do
    entries.each do |path|
      first_line = path.readlines.first.to_s.chomp
      assert_match(/\A# \S/, first_line, "#{relative(path)}: first line must be a '# ' title")
      assert first_line.delete_prefix("# ").strip.length > 10, "#{relative(path)}: title must be longer than 10 characters"
    end
  end

  test "every entry has exactly the fields Type, Date, Source and Status" do
    entries.each do |path|
      fields = fields(path)
      assert_equal FIELDS.sort, fields.keys.sort, "#{relative(path)}: fields must be exactly #{FIELDS.join(', ')}"
      assert_equal 4, field_lines(path).size, "#{relative(path)}: each field must appear once"
      fields.each { |key, value| assert value.present?, "#{relative(path)}: #{key} is empty" }
    end
  end

  test "Type matches the folder and Date matches the file name" do
    entries.each do |path|
      fields = fields(path)
      assert_equal TYPES[path.dirname.basename.to_s], fields["Type"], "#{relative(path)}: Type must match its folder"
      assert_equal path.basename.to_s[0, 10], fields["Date"], "#{relative(path)}: Date must match the file name"
    end
  end

  test "Status is active or superseded by an existing entry" do
    entries.each do |path|
      status = fields(path)["Status"].to_s
      assert_match(/\A(active|superseded by \S+\.md)\z/, status,
        "#{relative(path)}: Status must be 'active' or 'superseded by <file>.md', got #{status.inspect}")

      match = /\Asuperseded by (\S+\.md)\z/.match(status)
      next unless match

      target = match[1].delete_prefix("memory/")
      exists = MEMORY.join(target).file? || entries.any? { |entry| entry.basename.to_s == target }
      assert exists, "#{relative(path)}: superseding entry #{match[1]} does not exist in memory/"
    end
  end

  test "every entry has the sections What, Why and How to apply" do
    entries.each do |path|
      headings = path.readlines.map(&:chomp).grep(/\A## /)
      SECTIONS.each do |section|
        assert_includes headings, section, "#{relative(path)}: missing section '#{section}'"
      end
    end
  end

  test "every entry is at most #{MAX_LINES} lines" do
    entries.each do |path|
      assert path.readlines.size <= MAX_LINES, "#{relative(path)}: #{path.readlines.size} lines, at most #{MAX_LINES} allowed"
    end
  end

  test "no file in memory/ looks like it contains a secret" do
    master_key = Rails.root.join("config/master.key")
    master_key = master_key.file? ? master_key.read.strip : nil

    Dir.glob(MEMORY.join("**/*")).map { |path| Pathname(path) }.select(&:file?).each do |path|
      content = path.read
      SECRETS.each do |name, pattern|
        assert_no_match pattern, content, "#{relative(path)}: looks like it contains a secret (#{name})"
      end
      if master_key.present?
        assert_not_includes content, master_key, "#{relative(path)}: contains config/master.key"
      end
    end
  end

  test "the .claude copy of the skill is identical to the .agents original" do
    original = Rails.root.join(".agents/skills/shared-memory/SKILL.md")
    copy = Rails.root.join(".claude/skills/shared-memory/SKILL.md")

    assert original.file?, "missing #{relative(original)}"
    assert_equal original.read, copy.read, "#{relative(copy)} differs from #{relative(original)}" if copy.exist?
  end

  private
    def entries
      TYPES.keys.flat_map { |folder| Dir.glob(MEMORY.join(folder, "*")) }.map { |path| Pathname(path) }.sort
    end

    # Field lines ("- Key: value") between the title and the first section.
    def field_lines(path)
      path.readlines.map(&:chomp).drop(1).take_while { |line| !line.start_with?("## ") }.grep(/\A- \w+:/)
    end

    def fields(path)
      field_lines(path).to_h { |line| line.delete_prefix("- ").split(":", 2).map(&:strip) }
    end

    def relative(path)
      Pathname(path).relative_path_from(Rails.root).to_s
    end
end
