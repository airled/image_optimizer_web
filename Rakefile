task :prepare do
  Dir.mkdir('./public/downloads')
end

task :run do
  system('bundle exec thin -C config/thin.yml -R config.ru start')
end

task :default => [:run]
