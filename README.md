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
DNA     | 0x268F39ebB4868a09FA654D4fFE1Ab024bc937Db2 | Ethereum ERC20
AKI     | 0x7ef8eeD38c44f5952b65D9C778EED74807FdD12c | Ethereum ERC20
DOR     | 0x15C23ea5939420e2301952f85Dd26176a72AeC89 | Ethereum ERC20
NAR     | 0x45038b67b1B55D7E3E142eec49Ce6bd2254c4e57 | Ethereum ERC20
MPD     | 0x88B2469f8464A3B83E02C99F7766Ed933d9AF570 | Ethereum ERC20
GTV     | 0x6932497EA8635E959b78b38cEe4B20eF04d77f79 | Ethereum ERC20




More to be added later
