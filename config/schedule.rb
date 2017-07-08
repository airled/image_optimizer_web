env :PATH, ENV['PATH']

every 15.minutes do
  rake 'clean_old'
end
