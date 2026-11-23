require "spec_helper"
require "rake"
require "tmpdir"
require "fileutils"
require "isodoc/gem_tasks"

RSpec.describe "IsoDoc::GemTasks build safety" do
  around do |example|
    original_app = Rake.application
    original_ci = ENV.fetch("CI", nil)
    original_css = IsoDoc::GemTasks.css_list.dup
    original_clean = CLEAN.to_a
    ENV["CI"] = "true"
    Rake.application = Rake::Application.new
    IsoDoc::GemTasks.css_list.clear
    Dir.mktmpdir("isodoc-css-safety-") do |dir|
      Dir.chdir(dir) do
        FileUtils.mkdir_p("lib")
        @packaged = false
        Rake::Task.define_task(:build) { @packaged = true }
        Rake::Task.define_task(:release) { @packaged = true }
        Rake::Task.define_task(:clean)
        # Exercise the actual compiler and build prerequisites without staging
        # fixture assets in the source repository.
        example.run
      end
    end
  ensure
    Rake.application = original_app
    ENV["CI"] = original_ci
    IsoDoc::GemTasks.css_list.replace(original_css)
    CLEAN.clear.include(*original_clean)
  end

  before do
    allow(IsoDoc::GemTasks).to receive(:git_cache_compiled_files).and_return(true)
    allow(IsoDoc::GemTasks).to receive(:git_rm_compiled_files).and_return(true)
  end

  def install_and_build(task = "build")
    IsoDoc::GemTasks.install
    Rake::Task[task].invoke
  end

  it "fails CI compilation and restores every SCSS source byte for byte" do
    sources = {
      "lib/a-valid.scss" => "a {\r\ncolor: red;\r\nfont-family: \"{{bodyfont}}\";\r\n}",
      "lib/z-broken.scss" => "b {\r\ncolor: ;\r\nfont-family: \"{{bodyfont}}\";\r\n}"
    }
    sources.each { |name, text| File.binwrite(name, text) }

    expect { install_and_build }.to raise_error(StandardError, /Expected expression/)
      .and output(/Cannot compile/).to_stdout

    expect(File.size?("lib/a-valid.css")).to be_truthy
    sources.each { |name, text| expect(File.binread(name)).to eq(text) }
    expect(@packaged).to be false
  end

  ["build", "release"].each do |task|
    [nil, "true"].each do |ci|
      it "rejects stale CSS after compiler failure before #{task} with CI=#{ci.inspect}" do
        ENV["CI"] = ci
        source = "a { color: ;\r\n"
        File.binwrite("lib/style.scss", source)
        File.write("lib/style.css", "a { color: green; }")
        File.utime(Time.at(0), Time.at(0), "lib/style.css")
        expect($stdin).not_to receive(:gets)

        expect { install_and_build(task) }.to raise_error(StandardError, /Expected expression/)
        expect(@packaged).to be false
        expect(File.binread("lib/style.scss")).to eq(source)
        expect(File.read("lib/style.css")).to eq("a { color: green; }")
      end
    end

    [nil, ""].each do |content|
      it "rejects #{content.nil? ? 'missing' : 'empty'} CSS before #{task}" do
        source = "a { color: red; }\r\n/* {{bodyfont}} */"
        File.binwrite("lib/style.scss", source)
        allow(IsoDoc::GemTasks).to receive(:compile_scss_task) do
          File.write("lib/style.css", content) unless content.nil?
          nil # No successful compiler result confirms that an empty asset is valid.
        end

        expect { install_and_build(task) }
          .to raise_error(RuntimeError, /Missing or changed compiled CSS: lib\/style.css/)
        expect(@packaged).to be false
        expect(File.binread("lib/style.scss")).to eq(source)
      end
    end

    it "rejects uncompiled cached CSS before #{task}" do
      File.write("lib/style.scss", "a { color: red; }")
      File.write("lib/style.css", "a { color: green; }")
      future = Time.now + 60
      File.utime(future, future, "lib/style.css")
      expect { install_and_build(task) }.to raise_error(/Missing or changed compiled CSS/)
      expect(@packaged).to be false
    end

    it "rejects altered compiler output before #{task}" do
      File.write("lib/style.scss", "a { color: red; }")
      allow(IsoDoc::GemTasks).to receive(:compile_scss_task).and_wrap_original do |compile, current|
        digest = compile.call(current)
        File.write("lib/style.css", "a { color: green; }")
        digest
      end
      expect { install_and_build(task) }.to raise_error(/Missing or changed compiled CSS/)
      expect(@packaged).to be false
    end

    it "packages legitimately empty mixin CSS only after successful compilation for #{task}" do
      File.write("lib/mixins.scss", "@mixin title { color: red; }")
      install_and_build(task)
      expect(@packaged).to be true
      expect(File.size("lib/mixins.css")).to eq(0)
    end

    it "compiles every asset before #{task} and preserves successful cleanup hooks" do
      File.write("lib/one.scss", "a { color: red; }")
      File.write("lib/two.scss", "b { color: blue; }")
      packaged_assets = nil
      Rake::Task[task].enhance do
        packaged_assets = %w[lib/one.css lib/two.css].map { |name| File.read(name) }
      end
      expect(IsoDoc::GemTasks).to receive(:git_cache_compiled_files).and_return(true)
      expect(IsoDoc::GemTasks).to receive(:git_rm_compiled_files).and_return(true)

      install_and_build(task)

      expect(@packaged).to be true
      expect(packaged_assets).to all(match(/color: (red|blue)/))
      expect(IsoDoc::GemTasks.css_list).to contain_exactly("lib/one.css", "lib/two.css")
      expect(Rake::Task["clean"]).to have_attributes(already_invoked: true)
    end
  end
end
