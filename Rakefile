require 'fileutils'

task :prepare do
  system('mkdir ./public/downloads && touch ./public/downloads/.keep')
end

task :run do
  system('bundle exec foreman s')
end

task :clean_all do
  FileUtils.rm_rf('./public/downloads')
  Rake::Task["prepare"].execute
end

task :clean_old do
  Dir.foreach('public/downloads') do |entry|
    next if ['.', '..', '.keep'].include?(entry)
    entry_name = File.expand_path("../public/downloads/#{entry}", __FILE__)
    FileUtils.rm_rf(entry_name) if File.mtime(entry_name) < Time.now - (15 * 60)
  end
end

task :default => [:run]
