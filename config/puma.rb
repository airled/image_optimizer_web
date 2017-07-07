threads 2,2
workers 2
daemonize false
preload_app!
stdout_redirect 'log/stdout', 'log/stderr', true

on_worker_boot do
end
