# Deployment notes

## Dependencies

- imagemagic
- postgresql
- ruby
- redis

## Environment Vars

RAILS_ENV=production
DATABASE_URL=postgresql://localhost:5432/newart-tech?pool=5
SMTP_SERVER=smtp.mailgun.org
SMTP_PORT=465
SMTP_USER=user
SMTP_PASSWORD=123

## Background processes

- `bundle exec puma -t 5:5 -p ${PORT:-5000} -e production`: Webserver
- `bundle exec rake deposits`: Deposits scanner background process
- `bundle exec rake withdrawals`: Withdrawals sender background process
- `bundle exec rake ticker`: Push price ticker info via websockets

## Example Deployment with dokku

1. Install Dokku and required plugins

```
sudo dokku plugin:install https://github.com/dokku/dokku-postgres.git postgres
sudo dokku plugin:install https://github.com/dokku/dokku-redis.git redis
```

2. Create app and provision database and redis

```
dokku apps:create newart-tech

dokku postgres:create newart-tech
dokku postgres:link newart-tech newart-tech

dokku redis:create newart-tech
dokku redis:link newart-tech newart-tech
```

3. Provision persistent storage to app container

```
mkdir -p /var/lib/dokku/data/storage/newart-tech
chown -R 32767:32767 /var/lib/dokku/data/storage/newart-tech
dokku storage:mount newart-tech /var/lib/dokku/data/storage/newart-tech:/app/storage
```

4. Make nginx allow large file uploads uploads

```
mkdir /home/dokku/newart-tech/nginx.conf.d/
echo 'client_max_body_size 50m;' > /home/dokku/newart-tech/nginx.conf.d/upload.conf
chown dokku:dokku /home/dokku/newart-tech/nginx.conf.d/upload.conf
service nginx reload
```

5. Create keypair and provision it to container

```
openssl genrsa -out /var/lib/dokku/data/keys/wallet.priv.pem 2048
openssl rsa -in /var/lib/dokku/data/keys/wallet.priv.pem -outform PEM -pubout -out 
dokku storage:mount newart-tech /var/lib/dokku/data/keys/:/app/config/keys
```

6. Locally, push app to dokku

```
git remote add myserver dokku@server-ip:newart-tech
git push myserver master
```

7. Setup the database and start all processes

```
dokku run newart-tech bundle exec rails db:setup
dokku ps:scale web=1 deposits=1 withdrawals=1
```

