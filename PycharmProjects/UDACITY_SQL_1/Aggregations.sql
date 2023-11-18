--SUM

SELECT SUM(poster_qty) as poster_total
FROM orders;
--correct

SELECT SUM(standard_qty) as poster_total
FROM orders;
--correct

SELECT id, (gloss_amt_usd + standard_amt_usd) as gps
FROM orders;
--correct

SELECT round(SUM(standard_amt_usd/ standard_qty),2) AS std_div
FROM orders
WHERE standard_qty != 0;
--ish, answer:
SELECT SUM(standard_amt_usd)/SUM(standard_qty) AS standard_price_per_unit
FROM orders;
--Could also do:
SELECT round((SUM(standard_amt_usd/ standard_qty))/COUNT(*),2) AS std_div
FROM orders
WHERE standard_qty != 0;

--MIN, MAX, AVG

--MIN
SELECT MIN(occurred_at) as earliest_order
FROM  orders;
--is the same as:
SELECT occurred_at AS earliest_order
FROM orders
ORDER BY occurred_at
LIMIT 1;

--MAX
SELECT MAX(occurred_at) AS latest
FROM web_events;
--same as:
SELECT occurred_at AS latest
FROM web_events
ORDER BY occurred_at DESC
LIMIT 1;

--AVG
SELECT AVG(standard_amt_usd) AS std_av,
AVG(standard_qty) AS std_qty,
AVG(gloss_amt_usd) AS gloss_av,
AVG(gloss_qty) AS gloss_qty,
AVG(poster_amt_usd) AS poster_avg,
AVG(poster_qty) AS poster_qty

FROM orders; -- all good

--Answer:
SELECT *
FROM (SELECT total_amt_usd
   FROM orders
   ORDER BY total_amt_usd
   LIMIT 3457) AS Table1 -- 6912 orders so we'd need to average the 2 displayed
ORDER BY total_amt_usd DESC
LIMIT 2;
-- The above used a SUBQUERY

-- My attempt (error)
SELECT total_amt_usd
FROM (SELECT (COUNT(total_amt_usd)/2) AS location
      FROM orders) AS table1

      ORDER BY total_amt_usd DESC
      LIMIT 1;

-- v2:
SELECT (COUNT(total_amt_usd)/2) AS location
FROM orders AS table1;

SELECT orders.total_amt_usd
FROM orders
JOIN table1
ON orders.id = table1.location;


-- GROUP BY quiz

--1
SELECT accounts.name, orders.occurred_at AS time
FROM accounts
JOIN orders
ON accounts.id = orders.account_id
ORDER BY time ASC
LIMIT 1;
--correct

--2
SELECT accounts.name,
SUM(orders.total_amt_usd) AS total
FROM accounts
JOIN orders
ON accounts.id = orders.account_id
GROUP BY accounts.name
ORDER BY total ASC;
--correct

--3
SELECT web_events.occurred_at,
web_events.channel,
accounts.name

FROM accounts
JOIN web_events
ON accounts.id = web_events.account_id

ORDER BY web_events.occurred_at DESC
LIMIT 1;
--correct

--4
SELECT channel, COUNT(*)
FROM web_events
GROUP BY channel
ORDER BY count;
--correct

--5
SELECT accounts.primary_poc,
MIN(web_events.occurred_at) AS occurred_at
FROM accounts
JOIN web_events
ON accounts.id = web_events.account_id
GROUP BY accounts.primary_poc
ORDER BY occurred_at ASC
LIMIT 1;
--correct

--6
SELECT accounts.name,
MIN(orders.total_amt_usd) AS min_order_total_usd --Don't need to specify total_amt_usd if rom orders here
FROM accounts
JOIN orders
ON accounts.id = orders.account_id
GROUP BY accounts.name
ORDER BY min_order_total_usd;
--correct

--7
SELECT region.name, COUNT(*)
FROM region
JOIN sales_reps
ON region.id = sales_reps.region_id
GROUP BY region.name
ORDER BY count
--probably correct



--GROUP BY Part 2

