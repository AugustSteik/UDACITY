
--1, normal query
SELECT channel, COUNT(*) AS sum, DATE_PART('dow', occurred_at) AS day
 FROM web_events
GROUP BY 1, 3
ORDER BY 1, 3;


--2, inline subquery
SELECT channel, sum, day
FROM
(SELECT channel, COUNT(*) AS sum, DATE_TRUNC('day', occurred_at) AS day
 FROM web_events
GROUP BY 1, 3) sub
GROUP BY channel, sum, day
ORDER BY sum DESC, channel;


--3
SELECT channel,
AVG(sum)
FROM

(SELECT channel, COUNT(*) AS sum, DATE_TRUNC('day', occurred_at) AS day
FROM web_events
GROUP BY 3,1) sub

GROUP BY channel
ORDER BY channel;

-- All correct





-- Nested subqueries:

SELECT *
FROM orders
WHERE DATE_TRUNC('month',occurred_at) =
	(SELECT DATE_TRUNC('month',MIN(occurred_at))
                                   FROM orders)

SELECT AVG(standard_qty) AS std, AVG(gloss_qty) AS gloss, AVG(poster_qty) AS poster, SUM(total_amt_usd)
FROM orders
WHERE DATE_TRUNC('month',occurred_at) =
	(SELECT DATE_TRUNC('month',MIN(occurred_at))
                                   FROM orders)
--All correct


CREATE OR REPLACE VIEW myview1
AS
SELECT COUNT(orders.id) AS sum,
orders.account_id AS acc_id,
accounts.name AS acc_name,
web_events.channel AS we_channel
 FROM orders
 JOIN accounts
 ON accounts.id = orders.account_id
 JOIN web_events
 ON accounts.id = web_events.account_id
 GROUP BY 2, 3, 4;

SELECT acc_name, we_channel
FROM myview1

--Closer....

CREATE OR REPLACE VIEW temp101
AS
SELECT COUNT(subq.*),
acc_name,
we_channel
FROM
	(SELECT accounts.name AS acc_name,
     orders.account_id,
     web_events.channel AS we_channel
     FROM accounts
     JOIN orders
     ON accounts.id = orders.account_id
     JOIN web_events
     ON accounts.id = web_events.account_id) subq

     GROUP BY acc_name, we_channel;

     SELECT acc_name,
     we_channel,
     MAX(count)
     FROM temp101
     GROUP BY 1, 2

     ORDER BY acc_name;



--Answer:
SELECT t3.id, t3.name, t3.channel, t3.ct
FROM (SELECT a.id, a.name, we.channel, COUNT(*) ct
     FROM accounts a
     JOIN web_events we
     On a.id = we.account_id
     GROUP BY a.id, a.name, we.channel) T3
JOIN (SELECT t1.id, t1.name, MAX(ct) max_chan
      FROM (SELECT a.id, a.name, we.channel, COUNT(*) ct
            FROM accounts a
            JOIN web_events we
            ON a.id = we.account_id
            GROUP BY a.id, a.name, we.channel) t1
      GROUP BY t1.id, t1.name) t2
ON t2.id = t3.id AND t2.max_chan = t3.ct
ORDER BY name;


--QUIZ

--1

SELECT MAX(orders.total_amt_usd) maximum,
regionname--,
--subq1.srname

FROM
	(SELECT region.name AS regionname,
     sales_reps.id AS srid,
     sales_reps.name AS srname,
     accounts.id AS acc_id
     FROM accounts
     JOIN sales_reps
     ON sales_reps.id = accounts.sales_rep_id
     JOIN region
     ON sales_reps.region_id = region.id) subq1

     JOIN orders
     ON subq1.acc_id = orders.account_id
     JOIN sales_reps
     ON subq1.srid = sales_reps.id


GROUP BY subq1.regionname--, subq1.srname
ORDER BY maximum DESC, regionname;


--2
SELECT SUM(orders.total_amt_usd) total_usd,
subq1.regionname,
COUNT(*) total_orders

