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