--1
SELECT accounts.name AS name,
orders.standard_qty,
orders.gloss_qty,
orders.poster_qty
FROM accounts
JOIN orders
ON accounts.id = orders.account_id
GROUP BY name, orders.standard_qty, orders.gloss_qty, orders.poster_qty
--Incorrect
-- Here, we wanted the averages so we do:
SELECT accounts.name AS name,
AVG(orders.standard_qty) AS av_std,
AVG(orders.gloss_qty) AS av_gloss,
AVG(orders.poster_qty) AS av_poster
FROM accounts
JOIN orders
ON accounts.id = orders.account_id
GROUP BY name;


--2
SELECT accounts.name AS name,
round(AVG(orders.gloss_amt_usd), 1) AS av_gloss,
round(AVG(orders.poster_amt_usd), 1) AS av_poster,
round(AVG(orders.standard_amt_usd), 1) AS av_std
FROM accounts
JOIN orders
ON accounts.id = orders.account_id
GROUP BY name
ORDER BY name;
--correct

--3

SELECT sales_reps.name AS name,
web_events.channel AS channel,
COUNT(web_events.channel) AS channels_sum
FROM accounts
JOIN web_events
ON accounts.id = web_events.account_id

JOIN sales_reps
ON sales_reps.id = accounts.sales_rep_id

GROUP BY sales_reps.name, channel
ORDER BY channels_sum DESC;
--correct

--4

SELECT COUNT(web_events.channel) AS channel_no,
region.name AS name,
web_events.channel AS channel
FROM web_events
JOIN accounts
ON accounts.id = web_events.account_id

JOIN sales_reps
ON accounts.sales_rep_id = sales_reps.id

JOIN region
ON region.id = sales_reps.region_id


GROUP BY region.name, channel
ORDER BY channel_no DESC;
-- correct!



-- DISTINCT operator

--1

SELECT DISTINCT region.name AS region,
accounts.name AS acc_name
FROM sales_reps
JOIN accounts
ON sales_reps.id = accounts.sales_rep_id

JOIN region
ON region.id = sales_reps.region_id
--vs
SELECT region.name AS region,
accounts.name AS acc_name
FROM sales_reps
JOIN accounts
ON sales_reps.id = accounts.sales_rep_id

JOIN region
ON region.id = sales_reps.region_id
--No accounts associated with more than 1 region as both return 351 rows

--2
--Same again

SELECT DISTINCT sales_reps.name AS sales_rep,
accounts.name AS acc_name
FROM sales_reps
JOIN accounts
ON sales_reps.id = accounts.sales_rep_id

-- Incorrect:
SELECT s.id, s.name, COUNT(*) num_accounts
FROM accounts a
JOIN sales_reps s
ON s.id = a.sales_rep_id
GROUP BY s.id, s.name
ORDER BY num_accounts;
--shows the smallest no. of accounts worked is 3 per rep

--To check all of the sales reps are accounted for:
SELECT DISTINCT id, name
FROM sales_reps;
--50 results


--HAVING
--1
SELECT sales_reps.name AS name,
COUNT(*)num_accounts
FROM accounts
JOIN sales_reps
ON sales_reps.id = accounts.sales_rep_id
GROUP BY sales_reps.name
HAVING COUNT(*) > 5
ORDER BY num_accounts
--correct i think
--OR... subquery:
SELECT COUNT(*) num_reps_above5
FROM(SELECT s.id, s.name, COUNT(*) num_accounts
  FROM accounts a
  JOIN sales_reps s
  ON s.id = a.sales_rep_id
  GROUP BY s.id, s.name
  HAVING COUNT(*) > 5
  ORDER BY num_accounts) AS Table1;

--2
SELECT accounts.name,
COUNT(orders.account_id) AS no_orders -- same as COUNT(*)
FROM accounts
JOIN orders
on accounts.id = orders.account_id

GROUP BY accounts.name
HAVING COUNT(orders.account_id) > 20  -- same as COUNT(*)
ORDER BY no_orders;
--correct


