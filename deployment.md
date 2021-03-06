# Deployment notes

This is a rather boring [Ruby on Rails](https://rubyonrails.com) application and can be deployed as such.

## Dependencies

- imagemagic
- postgresql
- ruby
- redis

### PostgreSQL

This app depends on a `first` and `last` aggregate implementation being present. For Postgresql, please use either the SQL or C implementation here https://wiki.postgresql.org/wiki/First/last_(aggregate)

## Environment Vars

Adjust according to your env.

```
RAILS_ENV=production
DATABASE_URL=postgresql://localhost:5432/shitcoins?pool=5
SMTP_SERVER=smtp.mailgun.org
SMTP_PORT=465
SMTP_USER=user
SMTP_PASSWORD=123
```

## Background processes

These are defined in the `Procfile`. Platforms like [Heroku](https://heroku.com) or [Dokku](http://dokku.viewdocs.io/dokku/) will pick them up automatically.

- `bundle exec puma -t 5:5 -p ${PORT:-5000} -e production`: Webserver
- `bundle exec rake deposits`: Deposits scanner background process
- `bundle exec rake withdrawals`: Withdrawals sender background process
- `bundle exec rake caches`: Create caches/history of 24h volume

## Example Deployment with dokku

1. Install Dokku and required plugins

```
sudo dokku plugin:install https://github.com/dokku/dokku-postgres.git postgres
sudo dokku plugin:install https://github.com/dokku/dokku-redis.git redis
```

2. Create app and provision database and redis

```
dokku apps:create shitcoins

dokku postgres:create shitcoins
dokku postgres:link shitcoins shitcoins

dokku redis:create shitcoins
dokku redis:link shitcoins shitcoins
```

3. Provision persistent storage to app container

```
mkdir -p /var/lib/dokku/data/storage/shitcoins
chown -R 32767:32767 /var/lib/dokku/data/storage/shitcoins
dokku storage:mount shitcoins /var/lib/dokku/data/storage/shitcoins:/app/storage
```

4. Make nginx allow large file uploads uploads

```
mkdir /home/dokku/shitcoins/nginx.conf.d/
echo 'client_max_body_size 50m;' > /home/dokku/shitcoins/nginx.conf.d/upload.conf
chown dokku:dokku /home/dokku/shitcoins/nginx.conf.d/upload.conf
service nginx reload
```

5. Create keypair and provision it to container

```
openssl genrsa -out /var/lib/dokku/data/keys/wallet.priv.pem 2048
openssl rsa -in /var/lib/dokku/data/keys/wallet.priv.pem -outform PEM -pubout -out 
dokku storage:mount shitcoins /var/lib/dokku/data/keys/:/app/config/keys
```

6. Locally, push app to dokku

```
git remote add dokku dokku@server-ip:shitcoins
git push dokku master
```

7. Setup the database and start all processes

```
dokku run shitcoins bundle exec rails db:setup
dokku ps:scale web=1 deposits=1 withdrawals=1
```

