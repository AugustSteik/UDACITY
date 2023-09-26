-- Ordering columns

SELECT *
FROM orders
WHERE account_id = 4251
ORDER BY occurred_at
LIMIT 100;


-- Selecting data within certain range

SELECT *
FROM orders
WHERE gloss_amt_usd >=1000
LIMIT 5;

SELECT *
FROM orders
WHERE total_amt_usd < 500
LIMIT 10;


-- Using AS operator, rounding d.ps

SELECT id, round((standard_amt_usd/total_amt_usd)*100, 1) AS std_percent, total_amt_usd
FROM orders
LIMIT 10;


-- LIKE operator

SELECT *
FROM accounts
WHERE name LIKE 'C%';


-- IN operator

SELECT name, primary_poc, sales_rep_id
FROM accounts WHERE name IN ('Walmart', 'Target', 'Nordstorm');
-- This selects the chosen data for the companies specified


-- similarly, using NOT operator

SELECT name, primary_poc, sales_rep_id
FROM accounts
WHERE name NOT IN('Walmart', 'Target', 'Nordstorm');

SELECT *
FROM web_events --table
WHERE channel NOT IN('organic', 'adwords') -- channel is column
ORDER BY id DESC;
-- Notice, we can have multiple arguments for IN operator

SELECT name
FROM accounts
WHERE name NOT LIKE 'C%';


--AND, BETWEEN operators

SELECT *
FROM orders
WHERE standard_qty > 100 AND poster_qty = 0 AND gloss_qty = 0; -- Notice we dont need two ==

-- multiple conditions
SELECT name
FROM accounts
WHERE name NOT LIKE 'C%'
AND name LIKE '%s%'; -- notice how the conditions are separate logical operations


SELECT occurred_at, gloss_qty
FROM orders
WHERE gloss_qty BETWEEN  24 AND 29 -- BETWEEN includes the start and end values
ORDER BY gloss_qty;



SELECT id, occurred_at
FROM web_events
WHERE channel IN ('organic', 'adwords')
AND occurred_at >= '2016-01-01' AND occurred_at < '2017-01-01'
ORDER BY occurred_at;

--or this

SELECT *
FROM web_events
WHERE channel IN ('organic', 'adwords') AND occurred_at BETWEEN '2016-01-01' AND '2017-01-01'
ORDER BY occurred_at DESC;

--You will notice that using BETWEEN is tricky for dates! While BETWEEN
--is generally inclusive of endpoints, it assumes the time is
--at 00:00:00 (i.e. midnight) for dates. This is the reason why we set the
--right-side endpoint of the period at '2017-01-01'.

-- OR operator
--Note, it works with all previous operators

SELECT *
FROM orders
WHERE (gloss_qty > 4000) OR (poster_qty > 4000);

SELECT *
FROM orders
WHERE (standard_qty = 0) AND (gloss_qty > 1000 OR poster_qty > 1000);

SELECT name
FROM accounts
WHERE (name LIKE 'C%' OR name LIKE 'W%')
AND (primary_poc LIKE '%ana%') AND (name NOT LIKE '%eana%');
-- Note, the arguments for LIKE operator are case-sensitive.