--3
SELECT accounts.name,
COUNT(orders.account_id) AS orders
FROM accounts
JOIN orders
ON accounts.id = orders.account_id

GROUP BY accounts.name
HAVING COUNT(orders.account_id) > 20
ORDER BY orders DESC;
-- Correct
-- Leucadia National had the most at 71 orders

--4
SELECT accounts.name,
orders.total_amt_usd --SUM(orders.total_amt_usd) AS total_spent
FROM accounts
JOIN orders
ON accounts.id = orders.account_id

GROUP BY accounts.name, orders.total_amt_usd
HAVING orders.total_amt_usd > 30000 -- Correction: SUM(orders.total_amt_usd) > 30000
ORDER BY orders.total_amt_usd DESC; -- ORDER BY total_spent

--5
SELECT accounts.name,
orders.total_amt_usd
FROM accounts
JOIN orders
ON accounts.id = orders.account_id

GROUP BY accounts.name, orders.total_amt_usd
ORDER BY orders.total_amt_usd DESC
LIMIT 1;
--Incorrect:
SELECT a.id, a.name, SUM(o.total_amt_usd) total_spent
FROM accounts a
JOIN orders o
ON a.id = o.account_id
GROUP BY a.id, a.name
HAVING SUM(o.total_amt_usd) < 1000
ORDER BY total_spent;

--6
SELECT accounts.name,
orders.total_amt_usd -- SUM(order.total_amt_usd) total_spent
FROM accounts
JOIN orders
ON accounts.id = orders.account_id

GROUP BY accounts.name, orders.total_amt_usd
HAVING orders.total_amt_usd != 0
ORDER BY orders.total_amt_usd ASC --ORDER BY total_spent
LIMIT 1;
--Incorrect:
SELECT a.id, a.name, SUM(o.total_amt_usd) total_spent
FROM accounts a
JOIN orders o
ON a.id = o.account_id
GROUP BY a.id, a.name
ORDER BY total_spent DESC
LIMIT 1;

--8
SELECT accounts.name AS acc_name,
web_events.channel AS channel,
COUNT(*) AS no_of_channel_hits
FROM web_events
JOIN accounts
ON accounts.id = web_events.account_id

GROUP BY acc_name, channel
HAVING COUNT(*) > 6 AND channel IN ('facebook')
ORDER BY no_of_channel_hits;
--Maybe right

--9
SELECT accounts.name AS acc_name,
web_events.channel AS channel,
COUNT(*) AS no_of_channel_hits
FROM web_events
JOIN accounts
ON accounts.id = web_events.account_id

GROUP BY acc_name, channel
HAVING COUNT(*) > 6 AND channel IN ('facebook')
ORDER BY no_of_channel_hits DESC
LIMIT 1;
-- Gilead sciences used facebook most
--correct

--10
SELECT accounts.name AS acc_name,
web_events.channel AS channel,
COUNT(*) AS no_of_channel_hits
FROM web_events
JOIN accounts
ON accounts.id = web_events.account_id

GROUP BY channel, acc_name
ORDER BY no_of_channel_hits DESC
--direct was most used
--correct


--DATE FUNCTIONS

--1
SELECT DATE_TRUNC('year', occurred_at) AS year,
SUM(total_amt_usd)
FROM orders
GROUP BY 1
ORDER BY 2 DESC;
--correct

--2
SELECT DATE_PART('month', occurred_at) AS month,
SUM(total_amt_usd)
FROM orders
GROUP BY 1
ORDER BY 2 DESC;
--correct

--3
SELECT DATE_PART('year', occurred_at) AS year,
SUM(total)
FROM orders
GROUP BY 1
ORDER BY 2 DESC;
--Incorrect:
SELECT DATE_PART('year', occurred_at) ord_year,  COUNT(*) total_sales
FROM orders
GROUP BY 1
ORDER BY 2 DESC;
-- Remember, 1 row = 1 order (where not NULL)


--4
SELECT DATE_PART('month', occurred_at) AS month,
SUM(total) --Use COUNT(*)
FROM orders
--correction: WHERE DATE_PART('year', occurred_at) between 2014 AND 2016
GROUP BY 1
ORDER BY 2 DESC;

