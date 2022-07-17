CREATE TABLE IF NOT EXISTS "transactions" (
	"transaction_id"	INTEGER,
	"address"	INTEGER NOT NULL,
	"deposit"	INTEGER,
	"withdraw"	INTEGER,
	PRIMARY KEY("transaction_id")
);
CREATE TABLE IF NOT EXISTS "apy" (
	"apy_id"	INTEGER,
	"timestamp"	INTEGER NOT NULL,
	"depositAPY"	NUMERIC NOT NULL,
	"variableBorrowAPY"	INTEGER,
	"stableBorrowAPY"	INTEGER,
	PRIMARY KEY("apy_id")
);
CREATE TABLE IF NOT EXISTS "events" (
	"event_id"	INTEGER,
	"address"	TEXT NOT NULL,
	"deposit"	INTEGER,
	"withdraw"	INTEGER,
	"blockNumber"	INTEGER NOT NULL,
	PRIMARY KEY("event_id")
);
