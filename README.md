# Withdrawal System

To send tokens to our customers, we implement an automated withdrawal system.

We start with a postgresql database on AWS that authorized people can read and write to.

## Schema

```
CREATE TABLE "withdrawals" (
  "id" integer NOT NULL PRIMARY KEY AUTOINCREMENT,
  "symbol" varchar,
  "receiver_address" varchar,
  "transaction_id" varchar,
  "submitted_at" datetime,
  "amount" decimal(50,20),
  "status" varchar,
  "error" varchar,
  "error_at" datetime
);
```
