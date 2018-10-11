# Withdrawal System

A very simple and extendable platform to support all kinds of coins and tokens.

## Set up for local development

### Configure database

After cloning the repository, update the `.env` file with your local database connection settings.

### Load seed data

Run `rails db:seed` to import the initial seed data into the database.


### Generate hot wallet encryption keypair

```
[ -f config/hotwallet.priv.pem ] || openssl genrsa -out config/hotwallet.priv.pem 2048
[ -f config/hotwallet.pub.pem ] || openssl rsa -in config/hotwallet.priv.pem -outform PEM -pubout -out config/hotwallet.pub.pem
```


## Background Jobs

The `Procfile` defines several processes that have to run in the background.