--5
SELECT DATE_TRUNC('month', o.occurred_at) AS time,
a.name AS name,
SUM(o.gloss_amt_usd) AS sum_gloss
FROM accounts a
JOIN orders o
ON a.id = o.account_id

GROUP BY name, time

HAVING (name = 'Walmart')
ORDER BY sum_gloss DESC;
-- May 2016 Walmart spent the most on gloss
-- correct


-- CASE statements
--e.g. to avoid a divide by 0 error:
SELECT account_id, CASE WHEN standard_qty = 0 OR standard_qty IS NULL THEN 0
                        ELSE standard_amt_usd/standard_qty END AS unit_price
FROM orders
LIMIT 10;


--1
SELECT account_id,
total_amt_usd,
CASE WHEN total_amt_usd >= 3000 THEN 'Large'
 ELSE 'Small'END AS l_or_s --could swap which condition is primary
FROM orders
-- correct

--2
SELECT account_id, total,
CASE
	WHEN total >= 2000 THEN 'al2k'
    WHEN total <2000 AND total > 1000 THEN 'between_1k2k'
    ELSE 'under1k' END AS level

FROM orders
ORDER BY total DESC;
--Incorrect:
SELECT CASE WHEN total >= 2000 THEN 'At Least 2000'
WHEN total >= 1000 AND total < 2000 THEN 'Between 1000 and 2000'
ELSE 'Less than 1000' END AS order_category,
COUNT(*) AS order_count
FROM orders
GROUP BY 1;

--3
SELECT a.name,
SUM(o.total_amt_usd) AS LV,
CASE
	WHEN 2 > 200000 THEN 'top'
    WHEN 2 <=200000 AND 2 >100000 THEN '2nd'
    ELSE 'lower' END AS level
FROM orders o
JOIN accounts a
ON a.id = o.account_id
GROUP BY a.name
ORDER BY lv DESC;
--correct

--4
SELECT account_id,
total_amt_usd, DATE_PART('year', occurred_at) AS year,
CASE WHEN total_amt_usd >= 3000 THEN 'Large'
 ELSE 'Small'END AS l_or_s
FROM orders
GROUP BY account_id, total_amt_usd, year
HAVING (DATE_PART('year', occurred_at)= 2016 OR DATE_PART('year', occurred_at) = 2017)
ORDER BY total_amt_usd DESC;
--Incorrect:
SELECT a.name, SUM(total_amt_usd) total_spent,
CASE WHEN SUM(total_amt_usd) > 200000 THEN 'top'
WHEN  SUM(total_amt_usd) > 100000 THEN 'middle'
ELSE 'low' END AS customer_level
FROM orders o
JOIN accounts a
ON o.account_id = a.id
WHERE occurred_at > '2015-12-31'
GROUP BY 1
ORDER BY 2 DESC;

--5
SELECT sr.name,
COUNT(*) AS no_of_orders,
CASE
	WHEN COUNT(*) > 200 THEN 'top'
    ELSE 'not' END AS performance
FROM orders o
JOIN accounts a
ON a.id = o.account_id

JOIN sales_reps sr
ON sr.id = a.sales_rep_id

GROUP BY sr.name
ORDER BY COUNT(*);
-- Correct

--6
SELECT sr.name,
SUM(o.total_amt_usd) AS usd,
COUNT(*) AS no_of_orders,
CASE
	WHEN COUNT(*) > 200 OR SUM(o.total_amt_usd) > 750000 THEN 'top'
    WHEN COUNT(*) <= 200 AND COUNT(*) >= 150 OR
    SUM(o.total_amt_usd) <=750000 AND SUM(o.total_amt_usd) >= 50000 THEN 'middle'
    ELSE 'low' END AS performance
FROM orders o
JOIN accounts a
ON a.id = o.account_id

JOIN sales_reps sr
ON sr.id = a.sales_rep_id

GROUP BY sr.name
ORDER BY usd DESC;