FROM
	(SELECT region.name AS regionname,
     sales_reps.id AS srid,
     sales_reps.name AS srname,
     accounts.id AS acc_id
     FROM accounts
     JOIN sales_reps
     ON sales_reps.id = accounts.sales_rep_id
     JOIN region
     ON sales_reps.region_id = region.id) subq1

     JOIN orders
     ON subq1.acc_id = orders.account_id
     JOIN sales_reps
     ON subq1.srid = sales_reps.id


GROUP BY subq1.regionname
ORDER BY total_usd DESC
LIMIT 1;
     --2357 orders in Northeast

     --SOLUTION:
     SELECT r.name region_name, SUM(o.total_amt_usd) total_amt
FROM sales_reps s
JOIN accounts a
ON a.sales_rep_id = s.id
JOIN orders o
ON o.account_id = a.id
JOIN region r
ON r.id = s.region_id
GROUP BY r.name;

--3

SELECT accounts.name AS acc_name, SUM(orders.total)
FROM accounts
JOIN orders
ON accounts.id = orders.account_id
GROUP BY acc_name

HAVING SUM(orders.total) > (SELECT SUM(o.standard_qty) total
                      FROM accounts a
                      JOIN orders o
                            ON a.id = o.account_id
                      GROUP BY a.id
                      ORDER BY total DESC
                      LIMIT 1)

-- NOTE: GROUP BY comes before the HAVING CLAUSE in SQL.


--4
SELECT web_events.channel AS channel,
COUNT(*) no_of_events,
SUM(orders.total_amt_usd),
accounts.name
FROM accounts
JOIN web_events
ON accounts.id = web_events.account_id
JOIN orders
ON accounts.id = orders.account_id

GROUP BY accounts.name, channel

HAVING SUM(orders.total_amt_usd) >= (SELECT SUM(o.total_amt_usd) total
                      FROM accounts a
                      JOIN orders o
                            ON a.id = o.account_id
                      GROUP BY a.id
                      ORDER BY total DESC
                      LIMIT 1)

                      ORDER BY SUM(orders.total_amt_usd) DESC
                      LIMIT 1;






--5
CREATE OR REPLACE VIEW temp1
AS
	SELECT SUM(o.total_amt_usd) total
                      FROM accounts a
                      JOIN orders o
                            ON a.id = o.account_id
                      GROUP BY a.id
                      ORDER BY total DESC
                      LIMIT 10;

SELECT AVG(total)
FROM temp1;

--6
CREATE OR REPLACE VIEW temp1
AS
	SELECT SUM(o.total_amt_usd) total,
    a.id AS acc_id
                      FROM accounts a
                      JOIN orders o
                            ON a.id = o.account_id
                      GROUP BY acc_id
                      ORDER BY total DESC;


SELECT orders.account_id, orders.total_amt_usd

FROM orders
--ON orders.account_id = temp1.acc_id

--GROUP BY orders.account_id, orders.total_amt_usd

--HAVING orders.total_amt_usd > AVG(temp1.total)



--WITH queries example:
WITH table1 AS (
          SELECT *
          FROM web_events),

     table2 AS (
          SELECT *
          FROM accounts)


SELECT *
FROM table1
JOIN table2
ON table1.account_id = table2.id;

--Quiz - WITH

--1
--Provide the name of the sales_rep in each region with
--the largest amount of total_amt_usd sales.

WITH q1
    AS (
        SELECT sales_reps.name AS rep_name,
        sales_reps.id AS sr_id,
        region.name AS reg_name
        FROM region
        JOIN sales_reps
        ON region.id = sales_reps.region_id),
     q2
    AS(
        SELECT accounts.id AS acc_id,
        q1.rep_name AS rep,
        q1.reg_name AS reg
        FROM accounts
        JOIN q1
        ON q1.sr_id = accounts.sales_rep_id),

     q3
    AS(
        SELECT q2.reg AS reg,
        COUNT(orders) SUM
        FROM q2
        JOIN orders
        ON q2.acc_id = orders.account_id
        GROUP BY reg
    ),

    q4
    AS(
        SELECT q3.reg AS regionn,
        MAX(q3.sum)
        FROM q3
        )

        SELECT q2.rep, q4.*
        FROM q4
        JOIN q2
        ON q4.regionn = q2.reg;

-- ....... Could not crack it

