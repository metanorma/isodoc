require "spec_helper"
require "rake"
require "isodoc/gem_tasks"

RSpec.describe "IsoDoc::GemTasks" do
  before :all do
    @rake_app_orig = Rake.application
    @clean_orig = CLEAN
    @clobber_orig = CLOBBER
    @css_orig = IsoDoc::GemTasks.css_list.dup
    Rake.application = Rake::Application.new
    # The require cache belongs to the process, while tasks belong to an
    # application. Load Rake's native tasks into this fresh application even
    # when another spec already required gem_tasks during discovery.
    Object.send(:remove_const, :CLEAN)
    Object.send(:remove_const, :CLOBBER)
    load File.join(Gem.loaded_specs.fetch("rake").full_gem_path, "lib/rake/clean.rb")
    Rake.application.load_rakefile
  end

  after :all do
    Rake.application = @rake_app_orig
    Object.send(:remove_const, :CLEAN)
    Object.send(:remove_const, :CLOBBER)
    Object.const_set(:CLEAN, @clean_orig)
    Object.const_set(:CLOBBER, @clobber_orig)
    IsoDoc::GemTasks.css_list.replace(@css_orig)
  end

  around do |example|
    ci_env_orig = ENV.fetch("CI", nil)
    ENV["CI"] = "true"
    example.run
  ensure
    ENV["CI"] = ci_env_orig
  end

  it "test build deps has build_scss" do
    build_deps = Rake::Task["build"].all_prerequisite_tasks.map(&:name)
    expect(build_deps).to include("build_scss")
  end

  it "test generate/clean CSS" do
    Rake.application.invoke_task "build"

    expect(IsoDoc::GemTasks.css_list).not_to be_empty
    expect(CLEAN).to include(*IsoDoc::GemTasks.css_list)
  end
end
