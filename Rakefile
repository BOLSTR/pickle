# use pluginized rpsec if it exists
rspec_base = File.expand_path(File.dirname(__FILE__) + '/../rspec/lib')
$LOAD_PATH.unshift(rspec_base) if File.exist?(rspec_base) and !$LOAD_PATH.include?(rspec_base)

require 'spec/rake/spectask'
require 'spec/rake/verify_rcov'
require 'rake/rdoctask'
require 'rake/gempackagetask'

$LOAD_PATH.unshift File.dirname(__FILE__) + '/lib'
require 'pickle/version'

plugin_name = 'pickle'

task :default => [:spec]

plugins_base = File.expand_path(File.join(File.dirname(__FILE__), '..'))
cucumber_base = File.join(plugins_base, 'cucumber/lib')
if File.exists?(cucumber_base) && plugins_base =~ /\/vendor\/plugins$/ # if we're in rails app
  $:.unshift(cucumber_base)
  require 'cucumber/rake/task'

  Cucumber::Rake::Task.new(:features) do |t|
    t.cucumber_opts = "--format progress -r features/step_definitions features"
  end
  
  namespace :features do
    Cucumber::Rake::Task.new(:full) do |t|
      t.cucumber_opts = '-r features/step_definitions features'
    end
  end
end

desc "Run the specs for #{plugin_name}"
Spec::Rake::SpecTask.new(:spec) do |t|
  t.spec_files = FileList['spec/**/*_spec.rb']
  t.spec_opts  = ["--colour"]
end

namespace :spec do
  desc "Generate RCov report for #{plugin_name}"
  Spec::Rake::SpecTask.new(:rcov) do |t|
    t.spec_files  = FileList['spec/**/*_spec.rb']
    t.rcov        = true
    t.rcov_dir    = 'doc/coverage'
    t.rcov_opts   = ['--text-report', '--exclude', "spec/,rcov.rb,#{File.expand_path(File.join(File.dirname(__FILE__),'../../..'))}"] 
  end

  namespace :rcov do
    desc "Verify RCov threshold for #{plugin_name}"
    RCov::VerifyTask.new(:verify => "spec:rcov") do |t|
      t.threshold = 100.0
      t.index_html = File.join(File.dirname(__FILE__), 'doc/coverage/index.html')
    end
  end
  
  desc "Generate specdoc for #{plugin_name}"
  Spec::Rake::SpecTask.new(:doc) do |t|
    t.spec_files  = FileList['spec/**/*_spec.rb']
    t.spec_opts   = ["--format", "specdoc:SPECDOC"]
   end

  namespace :doc do
    desc "Generate html specdoc for #{plugin_name}"
    Spec::Rake::SpecTask.new(:html => :rdoc) do |t|
      t.spec_files    = FileList['spec/**/*_spec.rb']
      t.spec_opts     = ["--format", "html:doc/rspec_report.html", "--diff"]
    end
  end
end

task :rdoc => :doc
task "SPECDOC" => "spec:doc"

desc "Generate rdoc for #{plugin_name}"
Rake::RDocTask.new(:doc) do |t|
  t.rdoc_dir = 'doc'
  t.main     = 'README'
  t.title    = "#{plugin_name}"
  t.template = ENV['RDOC_TEMPLATE']
  t.options  = ['--line-numbers', '--inline-source', '--all']
  t.rdoc_files.include('README.rdoc', 'SPECDOC', 'License.txt', 'History.txt', 'Todo.txt')
  t.rdoc_files.include('lib/**/*.rb')
end

namespace :doc do 
  desc "Generate all documentation (rdoc, specdoc, specdoc html and rcov) for #{plugin_name}"
  task :all => ["spec:doc:html", "spec:doc", "spec:rcov", "doc"]
end

task :cruise do
  # run the garlic task, capture the output, if succesful make the docs and copy them to ardes
  sh "garlic all"
  `garlic run > .garlic/report.txt`
  `scp -i ~/.ssh/ardes .garlic/report.txt ardes@ardes.com:~/subdomains/plugins/httpdocs/doc/#{plugin_name}_garlic_report.txt`
  `cd .garlic/*/vendor/plugins/#{plugin_name}; rake doc:all; scp -i ~/.ssh/ardes -r doc ardes@ardes.com:~/subdomains/plugins/httpdocs/doc/#{plugin_name}`
  puts "The build is GOOD"
end

spec = Gem::Specification.new do |s|
  s.name          = plugin_name
  s.version       = Pickle::Version::String
  s.summary       = "Easy model creation and reference in your cucumber features"
  s.description   = "Easy model creation and reference in your cucumber features"
  s.author        = "Ian White"
  s.email         = "ian.w.white@gmail.com"
  s.homepage      = "http://github.com/ianwhite/pickle/tree"
  s.has_rdoc      = true
  s.rdoc_options << "--title" << "Pickle" << "--line-numbers"
  s.test_files    = FileList["spec/**/*_spec.rb"]
  s.files         = FileList["lib/**/*.rb", "rails_generators/**/*.rb", "License.txt", "README.textile", "Todo.txt", "History.txt"]
end

Rake::GemPackageTask.new(spec) do |p|
  p.gem_spec = spec
  p.need_tar = true
  p.need_zip = true
end

desc "Generate pickle.gemspec file"
task :build do
  File.open('pickle.gemspec', 'w') {|f| f.write spec.to_ruby }
end