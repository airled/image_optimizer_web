require 'fileutils'

task :prepare do
  system('mkdir ./public/downloads && touch ./public/downloads/.keep')
end

task :run do
  system('bundle exec thin -C config/thin.yml -R config.ru start')
end

task :clean do
  FileUtils.rm_rf('./public/downloads')
  Rake::Task["prepare"].execute
end

task :default => [:run]
