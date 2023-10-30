
UPDATE "people" SET "last_name" = INITCAP("last_name");


SELECT DATE_TRUNC('day', CURRENT_DATE-"born_ago"::INTERVAL)
FROM "people";

UPDATE "people"
SET "date_of_birth" = DATE_TRUNC('day', CURRENT_DATE-"born_ago"::INTERVAL);

DELETE FROM "people" WHERE "id" IS NULL;

--Solutions:
UPDATE "people" SET "last_name" =
  SUBSTR("last_name", 1, 1) ||
  LOWER(SUBSTR("last_name", 2));

-- Change the born_ago column to date_of_birth
ALTER TABLE "people" ADD column "date_of_birth" DATE;

UPDATE "people" SET "date_of_birth" =
  (CURRENT_TIMESTAMP - "born_ago"::INTERVAL)::DATE;

ALTER TABLE "people" DROP COLUMN "born_ago";

