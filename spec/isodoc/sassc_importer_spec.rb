# frozen_string_literal: true

require "spec_helper"
require "isodoc/sassc_importer"
require "tmpdir"

RSpec.describe SasscImporter do
  let(:dir) { Dir.mktmpdir }
  after { FileUtils.remove_entry(dir) }

  def write(name, contents)
    File.write(File.join(dir, name), contents)
  end

  it "resolves an extensionless import beside the parent and carries its contents" do
    write("main.scss", "@use 'part';")
    write("_part.scss", "$c: red;")
    import = described_class.new({}).imports("part", File.join(dir, "main.scss"))
    expect(import.path).to end_with("_part.scss")
    expect(import.source).to eq("$c: red;")
  end

  it "falls through to the load paths when the parent's dir does not carry the import" do
    other = Dir.mktmpdir
    File.write(File.join(other, "variables.scss"), "$w: 1;")
    import = described_class.new(load_paths: [other]).imports("variables", File.join(dir, "main.scss"))
    expect(import.path).to end_with("variables.scss")
    expect(import.source).to eq("$w: 1;")
  ensure
    FileUtils.remove_entry(other)
  end

  it "prefers the partial spelling over the plain one" do
    write("main.scss", "")
    write("_part.scss", "partial")
    write("part.scss", "plain")
    expect(described_class.new({}).imports("part", File.join(dir, "main.scss")).source).to eq("partial")
  end

  it "keeps the historic path-only shape when nothing matches ruby-side" do
    import = described_class.new({}).imports("absent", File.join(dir, "main.scss"))
    expect(import.path).to eq("absent.scss")
    expect(import.source).to be_nil
  end

  it "does not touch imports that arrive already extension-spelled" do
    expect(described_class.new({}).imports("x.css", File.join(dir, "main.scss"))).to be_nil
  end

  it "renders end to end through SassC::Engine with the helper reading nothing" do
    write("_part.scss", "$c: #123456;")
    engine = SassC::Engine.new("@use 'part' as *;\n.main { color: $c; }",
                               syntax: :scss, load_paths: [dir],
                               importer: described_class)
    css = engine.render
    expect(css).to include("#123456")
  end
end
