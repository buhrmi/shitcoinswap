# Token Distribution System

We are creating Newart Technology's automated token distribution system. We want to give back to the community, so we develop it as an open-source project.

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
RIK     | 0xECC3A47F5d0AC33db287D8f9DeBf03830853Cbb9 | Ethereum
SMS     | 0x39013f961c378f02c2b82a6e1d31e9812786fd9d | Ethereum
WHS     | 0x1f77db6ecbce65902d8e27888b40d344f45c337e | Ethereum


More to be added later
