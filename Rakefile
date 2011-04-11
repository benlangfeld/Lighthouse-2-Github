require 'bundler'
Bundler::GemHelper.install_tasks

require 'cucumber'
require 'cucumber/rake/task'

Cucumber::Rake::Task.new(:features) do |t|
  t.cucumber_opts = "features --tags ~@wip --format pretty"
end
