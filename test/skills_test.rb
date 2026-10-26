require "test_helper"

# Checks the agent skills in .agents/skills/ and their copies in .claude/skills/,
# where Claude Code looks for them.
class SkillsTest < ActiveSupport::TestCase
  ORIGINALS = Rails.root.join(".agents/skills")
  COPIES = Rails.root.join(".claude/skills")
  REQUIRED = %w[shared-memory code-review].freeze

  test "the required skills exist" do
    REQUIRED.each do |name|
      assert ORIGINALS.join(name, "SKILL.md").file?, "missing .agents/skills/#{name}/SKILL.md"
    end
  end

  test "every skill has front matter with its folder name and a description" do
    skills.each do |path|
      front_matter = front_matter(path)
      assert front_matter, "#{relative(path)}: must start with --- front matter ---"
      next unless front_matter

      assert_equal path.dirname.basename.to_s, front_matter["name"], "#{relative(path)}: name must match its folder"
      assert front_matter["description"].present?, "#{relative(path)}: description is empty"
    end
  end

  test "every skill has an identical copy in .claude/skills" do
    skills.each do |path|
      copy = COPIES.join(path.relative_path_from(ORIGINALS))
      assert copy.file?, "missing #{relative(copy)}"
      assert_equal path.read, copy.read, "#{relative(copy)} differs from #{relative(path)}" if copy.file?
    end
  end

  test ".claude/skills has no skill without an .agents original" do
    orphans = Dir.glob(COPIES.join("*/SKILL.md")).map { |path| Pathname(path) }.reject do |copy|
      ORIGINALS.join(copy.relative_path_from(COPIES)).file?
    end
    assert_empty orphans.map { |path| relative(path) }, "copies without an original in .agents/skills/"
  end

  private
    def skills
      Dir.glob(ORIGINALS.join("*/SKILL.md")).map { |path| Pathname(path) }.sort
    end

    def front_matter(path)
      match = /\A---\n(.*?)\n---\n/m.match(path.read)
      YAML.safe_load(match[1]) if match
    end

    def relative(path)
      Pathname(path).relative_path_from(Rails.root).to_s
    end
end
