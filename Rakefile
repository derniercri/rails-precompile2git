require 'rubygems'
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "rails-precompile2git"
    gem.summary = %Q{Rails Assets Precompile To Git}
    gem.description = %Q{Daemon that watch a Git repo for new commit, pull changes, precompile assets and push back to Git}
    gem.license = "Apache 2"
    gem.email = "robin.komiwes@gmail.com"
    gem.homepage = "http://github.com/nectify/rails-precompile2git"
    gem.authors = ["Robin Komiwes"]
    gem.rubyforge_project = "rails-precompile2git"
  end
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: sudo gem install jeweler"
end

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/*_test.rb'
  test.verbose = true
end

begin
  require 'rcov/rcovtask'
  Rcov::RcovTask.new do |test|
    test.libs << 'test'
    test.pattern = 'test/**/*_test.rb'
    test.verbose = true
  end
rescue LoadError
  task :rcov do
    abort "RCov is not available. In order to run rcov, you must: sudo gem install spicycode-rcov"
  end
end

task :test => :check_dependencies

task :default => :test

