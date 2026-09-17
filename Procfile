web: bundle exec itsi -C config/itsi.rb
worker: bundle exec rake solid_queue:start
ssr: bun ./public/vite-ssr/ssr.js
release: bin/rake db:migrate db:migrate:cache db:migrate:queue
# release: bin/rake db:reset FORCE=true DISABLE_DATABASE_ENVIRONMENT_CHECK=1