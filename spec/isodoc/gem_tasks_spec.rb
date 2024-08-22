require "spec_helper"
require "rake"

RSpec.describe "IsoDoc::GemTasks" do
  before :all do
    @rake_app_orig = Rake.application
    Rake.application = Rake::Application.new
    Rake.application.load_rakefile
  end

  after :all do
    Rake.application = @rake_app_orig
  end

  around do |example|
    ci_env_orig = ENV.fetch("CI", nil)
    ENV["CI"] = "true"
    example.run
    ENV["CI"] = ci_env_orig
  end

  it "test build deps has build_scss" do
    build_deps = Rake::Task["build"].all_prerequisite_tasks.map(&:name)
    expect(build_deps).to include "build_scss"
  end

  it "test generate/clean CSS" do
    Rake.application.invoke_task "build"

    expect(IsoDoc::GemTasks.css_list).not_to be_empty
    expect(CLEAN).to include(*IsoDoc::GemTasks.css_list)
  end
end
