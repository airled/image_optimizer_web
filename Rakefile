task :prepare do
  Dir.mkdir('./tmp')
end

task :run do
  system('bundle exec thin -C config/thin.yml -R config.ru start')
end
