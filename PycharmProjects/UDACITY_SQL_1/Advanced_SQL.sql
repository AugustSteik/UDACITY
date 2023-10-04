--FULL OUTER JOINs, finding unmatched rows:
SELECT sr.name AS rep, a.name AS account
FROM sales_reps sr
FULL OUTER JOIN accounts a -- Can also be written as FULL JOIN
ON sr.id = a.sales_rep_id
WHERE sr.name IS NULL OR a.name IS NULL;
--Correct



-- Inequality JOINs

SELECT a.name AS account,
a.primary_poc,
sr.name AS rep
FROM sales_reps sr
LEFT JOIN accounts a
ON sr.id = a.sales_rep_id
AND a.primary_poc < sr.name

--Result: primary pocs name comes before reps name alphabetically



--Self JOINs
SELECT o1.id AS o1_id,
       o1.account_id AS o1_account_id,
       o1.occurred_at AS o1_occurred_at,
       o1.channel AS o1_channel,
       o2.id AS o2_id,
       o2.account_id AS o2_account_id,
       o2.occurred_at AS o2_occurred_at,
       o2.channel AS o2_channel
  FROM web_events o1
 LEFT JOIN web_events o2
   ON o1.account_id = o2.account_id
  AND o2.occurred_at > o1.occurred_at
  AND o2.occurred_at <= o1.occurred_at + INTERVAL '1 day'
ORDER BY o1.account_id, o1.occurred_at
--ORDER BY o1.account_id, o2.occurred_at


--UNIONs

SELECT *
FROM accounts a1
WHERE a1.name = 'Walmart'

UNION ALL

SELECT *
FROM accounts a2
WHERE a2.name = 'Disney'

--Is the same as:
SELECT *
FROM accounts
WHERE name = 'Walmart' OR name = 'Disney'


-- Checking that each name appears twice...

WITH tt1 AS (SELECT *
FROM accounts a1

UNION ALL

SELECT *
FROM accounts a2)

SELECT name, COUNT(*)
FROM tt1
GROUP BY name


-- Performance Tuning


-- Checking query logic by using limited dataset from subquery:
SELECT account_id,
       SUM(poster_qty) AS sum_poster_qty
FROM   (SELECT * FROM orders LIMIT 100) sub
WHERE  occurred_at >= '2016-01-01'
AND    occurred_at < '2016-07-01'
GROUP BY 1

--Using EXPLAIN to check the order of query operations:

EXPLAIN SELECT *
FROM web_events
WHERE occurred_at >='2016-01-01' AND occurred_at < '2016-02-01'

-- Gives an indication of the cost for certain operations.


--Joining subqueries to improve performance:

SELECT COALESCE(orders.date, web_events.date) AS date,
orders.active_sales_reps,
orders.orders,
web_events.web_visits
FROM(
        SELECT DATE_TRUNC('day', o.occurred_at) AS date,
        COUNT(DISTINCT a.sales_rep_id) AS active_sales_reps,
        COUNT(DISTINCT o.id) AS orders
        FROM accounts a
        JOIN orders o ON o.account_id = a.id
        GROUP BY 1) AS orders

FULL JOIN(
   SELECT DATE_TRUNC('day', we.occurred_at) AS date,
          COUNT(we.id) AS web_visits
   FROM   web_events we
   GROUP BY 1) AS web_events

ON orders.date = web_events.date
ORDER BY 1 DESC