-- Answer using subqueries:
SELECT t3.rep_name, t3.region_name, t3.total_amt
FROM(SELECT region_name, MAX(total_amt) total_amt
     FROM(SELECT s.name rep_name, r.name region_name, SUM(o.total_amt_usd) total_amt
             FROM sales_reps s
             JOIN accounts a
             ON a.sales_rep_id = s.id
             JOIN orders o
             ON o.account_id = a.id
             JOIN region r
             ON r.id = s.region_id
             GROUP BY 1, 2) t1
     GROUP BY 1) t2
JOIN (SELECT s.name rep_name, r.name region_name, SUM(o.total_amt_usd) total_amt
     FROM sales_reps s
     JOIN accounts a
     ON a.sales_rep_id = s.id
     JOIN orders o
     ON o.account_id = a.id
     JOIN region r
     ON r.id = s.region_id
     GROUP BY 1,2
     ORDER BY 3 DESC) t3
ON t3.region_name = t2.region_name AND t3.total_amt = t2.total_amt;



-- 2
--For the region with the largest sales total_amt_usd,
--how many total orders were placed?

WITH t1 AS(
    SELECT region.name AS region_name,
    accounts.id AS acc_id
    FROM region
    JOIN sales_reps
    ON region.id = sales_reps.region_id
    JOIN accounts
    ON sales_reps.id = accounts.sales_rep_id
    )

SELECT t1.region_name, COUNT(orders)
    FROM t1
    JOIN orders
    ON t1.acc_id = orders.account_id

GROUP BY t1.region_name
ORDER BY count desc
LIMIT 1;
--2357 Northeast


--3
--How many accounts had more total purchases
--than the account name which has bought the most
--standard_qty paper throughout their lifetime as a customer?

WITH t1 AS(
    SELECT a.id AS id,
  a.name AS acc_name,
  SUM(o.standard_qty) sum_qty
    FROM accounts a
    JOIN orders o
    ON a.id = o.account_id
    GROUP BY a.id, acc_name
    ORDER BY sum_qty DESC
)


SELECT a.name AS acc_name, SUM(o.total) AS sum_tot
FROM accounts a
JOIN orders o
ON a.id = o.account_id
JOIN t1
ON a.id = t1.id
GROUP BY a.name

HAVING SUM(o.total) > MAX(t1.sum_qty)


--4
--For the customer that spent the most (in total over their lifetime as
--a customer) total_amt_usd, how many web_events did they have for each channel?


WITH t1 AS(
    SELECT a.id AS temp_id,
    a.name,
    SUM(o.total_amt_usd)
    FROM accounts a
    JOIN orders o ON a.id = o.account_id
    GROUP BY a.id, a.name
    ORDER BY sum desc
    LIMIT 1
)


SELECT a.name AS namee, we.channel AS channel,
COUNT(we) AS no_events

FROM accounts a
JOIN web_events we
ON a.id = we.account_id
JOIN t1 ON a.id = t1.temp_id

GROUP BY namee, a.id, t1.temp_id, channel

HAVING a.id = t1.temp_id
ORDER BY namee

--5
--What is the lifetime average amount spent
--in terms of total_amt_usd for the top 10 total spending accounts?

WITH t1 AS
(
    SELECT a.name AS temp_name,
    a.id AS temp_id,
    SUM(o.total_amt_usd) AS temp_ltv
    FROM accounts a
    JOIN orders o on a.id = o.account_id
    GROUP BY temp_name, temp_id
    ORDER BY temp_ltv desc
    LIMIT 10
)

SELECT ROUND(AVG(t1.temp_ltv),3)
FROM t1;

--6
--What is the lifetime average amount spent in terms of total_amt_usd,
--including only the companies that spent more per order, on
--average, than the average of all orders.


WITH t1 AS
(
    SELECT a.name AS temp_name,
    a.id AS temp_id,
    AVG(o.total_amt_usd) AS temp_lt_av
    FROM accounts a
    JOIN orders o on a.id = o.account_id
    GROUP BY temp_id, temp_name
)

    SELECT
    AVG(o.total_amt_usd)
    FROM orders o
    JOIN accounts a ON a.id = o.account_id
    JOIN t1 ON a.id = t1.temp_id
GROUP BY t1.temp_lt_av
HAVING t1.temp_lt_av > AVG(o.total_amt_usd)
--Not there


