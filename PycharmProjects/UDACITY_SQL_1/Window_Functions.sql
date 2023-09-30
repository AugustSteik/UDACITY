

--1
SELECT SUM(total_amt_usd) OVER
(PARTITION BY occurred_at ORDER BY occurred_at) AS running_total,
total_amt_usd
FROM orders
--Answer:
SELECT standard_amt_usd,
       SUM(standard_amt_usd) OVER (ORDER BY occurred_at) AS running_total
FROM orders


--2
SELECT SUM(total_amt_usd) OVER
(PARTITION BY DATE_TRUNC('year', occurred_at) ORDER BY occurred_at) AS running_total,
total_amt_usd, DATE_TRUNC('year', occurred_at)
FROM orders
--correct


--Ranking Functions:

--1
SELECT id,
account_id,
total,
DENSE_RANK() OVER(ORDER BY total DESC) AS total_rank
FROM orders;

--Just no.
SELECT id,
       account_id,
       total,
       RANK() OVER (PARTITION BY account_id ORDER BY total DESC) AS total_rank
FROM orders

-- Quiz - Comparing a row to a previous row:
SELECT occurred_at,
total_amt_usd,
LEAD(total_amt_usd) OVER (ORDER BY occurred_at) AS lead,
total_amt_usd - LEAD(total_amt_usd) OVER (ORDER BY occurred_at) AS lead_difference
FROM orders
--Seems correct, but reverse the subtraction.
SELECT occurred_at,
       total_amt_usd,
       LEAD(total_amt_usd) OVER (ORDER BY occurred_at) AS lead,
       LEAD(total_amt_usd) OVER (ORDER BY occurred_at) - total_amt_usd AS lead_difference
FROM (
SELECT occurred_at,
       SUM(total_amt_usd) AS total_amt_usd
  FROM orders
 GROUP BY 1
) sub


--Percentiles Quiz:

--1
SELECT account_id,
occurred_at,
standard_qty,
NTILE(4) OVER (PARTITION BY account_id ORDER BY standard_QTY DESC) AS standard_quartile
FROM orders
ORDER BY account_id DESC;

--2
SELECT account_id,
occurred_at,
gloss_qty,
NTILE(2) OVER (PARTITION BY account_id ORDER BY gloss_qty) AS gloss_half
FROM orders
ORDER BY account_id DESC;


--3
SELECT account_id,
occurred_at,
total_amt_usd,
NTILE(100) OVER (PARTITION BY account_id ORDER BY total_amt_usd) AS total_percentile
FROM orders
ORDER BY account_id DESC;

