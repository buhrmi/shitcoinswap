# Withdrawal System

We are implementing Newart Technology's withdrawal system to send tokens and coins to our costumers.

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
)
```

## Supported Currencies / Tokens

Symbol  | Contract Address | Platform
--------|------------------|-----------
ETH     | - | -
RIK     | 0xECC3A47F5d0AC33db287D8f9DeBf03830853Cbb9 | Ethereum ERC20
SMS     | 0x39013f961c378f02c2b82a6e1d31e9812786fd9d | Ethereum ERC20
WHS     | 0x1f77db6ecbce65902d8e27888b40d344f45c337e | Ethereum ERC20


More to be added later
