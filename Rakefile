%w[rubygems rake rake/clean fileutils newgem rubigen rake/testtask].each { |f| require f }
require File.dirname(__FILE__) + '/lib/chrono_trigger'

## Generate all the Rake tasks
## Run 'rake -T' to see list of generated tasks (from gem root directory)
# $hoe = Hoe.new('chrono_trigger', ChronoTrigger::VERSION) do |p|
#   p.developer('Greg Fitzgerald', 'fitzgerald@healthcentral.com')
#   p.changes              = p.paragraphs_of("History.txt", 0..1).join("\n\n")
#   # p.post_install_message = 'PostInstall.txt' # TODO remove if post-install message not required
#   p.rubyforge_name       = "gregfitz23-chrono_trigger"
#   p.extra_deps         = [
# #    ['activesupport','>= 2.0.2'],
#   ]
#   p.extra_dev_deps = [
#     ['newgem', ">= #{::Newgem::VERSION}"],
#     ['thoughtbot_shoulda', ">= 2.0.6"]
#   ]
#   
#   p.clean_globs |= %w[**/.DS_Store tmp *.log]
#   path = (p.rubyforge_name == p.name) ? p.rubyforge_name : "\#{p.rubyforge_name}/\#{p.name}"
#   p.remote_rdoc_dir = File.join(path.gsub(/^#{p.rubyforge_name}\/?/,''), 'rdoc')
#   p.rsync_args = '-av --delete --ignore-errors'
# end
# 
# require 'newgem/tasks' # load /tasks/*.rake
# Dir['tasks/**/*.rake'].each { |t| load t }
# 
# # TODO - want other tests/tasks run by default? Add them to the list
# task :default => [:spec, :features]

Rake::TestTask.new do |t|
  t.libs << 'test'
end

desc "Run tests"
task :default => :test

begin
  require 'jeweler'
  Jeweler::Tasks.new do |s|
    s.name = "chrono_trigger"
    s.summary = "TODO"
    s.email = "greg_fitz@yahoo.com"
    s.homepage = ""
    s.description = "TODO"
    s.authors = ["Greg Fitzgerald"]
  end
rescue LoadError
  puts "Jeweler not available. Install it with: sudo gem install technicalpickles-jeweler -s http://gems.github.com"
end
